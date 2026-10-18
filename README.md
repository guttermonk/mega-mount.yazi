# mega-mount.yazi

A disk mount manager for [Yazi](https://github.com/sxyazi/yazi), providing mount, unmount, and eject functionality for removable drives.

## Supported Platforms

- **Linux** with [`udisksctl`](https://github.com/storaged-project/udisks), `lsblk` and `eject` (provided by [`util-linux`](https://github.com/util-linux/util-linux))
- **macOS** with `diskutil` (pre-installed)

## Features

- 📂 **Browse drives**: View all connected drives and partitions in an interactive UI
- 🔌 **Mount/Unmount**: Mount and unmount partitions with a single keypress, with a toast confirming the result
- 🚦 **Status at a glance**: A `Status` column shows what's mounted, including a per-drive summary
- ⏏️ **Eject**: Safely eject removable drives
- 🔔 **Insertion alerts**: Get a toast when a removable drive is plugged in, telling you which key mounts it
- 🔗 **Symlinks**: Optionally create symlinks to mounted drives for easy access
- 🛡️ **Safety filters**: Hide system drives to prevent accidental unmounting
- ⌨️ **Customizable keys**: Configure keybindings to your preference

## Requirements

| Software | Notes |
| --- | --- |
| Yazi | `>=25.2.26` |
| udisksctl | **Linux**: `sudo apt/dnf/pacman install udisks2` |
| util-linux | **Linux**: Usually pre-installed (provides `lsblk`, `eject`) |
| diskutil | **macOS**: Pre-installed |

## Installation

```sh
ya pkg add guttermonk/mega-mount
```

Or manually clone to your Yazi plugins directory:

```sh
git clone https://github.com/guttermonk/mega-mount.yazi.git ~/.config/yazi/plugins/mega-mount.yazi
```

### Nix Flake

This is a plain Lua plugin, so add it as a source-only input:

```nix
{
  inputs = {
    mega-mount-yazi = {
      url = "github:guttermonk/mega-mount.yazi";
      flake = false;
    };
  };
}
```

Then add the plugin to your Yazi configuration:

```nix
{ inputs, ... }:
{
  programs.yazi = {
    enable = true;
    plugins = {
      mega-mount = inputs.mega-mount-yazi;
    };
  };
}
```

`programs.yazi.plugins` accepts a source directory, which is all this plugin
is -- there is nothing to build, so `flake = false` keeps it out of your lock
file's dependency graph.

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on  = "M"
run = "plugin mega-mount"
desc = "Open disk mount manager"
```

## Configuration

Add the following to your `~/.config/yazi/init.lua` to customize the plugin:

```lua
require("mega-mount"):setup({
    -- Customizable keybindings (all optional, showing defaults)
    -- Each action can have a single key or an array of keys
    keys = {
        quit = "q",           -- single key
        -- quit = { "q", "n" },  -- multiple keys
        up = "k",
        down = "j",
        enter = "l",
        mount = "m",
        unmount = "u",
        eject = "e",
    },

    -- Create symlinks to mounted drives (default: false)
    symlinks = false,

    -- Directory for symlinks (default: $HOME)
    symlink_dir = "/path/to/symlinks",

    -- Filter out the entire drive containing the root partition (default: true)
    exclude_root_drive = true,

    -- Filter out partitions mounted at these paths (default: {"/", "/boot", "/boot/efi"})
    exclude_mounts = { "/", "/boot", "/boot/efi" },

    -- Filter out partitions with these filesystem types (default: {})
    exclude_fstypes = { "swap" },

    -- Filter out devices matching these patterns (default: {})
    exclude_devices = { "^/dev/sda", "^/dev/nvme0n1" },

    -- Show keybinding hints at the bottom (default: true)
    show_help = true,

    -- Notify when a removable drive is inserted (default: true)
    notify = true,

    -- Key shown in that notification, e.g. "Press `M` to open Mega Mount."
    -- Set this to whatever you bound in keymap.toml (default: none)
    notify_keybind = "M",

    -- Also notify for drives that appear already mounted, such as those
    -- automounted by udisks (default: false)
    notify_mounted = false,
})
```

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | table | - | Custom keybindings for plugin actions |
| `symlinks` | boolean | `false` | Create symlinks to mounted drives |
| `symlink_dir` | string | `$HOME` | Directory where symlinks are created |
| `exclude_root_drive` | boolean | `true` | Hide the entire drive containing the root (`/`) partition |
| `exclude_mounts` | table | `{"/", "/boot", "/boot/efi"}` | Hide partitions mounted at these paths |
| `exclude_fstypes` | table | `{}` | Hide partitions with these filesystem types |
| `exclude_devices` | table | `{}` | Hide devices matching these Lua patterns |
| `show_help` | boolean | `true` | Show keybinding hints at the bottom of the window |
| `notify` | boolean | `true` | Notify when a removable drive is inserted |
| `notify_keybind` | string | - | Key that opens this plugin, named in the insertion notification |
| `notify_mounted` | boolean | `false` | Also notify for drives that appear already mounted |

## Keybindings

| Key | Alternate | Action |
| --- | --- | --- |
| <kbd>q</kbd> | <kbd>Esc</kbd> | Quit the plugin |
| <kbd>k</kbd> | <kbd>↑</kbd> | Move up |
| <kbd>j</kbd> | <kbd>↓</kbd> | Move down |
| <kbd>l</kbd> | <kbd>→</kbd> / <kbd>Enter</kbd> | Smart action: mount and open it, or unmount, eject and navigate away -- then close this window |
| <kbd>m</kbd> | - | Mount the partition or disk |
| <kbd>u</kbd> | - | Unmount the partition or disk |
| <kbd>e</kbd> | - | Eject the partition or disk |

The hint line at the bottom of the window tracks the row under the cursor, so
you can see what a key will do before pressing it:

- The smart action reads `mount & open` when the highlighted drive is unmounted
  and `unmount & eject` when it's mounted. It's named for everything it does,
  which is more than the plain `mount` key: it also navigates to the drive (or
  away from it) and closes this window. The hint lists `Enter` alongside your
  configured key, since both are always bound to it.
- Keys that would be rejected are dimmed -- `mount` on an already-mounted
  drive, `unmount` on an unmounted one. A partition with no filesystem dims
  both, along with the smart action.
- `eject` stays lit for any listed drive. Unlike mount and unmount it has no
  already-in-that-state guard, and powering off a drive you've unmounted is a
  normal thing to want.
- When no drives are listed at all, every operation is dimmed -- there's
  nothing for any of them to act on, so only `quit` does anything.

Drive rows aggregate their partitions: `mount` stays lit while any partition is
still unmounted, `unmount` while any is still mounted, so a partially mounted
drive offers both. Set `show_help = false` to hide the line entirely.

## The Drive List

| Column | Shows |
| --- | --- |
| `Src` | The device -- `/dev/sdb` for a drive, its number for each partition below it |
| `Label` | The volume label. Drive rows show the *drive's own* label, which exists when a filesystem spans the whole device (a hybrid ISO written to a stick, for instance) and is blank otherwise -- it isn't inherited from the partitions |
| `Mount Point` | Where a mounted partition is mounted. Blank on drive rows, since mounting here acts on the partitions |
| `FSType` | The filesystem. Blank on drive rows, for the same reason |
| `Status` | See below |

Yazi only learns the filesystem type from `/proc/mounts`, and resolves labels
from `/dev/disk/by-label` at the moment it snapshots the partition table --
which for a just-inserted drive can beat udev to creating those symlinks. Both
are therefore read from `lsblk` instead, which is live.

## The Status Column

The rightmost column summarises mount state, so you don't have to read the
`Mount Point` column to tell what's in use:

| Value | Meaning |
| --- | --- |
| `Mounted` | The partition is mounted -- or, on a drive row, all of its mountable partitions are |
| `Unmounted` | It has a filesystem but isn't mounted |
| `No FS` | No filesystem was detected, so there's nothing to mount |
| `1/2` | Drive rows only: how many of the drive's mountable partitions are mounted |
| `--` | Drive rows only: nothing on the drive is mountable |

A drive row's summary counts only the partitions actually listed, so the
`exclude_*` options affect it too.

## Operation Notifications

Mounting, unmounting and ejecting each confirm what happened:

```
Mounted `MYSTICK` at `/run/media/greg/MYSTICK`.
Unmounted `MYSTICK`.
Ejected `MYSTICK` -- safe to remove.
```

The smart action (<kbd>l</kbd> / <kbd>Enter</kbd>) unmounts *and* ejects, but
reports only once -- you get the eject confirmation, not both. Failures are
reported as errors as before.

## Disk Operations

When a disk (main device) is selected instead of a partition:

| Action | Behavior |
| --- | --- |
| Mount | Mounts all unmounted partitions on the disk that have a filesystem |
| Unmount | Unmounts all mounted partitions on the disk |
| Eject | Unmounts all partitions and powers off the disk |

## Filtering

By default, the plugin hides your OS drive to prevent accidental unmounting of system partitions. This is controlled by `exclude_root_drive = true`, which automatically detects and hides the entire drive (e.g., `/dev/sda` or `/dev/nvme0n1`) that contains your root filesystem.

For more granular control, you can:

- Use `exclude_mounts` to hide specific mount points
- Use `exclude_fstypes` to hide certain filesystem types (e.g., `{"swap", "tmpfs"}`)
- Use `exclude_devices` to hide devices by pattern (e.g., `{"^/dev/sda"}` to hide all `/dev/sda*` partitions)

To show all drives including your OS drive (**use with caution**):

```lua
require("mega-mount"):setup({
    exclude_root_drive = false,
    exclude_mounts = {},
})
```

## Insertion Notifications

When a removable drive is plugged in, Yazi shows a toast:

```
Mega Mount
Drive `MYSTICK` detected.
Press `M` to open Mega Mount.
```

The key opens this plugin's window -- it doesn't mount on its own, so the
message doesn't promise that it will.

The drive is named after its volume label, falling back to the device name
(e.g. `sdb1`). One notification is sent per physical drive, so a stick with
several partitions won't announce itself more than once.

`notify_keybind` is only interpolated into that message -- it does not register
a binding, so it cannot clash with the `plugin` binding in your `keymap.toml`,
and notifications never capture keyboard input.

This requires `require("mega-mount"):setup({ ... })` in your `init.lua` -- that
call is what registers the device watcher, so without it nothing is listening
while the plugin's window is closed. Set `notify_keybind` to match your
`keymap.toml` binding; there is no API for reading `keymap.toml`, so the plugin
can't work the key out on its own, and the message falls back to
"Open Mega Mount to mount it." when it isn't set.

A few details worth knowing:

- **Only removable drives are announced.** A drive qualifies if the kernel marks
  it removable (`/sys/block/<disk>/removable` on Linux, DiskArbitration on
  macOS), or if `lsblk` reports its transport as USB -- the second check catches
  USB SATA and NVMe enclosures, which report themselves as non-removable because
  their *media* isn't removable.
- **Up to ~3 seconds of delay.** Yazi polls `/proc/partitions` on that interval
  to spot devices that aren't mounted yet, so the toast isn't instantaneous.
- **Drives attached before Yazi starts are not announced**, only ones inserted
  while it's running. Unplugging and reinserting a drive notifies again.
- **The `exclude_*` filters apply.** Drives hidden from the UI stay silent.
- **Automounted drives are skipped by default**, since the "press a key to
  mount" advice doesn't apply to them. Set `notify_mounted = true` to get a
  "mounted at `/run/media/...`" toast for those instead.

## Symlinks

When `symlinks` is enabled:

- A symlink is created in `symlink_dir` when a partition is mounted
- The symlink is named after the volume label (if available) or the partition name (e.g., `sda1`)
- The symlink is automatically removed when the partition is unmounted or ejected
- Only actual symlinks are removed (regular files/directories are never deleted)

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.