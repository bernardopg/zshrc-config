# -*- mode: zsh; sh-shell: zsh; -*-
# ~/.zshrc – UNIVERSAL (Linux, WSL, MSYS2, Cygwin, Git-Bash)

# -----------------------------------------------------------
# 0) Profiling (uncomment to debug load-time)
# -----------------------------------------------------------
# zmodload zsh/zprof 2>/dev/null

# -----------------------------------------------------------
# 1) Private environment (API keys, etc.) – keep OUT of repo
# -----------------------------------------------------------
[[ -f ~/.config/private/env.zsh ]] && source ~/.config/private/env.zsh

# -----------------------------------------------------------
# 2) XDG base dirs
# -----------------------------------------------------------
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_STATE_HOME:=$HOME/.local/state}
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_STATE_HOME/zsh" 2>/dev/null

# Ruby gems config - disable documentation generation
[[ ! -f ~/.gemrc ]] && echo "gem: --no-document" > ~/.gemrc

# -----------------------------------------------------------
# 3) History – multi-terminal, no dupes, monthly rotate
# -----------------------------------------------------------
export HISTFILE=${XDG_STATE_HOME}/zsh/history-$(date +%Y-%m)
export HISTSIZE=100000
export SAVEHIST=100000
setopt INC_APPEND_HISTORY_TIME SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE

# -----------------------------------------------------------
# 4) Shell behaviour
# -----------------------------------------------------------
setopt PROMPT_SUBST INTERACTIVE_COMMENTS AUTO_CD EXTENDED_GLOB NO_BEEP NOTIFY
# Only enable line-editor dependent options when a TTY is present
if [[ -t 0 || -t 1 ]]; then
  setopt CORRECT CORRECT_ALL
  bindkey -e
fi
SPROMPT='zsh: %R → %r ? [Nyae] '

# -----------------------------------------------------------
# 5) PATH dedup + Windows (MSYS2 / Git-Bash) extras
# -----------------------------------------------------------
typeset -U path
# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"

path=(
    $HOME/.local/bin
    $HOME/bin
    $HOME/.cargo/bin
    $HOME/.npm-global/bin
    $PNPM_HOME
    $HOME/.local/share/gem/ruby/3.3.0/bin
    $HOME/Scripts
    $HOME/dev/tools/flutter/bin
    $path
)
[[ -d /mingw64/bin ]] && path+=( /mingw64/bin )
[[ -d /c/Program\ Files/Docker/Docker/resources/bin ]] && path+=( /c/Program\ Files/Docker/Docker/resources/bin )
export PATH

# -----------------------------------------------------------
# 6) Colors
# -----------------------------------------------------------
autoload -Uz colors && colors

# -----------------------------------------------------------
# 7) Platform detection
# -----------------------------------------------------------
WSL=0
[[ -f /proc/version ]] && grep -qi microsoft /proc/version && WSL=1
export WSL

# -----------------------------------------------------------
# 8) True-color auto-detection
# -----------------------------------------------------------
[[ $COLORTERM = truecolor || $TERM = *256* ]] && {
    export TERM=xterm-256color
    export BAT_THEME=TwoDark
}

# -----------------------------------------------------------
# 9) Oh-My-Zsh (optional)
# -----------------------------------------------------------
if [[ -d ${ZSH:-$HOME/.oh-my-zsh} ]]; then
    export ZSH=$HOME/.oh-my-zsh
    export ZSH_CACHE_DIR=${XDG_CACHE_HOME}/zsh/omx-cache
    export ZSH_COMPDUMP=${XDG_CACHE_HOME}/zsh/omx-compdump
    ZSH_THEME="robbyrussell"
    plugins=(git fzf colored-man-pages command-not-found history-substring-search zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    source $ZSH/oh-my-zsh.sh
else
    autoload -Uz compinit
    zstyle ':completion:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*' use-cache yes
    zstyle ':completion:*' cache-path ${XDG_CACHE_HOME}/zsh/zcompcache
    compinit -d ${XDG_CACHE_HOME}/zsh/zcompdump
fi

# -----------------------------------------------------------
# 10) Bash completions (AdGuard, etc.)
# -----------------------------------------------------------
autoload -U +X bashcompinit && bashcompinit
for f in /opt/adguard-cli/bash-completion.sh /opt/adguardvpn_cli/bash-completion.sh; do
    [[ -r $f ]] && source $f
done

# -----------------------------------------------------------
# 11) FZF + FD
# -----------------------------------------------------------
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# Add true-color settings if supported
[[ $COLORTERM = truecolor || $TERM = *256* ]] && {
    FZF_DEFAULT_OPTS+=" --color=16,bg+:238,preview-bg:235"
}
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# -----------------------------------------------------------
# 12) Aliases universais
# -----------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lh'
    alias la='eza -lha'
else
    alias ls='ls --color=auto -F'
    alias ll='ls -lh --group-directories-first'
    alias la='ls -lha --group-directories-first'
fi
alias l='ls'
alias ..='cd ..'
alias ...='cd ../..'
alias cp='cp -iv --reflink=auto'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias wget='wget -c'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'
alias serve='python3 -m http.server 8080'
alias json='python3 -m json.tool'
alias urlencode='python3 -c "import sys,urllib.parse as u; print(u.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys,urllib.parse as u; print(u.unquote_plus(sys.argv[1]))"'
alias gh='history -i | grep'
alias path='echo $PATH | tr ":" "\n"'
[[ -x $HOME/platformio-env/bin/pio ]] && alias pio=$HOME/platformio-env/bin/pio

# -----------------------------------------------------------
# 13) Funções úteis
# -----------------------------------------------------------
mkcd() { mkdir -p "$1" && cd "$1"; }
bk() { cp -f "$1" "$1.bak"; }
ff() { command find . -type f -iname "*$1*" 2>/dev/null; }
hist() { (( $# )) && history | grep -- "$*" || history; }
extract() {
    [[ -f $1 ]] || { echo "'$1' não é um arquivo válido"; return 1; }
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar e "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.zip) unzip -o "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *.xz) unxz "$1" ;;
        *.lzma) unlzma "$1" ;;
        *) echo "'$1' não pode ser extraído" ;;
    esac
}
killport() {
    local port=$1
    [[ -z $port ]] && { echo "Uso: killport <porta>"; return 1; }
    if command -v lsof >/dev/null; then
        lsof -ti ":$port" | xargs -r kill -9
    elif command -v netstat >/dev/null; then
        netstat -ano | awk -v p=$port '$2==p {print $1}' | xargs -r kill -9
    else
        echo "lsof/netstat não encontrado"; return 1
    fi
}

# -----------------------------------------------------------
# 14) Prompt com git minimal
# -----------------------------------------------------------
git_info() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local b=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -n $b ]] && print -n " (%F{green}$b%f)"
}
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f$(git_info) %# '

# -----------------------------------------------------------
# 15) Modern tools
# -----------------------------------------------------------
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

if ! alias cat >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1; then
        alias cat='bat --paging=never'
    elif command -v batcat >/dev/null 2>&1; then
        alias bat='batcat'
        alias cat='bat --paging=never'
    fi
fi
if ! alias fd >/dev/null 2>&1; then
    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        alias fd='fdfind'
    fi
fi

# -----------------------------------------------------------
# 16) Keybindings
# -----------------------------------------------------------
if [[ -t 0 || -t 1 ]]; then
  if (( $+functions[history-substring-search-up] )); then
      [[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
      [[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
  fi
  bindkey -M menuselect '^M' .accept-line
fi
setopt NO_LIST_BEEP

# -----------------------------------------------------------
# 17) SSH-Agent auto-start (non-blocking)
# -----------------------------------------------------------
[[ -z $SSH_AUTH_SOCK ]] && command -v ssh-agent >/dev/null && {
    eval $(ssh-agent -s -t 12h) >/dev/null
    (ssh-add -q ~/.ssh/id_ed25519 ~/.ssh/id_rsa 2>/dev/null &)
}

# -----------------------------------------------------------
# 18) GPG TTY
# -----------------------------------------------------------
export GPG_TTY=$TTY

# -----------------------------------------------------------
# 19) Docker / Podman env
# -----------------------------------------------------------
export DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain
export PODMAN_USERNS=keep-id

# -----------------------------------------------------------
# 20) Pipx ensure-path only once
# -----------------------------------------------------------
[[ -f $XDG_STATE_HOME/zsh/pipx-ensured ]] || {
    pipx ensurepath 2>/dev/null && touch $XDG_STATE_HOME/zsh/pipx-ensured
}

# -----------------------------------------------------------
# 21) UPDATE FUNCTION v2.1 + IMPROVEMENTS
# -----------------------------------------------------------

update() {
  emulate -L zsh -o nounset -o pipefail
  setopt localtraps

  # ---------- CONFIG ----------
  local -r VERSION="2.1.0"
  local -r STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sysupdate"
  local -r LOG_DIR="$STATE_DIR/logs"
  local -r CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sysupdate"

  local LOGFILE="" ; local -i LOG_REDIR_ACTIVE=0
  local -i LOG_KEEP=${SYSUPDATE_LOG_KEEP:-10} \
           KERNELS_KEEP=${SYSUPDATE_KERNELS_KEEP:-2} \
           MAX_RETRIES=${SYSUPDATE_MAX_RETRIES:-3} \
           TIMEOUT=${SYSUPDATE_TIMEOUT:-300} \
           VERBOSE=${SYSUPDATE_VERBOSE:-0}

  local -i dryrun=0 quiet=0 force=0 cleanup=0 interactive=1 low_data=0 \
           include_phased=0 security_only=0 show_stats=1
  local -a include_managers=() exclude_managers=()
  local scope="all"

  # ---------- COLORS ----------
  local -A colors
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    colors=(
      [reset]="$(tput sgr0)" [bold]="$(tput bold)" [dim]="$(tput dim)"
      [red]="$(tput setaf 1)" [green]="$(tput setaf 2)" [yellow]="$(tput setaf 3)"
      [blue]="$(tput setaf 4)" [magenta]="$(tput setaf 5)" [cyan]="$(tput setaf 6)"
    )
  else
    colors=([reset]="" [bold]="" [dim]="" [red]="" [green]="" [yellow]="" [blue]="" [magenta]="" [cyan]="")
  fi

  # ---------- LOGGING ----------
  log_init() {
    mkdir -p "$LOG_DIR" "$CACHE_DIR"
    chmod 700 "$STATE_DIR" 2>/dev/null
    local timestamp="$(date +%Y%m%d-%H%M%S)"
    LOGFILE="$LOG_DIR/sysupdate-$timestamp.log"
    if (( ! dryrun )); then
      exec 3>&1 4>&2
      exec 1> >(tee -a "$LOGFILE")
      exec 2> >(tee -a "$LOGFILE" >&2)
      LOG_REDIR_ACTIVE=1
      trap update__sig_cleanup INT TERM
    fi
  }
  log_rotate() {
    local -a logs=("$LOG_DIR"/sysupdate-*.log(.N))
    if (( ${#logs} > LOG_KEEP )); then
      local -i to_remove=$((${#logs} - LOG_KEEP))
      for ((i=1; i<=to_remove; i++)); do rm -f "${logs[i]}"; done
    fi
  }

  msg() { (( quiet )) || echo "${colors[green]}►${colors[reset]} $*"; }
  info() { (( quiet )) || echo "${colors[blue]}ℹ${colors[reset]} $*"; }
  warn() { echo "${colors[yellow]}⚠${colors[reset]} $*" >&2; }
  error() { echo "${colors[red]}✖${colors[reset]} $*" >&2; }
  success() { (( quiet )) || echo "${colors[green]}✓${colors[reset]} $*"; }
  section() { (( quiet )) && return; echo ""; echo "${colors[bold]}${colors[cyan]}═══ $* ═══${colors[reset]}"; }

  # ---------- SPINNER (FIXED) ----------
  local spinner_pid=0
  spinner_start() {
    (( quiet || dryrun )) && return
    ( while true; do
        for s in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏; do
          printf "\r${colors[cyan]}%s${colors[reset]} $1..." "$s"
          sleep 0.1
        done
      done ) &
    spinner_pid=$!
    # Ensure spinner doesn't print job control messages
    disown $spinner_pid 2>/dev/null
  }
  spinner_stop() {
    if (( spinner_pid > 0 )); then
      kill $spinner_pid 2>/dev/null
      wait $spinner_pid 2>/dev/null
      spinner_pid=0
      printf "\r\033[K"
    fi
  }

  # ---------- CLEANUP ----------
  update__cleanup() {
    spinner_stop
    [[ -n "${sudo_pid:-}" ]] && kill $sudo_pid 2>/dev/null
    if (( LOG_REDIR_ACTIVE )); then
      exec 1>&3 2>&4
      exec 3>&- 4>&-
      LOG_REDIR_ACTIVE=0
    fi
  }
  update__sig_cleanup() { update__cleanup; return 130; }

  # ---------- RETRY w/ EXPONENTIAL BACKOFF ----------
  run_cmd() {
    local cmd="$1" retries=${2:-$MAX_RETRIES} i=0 ret=0
    while (( ++i <= retries )); do
      if (( dryrun )); then
        info "[DRY-RUN] Would execute: $cmd"; return 0
      fi
      if eval "$cmd" 2>/dev/null; then
        return 0
      fi
      ret=$?
      (( i < retries )) && sleep $(( 2 ** (i-1) ))
    done
    return $ret
  }

  # ---------- ARGUMENT PARSING ----------
  while (( $# )); do
    case "$1" in
      -n|--dry-run) dryrun=1 ;;
      -y|--yes) interactive=0 ;;
      -q|--quiet) quiet=1; show_stats=0 ;;
      -v|--verbose) VERBOSE=1 ;;
      -f|--force) force=1 ;;
      --all) scope="all" ;;
      --system) scope="system" ;;
      --dev) scope="dev" ;;
      --lang) scope="lang" ;;
      --frameworks) scope="frameworks" ;;
      --only) shift; IFS=',' read -A include_managers <<< "$1" ;;
      --exclude) shift; IFS=',' read -A exclude_managers <<< "$1" ;;
      --include-phased) include_phased=1 ;;
      --security-only) security_only=1 ;;
      --cleanup) cleanup=1 ;;
      --low-data) low_data=1 ;;
      --kernels-keep) shift; KERNELS_KEEP="$1" ;;
      --max-retries) shift; MAX_RETRIES="$1" ;;
      --timeout) shift; TIMEOUT="$1" ;;
      --log-keep) shift; LOG_KEEP="$1" ;;
      --no-stats) show_stats=0 ;;
      -h|--help)
        cat <<'HELP'
Universal System Update Function v2.1+
Usage: update [options]
  -n --dry-run      Simulate
  -y --yes          Non-interactive
  -q --quiet        Minimal output
  -v --verbose      Detailed
  -f --force        Continue on warnings
  --low-data        Skip bandwidth-heavy steps
  --cleanup         Clean caches / old kernels
  --security-only   Security updates only
  --only apt,npm    Update only listed managers
  --exclude snap    Skip listed managers
  -h --help         This help
HELP
        return 0 ;;
      --) shift; break ;;
      *) error "Unknown option: $1"; return 2 ;;
    esac
    shift
  done

  # ---------- PRE-FLIGHT ----------
  log_init
  [[ -f /etc/os-release ]] && {
    local os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    [[ $os_id != "ubuntu" && $os_id != "debian" && -z $force ]] && {
      warn "Optimised for Debian/Ubuntu (found: $os_id). Use --force to run anyway."
      update__cleanup; return 1
    }
  }

  local sudo=''
  if (( EUID != 0 )); then
    if command -v sudo >/dev/null; then
      sudo='sudo'
      if (( ! dryrun )); then
        msg "Requesting administrative privileges..."
        $sudo -v || { error "Failed to obtain sudo"; return 1; }
        # Suppress job control messages
        setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
        ( while true; do $sudo -v; sleep 50; done ) &!
        local sudo_pid=$!
      fi
    else
      error "Root privileges required. Install sudo or run as root."
      update__cleanup; return 1
    fi
  fi

  export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
  local -a envv=(DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=none)

  # ---------- MANAGER DETECTION ----------
  local -A available_managers
  local -a active_managers

  detect_managers() {
    # System
    command -v apt-get >/dev/null  && available_managers[apt]=1
    command -v snap >/dev/null && [[ -d /run/systemd/system ]] && available_managers[snap]=1
    command -v flatpak >/dev/null && available_managers[flatpak]=1
    command -v brew >/dev/null && available_managers[brew]=1
    command -v nix-env >/dev/null && available_managers[nix]=1
    # Languages
    if [[ ${SYSUPDATE_SKIP_PIP:-1} != 1 ]] && command -v pip3 >/dev/null; then
      available_managers[pip]=1
    fi
    command -v pipx >/dev/null && available_managers[pipx]=1
    command -v npm >/dev/null && available_managers[npm]=1
    # Only enable yarn if it's actually functional (not broken Corepack)
    command -v yarn >/dev/null && yarn --version &>/dev/null && available_managers[yarn]=1
    command -v pnpm >/dev/null && available_managers[pnpm]=1
    command -v cargo >/dev/null && available_managers[cargo]=1
    command -v rustup >/dev/null && available_managers[rust]=1
    command -v gem >/dev/null && available_managers[gem]=1
    command -v composer >/dev/null && available_managers[composer]=1
    command -v go >/dev/null && available_managers[go]=1
    command -v flutter >/dev/null && available_managers[flutter]=1
    # Dev tools
    command -v docker >/dev/null && available_managers[docker]=1
    command -v podman >/dev/null && available_managers[podman]=1
    command -v conda >/dev/null && available_managers[conda]=1
    command -v mamba >/dev/null && available_managers[mamba]=1
    command -v asdf >/dev/null && available_managers[asdf]=1
    [[ -s $HOME/.sdkman/bin/sdkman-init.sh ]] && available_managers[sdkman]=1
    # Shell frameworks
    [[ -d ${ZSH:-$HOME/.oh-my-zsh} ]] && available_managers[ohmyzsh]=1
    command -v antigen >/dev/null && available_managers[antigen]=1
    [[ -d ${ZINIT_HOME:-$HOME/.zinit} ]] && available_managers[zinit]=1
    # Firmware
    command -v fwupdmgr >/dev/null && available_managers[firmware]=1
    # PlatformIO
    [[ -x $HOME/platformio-env/bin/pio ]] && available_managers[platformio]=1

    # Scope filter
    case "$scope" in
      system)   active_managers=(apt snap flatpak brew nix firmware) ;;
      dev)      active_managers=(docker podman conda mamba asdf sdkman platformio) ;;
      lang)     active_managers=(pip pipx npm yarn pnpm cargo rust gem composer go flutter) ;;
      frameworks) active_managers=(ohmyzsh antigen zinit) ;;
      all|*)    active_managers=(${(k)available_managers}) ;;
    esac

    # Include / exclude
    if (( ${#include_managers} )); then
      local -a filtered=()
      for mgr in "${include_managers[@]}"; do
        [[ -n ${available_managers[$mgr]} ]] && filtered+=($mgr)
      done
      active_managers=(${filtered})
    fi
    if (( ${#exclude_managers} )); then
      for mgr in "${exclude_managers[@]}"; do
        active_managers=(${active_managers[@]:#$mgr})
      done
    fi
  }

  detect_managers
  (( ${#active_managers} )) || { warn "No package managers selected"; update__cleanup; return 0 }

  # ---------- STATS ----------
  local -A stats=( [start_time]=$(date +%s) [updated]=0 [errors]=0 )

  # ---------- UPDATE HANDLERS ----------
  update_apt() {
    section "APT Package Manager"
    [[ $low_data = 1 ]] && { info "Low-data mode: skipping APT"; return 0; }

    # Validate apt-get is available
    if ! command -v apt-get >/dev/null 2>&1; then
      error "apt-get not found"; return 1
    fi

    # locks
    local -a locks=(/var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock)
    local -i tries=30
    spinner_start "Waiting for APT locks"
    while (( tries-- )) && { $sudo fuser "${locks[@]}" &>/dev/null || pgrep -x '(apt|dpkg)' &>/dev/null; }; do sleep 2; done
    spinner_stop
    (( tries )) || { error "APT locks timed out"; return 1; }

    # parallel + low-data friendly
    local apt_opts="-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
    apt_opts+=" -o Acquire::Queue-Mode=access -o Acquire::Retries=3 -o Acquire::https::Timeout=60"
    (( include_phased )) && apt_opts+=" -o APT::Get::Always-Include-Phased-Updates=true"

    msg "Updating package lists..."
    if (( dryrun )); then
      info "[DRY-RUN] apt-get update"; else
      local out=$($sudo env "${envv[@]}" apt-get update -o Acquire::Retries=3 2>&1)
      echo "$out" | grep -vE '^(Hit|Get|Fetched|Reading)'

      # Check for duplicate sources
      if echo "$out" | grep -q "is configured multiple times"; then
        warn "Duplicate APT sources detected!"
        local -a dupes=($(echo "$out" | grep "is configured multiple times" | grep -oP '/etc/apt/sources\.list\.d/[^ ]+' | sort -u))
        if (( ${#dupes} )); then
          warn "Files with duplicates: ${dupes[@]}"
          warn "Fix: Check /etc/apt/sources.list.d/ for duplicate .list and .sources files"
          warn "Example: sudo rm /etc/apt/sources.list.d/warpdotdev.list  # if warpdotdev.sources exists"
        fi
      fi
    fi

    # broken packages
    if ! $sudo dpkg --audit &>/dev/null; then
      warn "Broken packages detected, fixing..."
      (( dryrun )) || $sudo env "${envv[@]}" apt-get -f install -y
    fi

    # upgrade
    if (( security_only )); then
      msg "Security updates only..."
      if command -v unattended-upgrade >/dev/null; then
        (( dryrun )) || $sudo unattended-upgrade -v
      else
        (( dryrun )) || $sudo env "${envv[@]}" apt-get upgrade -y -o Dir::Etc::SourceList=/etc/apt/security.sources.list
      fi
    else
      if (( dryrun )); then
        msg "Simulating full upgrade..."
        $sudo env "${envv[@]}" apt-get -s full-upgrade $apt_opts
      else
        msg "Upgrading system packages..."
        $sudo env "${envv[@]}" apt-get full-upgrade -y $apt_opts
      fi
    fi

    # cleanup
    if (( cleanup )); then
      msg "Cleaning APT..."
      (( dryrun )) || { $sudo env "${envv[@]}" apt-get autoremove --purge -y
                        $sudo env "${envv[@]}" apt-get autoclean -y; }
      # kernels
      local current=$(uname -r)
      local -a kernels=($($sudo dpkg -l 'linux-image-[0-9]*' 2>/dev/null | awk '/^ii/ && $2 !~ current {print $2}' | sort -V | head -n -$KERNELS_KEEP))
      if (( ${#kernels} )); then
        msg "Removing old kernels (keep $KERNELS_KEEP)..."
        (( dryrun )) || $sudo apt-get remove --purge -y ${kernels[@]}
      fi
    fi
    success "APT updates completed"
  }

  update_snap() {
    section "Snap Package Manager"
    [[ $low_data = 1 ]] && { info "Low-data mode: skipping Snap"; return 0; }
    if (( dryrun )); then
      snap refresh --list 2>/dev/null || info "No snap updates available"
    else
      msg "Updating snap packages..."
      $sudo snap refresh
    fi
    success "Snap updates completed"
  }

  update_flatpak() {
    section "Flatpak Package Manager"
    [[ $low_data = 1 ]] && { info "Low-data mode: skipping Flatpak"; return 0; }
    if (( dryrun )); then
      flatpak remote-ls --updates 2>/dev/null || info "No flatpak updates available"
    else
      msg "Updating flatpak packages..."
      local out=$(flatpak update -y --noninteractive 2>&1)
      echo "$out"

      # Check for EOL runtimes
      if echo "$out" | grep -qi "fim de vida\|end of life\|eol"; then
        warn "End-of-life Flatpak runtimes detected!"
        local -a eol_runtimes=($(echo "$out" | grep -i "fim de vida\|end of life" | grep -oP 'org\.[a-zA-Z0-9._-]+' | sort -u))
        if (( ${#eol_runtimes} )); then
          warn "EOL runtimes: ${eol_runtimes[@]}"
          warn "These runtimes no longer receive security updates."
          warn "Action needed: Update apps using these runtimes or remove them."
          warn "List apps: flatpak list --app"
          warn "Check runtime: flatpak info <app-id>"
        fi
      fi

      if (( cleanup )); then
        msg "Removing unused runtimes..."
        flatpak uninstall --unused -y --noninteractive
      fi
    fi
    success "Flatpak updates completed"
  }

  update_pip() {
    section "Python Package Manager (pip)"
    # PEP 668 safe
    if python3 -c "import sys,sysconfig,os; sys.exit(os.access(sysconfig.get_path('purelib'),2))" 2>/dev/null; then
      info "System pip is externally managed – skipping (use pipx)."
      return 0
    fi
    msg "Updating pip..."
    run_cmd "python3 -m pip install --upgrade --user --quiet --break-system-packages pip"
    msg "Updating user pip packages..."
    local outdated=$(python3 -m pip list --outdated --user --format=json 2>/dev/null | jq -r '.[].name' 2>/dev/null)
    if [[ -n $outdated ]]; then
      for pkg in ${(f)outdated}; do
        run_cmd "python3 -m pip install --upgrade --user --quiet --break-system-packages \"$pkg\""
      done
    else
      info "All user pip packages up to date"
    fi
    success "pip updates completed"
  }

  update_pipx() {
    section "Python Application Manager (pipx)"
    if ! command -v pipx >/dev/null; then
      info "pipx not installed – skipping"; return 0
    fi
    if (( dryrun )); then
      msg "Would update pipx packages"
    else
      msg "Updating pipx packages..."
      local out=$(pipx upgrade-all 2>&1)
      if echo "$out" | grep -q "No packages upgraded"; then
        info "All pipx packages up to date"
      else
        echo "$out" | grep -E "(upgraded|Upgrading)" || true
      fi
    fi
    success "pipx updates completed"
  }

  update_npm() {
    section "Node Package Manager (npm)"
    export NPM_CONFIG_FUND=false NPM_CONFIG_AUDIT=false
    msg "Updating npm..."
    run_cmd "npm install -g npm@latest --quiet"
    if (( ! dryrun )); then
      msg "Updating global npm packages..."
      run_cmd "npm update -g --quiet"
      if (( cleanup )); then
        msg "Verifying npm cache..."
        run_cmd "npm cache verify"
      fi
    fi
    success "npm updates completed"
  }

  update_rust() {
    section "Rust Toolchain"
    if (( ! dryrun )); then
      msg "Updating rustup..."
      run_cmd "rustup self update"
      msg "Updating rust toolchain..."
      run_cmd "rustup update"
      if command -v cargo-binstall >/dev/null 2>&1; then
        msg "Using cargo-binstall where possible..."
        run_cmd "cargo binstall -y cargo-update"
      fi
      if command -v cargo-install-update >/dev/null 2>&1; then
        msg "Updating cargo packages..."
        run_cmd "cargo install-update -a"
      fi
    else
      msg "Would update rust toolchain"
    fi
    success "Rust updates completed"
  }

  update_ohmyzsh() {
    section "Oh My Zsh Framework"
    if (( ! dryrun )); then
      msg "Updating Oh My Zsh..."
      if command -v omz >/dev/null 2>&1; then
        run_cmd "omz update --unattended"
      elif [[ -f $ZSH/tools/upgrade.sh ]]; then
        run_cmd "env ZSH='$ZSH' sh '$ZSH/tools/upgrade.sh'"
      fi
    else
      msg "Would update Oh My Zsh"
    fi
    success "Oh My Zsh updates completed"
  }

  update_firmware() {
    section "System Firmware"
    [[ $WSL = 1 ]] && { info "WSL: skipping firmware"; return 0; }
    if (( ! dryrun )); then
      msg "Refreshing firmware metadata..."
      run_cmd "$sudo fwupdmgr refresh --force"
      if $sudo fwupdmgr get-updates &>/dev/null; then
        msg "Installing firmware updates..."
        run_cmd "$sudo fwupdmgr update -y"
      else
        info "No firmware updates available"
      fi
    else
      $sudo fwupdmgr get-updates 2>/dev/null || info "No firmware updates available"
    fi
    success "Firmware updates completed"
  }

  update_platformio() {
    section "PlatformIO"
    if (( ! dryrun )); then
      msg "Updating PlatformIO..."
      run_cmd "$HOME/platformio-env/bin/python -m pip install -U platformio"
      msg "Updating PlatformIO platforms and libraries..."
      run_cmd "$HOME/platformio-env/bin/pio pkg update --global"
    else
      msg "Would update PlatformIO"
    fi
    success "PlatformIO updates completed"
  }

  update_flutter() {
    section "Flutter SDK"
    if (( ! dryrun )); then
      msg "Updating Flutter..."
      run_cmd "flutter upgrade --force"
      msg "Updating Dart packages..."
      run_cmd "dart pub global upgrade"
    else
      msg "Would update Flutter SDK"
    fi
    success "Flutter updates completed"
  }

  update_yarn() {
    section "Yarn Package Manager"

    # Check if yarn is functional
    if ! command -v yarn >/dev/null 2>&1; then
      warn "Yarn not found - skipping"
      return 0
    fi

    if ! timeout 5 yarn --version &>/dev/null; then
      warn "Yarn appears to be misconfigured or broken (Corepack issue?)"
      info "Skipping yarn updates. To fix: npm install -g yarn or corepack enable"
      return 0
    fi

    if (( ! dryrun )); then
      msg "Updating yarn..."
      # Use --non-interactive and timeout to prevent hanging
      if timeout 120 yarn global upgrade --non-interactive 2>&1 | grep -v "warning"; then
        success "Yarn updates completed"
      else
        local ret=$?
        if (( ret == 124 )); then
          warn "Yarn upgrade timed out - skipping"
        else
          warn "Yarn upgrade failed - skipping"
        fi
        return 0
      fi
    else
      msg "Would update yarn packages"
      success "Yarn updates completed"
    fi
  }

  update_pnpm() {
    section "PNPM Package Manager"
    if (( ! dryrun )); then
      msg "Updating pnpm..."
      run_cmd "pnpm self-update"
      msg "Updating global pnpm packages..."
      run_cmd "pnpm update -g"
    else
      msg "Would update pnpm packages"
    fi
    success "PNPM updates completed"
  }

  update_cargo() {
    section "Cargo Package Manager"
    if command -v cargo-install-update >/dev/null 2>&1; then
      if (( ! dryrun )); then
        msg "Updating cargo packages..."
        run_cmd "cargo install-update -a"
      else
        msg "Would update cargo packages"
      fi
    else
      info "cargo-install-update not found"
      if (( ! dryrun )); then
        msg "Installing cargo-update..."
        if run_cmd "cargo install cargo-update"; then
          msg "Updating cargo packages..."
          run_cmd "cargo install-update -a"
        else
          warn "Failed to install cargo-update"
        fi
      else
        info "Install with: cargo install cargo-update"
      fi
    fi
    success "Cargo updates completed"
  }

  update_gem() {
    section "Ruby Gems"

    if ! timeout 5 gem --version &>/dev/null 2>&1; then
      warn "Ruby gem not found or unresponsive - skipping"
      return 0
    fi

    if (( ! dryrun )); then
      # Skip system update if RubyGems installed via APT
      if dpkg -l rubygems ruby-rubygems 2>/dev/null | grep -q '^ii'; then
        info "RubyGems installed via APT - skipping system update (use APT to upgrade)"
      else
        msg "Updating RubyGems system..."
        timeout 120 gem update --system --no-document --quiet 2>&1 | \
          grep -vE '(Parsing|Installing ri|Done|Successfully|Defaulting|WARNING|already initialized|previous definition)' | \
          grep -v '^$' || true
      fi

      msg "Updating installed gems..."
      local gems_output=$(timeout 300 gem update --no-document 2>&1 | \
        grep -vE '(warning:|already initialized|previous definition|Parsing|Installing ri|Done|Defaulting)' | \
        grep -E '^(Updating|Fetching|Building|Successfully installed)' | head -30)

      if [[ -n "$gems_output" ]]; then
        echo "$gems_output"
        if (( cleanup )); then
          msg "Cleaning old gem versions..."
          local clean_cmd="gem cleanup --quiet 2>&1"
          [[ -n "$sudo" ]] && clean_cmd="$sudo $clean_cmd"
          timeout 60 sh -c "$clean_cmd" | grep -vE '(Cleaning|Clean up|warning|already initialized|Skipped|Unable to uninstall|FilePermissionError)' | head -10 || true
        fi
      else
        info "All gems are up to date"
      fi
    else
      msg "Would update Ruby gems"
    fi
    success "Gem updates completed"
  }


  update_composer() {
    section "PHP Composer"
    if (( ! dryrun )); then
      msg "Updating composer..."
      run_cmd "composer self-update"
      msg "Updating global composer packages..."
      run_cmd "composer global update"
    else
      msg "Would update composer packages"
    fi
    success "Composer updates completed"
  }

  update_go() {
    section "Go Modules"
    if (( ! dryrun )); then
      msg "Updating Go tools..."
      # Update go itself if installed via go
      if command -v go >/dev/null && [[ -d $HOME/go/bin ]]; then
        local -a gotools=($(go list -f '{{.Path}}' -m all 2>/dev/null | grep '^.*/.*/.*$'))
        if (( ${#gotools} )); then
          for tool in "${gotools[@]}"; do
            run_cmd "go install ${tool}@latest"
          done
        fi
      fi
    else
      msg "Would update Go tools"
    fi
    success "Go updates completed"
  }

  update_docker() {
    section "Docker"
    if (( ! dryrun )); then
      msg "Pruning Docker system..."
      if (( cleanup )); then
        run_cmd "docker system prune -af --volumes"
      else
        run_cmd "docker system prune -f"
      fi
      msg "Pulling latest images for running containers..."
      local -a images=($(docker ps --format '{{.Image}}' | sort -u))
      for img in "${images[@]}"; do
        [[ $img != *:* ]] && img="${img}:latest"
        run_cmd "docker pull $img"
      done
    else
      msg "Would prune Docker and update images"
    fi
    success "Docker updates completed"
  }

  update_podman() {
    section "Podman"
    if (( ! dryrun )); then
      msg "Updating Podman images..."
      run_cmd "podman auto-update"
      if (( cleanup )); then
        msg "Pruning Podman system..."
        run_cmd "podman system prune -af --volumes"
      fi
    else
      msg "Would update Podman images"
    fi
    success "Podman updates completed"
  }

  update_brew() {
    section "Homebrew"
    if (( ! dryrun )); then
      msg "Updating Homebrew..."
      run_cmd "brew update"
      msg "Upgrading Homebrew packages..."
      run_cmd "brew upgrade"
      if (( cleanup )); then
        msg "Cleaning Homebrew..."
        run_cmd "brew cleanup"
        run_cmd "brew autoremove"
      fi
    else
      msg "Would update Homebrew packages"
    fi
    success "Homebrew updates completed"
  }

  update_nix() {
    section "Nix Package Manager"
    if (( ! dryrun )); then
      msg "Updating Nix channels..."
      run_cmd "nix-channel --update"
      msg "Upgrading Nix packages..."
      run_cmd "nix-env -u"
      if (( cleanup )); then
        msg "Collecting Nix garbage..."
        run_cmd "nix-collect-garbage -d"
      fi
    else
      msg "Would update Nix packages"
    fi
    success "Nix updates completed"
  }

  update_conda() {
    section "Conda Package Manager"
    if (( ! dryrun )); then
      msg "Updating conda..."
      run_cmd "conda update -n base -c defaults conda -y"
      msg "Updating conda packages..."
      run_cmd "conda update --all -y"
      if (( cleanup )); then
        msg "Cleaning conda..."
        run_cmd "conda clean --all -y"
      fi
    else
      msg "Would update conda packages"
    fi
    success "Conda updates completed"
  }

  update_mamba() {
    section "Mamba Package Manager"
    if (( ! dryrun )); then
      msg "Updating mamba..."
      run_cmd "mamba update -n base mamba -y"
      msg "Updating mamba packages..."
      run_cmd "mamba update --all -y"
      if (( cleanup )); then
        msg "Cleaning mamba..."
        run_cmd "mamba clean --all -y"
      fi
    else
      msg "Would update mamba packages"
    fi
    success "Mamba updates completed"
  }

  update_asdf() {
    section "ASDF Version Manager"
    if (( ! dryrun )); then
      msg "Updating asdf..."
      run_cmd "asdf update"
      msg "Updating asdf plugins..."
      run_cmd "asdf plugin update --all"
    else
      msg "Would update asdf and plugins"
    fi
    success "ASDF updates completed"
  }

  update_sdkman() {
    section "SDKMAN!"
    if (( ! dryrun )); then
      msg "Updating SDKMAN!..."
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      run_cmd "sdk selfupdate force"
      msg "Updating SDK candidates..."
      run_cmd "sdk update"
      # Upgrade installed versions
      local -a candidates=($(sdk list | grep -oP '(?<=\* )[a-z]+'))
      for candidate in "${candidates[@]}"; do
        run_cmd "sdk upgrade $candidate"
      done
    else
      msg "Would update SDKMAN! and candidates"
    fi
    success "SDKMAN! updates completed"
  }

  update_antigen() {
    section "Antigen Plugin Manager"
    if (( ! dryrun )); then
      msg "Updating Antigen..."
      run_cmd "antigen update"
      run_cmd "antigen selfupdate"
    else
      msg "Would update Antigen"
    fi
    success "Antigen updates completed"
  }

  update_zinit() {
    section "Zinit Plugin Manager"
    if (( ! dryrun )); then
      msg "Updating Zinit..."
      run_cmd "zinit self-update"
      msg "Updating Zinit plugins..."
      run_cmd "zinit update --all"
    else
      msg "Would update Zinit and plugins"
    fi
    success "Zinit updates completed"
  }

  # ---------- EXECUTION ----------
  (( quiet )) || {
    echo "${colors[bold]}${colors[cyan]}╔════════════════════════════════════════════════════════════════╗${colors[reset]}"
    echo "${colors[bold]}${colors[cyan]}║       Universal System Update v${VERSION} - $(date +%Y-%m-%d\ %H:%M:%S)       ║${colors[reset]}"
    echo "${colors[bold]}${colors[cyan]}╚════════════════════════════════════════════════════════════════╝${colors[reset]}"
    (( dryrun )) && echo "${colors[yellow]}${colors[bold]}⚠ DRY RUN MODE - No changes will be made${colors[reset]}"
    echo "${colors[dim]}Active package managers: ${active_managers[@]}${colors[reset]}"
    echo ""
  }

  for manager in "${active_managers[@]}"; do
    case "$manager" in
      apt) update_apt ;;
      snap) update_snap ;;
      flatpak) update_flatpak ;;
      pip) update_pip ;;
      pipx) update_pipx ;;
      npm) update_npm ;;
      yarn) update_yarn ;;
      pnpm) update_pnpm ;;
      cargo) update_cargo ;;
      rust) update_rust ;;
      gem) update_gem ;;
      composer) update_composer ;;
      go) update_go ;;
      flutter) update_flutter ;;
      docker) update_docker ;;
      podman) update_podman ;;
      brew) update_brew ;;
      nix) update_nix ;;
      conda) update_conda ;;
      mamba) update_mamba ;;
      asdf) update_asdf ;;
      sdkman) update_sdkman ;;
      ohmyzsh) update_ohmyzsh ;;
      antigen) update_antigen ;;
      zinit) update_zinit ;;
      firmware) update_firmware ;;
      platformio) update_platformio ;;
      *) (( VERBOSE )) && warn "Handler not implemented for: $manager" ;;
    esac
  done

  # ---------- POST-CHECKS ----------
  section "System Health Check"
  [[ -f /var/run/reboot-required ]] && {
    warn "System reboot required!"
    [[ -f /var/run/reboot-required.pkgs ]] && cat /var/run/reboot-required.pkgs
  }
  if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
    local failed=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
    (( failed > 0 )) && warn "Failed systemd services: $failed – run 'systemctl --failed'"
  fi

  # ---------- SUMMARY ----------
  stats[end_time]=$(date +%s)
  local dur=$((stats[end_time] - stats[start_time]))
  if (( show_stats && ! quiet )); then
    echo ""
    echo "${colors[bold]}${colors[green]}═══ Update Summary ═══${colors[reset]}"
    printf "Duration: %02d:%02d:%02d\n" $((dur/3600)) $((dur%3600/60)) $((dur%60))
    echo "Managers updated: ${#active_managers}"
    [[ -n $LOGFILE ]] && echo "Log saved to: ${colors[dim]}$LOGFILE${colors[reset]}"
    success "System update completed successfully!"
  fi
  update__cleanup
  return 0
}

# -----------------------------------------------------------
# 22) Completion for update
# -----------------------------------------------------------
_update_completion() {
    local -a opts managers
    opts=(
        '-n:Dry run' '--dry-run:Simulate' '-y:Non-interactive' '--yes:Auto-confirm'
        '-q:Quiet' '--quiet:Minimal output' '-v:Verbose' '--verbose:Detailed'
        '-f:Force' '--force:Continue on warnings' '-h:Help' '--help:Usage'
        '--all:Everything' '--system:System only' '--dev:Dev tools' '--lang:Languages'
        '--frameworks:Shell frameworks' '--low-data:Skip heavy downloads'
        '--include-phased:Phased updates' '--security-only:Security only'
        '--cleanup:Clean caches' '--no-stats:Skip summary'
    )
    managers=(apt snap flatpak brew nix pipx npm yarn pnpm cargo rust gem composer go flutter docker podman conda mamba asdf sdkman ohmyzsh antigen zinit platformio firmware)
    _arguments -C \
        '(--dry-run -n)'{-n,--dry-run}'[Simulate]' \
        '(--yes -y)'{-y,--yes}'[Non-interactive]' \
        '(--quiet -q)'{-q,--quiet}'[Minimal]' \
        '(--verbose -v)'{-v,--verbose}'[Detailed]' \
        '(--force -f)'{-f,--force}'[Force]' \
        '(--help -h)'{-h,--help}'[Help]' \
        '--all[Everything]' '--system[System]' '--dev[Dev]' '--lang[Lang]' '--frameworks[Frameworks]' \
        '--only[Only]:managers:(${managers})' '--exclude[Exclude]:managers:(${managers})' \
        '--low-data[Skip heavy downloads]' '--include-phased[Phased]' '--security-only[Security]' \
        '--cleanup[Clean]' '--kernels-keep[Keep]:number:' '--max-retries[Retries]:number:' \
        '--timeout[Timeout]:seconds:' '--log-keep[Logs]:number:' '--no-stats[Skip summary]'
}
compdef _update_completion update update_system up
alias update_system='update'
alias up='update'

# -----------------------------------------------------------
# 23) Fast reload + health
# -----------------------------------------------------------
reload-zsh() { exec zsh }
alias rz='reload-zsh'
zsh-health() {
  printf 'Cache: %s  PATH dirs: %d  History: %d  Zoxide: %s\n' \
    "$(du -sh $XDG_CACHE_HOME/zsh 2>/dev/null | cut -f1)" \
    ${#path} $(history -n | wc -l) \
    "$(command -v zoxide >/dev/null && echo ok || echo no)"
}

# -----------------------------------------------------------
# 24) Local overrides (last)
# -----------------------------------------------------------
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# -----------------------------------------------------------
# 25) Compile for speed
# -----------------------------------------------------------
if [[ ! -f ${ZDOTDIR:-$HOME}/.zshrc.zwc || ~/.zshrc -nt ${ZDOTDIR:-$HOME}/.zshrc.zwc ]]; then
    zcompile -R ${ZDOTDIR:-$HOME}/.zshrc.zwc ~/.zshrc 2>/dev/null
fi

# -----------------------------------------------------------
# 26) System info on new shell (optional - can slow down)
# -----------------------------------------------------------
# Uncomment to run fastfetch on shell start
# if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
#     [[ ! "${ZSH_EVAL_CONTEXT:-}" =~ "file" ]] && fastfetch
# fi
