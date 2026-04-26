#!/usr/bin/env bash
# terminal-dotfiles installer — Ghostty + tmux + zsh
# Goal: clone → run → identical terminal experience to source machine.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup-$TS"

say()  { printf "\033[1;36m▸\033[0m %s\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m!\033[0m %s\n" "$*"; }
err()  { printf "  \033[1;31m✗\033[0m %s\n" "$*" >&2; }

# ---------- 1. macOS check ----------
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "macOS only. Detected: $(uname -s)"
  exit 1
fi
say "macOS detected ($(sw_vers -productVersion))"

# ---------- 2. Homebrew ----------
if ! command -v brew >/dev/null 2>&1; then
  say "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew present ($(brew --version | head -1))"
fi

# ---------- 3. Brewfile bundle (fonts, tmux, zsh plugins, ghostty, etc.) ----------
say "Installing packages from Brewfile"
brew bundle --file="$REPO_DIR/Brewfile"
ok "Brewfile bundle complete"

# ---------- 4. uv (creates ~/.local/bin/env that .zshrc sources) ----------
if [[ ! -x "$HOME/.local/bin/uv" ]] || [[ ! -r "$HOME/.local/bin/env" ]]; then
  say "Installing uv (official installer — provisions ~/.local/bin/env)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ok "uv installed"
else
  ok "uv present ($("$HOME/.local/bin/uv" --version))"
fi

# ---------- 5. Backup existing dotfiles ----------
mkdir -p "$BACKUP_DIR"
say "Backing up existing dotfiles → $BACKUP_DIR"
backup() {
  local src="$1"
  if [[ -e "$src" || -L "$src" ]]; then
    local rel="${src#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -aL "$src" "$BACKUP_DIR/$rel" 2>/dev/null || cp -a "$src" "$BACKUP_DIR/$rel"
    ok "backed up $src"
  fi
}
backup "$HOME/.zshrc"
backup "$HOME/.zprofile"
backup "$HOME/.tmux.conf"
backup "$HOME/.config/ghostty/config"
backup "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

# ---------- 6. Install dotfiles ----------
say "Installing dotfiles"

# zsh
install -m 0644 "$REPO_DIR/zsh/.zshrc"    "$HOME/.zshrc"     && ok "~/.zshrc"
install -m 0644 "$REPO_DIR/zsh/.zprofile" "$HOME/.zprofile"  && ok "~/.zprofile"

# tmux
install -m 0644 "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" && ok "~/.tmux.conf"

# ghostty (primary)
mkdir -p "$HOME/.config/ghostty"
install -m 0644 "$REPO_DIR/ghostty/config" "$HOME/.config/ghostty/config" && ok "~/.config/ghostty/config"

# ghostty (Application Support — option-as-alt fragment)
GHOSTTY_APPSUP="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_APPSUP"
install -m 0644 "$REPO_DIR/ghostty/config.ghostty" "$GHOSTTY_APPSUP/config.ghostty" && ok "Application Support/.../config.ghostty"

# ---------- 7. Custom binaries ----------
say "Installing custom scripts → ~/.local/bin"
mkdir -p "$HOME/.local/bin"
install -m 0755 "$REPO_DIR/bin/clip-image" "$HOME/.local/bin/clip-image" && ok "clip-image"

# ---------- 8. VS Code 'code' symlink (TCC 팝업 회피) ----------
if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  ln -sf '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' "$HOME/.local/bin/code"
  ok "VS Code 'code' symlink → ~/.local/bin/code"
else
  warn "VS Code not installed — skipped 'code' symlink"
fi

# ---------- 9. Verify font registration ----------
say "Verifying fonts"
need_fc=()
fc-list 2>/dev/null | grep -qi "JetBrains Mono"   || need_fc+=("JetBrains Mono")
fc-list 2>/dev/null | grep -qi "D2Coding"          || need_fc+=("D2Coding")
# fc-list may not exist on macOS — fall back to system_profiler
if [[ -z "$(command -v fc-list)" ]]; then
  if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "JetBrainsMono"; then
    need_fc+=("JetBrains Mono")
  fi
  if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "D2Coding"; then
    need_fc+=("D2Coding")
  fi
fi
if [[ ${#need_fc[@]} -eq 0 ]]; then
  ok "fonts registered (JetBrains Mono, D2Coding)"
else
  warn "missing/unregistered: ${need_fc[*]} — log out & back in if just installed"
fi

# ---------- 10. Reload tmux server (so new conf is the source of truth) ----------
if pgrep -x tmux >/dev/null 2>&1; then
  say "Killing tmux server so new ~/.tmux.conf is the source of truth on next attach"
  tmux kill-server 2>/dev/null || true
  ok "tmux server killed"
fi

# ---------- 11. Done ----------
cat <<EOF

\033[1;32m✔ Install complete\033[0m
  Backups saved to: $BACKUP_DIR

Next:
  1. Quit & reopen Ghostty (Cmd+Q, relaunch — config is read at startup).
  2. Open a new shell to pick up .zshrc / .zprofile.
  3. \`tmux\` to start fresh server with new config.

If fonts still look wrong:
  - Quit Ghostty, then: \`atsutil databases -remove && killall fontd\`
  - Reopen Ghostty.

If shift+arrow / opt+arrow still don't work:
  - Confirm: System Settings → Keyboard → Keyboard Shortcuts → Mission Control / etc.
    do not capture super+alt+arrow, super+shift+arrow.
EOF
