# KDE Three-Finger Window Switcher Gesture

A KDE Plasma/KWin setup that turns a **3-finger touchpad swipe** into window switching using KWin's built-in Alt+Tab switcher (configured here with the **Big Icons** layout).

It uses [InputActions](https://github.com/taj-ny/InputActions) (`inputactions-kwin`) to translate touchpad gestures into keyboard actions that drive the normal Alt+Tab UI.

## How it works

- **3-finger horizontal swipe**: opens Alt+Tab and moves selection left/right.
- **3-finger vertical swipe**: moves selection up/down in grid layouts (when supported by the active config/plugin behavior).
- **Lift fingers**: releases Alt and activates the selected window.

> Exact behavior depends on the InputActions/plugin version and config variant you use (see below).

## Repository contents

| Path | Purpose |
|---|---|
| `big_icons/` | KWin tabbox/switcher layout (install to `~/.local/share/kwin/tabbox/big_icons/`) |
| `inputactions-config.yaml` | Original/patched-style gesture config from the source project (uses scripting/variables and `retain_on_mismatch`) |
| `inputactions-config.stock-compatible.yaml` | Simplified config that works with stock InputActions versions that don't support the patched features/fields |
| `kwinrc-settings.ini` | Reference KWin settings (`kwin_gesturesEnabled`, tabbox layout) |
| `inputactions-core.patch`, `kwin-plugin-lifecycle.patch` | Patches referenced by the original project for enhanced gesture behavior/lifecycle handling |
| `bin/kwin_gestures.so` | Prebuilt plugin binary from the original environment (**ABI-specific; may not work on your system**) |
| `install-fixed-plugin.sh` | Original install script (**Fedora-oriented paths/assumptions; review before use**) |

## Requirements

- KDE Plasma / KWin (Wayland or X11 session as supported by your InputActions/KWin setup)
- InputActions with KWin integration (e.g. `inputactions-kwin`)
- A touchpad that InputActions can detect

## Setup

### 1. Install InputActions (KWin integration)

Install the appropriate package for your distro. On Arch Linux (AUR):

```bash
yay -S inputactions-kwin
# or: paru -S inputactions-kwin
```

Make sure the installed plugin matches your current KWin version. If KWin is updated later, you may need to rebuild/reinstall the InputActions KWin package.

### 2. Install the Big Icons tabbox layout

```bash
mkdir -p ~/.local/share/kwin/tabbox
cp -r big_icons ~/.local/share/kwin/tabbox/
```

### 3. Install the InputActions config

Create the config directory and copy a config variant:

```bash
mkdir -p ~/.config/inputactions

# Recommended starting point for stock inputactions-kwin:
cp inputactions-config.stock-compatible.yaml ~/.config/inputactions/config.yaml

# Or try the original/patched-style config (may require compatible plugin/features):
# cp inputactions-config.yaml ~/.config/inputactions/config.yaml
```

#### Set your touchpad device name

Edit `~/.config/inputactions/config.yaml` and update the device rule to match your touchpad exactly:

```yaml
device_rules:
  - conditions: $name == "YOUR TOUCHPAD NAME HERE"
```

Find the correct name with:

```bash
cat /proc/bus/input/devices | grep -B2 -A8 -i touchpad | grep "N: Name"
# or, depending on your setup/permissions:
# libinput list-devices | grep -A2 -i touchpad
```

If the InputActions DBus interface is available (after login/effect load), you can also check:

```bash
inputactions devices list
inputactions config issues
```

### 4. Apply KWin settings

Reference values are in `kwinrc-settings.ini`:

```ini
[Plugins]
kwin_gesturesEnabled=true
gestureswitchEnabled=false

[TabBox]
LayoutName=big_icons

[TabBoxAlternative]
LayoutName=big_icons
```

Apply with:

```bash
kwriteconfig6 --file kwinrc --group Plugins --key kwin_gesturesEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key gestureswitchEnabled false
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName big_icons
kwriteconfig6 --file kwinrc --group TabBoxAlternative --key LayoutName big_icons
```

### 5. Reload and test

- **Log out and log back in** (recommended) so KWin loads the effect and layout changes.
- After login, validate/reload config if needed:
  ```bash
  inputactions config issues
  inputactions config reload
  ```
- Test a 3-finger swipe on the touchpad.

## Stock vs patched plugin/config

- **Stock-compatible config** (`inputactions-config.stock-compatible.yaml`): avoids patched-only features like `retain_on_mismatch`-dependent behavior and scripted variable state used by the original config. This is the safest starting point with distro/AUR packages.
- **Original config** (`inputactions-config.yaml`): expects behavior/features provided by the patched setup described in the source project (see patches and `bin/kwin_gestures.so`). On stock InputActions, it may produce validation errors or reduced functionality.

### Using the patched plugin (advanced)

If you need the patched behavior, build InputActions' KWin plugin from source compatible with your KWin/Qt version and apply the included patches as appropriate:

- `inputactions-core.patch`
- `kwin-plugin-lifecycle.patch`

Then install the resulting `kwin_gestures.so` to your system's KWin effects plugin path (on Arch typically `/usr/lib/qt6/plugins/kwin/effects/plugins/kwin_gestures.so`), after backing up the existing file. **Do not copy `bin/kwin_gestures.so` blindly** unless you know it matches your exact KWin/Qt ABI.

## Troubleshooting

### Gestures stopped working after a system update (Arch/KDE)

If KWin was upgraded, an AUR-installed `inputactions-kwin` plugin may be built for the previous KWin version. Check logs:

```bash
journalctl -b --no-pager | grep -iE "inputaction|kwin_gestures|gestures" | tail -80
```

A common error looks like:

```text
Effect "kwin_gestures" was built for a different version of KWin and needs to be rebuilt...
```

Fix by rebuilding/reinstalling the package against the current KWin, then logging out/in:

```bash
yay -S --rebuild inputactions-kwin
# or rebuild from the cached PKGBUILD directory with makepkg
```

### Config or device issues

```bash
inputactions devices list
inputactions config issues
```

- Ensure the touchpad name in `device_rules.conditions` matches exactly.
- If `Failed to connect to the InputActions DBus interface` appears, the effect/service may not be loaded in the current session yet (try relogin and verify the effect is enabled).

### KWin effect not active

- Confirm `kwin_gesturesEnabled=true` in `~/.config/kwinrc`.
- Check *System Settings → Window Management → Desktop Effects* for an InputActions/KWin Gestures effect and enable it if present.
- Re-login after plugin/config changes.

## Notes

- `install-fixed-plugin.sh` and `bin/kwin_gestures.so` are preserved from the original project context and may require adaptation for your distro, paths, and ABI.
- This repo documents a practical setup for KDE Plasma; behavior can vary across InputActions/KWin/Qt versions.
