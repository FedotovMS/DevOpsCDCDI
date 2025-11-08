#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# Helpers
# ---------------------------
log()   { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERR ]\033[0m $*"; }

need_cmd() { command -v "$1" &>/dev/null; }

require_root_or_sudo() {
  if [[ $EUID -ne 0 ]] && ! need_cmd sudo; then
    error "Потрібні привілеї root або встановлений sudo."
    exit 1
  fi
}

SUDO=""
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo"
fi

# ---------------------------
# OS check
# ---------------------------
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) log "Виявлено ${PRETTY_NAME}";;
    *) warn "Непідтримуваний дистрибутив: ${PRETTY_NAME:-unknown}. Спробую продовжити."; ;;
  esac
else
  warn "/etc/os-release не знайдено. Продовжую без перевірки ОС."
fi

# ---------------------------
# apt update (один раз)
# ---------------------------
apt_updated=0
apt_update_once() {
  if [[ $apt_updated -eq 0 ]]; then
    log "Оновлюю індекс пакетів (apt update)…"
    $SUDO apt-get update -y
    apt_updated=1
  fi
}

# ---------------------------
# Docker
# ---------------------------
install_docker() {
  if need_cmd docker; then
    log "Docker вже встановлено: $(docker --version)"
  else
    log "Встановлюю Docker (docker.io)…"
    apt_update_once
    $SUDO apt-get install -y docker.io
    $SUDO systemctl enable --now docker
    log "Docker встановлено: $(docker --version)"
  fi

  # Додати поточного користувача до групи docker (для запуску без sudo)
  if getent group docker >/dev/null 2>&1; then
    if id -nG "$USER" | grep -qw docker; then
      log "Користувач '$USER' вже у групі docker."
    else
      log "Додаю користувача '$USER' до групи docker…"
      $SUDO usermod -aG docker "$USER" || warn "Не вдалося додати користувача до групи docker."
      warn "Щоб зміни набрали чинності, потрібно перелогінитися."
    fi
  fi
}

# ---------------------------
# Docker Compose (плагін v2)
# ---------------------------
install_docker_compose() {
  if docker compose version >/dev/null 2>&1; then
    log "Docker Compose (v2 plugin) вже встановлено: $(docker compose version | head -n1)"
    return
  fi

  # Також підтримай старий бінарник docker-compose, якщо раптом він є
  if need_cmd docker-compose; then
    log "Знайдено docker-compose (legacy): $(docker-compose --version)"
    return
  fi

  log "Встановлюю docker-compose-plugin…"
  apt_update_once
  $SUDO apt-get install -y docker-compose-plugin
  if docker compose version >/dev/null 2>&1; then
    log "Docker Compose встановлено: $(docker compose version | head -n1)"
  else
    warn "Плагін docker compose недоступний. Спробую встановити legacy docker-compose…"
    $SUDO apt-get install -y docker-compose || error "Не вдалося встановити Docker Compose."
    need_cmd docker-compose && log "Встановлено: $(docker-compose --version)"
  fi
}

# ---------------------------
# Python (>= 3.9) + pip
# ---------------------------
python_bin=""
ensure_python() {
  local min_major=3
  local min_minor=9

  # Кандидати на інтерпретатор (спочатку системний, далі новіші)
  local candidates=(python3 python3.12 python3.11 python3.10 python3.9)

  for bin in "${candidates[@]}"; do
    if need_cmd "$bin"; then
      local ver
      ver=$("$bin" -V 2>&1 | awk '{print $2}')
      local major minor
      major=$(echo "$ver" | cut -d. -f1)
      minor=$(echo "$ver" | cut -d. -f2)
      if (( major > min_major )) || { (( major == min_major )) && (( minor >= min_minor )); }; then
        python_bin="$bin"
        log "Знайдено $bin ($ver) — придатно."
        break
      fi
    fi
  done

  if [[ -z "$python_bin" ]]; then
    log "Потрібен Python >= 3.9. Встановлюю python3 та залежності…"
    apt_update_once
    $SUDO apt-get install -y python3 python3-pip python3-venv
    if need_cmd python3; then
      local ver
      ver=$(python3 -V 2>&1 | awk '{print $2}')
      local major minor
      major=$(echo "$ver" | cut -d. -f1)
      minor=$(echo "$ver" | cut -d. -f2)
      if (( major > min_major )) || { (( major == min_major )) && (( minor >= min_minor )); }; then
        python_bin="python3"
        log "Встановлено Python $ver"
      else
        # Спроба поставити новішу версію, якщо доступна у репозиторіях
        warn "Системний python3 ($ver) < 3.9. Спробую встановити оновлену версію (python3.11/3.10/3.9)…"
        for pkg in python3.12 python3.11 python3.10 python3.9; do
          if apt-cache policy "$pkg" | grep -q Candidate; then
            $SUDO apt-get install -y "$pkg"
            if need_cmd "${pkg}"; then
              python_bin="${pkg}"
              log "Встановлено ${pkg} ($(${pkg} -V | awk '{print $2}'))"
              break
            fi
          fi
        done
        if [[ -z "$python_bin" ]]; then
          error "Не вдалося отримати Python 3.9+ із репозиторіїв. Встанови вручну (наприклад, із PPA або backports) і перезапусти скрипт."
          exit 1
        fi
      fi
    else
      error "Python не встановлено і не знайдено в репозиторіях."
      exit 1
    fi
  fi

  # Переконаймось, що є pip для обраного python
  if ! "$python_bin" -m pip --version >/dev/null 2>&1; then
    log "Встановлюю pip для $python_bin…"
    apt_update_once
    $SUDO apt-get install -y python3-pip || true
    if ! "$python_bin" -m pip --version >/dev/null 2>&1; then
      warn "pip все ще недоступний для $python_bin. Спробую встановити пакет python3-pip та повторити."
      $SUDO apt-get install -y python3-pip
      "$python_bin" -m pip --version >/dev/null 2>&1 || {
        error "Не вдалося підготувати pip для $python_bin."
        exit 1
      }
    fi
  fi
}

# ---------------------------
# Django (через pip)
# ---------------------------
install_django() {
  local PY="$python_bin"

  if "$PY" -m django --version >/dev/null 2>&1; then
    log "Django вже встановлено: версія $("$PY" -m django --version)"
    return
  fi

  log "Встановлюю Django через pip…"
  # Якщо root — ставимо глобально; інакше — в користувача
  if [[ $EUID -eq 0 ]]; then
    "$PY" -m pip install -U pip
    "$PY" -m pip install Django
  else
    "$PY" -m pip install -U --user pip
    "$PY" -m pip install --user Django
    # Додати ~/.local/bin до PATH при необхідності
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      warn "Django встановлено у ~/.local/bin. Додай до PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
  fi

  log "Django встановлено: версія $("$PY" -m django --version)"
}

# ---------------------------
# Run
# ---------------------------
require_root_or_sudo
install_docker
install_docker_compose
ensure_python
install_django

log "✅ Усе готово! Docker / Docker Compose / Python / Django встановлені або вже були встановлені."