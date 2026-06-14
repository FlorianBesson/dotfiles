#!/usr/bin/env bash

set -euo pipefail

have_command() {
    command -v "$1" >/dev/null 2>&1
}

port_rows() {
    if have_command lsof; then
        lsof -nP -iTCP -sTCP:LISTEN -iUDP 2>/dev/null | awk '
            NR == 1 { next }
            {
                command = $1
                pid = $2
                user = $3
                proto = $8
                endpoint = $9

                port = endpoint
                sub(/^.*\]:/, "", port)
                sub(/^.*:/, "", port)

                bind = endpoint
                sub(/:[^:]*$/, "", bind)

                if (port ~ /^[0-9]+$/) {
                    key = port "\t" proto "\t" pid "\t" user "\t" bind "\t" command
                    if (!seen[key]++) {
                        print key
                    }
                }
            }
        ' | sort -n -k1,1 -k3,3
        return
    fi

    ss -lntupH 2>/dev/null | awk '
        {
            proto = toupper($1)
            endpoint = $5
            pid = "-"
            command = "-"
            user = "-"

            if ($0 ~ /pid=[0-9]+/) {
                pid_line = $0
                sub(/^.*pid=/, "", pid_line)
                sub(/,.*/, "", pid_line)
                pid = pid_line
            }

            if ($0 ~ /users:\(\("[^"]+"/) {
                command_line = $0
                sub(/^.*users:\(\("/, "", command_line)
                sub(/".*/, "", command_line)
                command = command_line
            }

            port = endpoint
            sub(/^.*\]:/, "", port)
            sub(/^.*:/, "", port)

            bind = endpoint
            sub(/:[^:]*$/, "", bind)

            if (port ~ /^[0-9]+$/) {
                key = port "\t" proto "\t" pid "\t" user "\t" bind "\t" command
                if (!seen[key]++) {
                    print key
                }
            }
        }
    ' | sort -n -k1,1 -k3,3
}

kill_selected() {
    local signal="$1"
    local rows="$2"
    local killed=0
    local pid port command

    while IFS=$'\t' read -r port _ pid _ _ command; do
        [[ -z "${pid}" || "${pid}" == "-" ]] && continue

        if kill "-${signal}" "${pid}" 2>/dev/null; then
            printf "Sent SIG%s to PID %s (%s) on port %s\n" "${signal}" "${pid}" "${command}" "${port}"
            killed=1
        else
            printf "Failed to kill PID %s on port %s. Try sudo if it belongs to root.\n" "${pid}" "${port}"
        fi
    done <<< "${rows}"

    if [[ "${killed}" -eq 0 ]]; then
        printf "No killable PID selected.\n"
    fi

    printf "\nPress Enter to refresh..."
    read -r _
}

if ! have_command fzf; then
    echo "Error: fzf is required for the ports dashboard."
    echo "Fallback: lsof -nP -iTCP -sTCP:LISTEN -iUDP"
    read -r -p "Press Enter to close..."
    exit 1
fi

if ! have_command lsof && ! have_command ss; then
    echo "Error: lsof or ss is required."
    read -r -p "Press Enter to close..."
    exit 1
fi

while true; do
    rows="$(port_rows)"

    if [[ -z "${rows}" ]]; then
        clear
        echo "No occupied ports found."
        echo
        read -r -p "Press Enter to refresh, Ctrl-C to close..."
        continue
    fi

    selected="$(
        printf '%s\n' "${rows}" |
            fzf --multi \
                --delimiter=$'\t' \
                --with-nth=1,2,3,4,5,6 \
                --header=$'PORT\tPROTO\tPID\tUSER\tBIND\tPROCESS\nEnter: SIGTERM  |  Ctrl-K: SIGKILL  |  Ctrl-R: refresh  |  Esc: close' \
                --preview='ps -fp {3} 2>/dev/null || true' \
                --preview-window='down,4,border-top' \
                --expect=ctrl-k,ctrl-r
    )"
    fzf_status="$?"

    if [[ "${fzf_status}" -ne 0 ]]; then
        exit 0
    fi

    key="$(printf '%s\n' "${selected}" | sed -n '1p')"
    picked="$(printf '%s\n' "${selected}" | sed '1d')"

    if [[ "${key}" != "ctrl-k" && "${key}" != "ctrl-r" ]]; then
        picked="${selected}"
        key="enter"
    fi

    case "${key}" in
        ctrl-r)
            continue
            ;;
        ctrl-k)
            [[ -n "${picked}" ]] && kill_selected "KILL" "${picked}"
            ;;
        enter)
            [[ -n "${picked}" ]] && kill_selected "TERM" "${picked}"
            ;;
    esac
done
