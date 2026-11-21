# Dux Translate repository instructions

## Project scope

Dux Translate is a plugin (id `duxTranslate`) for Dux Shell 2.x with a top bar widget and a launcher surface. It translates typed text through Google Cloud Translation (Basic v2), DeepL or OpenRouter. It is pure QML/JavaScript: no Python, no curl, no runtime dependencies beyond the shell itself. Keep it a basic translator; history, TTS, clipboard watching and similar features are out of scope unless the user asks.

Version 2.0 dropped DankMaterialShell 1.x and renamed the plugin from `dmsTranslate`. The last 1.x commit is `a6bb3b9`.

Read the relevant file and test before changing behavior. Prefer the smallest change that keeps the setting keys, the plugin id and the install paths working.

## Repository map

- `src/` is the plugin directory that `install.sh` copies or symlinks into the shell's `plugins/duxTranslate`.
  - `plugin.json` is the manifest (composite: `components.widget` and `components.launcher`).
  - `Widget.qml` holds the bar icon, the popout UI, the right click on the pill and the `XMLHttpRequest` call with its 15 s timeout.
  - `Launcher.qml` is the launcher surface (`tr <text>`, Enter translates and copies). The launcher host reads items synchronously and ignores `itemsChanged`, so the translation runs in `executeItem`.
  - `Settings.qml` holds the provider choice, keys, model and prompt. `KeySetting.qml` is a masked variant of the shell's `StringSetting`.
  - `Providers.js` (`.pragma library`) holds every provider-specific detail: language list, defaults, `buildRequest()`, `parseResponse()` and `migrateLegacy()`. It has no QML dependencies.
  - `translations/ru.json` holds the Russian UI strings. Every UI string goes through `I18n.trFor("duxTranslate", ...)`, and `ru.json` has one entry per string.
- `tests/providers.test.mjs` loads `Providers.js` in a `node:vm` context and covers request shape, response parsing and the id migration.
- `assets/logo.svg` is the logo, used in the READMEs.
- `install.sh` / `uninstall.sh` are POSIX `sh`.
- `README.md` and `README_RU.md` are full mirrors in English and Russian.

## Development commands

```bash
node --test tests/*.test.mjs
shellcheck install.sh uninstall.sh
./install.sh --link
dms ipc call plugins reload duxTranslate
```

QML has no automated test. After QML changes, reload the plugin, open the popout, and check the shell log for errors.

## Rules the code does not show

- Compatibility: use the `D*` widgets (`DTextField`, `DButton`, ...) from `qs.DCommon.Widgets` and `Theme`, `I18n` from `qs.Common`. The `Dank*` names in `qs.Widgets` are deprecated shims that log an error naming this plugin. The reference is the shell's `PLUGINS/` directory (`README.md`, `plugin-schema.json`): the running shell is extracted under `/run/user/$UID/dms-shell/*/`, the source is `duxlabs-dev/dux-shell`.
- Setting keys (`provider`, `googleApiKey`, `deeplApiKey`, `openrouterApiKey`, `openrouterModel`, `openrouterReasoning`, `openrouterPrompt`) and state keys (`source`, `target`, `recentPairs`) are stored user data. Do not rename them. They are stored per plugin id; `migrateLegacy()` copies them from the pre-2.0 id `dmsTranslate` and never overwrites. Do not change the plugin id again without a migration.
- API keys go only into request headers: never into URLs, process arguments, logs or error messages. Tests assert this.
- Provider logic lives in `Providers.js`, so it stays testable. `Widget.qml` and `Launcher.qml` only send what `buildRequest()` returns.
- DeepL accepts only the `Authorization: DeepL-Auth-Key` header (legacy auth was removed in 2026). Google v3 needs OAuth, so v2 stays.
- Clipboard copy goes through `dms cl copy`, text paste through `dms cl paste`. Image paste reads the clipboard with `wl-paste` (`dms cl` has no image read); images go only to OpenRouter as a `data:` URL part.
- The default prompt stays one line: the settings field is single-line.
- Do not add dependencies. Tests use only Node's built-in `node:test`.

## Documentation and delivery

Keep `README.md` and `README_RU.md` in sync with each other and with the code (settings, defaults, paths, commands). Do not commit, tag, push or publish unless the user explicitly asks.
