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
- Separate scrollable bundle output window
- Minimap button with a simple orange `PE` icon
- Serializer for `WOW_PROFILE_VAULT` blocks
- Adapter registry scaffold under `Adapters/Core.lua`
- Auto Collect button that runs available adapters and adds/updates bundle entries
- Adapter checkboxes saved in `ProfileExporterDB.adapters`
- Details mode checkbox:
  - Off: export only the current Details profile
  - On: export every profile returned by `Details:GetProfileList()`
- First-pass automatic adapters:
  - ElvUI
  - ElvUI WindTools
  - Details!
  - Plater
  - Cell
  - Cooldown Manager Centered
  - DBM
  - Sensei Resource Bar
  - XIV Databar
  - WoW Edit Mode
- SavedVariables: `ProfileExporterDB`

Not yet implemented:

- In-game QA in WoW client
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

Automatic adapters live under `Adapters/`.

Implemented adapters should still be verified in-game because several export APIs only exist after the target addon has fully loaded.

Remaining planned adapters:

- None for the current profile bundle target

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
- adapter checkboxes can be enabled/disabled
- `Generate` produces valid `WOW_PROFILE_VAULT` text
- output text opens in a scrollable window and can be selected/copied with `Ctrl+C`

## Details Profile Handling

Details can store multiple named profiles. Exporting all of them every time can make the bundle much larger and may publish old profiles the user no longer cares about.

The default behavior is therefore conservative:

- `Details: all profiles` unchecked: export only the currently active Details profile.
- `Details: all profiles` checked: export each profile from `Details:GetProfileList()` as a separate `WOW_PROFILE_VAULT` block.

Each exported Details block gets its own id, such as `details-main` or `details-raid`.

4. Improve large text usability:

- add entry delete/edit buttons
- add "copy instructions" text in UI

5. Add more adapters when new profile-owning addons are added to the setup.

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
