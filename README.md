# docksteady

![The docksteady wordmark rendered with light rays streaming through the letters, above the tagline "Steady. Beyond belief."](docs/hero.png)

docksteady keeps your Mac's external displays in the arrangement you chose,
even when macOS cannot tell them apart.

## Check whether you need it

You need docksteady if all of the following are true:

- Your Mac has Apple silicon and two external displays of the same model,
  typically connected through a dock.
- After your Mac sleeps, or after you replug the dock, the displays sometimes
  swap places: your left desktop appears on the right screen, and the pointer
  crosses between screens on the wrong side.
- The arrangement you set in System Settings doesn't stay.

This happens because a display introduces itself to the Mac with a small
identity record, and that record carries two serials: a number, which macOS
uses to tell displays apart, and a text field with the serial printed on the
panel's label. On many identical displays the number is a factory
placeholder, the same on every unit, so macOS has to guess which panel is
which each time they reconnect, and sometimes it guesses wrong. The text
serial is still unique to each panel; docksteady reads that one instead, and
uses it to put the arrangement right within seconds, automatically.

## What docksteady corrects, and what it can't move

docksteady corrects the arrangement on its own. Your windows and Spaces move
back with one click or one command.

The arrangement it keeps:

- which display is on the left and which is on the right
- the seam where the pointer crosses between them
- the exact positions you arranged, including any offsets; the layout you
  have when you set docksteady up is the layout it keeps

Windows and Spaces are different. macOS attaches them to each display, and
when a mix-up happens they travel with the display to the wrong side. This is
how macOS works: correcting the arrangement doesn't bring them back. To move
them back:

- Click **Swap windows** in the dialog docksteady can show when it corrects
  the arrangement (see Settings), or run `docksteady swap-windows` any time.
  Either moves the standard windows across in one pass.
- Run `docksteady swap-windows --with-fullscreen` to carry full-screen
  windows too: docksteady takes each one out of full screen, moves it across
  with the rest, then puts it back into full screen on its new display. It
  can only reach full-screen windows that are showing on their display when
  you run it; a hidden full-screen Space stays put, and a window that
  refuses or loses its name along the way stays a standard window, noted in
  the log. Split View pairs come back as two separate full-screen Spaces.
- Additional desktops, hidden full-screen Spaces included, move by dragging
  them between displays in Mission Control.

## What you need

- A Mac laptop with Apple silicon; the lid can be open or closed, and
  docksteady keeps a separate arrangement for each
- Exactly two identical external displays; docksteady doesn't manage other
  setups
- macOS 26, where docksteady is developed and in daily use
- [Homebrew](https://brew.sh); if Terminal answers `command not found: brew`,
  install it first

## Install docksteady

```sh
brew install den-frie-vilje/tap/docksteady
brew install jakehilborn/jakehilborn/displayplacer  # moves displays; the long name is its maker's tap
brew services start sleepwatcher  # runs docksteady when your Mac wakes; installed with docksteady
```

Or from a clone of this repository, run `./install.sh`, which walks through
the same dependencies.

## Set up docksteady

1. Connect both displays and arrange everything the way you want it in
   System Settings > Displays, including which physical screen shows what.
   Your exact arrangement is what docksteady will keep.
2. Run:

   ```sh
   docksteady init
   ```

   docksteady detects both panels and answers with something like:

   ```
   Detected arrangement:
     panel CNK548040N at origin (-2252,-1692)
     panel CNK548049R at origin (756,-1692)
   Blessing: left=CNK548040N right=CNK548049R (taken from the current arrangement)
   config written to ~/.config/docksteady/config.json
   LaunchAgent armed: ... (login + every 45s)
   wake hook installed in ~/.wakeup
   initial apply: layout verified
   ```

3. Check that it worked: run `docksteady status`. You should see both
   panels, each with its serial number and position, and your settings.
4. To see it work now, put your Mac to sleep, wake it, and watch the
   arrangement come back.
5. If left and right are reversed after a correction, run `docksteady swap`
   once.

From now on, docksteady sets itself to run at login, when your Mac wakes,
and every 45 seconds, and puts the arrangement right whenever macOS has
mixed the displays up. If you use the Mac both lid open and lid closed, run
`docksteady save` once in the other mode too: each mode keeps its own
recorded arrangement.

## What macOS will ask you

macOS tells you about background activity, so expect these once:

- **Background Items Added**, after install and setup: sleepwatcher, and
  docksteady's schedule, which can appear as "sh", the small system shell it
  runs through. That is the schedule being registered.
- **Allow notifications**, the first time docksteady reports a correction.
  Command-line notifications appear under Script Editor's name; allow them
  there.
- **Accessibility permission**, the first time you move windows. The prompt
  names the program that moves them: python3 if you clicked the dialog's
  button, or your terminal app if you ran `docksteady swap-windows`
  yourself. Allow it in System Settings > Privacy & Security >
  Accessibility. If you decline, you can still move windows from your
  terminal, after allowing your terminal app the same way.

## What to expect

Most days you won't notice docksteady at all. It stays silent while the
arrangement is correct, and it waits whenever System Settings is the
frontmost app, so it never interferes while you drag displays yourself.

To pause docksteady for a while, run `docksteady pause`; it then leaves the
displays alone for an hour. Add a number of minutes to choose how long:
`docksteady pause 30`. Run `docksteady resume` to lift the pause early.

When docksteady corrects a mix-up, it lets you know with a notification. Run
`docksteady notify dialog` to get a dialog instead: it stays on screen for
two minutes and carries the **Swap windows** button. `docksteady notify
banner` switches back, and `docksteady notify off` silences both.

## Settings

Setup and routine operation use these files, and nothing else:

- `~/.config/docksteady/config.json`, the settings below
- `~/.config/docksteady/state.json`, a snapshot used as fallback
- small runtime markers in `~/.config/docksteady/` (`lock`, `pause-until`,
  `last-skip`)
- `~/Library/LaunchAgents/dk.denfrievilje.docksteady.plist`, the schedule
- a marked block in `~/.wakeup`, the wake trigger (sleepwatcher's hook file)
- `~/Library/Logs/docksteady.log`, the log of every action and every reason
  it stood aside

`config.json` keys:

| Key | Default | Meaning |
| --- | --- | --- |
| `left`, `right` | set by `init` | factory serial of the panel assigned to each side |
| `origins`, `origins_clamshell` | set by `init` and `save` | the arranged positions, one recording per lid mode, replayed exactly |
| `poll_seconds` | `45` | how often the background check runs; change with `docksteady init --poll N` |
| `notify` | `"banner"` | `"banner"`, `"dialog"`, or `"off"`; change with `docksteady notify ...` |
| `dialog_timeout` | `120` | seconds the dialog stays on screen |
| `swap_fullscreen` | `false` | make the dialog's button carry full-screen windows too |

Change any of the last four from the command line, no file editing needed,
for example `docksteady set swap_fullscreen true` or `docksteady set
dialog_timeout 300`.

If you rearrange your desk, set the new arrangement in System Settings, then
run `docksteady save` to make it the one docksteady keeps. `save` also
refreshes the stored positions after a resolution or scaling change.

## All commands

```
init            detect panels, save settings, schedule the checks
apply           put the arrangement right now (what the schedule runs)
swap            swap which panel is assigned left and right
swap-windows    move standard windows between the two externals
                (--with-fullscreen carries full-screen windows too)
save            save the current arrangement as the correct one
status          show panels, serials, settings, and pause state
pause [min]     leave the displays alone (default 60 minutes)
resume          lift a pause early
notify MODE     set banner, dialog, or off
set KEY VALUE   change a setting (notify, dialog_timeout,
                swap_fullscreen, poll_seconds)
probe NAMEPART  inspect an app's windows through accessibility
disarm          remove the schedule and wake trigger (before uninstalling)
version         print the version
```

`docksteady help` lists the flags (`--retries`, `--quiet`, `--dry-run`,
`--left`, `--right`, `--poll`, `--yes`, `--with-fullscreen`).

## How it works

The identity record a display sends is its EDID. macOS keys arrangements on
the EDID's numeric serial field, the one identical panels share; the EDID's
text serial, the unique one on the label, surfaces in the Mac's hardware
registry (IOKit), attached to the display pipe that drives each panel. Which
pipe each of macOS's display identities renders to is readable through the
CoreDisplay framework. Chaining the two gives docksteady what macOS itself never has: a
firm link between a display identity and a physical panel. On that link it
replays your saved arrangement with
[displayplacer](https://github.com/jakehilborn/displayplacer), triggered by
[sleepwatcher](https://formulae.brew.sh/formula/sleepwatcher) on wake and by
a LaunchAgent at login and on the poll.

Every run first checks, by serial, that both of your panels are attached.
docksteady changes only those two panels and, when the lid is open, the
MacBook's own screen; with any other display attached it does nothing at
all, and says so in the log.

The serial link uses a private CoreDisplay dictionary. If a macOS update
changes it, docksteady says so in the log and keeps working from its last
snapshot: your geometry stays put, but identity mix-ups go undetected until
a docksteady update restores the link. Everything runs as your user, with no
elevated privileges and no network access.

**Warning:** never disable one of two identical panels with displayplacer
(`enabled:false`). macOS loses the panel beyond software recovery, and only
replugging it, sometimes with a dock power-cycle, brings it back. docksteady
never does this, and neither should you.

## Uninstall

If you installed with Homebrew:

```sh
docksteady disarm
brew uninstall docksteady
```

If you installed from a clone, run `./uninstall.sh`, which does both.

If you forget `disarm`, nothing breaks: the schedule and wake trigger check
that docksteady is still installed, and stay silent when it isn't. Leave
them; they do nothing. To clear them away later, delete
`~/Library/LaunchAgents/dk.denfrievilje.docksteady.plist` and the marked
block in `~/.wakeup`, both listed under Settings.

If you no longer want the helpers either: `brew services stop sleepwatcher`,
then `brew uninstall sleepwatcher displayplacer`. Settings and the log stay
behind; remove `~/.config/docksteady` and `~/Library/Logs/docksteady.log`
for a clean slate.

## About

Built at [Den Frie Vilje](https://denfrievilje.dk) after a pair of identical
HP panels on a Thunderbolt dock spent a day demonstrating exactly where
macOS's boundaries are. MIT licensed.
