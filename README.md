# Profile Exporter

World of Warcraft addon for collecting addon profile strings into one `WOW_PROFILE_VAULT` bundle.

This repository is the in-game companion tool for the All The Profiles site.

## First Milestone

The first version focuses on a safe manual workflow:

1. Open the addon with `/pex` or `/profileexporter`.
2. Enter addon/profile metadata.
3. Paste an existing profile string.
4. Add it to the bundle.
5. Generate one combined export string.
6. Press `Ctrl+C` from the selected output box.
7. Paste the bundle into the private admin site.

## Bundle Format

```text
===== WOW_PROFILE_VAULT BEGIN =====
id: elvui-main
addon: ElvUI
name: Main UI
group: Elv UI
format: elvui
tags: ui, required
order: 10
instructions: ElvUI 프로필 가져오기 창에 붙여넣습니다.
source: manual
===== CONTENT =====
profile string here
===== WOW_PROFILE_VAULT END =====
```

## Future Direction

Automatic adapters can be added under `Adapters/`.

Planned adapters:

- ElvUI
- WindTools
- DBM
- Plater
- Cell
- EditMode
- Sensei Resource Bar
- Cooldown Manager Centered

Each adapter should return the same normalized entry shape used by the manual UI.
