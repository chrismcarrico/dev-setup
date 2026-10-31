# dev-setup

Ansible recipe for my Arch-based dev machine. On top of a fresh EndeavourOS KDE install, it adds my packages, apps, shell setup, language tooling, VS Code extensions and repos.

## Set up a new machine

1. Install EndeavourOS with the KDE desktop. This recipe doesn't handle the base OS.

2. Clone this repo and run it. `run.sh` installs Ansible, then asks for your sudo password twice: once for `pacman`, once for Ansible at the `BECOME password:` prompt.

   ```bash
   sudo pacman -S --needed git
   ```

   ```bash
   git clone https://github.com/chrismcarrico/dev-setup ~/Source/dev-setup
   ```

   ```bash
   ~/Source/dev-setup/run.sh
   ```

3. Create an SSH key and add the public key at <https://github.com/settings/keys>:

   ```bash
   ssh-keygen -t ed25519
   ```

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

4. Clone the personal repos. They're skipped by default because they need the SSH key:

   ```bash
   ~/Source/dev-setup/run.sh --tags personal-repos
   ```

5. Log out and back in so the zsh login shell, `docker` group and KDE configs take effect.

6. Sign in to the apps (VS Code, Chrome, Claude and so on), and run `claude` once to sign in to Claude Code.

## Running part of it

`run.sh` passes its arguments to `ansible-playbook`, so you can target tags or do a dry run:

```bash
./run.sh --tags vscode,dotfiles
```

```bash
./run.sh --check
```

`--check` only applies to the playbook: `run.sh` still does its real `pacman -Syu` and collection install first. Tasks that run a command, including `link.sh`, are skipped in a dry run.

| Tag | What it does |
|---|---|
| `core` | Installs pacman packages. |
| `yay` | Creates the `aur_builder` user and installs yay if it's missing. |
| `aur` | Installs AUR packages. Needs `yay` to have run once. |
| `sublime` | Adds the Sublime repo and key, and installs Sublime Text and Merge. |
| `dotfiles` | Clones [dotfiles](https://github.com/chrismcarrico/dotfiles) to `~/Source/dotfiles`, installs Oh My Zsh, runs the repo's `scripts/link.sh`, and sets zsh as the login shell. |
| `rust` | Installs the stable toolchain through rustup. |
| `python` | Creates the `~/.default` venv with `uv`, `ruff` and `ipython`. |
| `vscode` | Installs VS Code extensions. |
| `claude` | Installs the Claude Code CLI with the official installer. |
| `config` | Enables Docker and adds you to the `docker` group. |
| `github` | Clones public repos into `~/Source`. |
| `personal-repos` | Clones personal repos over SSH. Only runs when you ask for this tag. |

## Re-running

The playbook is safe to re-run, and a second run should change little. Keep in mind:

- `run.sh` always does a full `pacman -Syu` first, because Arch doesn't support partial upgrades. Reboot afterwards if the kernel updated.
- Existing clones are left alone, so nothing gets pulled or overwritten. Update them with git yourself.
- `link.sh` moves any real file in the way to `<file>.bak-<timestamp>` before linking the repo's copy. KDE apps can replace their symlinks with regular files when they save, so copy any newer file into the dotfiles repo before re-running, or the older repo version wins.
- Shell, git, KDE, GTK and editor configs belong to the dotfiles repo. Change them there, not here. This recipe only installs Oh My Zsh.

## Changing what gets installed

| To add | Edit |
|---|---|
| A pacman package | `roles/core_packages/vars/main.yml` |
| An AUR package | `roles/aur_packages/vars/main.yml` |
| A VS Code extension | `roles/vscode_extensions/vars/main.yml` (`code --list-extensions` shows what's installed) |
| A Python tool | `roles/python_setup/vars/main.yml` |
| A public repo | `roles/github_repos/vars/main.yml` |
| A personal repo | `roles/personal_repos/vars/main.yml` |

To see what's on the machine, `pacman -Qqen` lists explicitly installed repo packages and `pacman -Qqem` lists AUR ones. Most of the first list comes from the EndeavourOS install.

## Not covered

- The base OS: kernel, bootloader, drivers, and the KDE desktop. Its settings come from the dotfiles repo.
- Hardware-specific packages. This laptop also needs `nvidia-open`, `nvidia-utils`, `nvidia-settings`, `asusctl` and `rog-control-center`.
- SSH keys. See step 3.

## Notes

- The `yay` role leaves an `aur_builder` user with passwordless `pacman` in `/etc/sudoers.d/11-install-aur_builder`. AUR builds can't run as root, and Ansible can't answer a sudo prompt mid-build. This is the setup the `kewlfft.aur` collection recommends. That user is effectively root-equivalent, so don't log in as it or run anything else as it.
- `claude-desktop` comes from the AUR, where anyone can maintain a package. Check its PKGBUILD before installing or updating it.
