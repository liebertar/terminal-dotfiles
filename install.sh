#!/bin/bash
# Install Ghostty + tmux + zsh configs

set -e

echo "Installing terminal configs..."

# Ghostty
mkdir -p ~/.config/ghostty
cp ghostty/config ~/.config/ghostty/config
echo "  Ghostty config installed"

# tmux
cp tmux/.tmux.conf ~/.tmux.conf
echo "  tmux config installed"

# zsh (backup existing)
if [[ -f ~/.zshrc ]]; then
  cp ~/.zshrc ~/.zshrc.backup
  echo "  Existing .zshrc backed up to .zshrc.backup"
fi
cp zsh/.zshrc ~/.zshrc
echo "  .zshrc installed"

# VS Code symlink
if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  mkdir -p ~/.local/bin
  ln -sf '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' ~/.local/bin/code
  echo "  VS Code 'code' symlink created"
fi

echo ""
echo "Done! Restart Ghostty to apply."
echo "Required fonts: JetBrains Mono, D2Coding"
