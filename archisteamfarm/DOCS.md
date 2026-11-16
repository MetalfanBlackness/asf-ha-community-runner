# ArchiSteamFarm Home Assistant App

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

Run [ArchiSteamFarm](https://github.com/JustArchiNET/ArchiSteamFarm) as a
Home Assistant app (add-on). ASF logs into your Steam accounts and farms
trading cards automatically. This add-on exposes ASF's IPC web interface
(ASF-ui) on port 1242, both for manual management and for integrations
via the ASF API.

## Options

- **config_location** — where ASF's configuration directory lives:
  `config` (default) puts it in Home Assistant's configuration
  (`/config/archisteamfarm`), editable with File editor / Studio Code Server
  and included in Home Assistant backups; `addon` puts it in the add-on data
  directory (`/data/asf`); `share` puts it in
  `/share/archisteamfarm` (e.g. reachable via the Samba add-on). The directory
  is created on first run and never overwritten by the add-on; switching
  locations later does not move existing files.
- **ipc_password** — password protecting the IPC interface and API. Leave
  empty only if nobody else on your network can reach port 1242.
- **headless** — when enabled (default) ASF never waits for interactive
  console input; logins rely entirely on saved passwords and imported 2FA.
- **bot_username / bot_password / steam_parental_code** — convenience for the
  first start: if the config directory has no bot yet, one bot file is created
  from these options. You can manage unlimited additional bots from ASF-ui.
- **extra_args** — extra command-line arguments for ASF.

## Data

ASF's configuration (bot files, `ASF.json`, `IPC.config`, database, logs) is
stored in the directory selected with the `config_location` option and is
preserved across add-on updates and restarts. On first start this add-on
creates:

- `ASF.json` with `EulaAccepted: true`, stable update channel and `Headless`
  from the options above,
- `IPC.config` binding port 1242 on all interfaces (loopback plus RFC1918
  and Docker bridge ranges marked as known networks),
- one bot file when `bot_username` is set and no bot exists yet.

Any file you create or edit yourself in that directory is never overwritten.

> **Warning — no automatic migration.** Changing `config_location` after
> first start does **not** move or copy any files. ASF will simply wake up
> with an empty config directory there: no bots, no `ASF.json`, and the
> add-on will generate a fresh, password-less `IPC.config` (unless you
> recreate your own). Your passwords, bots and database stay in the old
> directory untouched. If you want to switch locations, copy the directory
> contents over first (excluding `logs`), then change the option.

> **Note — upgrading from add-on 1.0.0:** IPC now listens on ASF's default
> port 1242 instead of 12424. The add-on only rewrites `IPC.config` when you
> don't have your own, so if you installed 1.0.0, delete `IPC.config` in the
> ASF config directory once (or change the port in it to `http://0.0.0.0:1242`)
> and restart the add-on.

## Accessing the interface

- Direct: `http://<home-assistant-host>:1242`
- API: same host, e.g. `GET /api/ASF` with header
  `Authorization: Bearer <ipc_password>` (when a password is set).
- Swagger: `http://<home-assistant-host>:1242/swagger`

## 2FA note

Interactive login prompts do not work inside the add-on console. For accounts
with two-factor authentication, import the authenticator into ASF (ASF 2FA
plugin / `.maFile`) or configure the encryptions documented in the
[ASF wiki](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Two-factor-authentication).
