# docksteady

Keeps a macOS multi-monitor arrangement steady when the Mac cannot tell your
displays apart.

## The problem

Two identical monitors on one Mac, typically through a Thunderbolt dock, will
often ship with the same placeholder EDID serial number. macOS then has no way
to distinguish the panels, so each time they attach (wake from sleep, replug,
dock power-cycle) it assigns the two display identities essentially at random.
When the assignment lands the wrong way round, everything trades sides: your
left desktop appears on the right monitor, the mouse crosses the seam
backwards, and windows are on the wrong screens.

The cruel part is that nothing in software looks wrong. macOS stores
arrangements per display identity, and the identities are self-consistent;
only their binding to the physical glass has flipped. Dragging displays around
in System Settings cannot fix it, because dragging moves an identity's
coordinates and the content rides along with the identity.

docksteady fixes what can be fixed, automatically, and gives you a one-line
command for the rest.

## How it works

The panels' real factory serials are readable in IOKit, attached to the SoC
display pipe that drives each panel. The window server side is bridged through
the CoreDisplay info dictionary, which reveals which pipe each display
identity renders to. Chaining the two grounds every display identity in an
immutable factory serial, which macOS itself never does.

On that foundation docksteady enforces your blessed arrangement (the two
externals side by side with a central seam, the laptop screen centred
underneath) whenever it drifts: at login, on wake (via sleepwatcher), and on a
poll every 45 seconds. Enforcement is idempotent and silent when everything is
already correct, skips whenever System Settings is the frontmost app so it
never fights your drags, and only ever touches the two configured panels.

One honest limitation is a platform boundary, not a bug: window content is
welded to the display identity, and no arrangement tool can move content
between panels. When an identity flip trades your windows, docksteady
re-pins the geometry within seconds, posts a notification, and
`docksteady swap-windows` moves the windows back in one pass.

## Install

With Homebrew:

```sh
brew install den-frie-vilje/tap/docksteady
brew install jakehilborn/jakehilborn/displayplacer
brew services start sleepwatcher
docksteady init
```

Or from a clone:

```sh
git clone https://github.com/den-frie-vilje/docksteady.git
cd docksteady && ./install.sh
docksteady init
```

Run `init` while docked with both panels attached and the arrangement looking
right; it detects the panels' serials, blesses the current sides, and arms the
triggers. If the sides were backwards at that moment, `docksteady swap` flips
the blessing once.

## Commands

```
init            detect panels, write config, arm the triggers
apply           enforce the arrangement (what the triggers run)
swap            flip which panel is blessed left and right
swap-windows    move all standard windows between the two externals
save            bless the current arrangement as the good one
status          show panels, serials, config, and guard state
pause [min]     suspend enforcement (default 60); resume lifts it
probe FRAGMENT  inspect an app's windows through Accessibility
version         print the version
```

## Configuration

`~/.config/docksteady/config.json`:

```json
{
  "left": "SERIALOFLEFTPANEL",
  "right": "SERIALOFRIGHTPANEL",
  "poll_seconds": 45,
  "notify": true
}
```

`left` and `right` are the factory serials blessed to each side; `init` and
`swap` maintain them. `poll_seconds` sets the LaunchAgent interval (rerun
`init` after changing it). `notify` controls the macOS notification posted
when enforcement acts. The log is `~/Library/Logs/docksteady.log`.

## Scope and caveats

- Built for one specific topology: a MacBook with exactly two identical
  external panels. Other arrangements are out of scope for now.
- Apple silicon only; developed and lived-with on macOS 26. The serial bridge
  reads a private CoreDisplay dictionary and degrades gracefully (falling back
  to identity snapshots and positions) if an OS update changes it.
- `swap-windows` uses the Accessibility API and needs assistive access for
  the terminal you run it from. It covers windows on each display's visible
  Space; full-screen Spaces move by dragging in Mission Control. It never
  runs automatically.
- Never disable one of the panels with `displayplacer enabled:false`: the
  panel vanishes beyond software recovery and only a replug, possibly with a
  dock power-cycle, brings it back. docksteady never does this.

## Uninstall

```sh
./uninstall.sh          # from a clone; disarms triggers, removes the command
brew uninstall docksteady   # if installed via the tap
```

Configuration and the log are left behind; remove `~/.config/docksteady` and
`~/Library/Logs/docksteady.log` for a clean slate.

## Provenance

Built at [Den Frie Vilje](https://denfrievilje.dk) after a pair of HP E27k G5
panels on a Kensington SD5760T dock spent a day teaching us exactly where
macOS's boundaries are. MIT licensed.
