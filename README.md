# mega-mount.yazi

A disk mount manager for [Yazi](https://github.com/sxyazi/yazi), providing mount, unmount, and eject functionality for removable drives.

## Supported Platforms

- **Linux** with [`udisksctl`](https://github.com/storaged-project/udisks), `lsblk` and `eject` (provided by [`util-linux`](https://github.com/util-linux/util-linux))
- **macOS** with `diskutil` (pre-installed)

## Features

- 📂 **Browse drives**: View all connected drives and partitions in an interactive UI
- 🔌 **Mount/Unmount**: Mount and unmount partitions with a single keypress
- ⏏️ **Eject**: Safely eject removable drives
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

## Keybindings

| Key | Alternate | Action |
| --- | --- | --- |
| <kbd>q</kbd> | <kbd>Esc</kbd> | Quit the plugin |
| <kbd>k</kbd> | <kbd>↑</kbd> | Move up |
| <kbd>j</kbd> | <kbd>↓</kbd> | Move down |
| <kbd>l</kbd> | <kbd>→</kbd> / <kbd>Enter</kbd> | Smart action: mount if unmounted, or unmount+eject if mounted |
| <kbd>m</kbd> | - | Mount the partition or disk |
| <kbd>u</kbd> | - | Unmount the partition or disk |
| <kbd>e</kbd> | - | Eject the partition or disk |

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

## Symlinks

When `symlinks` is enabled:

- A symlink is created in `symlink_dir` when a partition is mounted
- The symlink is named after the volume label (if available) or the partition name (e.g., `sda1`)
- The symlink is automatically removed when the partition is unmounted or ejected
- Only actual symlinks are removed (regular files/directories are never deleted)

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.