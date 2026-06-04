# DPL-Platform Nix shell

`dpl-platform` can be used via Nix using this flake.

## Installation

Nothing is required to use this shell, beside Nix itself.

Nix is presently available for Linux and macOS. It can be installed in many different ways, but for this use case, [using the Determinate Nix Installer is the easiest](https://github.com/determinate-systems/nix-installer).

If you already have Nix installed, you need to have [Flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes).

## Usage

From the root of this repository, run `nix develop ./tools/nix#` to enter the shell.

### With direnv

If you use [direnv](https://direnv.net/), you can automatically enter the shell when you `cd` into the repository root.

To set this up, add an `.envrc` file in the repository root, with the following content:

```
use flake path:./tools/nix
```
