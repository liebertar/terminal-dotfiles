# terminal-dotfiles

macOS 터미널 환경 (Ghostty + tmux + zsh) 의 1:1 복원용 dotfiles.
클론 → `./install.sh` → 같은 머신.

## What you get

- **Ghostty** — GitHub dark, JetBrains Mono / D2Coding, blur 0.92, borderless, Cmd+V Claude Code 이미지 paste 우회 키바인딩
- **tmux** — Ctrl+A prefix, vim-style pane nav, repo+branch pane header (yellow), 노란 status bar, alternate-screen 마우스 패스스루, Claude Code 이미지 paste 손상 방지 (extended-keys off)
- **zsh** — colored prompt + git branch, syntax highlighting, autosuggestions, Shift+Arrow / Shift+Cmd+Arrow text selection, Ghostty pane title (`repo [branch]`)
- **clip-image** — macOS 클립보드의 PNG 를 `/tmp/clip-*.png` 로 저장하고 `/image <path>` 출력 (Claude Code paste 보조)
- **Brewfile** — JetBrains Mono / D2Coding cask, zsh-syntax-highlighting, zsh-autosuggestions, tmux, gh, pyenv, ghostty, coreutils

## Install

```bash
git clone https://github.com/liebertar/terminal-dotfiles.git
cd terminal-dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` 가 하는 일:

1. macOS 확인
2. Homebrew 없으면 설치
3. `brew bundle` 으로 Brewfile 전체 설치 (폰트 포함)
4. uv 공식 설치 스크립트 실행 → `~/.local/bin/env` 생성 (`.zshrc` 가 source 함)
5. 기존 dotfile 들을 `~/.dotfiles-backup-<timestamp>/` 로 백업
6. `~/.zshrc`, `~/.zprofile`, `~/.tmux.conf`, `~/.config/ghostty/config`, `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` 복사
7. `~/.local/bin/clip-image` 설치
8. VS Code `code` symlink (`~/.local/bin/code`)
9. 폰트 등록 검증 (JetBrains Mono, D2Coding)
10. tmux server kill (다음 attach 부터 새 conf 적용)

## File map

| Repo path                               | Destination                                                              |
|-----------------------------------------|--------------------------------------------------------------------------|
| `ghostty/config`                        | `~/.config/ghostty/config`                                               |
| `ghostty/config.ghostty`                | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`     |
| `tmux/.tmux.conf`                       | `~/.tmux.conf`                                                           |
| `zsh/.zshrc`                            | `~/.zshrc`                                                               |
| `zsh/.zprofile`                         | `~/.zprofile`                                                            |
| `bin/clip-image`                        | `~/.local/bin/clip-image`                                                |

## Why fonts / keybinds 가 안 먹었던 이유 (히스토리)

- **폰트**: `install.sh` 가 폰트를 설치하지 않으면 ghostty가 fallback 글꼴로 렌더링 — JetBrains Mono / D2Coding 둘 다 cask 로 설치해야 보임. → Brewfile 에 `font-jetbrains-mono`, `font-d2coding` 명시.
- **Shift+Arrow / Shift+Cmd+Arrow**: `.zshrc` 에서 `bindkey` 가 정의됨. zsh-syntax-highlighting / zsh-autosuggestions brew formulae 가 없으면 source 가 에러 출력하지만 후속 라인은 실행됨. 진짜 원인은 `~/.local/bin/env` (uv 가 만듦) 가 없을 때 `.` 명령이 에러를 내며 그 자체로는 후속 안 막지만 환경이 어그러질 수 있음. → install.sh 가 uv 도 설치.
- **Opt+Arrow**: ghostty `macos-option-as-alt = true` 가 두 곳 (`~/.config/ghostty/config` + Application Support `config.ghostty`) 모두에 있어야 안전 — Ghostty 가 두 경로를 다 읽음. → 둘 다 repo 에 포함.
- **tmux extended-keys**: 활성화 시 Claude Code 이미지 paste 깨짐 (Issue #43169). → 주석 처리된 상태가 정답.

## 검증

설치 후 다음을 확인:

```bash
# 폰트
fc-list 2>/dev/null | grep -E "(JetBrains Mono|D2Coding)" \
  || system_profiler SPFontsDataType | grep -E "(JetBrainsMono|D2Coding)"

# zsh plugins
ls /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ls /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# uv env
ls ~/.local/bin/env

# 키바인딩 (zsh 안에서)
bindkey | grep -E "shift-select"
```

## Uninstall / 롤백

```bash
# install.sh 실행 시 출력된 백업 디렉토리 사용
ls ~/.dotfiles-backup-*
cp -a ~/.dotfiles-backup-<timestamp>/. ~/
```
