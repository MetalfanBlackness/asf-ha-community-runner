# ASF Home Assistant Community Runner

> **⚠️ IMPORTANT - Unofficial Third-Party App**
>
> **This is NOT the official ArchiSteamFarm app for Home Assistant.**
>
> - ❌ NOT developed by JustArchi (ASF author)
> - ❌ NOT officially supported by ArchiSteamFarm
> - ✅ Community developed and maintained
> - ✅ Use at your own risk
>
> **Official ArchiSteamFarm:** https://github.com/JustArchiNET/ArchiSteamFarm
>
> **Disclaimer**: This add-on is a third-party, unofficial project. It is not
> affiliated with, endorsed by, or supported by JustArchi or the
> ArchiSteamFarm project. ArchiSteamFarm® is a trademark of its respective
> owners. It merely packages the ArchiSteamFarm docker image as a Home
> Assistant app.
> Report issues to this repository only.

A [Home Assistant](https://www.home-assistant.io/) app (add-on) that runs
[ArchiSteamFarm](https://github.com/JustArchiNET/ArchiSteamFarm) (ASF) inside
Home Assistant — farm Steam trading cards on your home server, managed through
the built-in ASF web interface (ASF-ui) exposed on port 1242.

## Installation

1. In Home Assistant, go to **Settings -> Add-ons -> Add-on Store**.
2. Open the top-right menu (three dots) and choose **Repositories**.
3. Add the URL of this repository and click **Add**, then **Close**.
4. Find **ArchiSteamFarm** in the list and click **Install**.
5. Configure your options and **Start** the add-on.

Requirements: Home Assistant OS or Home Assistant Supervised on `amd64`,
`aarch64` or `armv7`.

## Configuration

| Option | Description |
| ------ | ----------- |
| `config_location` | Where ASF configs live: `config` (default, Home Assistant `/config/archisteamfarm`, easy to edit with File editor/Studio Code Server and always included in HA backups), `addon` (add-on data dir) or `share` (`/share/archisteamfarm`). **No automatic migration:** switching after first start leaves the old directory untouched and ASF starts with an empty config there — copy the directory contents first if you want to move. |
| `ipc_password` | Password for the ASF IPC interface/API. Strongly recommended when port 1242 is reachable from your LAN. |
| `headless` | Run ASF in headless mode (no interactive console prompts). Default: `true`. |
| `bot_username` | Optional. Steam account name used to create the first bot config on first start. |
| `bot_password` | Optional. Password for the bot above. |
| `steam_parental_code` | Optional. Steam Parental PIN for the bot above. |
| `extra_args` | Optional. Extra command-line arguments passed to ASF (e.g. `--no-restart`). |

## Usage

- Open `http://<hostassistant-ip>:1242` for ASF-ui.
- The same port also serves the ASF API (`/api`, swagger under `/swagger`)
  for automation against Home Assistant.
- ASF configs live in the directory chosen with `config_location`. On first
  start the add-on creates a default `ASF.json` and an `IPC.config` (if you
  didn't provide your own), plus one bot file from the options above if you
  filled them in. All further bots and settings can be managed from ASF-ui.

## Two-factor authentication

- Accounts with the **Steam Mobile Authenticator**: import your authenticator
  into ASF (ASF 2FA, see the [ASF wiki](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Two-factor-authentication))
  so logins work unattended.
- Accounts with **email SteamGuard**: each new login triggers an email code.
  The default `Headless` mode cannot answer those prompts, so import a 2FA
  file or temporarily disable email SteamGuard for the bot.

## Updating ASF

The add-on is built on top of the official ASF docker image
(`justarchi/archisteamfarm`, see `archisteamfarm/build.yaml`). Bump the image
tag there to update ASF, then bump `version` in `archisteamfarm/config.yml`,
so Supervisor rebuilds the add-on.

## Base image

`run.sh` runs on the official upstream image, so runtime behavior (bundled
.NET runtime, official plugins, ASF-ui) matches plain docker ASF exactly.

## License

The add-on glue code is provided as-is under MIT. ArchiSteamFarm itself is
Apache-2.0, (c) JustArchi and contributors.
