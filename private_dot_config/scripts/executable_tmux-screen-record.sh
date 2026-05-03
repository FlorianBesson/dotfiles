#!/usr/bin/env bash

set -uo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/tmux-screen-record-${USER}"
pid_file="${state_dir}/ffmpeg.pid"
path_file="${state_dir}/output.path"
output_dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/screen-recordings"
latest_file="${output_dir}/latest.txt"
max_upload_size=$((1024 * 1024 * 1024))

tmux_message() {
  if command -v tmux >/dev/null 2>&1 && [ -n "${TMUX:-}" ]; then
    tmux display-message "$1"
  fi
}

message() {
  tmux_message "$1"
  printf '%s\n' "$1"
}

is_recording() {
  [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" >/dev/null 2>&1
}

screen_geometry() {
  local line geometry size offset_x offset_y

  if command -v xrandr >/dev/null 2>&1; then
    line="$(xrandr --query | awk '/ connected primary / { print; exit }')"
    if [ -z "$line" ]; then
      line="$(xrandr --query | awk '/ connected / && match($0, /[0-9]+x[0-9]+[+][0-9]+[+][0-9]+/) { print; exit }')"
    fi

    geometry="$(printf '%s\n' "$line" | sed -nE 's/.* ([0-9]+x[0-9]+)\+([0-9]+)\+([0-9]+).*/\1 \2 \3/p')"
    if [ -n "$geometry" ]; then
      read -r size offset_x offset_y <<< "$geometry"
      printf '%s +%s,%s\n' "$size" "$offset_x" "$offset_y"
      return 0
    fi
  fi

  if command -v xdpyinfo >/dev/null 2>&1; then
    size="$(xdpyinfo | awk '/dimensions:/ { print $2; exit }')"
    if [ -n "$size" ]; then
      printf '%s +0,0\n' "$size"
      return 0
    fi
  fi

  return 1
}

system_audio_source() {
  local sink source

  if ! command -v pactl >/dev/null 2>&1; then
    return 1
  fi

  sink="$(pactl get-default-sink 2>/dev/null || true)"
  if [ -z "$sink" ]; then
    return 1
  fi

  source="${sink}.monitor"
  if pactl list short sources | awk '{ print $2 }' | grep -Fxq "$source"; then
    printf '%s\n' "$source"
    return 0
  fi

  return 1
}

mic_audio_source() {
  local source

  if ! command -v pactl >/dev/null 2>&1; then
    return 1
  fi

  source="$(pactl get-default-source 2>/dev/null || true)"
  if [ -z "$source" ]; then
    return 1
  fi

  case "$source" in
    *.monitor)
      return 1
      ;;
  esac

  if pactl list short sources | awk '{ print $2 }' | grep -Fxq "$source"; then
    printf '%s\n' "$source"
    return 0
  fi

  return 1
}

write_latest() {
  local output url

  output="$1"
  url="${2:-}"

  mkdir -p "$output_dir"
  {
    printf 'file=%s\n' "$output"
    if [ -n "$url" ]; then
      printf 'url=%s\n' "$url"
    fi
  } > "$latest_file"
}

copy_to_clipboard() {
  local text

  text="$1"

  if command -v tmux >/dev/null 2>&1; then
    tmux set-buffer -w -- "$text" >/dev/null 2>&1 || tmux set-buffer -- "$text" >/dev/null 2>&1 || true
  fi

  if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    printf '%s' "$text" | wl-copy
    return $?
  fi

  if command -v xclip >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    nohup sh -c 'printf %s "$1" | xclip -selection clipboard' sh "$text" >/dev/null 2>&1 &
    return 0
  fi

  if command -v xsel >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    nohup sh -c 'printf %s "$1" | xsel --clipboard --input' sh "$text" >/dev/null 2>&1 &
    return 0
  fi

  command -v tmux >/dev/null 2>&1
}

upload_recording() {
  local output size url

  output="$1"

  if [ -z "$output" ] || [ ! -f "$output" ]; then
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    message "Lien non genere: curl introuvable"
    return 1
  fi

  size="$(stat -c '%s' "$output" 2>/dev/null || printf 0)"
  if [ "$size" -gt "$max_upload_size" ]; then
    message "Lien non genere: fichier trop gros pour Litterbox (>1 Gio)"
    return 1
  fi

  message "Upload en cours: $output"
  url="$(curl -fsS -F reqtype=fileupload -F time=72h -F "fileToUpload=@${output}" https://litterbox.catbox.moe/resources/internals/api.php 2>/dev/null | tr -d '\r\n')"

  if ! printf '%s\n' "$url" | grep -Eq '^https://litter\.catbox\.moe/[A-Za-z0-9._/-]+$'; then
    message "Upload echoue"
    return 1
  fi

  if copy_to_clipboard "$url"; then
    message "Lien copie: $url"
  else
    message "Lien genere: $url"
  fi

  write_latest "$output" "$url"
}

stop_recording() {
  local pid output

  pid="$(cat "$pid_file")"
  output="$(cat "$path_file" 2>/dev/null || true)"

  kill -INT "$pid" >/dev/null 2>&1 || true

  for _ in $(seq 1 50); do
    if ! kill -0 "$pid" >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done

  rm -f "$pid_file" "$path_file"

  if [ -n "$output" ]; then
    message "Enregistrement arrete: $output"
    write_latest "$output"
    upload_recording "$output"
  else
    message "Enregistrement arrete"
  fi
}

start_recording() {
  local display geometry size offset timestamp output ffmpeg_log pid audio_message
  local system_audio mic_audio audio_count audio_filter
  local ffmpeg_args

  if ! command -v ffmpeg >/dev/null 2>&1; then
    message "ffmpeg introuvable"
    exit 1
  fi

  if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] && [ -z "${DISPLAY:-}" ]; then
    message "Session Wayland sans DISPLAY: ffmpeg x11grab ne peut pas capturer l'ecran"
    exit 1
  fi

  display="${DISPLAY:-:0}"

  if ! geometry="$(screen_geometry)"; then
    message "Impossible de detecter la taille de l'ecran"
    exit 1
  fi

  read -r size offset <<< "$geometry"
  timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"
  mkdir -p "$state_dir" "$output_dir"
  output="${output_dir}/screen-${timestamp}.mp4"
  ffmpeg_log="${state_dir}/ffmpeg.log"

  ffmpeg_args=(
    -hide_banner \
    -loglevel warning \
    -thread_queue_size 1024 \
    -f x11grab \
    -framerate 30 \
    -video_size "$size" \
    -i "${display}${offset}" \
  )

  audio_count=0
  audio_filter=""

  if system_audio="$(system_audio_source)"; then
    audio_count=$((audio_count + 1))
    ffmpeg_args+=(
      -thread_queue_size 1024 \
      -f pulse \
      -i "$system_audio" \
    )
    audio_filter="[1:a]aresample=async=1:first_pts=0,pan=stereo|c0=c0|c1=c1[sysa]"
    audio_message="avec son systeme"
  fi

  if mic_audio="$(mic_audio_source)"; then
    audio_count=$((audio_count + 1))
    ffmpeg_args+=(
      -thread_queue_size 1024 \
      -f pulse \
      -i "$mic_audio" \
    )
    if [ "$audio_count" -eq 1 ]; then
      audio_filter="[1:a]aresample=async=1:first_pts=0,pan=stereo|c0=c0|c1=c1[mica]"
      audio_message="avec micro"
    else
      audio_filter="${audio_filter};[2:a]aresample=async=1:first_pts=0,pan=stereo|c0=c0|c1=c1[mica];[sysa][mica]amix=inputs=2:duration=longest:normalize=0[aout]"
      audio_message="avec son systeme + micro"
    fi
  fi

  if [ "$audio_count" -eq 1 ]; then
    if [ -n "$system_audio" ]; then
      audio_filter="${audio_filter};[sysa]anull[aout]"
    else
      audio_filter="${audio_filter};[mica]anull[aout]"
    fi
  fi

  if [ "$audio_count" -gt 0 ]; then
    ffmpeg_args+=(
      -filter_complex "$audio_filter" \
      -map 0:v:0 \
      -map "[aout]" \
      -c:a aac \
      -b:a 192k \
    )
  else
    ffmpeg_args+=(
      -map 0:v:0 \
      -an \
    )
    audio_message="sans son"
  fi

  ffmpeg_args+=(
    -c:v libx264 \
    -preset veryfast \
    -crf 23 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    "$output"
  )

  ffmpeg "${ffmpeg_args[@]}" >"$ffmpeg_log" 2>&1 &

  pid="$!"
  printf '%s\n' "$pid" > "$pid_file"
  printf '%s\n' "$output" > "$path_file"

  sleep 0.3
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    rm -f "$pid_file" "$path_file"
    message "ffmpeg a echoue: $(tail -n 1 "$ffmpeg_log")"
    exit 1
  fi

  message "Enregistrement demarre ($audio_message): $output"
}

if is_recording; then
  stop_recording
else
  rm -f "$pid_file" "$path_file"
  start_recording
fi
