# Profile Exporter

World of Warcraft addon for collecting addon profile strings into one `WOW_PROFILE_VAULT` bundle.

This repository is the in-game companion tool for the All The Profiles site.

## Repository Role

This is separate from:

```text
EZH0/All_The_Profiles
  public GitHub Pages site

EZH0/All_The_Profiles_Admin
  private local admin tool
```

This addon produces bundle strings that the private admin tool can import.

## Current Implementation

Implemented:

- TOC: `ProfileExporter.toc`
- Slash commands:
  - `/pex`
  - `/profileexporter`
- Basic in-game frame
- Manual entry form
- Entry list
- Bundle generation
- Output box auto-select for user `Ctrl+C`
- Serializer for `WOW_PROFILE_VAULT` blocks
- Adapter registry scaffold under `Adapters/Core.lua`
- SavedVariables: `ProfileExporterDB`

Not yet implemented:

- Real automatic export adapters
- In-game QA in WoW client
- ScrollFrame polish for very large strings
- Editing/deleting individual queued entries
- Importing existing SavedVariables

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

## Next Recommended Work

1. Install the addon folder into WoW:

```text
World of Warcraft/_retail_/Interface/AddOns/ProfileExporter/
```

2. Launch WoW and test:

```text
/pex
```

3. Verify:

- frame opens
- manual entry can be added
- `Generate` produces valid `WOW_PROFILE_VAULT` text
- output text can be selected and copied with `Ctrl+C`

4. Improve large text usability:

- replace raw multiline edit boxes with scrollable edit boxes
- add entry delete/edit buttons
- add "copy instructions" text in UI

5. Add adapters one by one:

- ElvUI first
- WindTools
- DBM
- Plater
- Cell
- EditMode

## Adapter Contract

Each adapter should eventually produce entries like:

```lua
{
  id = "elvui-main",
  addon = "ElvUI",
  name = "Main UI",
  group = "Elv UI",
  format = "elvui",
  tags = "ui, required",
  order = "10",
  instructions = "ElvUI 프로필 가져오기 창에 붙여넣습니다.",
  source = "official-export",
  body = "profile string"
}
```
