#!/usr/bin/env bash
set -euo pipefail

OPTIONS="/data/options.json"
# Official ArchiSteamFarm image ships the binary as /usr/bin/ArchiSteamFarm
# (symlink to /asf/ArchiSteamFarm.sh) with the .NET runtime bundled.
ASF_BIN="/usr/bin/ArchiSteamFarm"
# ASF config directory location, chosen with the add-on's "config_location"
# option (default: config -> /config/archisteamfarm):
#   config -> /config/archisteamfarm (HA config dir, in backups & File editor)
#   addon  -> /data/asf             (add-on internal, survives updates)
#   share  -> /share/archisteamfarm  (shared folder, e.g. Samba add-on)

get_opt() { jq -r "${1} // empty" "${OPTIONS}"; }

case "$(get_opt 'config_location' | tr -d '[:space:]')" in
    addon)  ASF_DATA="/data/asf" ;;
    share)  ASF_DATA="/share/archisteamfarm" ;;
    *)      ASF_DATA="/config/archisteamfarm" ;;
esac
echo "[addon] ASF config dir: ${ASF_DATA}"

mkdir -p "${ASF_DATA}/config"

# --- ASF.json: global ASF config -------------------------------------------
# Only written on first run; edits made via ASF-ui or by hand are preserved.
if [ ! -f "${ASF_DATA}/ASF.json" ]; then
    headless="$(get_opt 'headless')"
    if [ "${headless}" != "false" ]; then headless="true"; fi
    jq -n --argjson headless "${headless}" '{
        AutoUpdates: false,
        EulaAccepted: true,
        Headless: $headless,
        IPC: true,
        UpdateChannel: 0
    }' > "${ASF_DATA}/ASF.json"
    echo "[addon] Wrote default ASF.json to ${ASF_DATA}/ASF.json"
fi

# --- IPC.config: Kestrel binding for the exposed port ----------------------
# Regenerated on every start so option changes take effect. If the user placed
# their own IPC.config in the data directory, it wins.
if [ ! -f "${ASF_DATA}/IPC.config" ]; then
    ipc_password="$(get_opt 'ipc_password')"
    jq -n --arg pw "${ipc_password}" '{
        Kestrel: {
            Endpoints: {
                HTTP: { Url: "http://0.0.0.0:1242" }
            },
            KnownNetworks: [
                "10.0.0.0/8",
                "127.0.0.0/8",
                "172.16.0.0/12",
                "192.168.0.0/16"
            ]
        },
        IPCPassword: $pw
    }' > "${ASF_DATA}/IPC.config"
    echo "[addon] Wrote IPC.config (port 1242)"
fi

# --- First bot from add-on options ------------------------------------------
# Only creates a bot file when none exists yet. Additional bots can be added
# through ASF-ui or by dropping .json files into the config directory.
bot_username="$(get_opt 'bot_username')"
if [ -n "${bot_username}" ]; then
    existing_bots="$(find "${ASF_DATA}/config" -maxdepth 1 -name '*.json' -not -name 'ASF.json' | wc -l)"
    if [ "${existing_bots}" -eq 0 ]; then
        bot_password="$(get_opt 'bot_password')"
        parental_code="$(get_opt 'steam_parental_code')"
        bot_name="$(printf '%s' "${bot_username}" | tr -cd 'a-zA-Z0-9')"
        [ -n "${bot_name}" ] || bot_name="bot"
        jq -n \
            --arg login "${bot_username}" \
            --arg password "${bot_password}" \
            --arg parental "${parental_code}" \
            '{ Enabled: true, SteamLogin: $login, SteamPassword: $password }
             + (if $parental != "" then { SteamParentalCode: $parental } else {} end)' \
            > "${ASF_DATA}/config/${bot_name}.json"
        echo "[addon] Created bot file config/${bot_name}.json"
    fi
fi

# --- Run ASF -------------------------------------------------------------
ASF_ARGS=(--path "${ASF_DATA}" --process-required)
extra_args="$(get_opt 'extra_args')"
if [ -n "${extra_args}" ]; then
    # shellcheck disable=SC2206
    ASF_ARGS+=(${extra_args})
fi

echo "[addon] Starting ArchiSteamFarm..."
exec "${ASF_BIN}" "${ASF_ARGS[@]}"
