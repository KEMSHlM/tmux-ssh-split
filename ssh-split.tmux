#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local raw_value

  raw_value=$(tmux show-option -gqv "$option")

  echo "${raw_value:-$default_value}"
}

main() {
  local -a extra_args
  local current_dir
  local fail
  local hkey
  local noenv
  local noshell
  local script_path
  local verbose
  local debug
  local vkey
  local wkey
  local keep_cwd
  local keep_remote_cwd
  local rkey

  debug="$(get_tmux_option @ssh-split-debug)"
  verbose="$(get_tmux_option @ssh-split-verbose)"
  fail="$(get_tmux_option @ssh-split-fail)"
  keep_cwd="$(get_tmux_option @ssh-split-keep-cwd)"
  keep_remote_cwd="$(get_tmux_option @ssh-split-keep-remote-cwd)"
  noenv="$(get_tmux_option @ssh-split-no-env)"
  noshell="$(get_tmux_option @ssh-split-no-shell)"
  stripcmd="$(get_tmux_option @ssh-split-strip-cmd)"
  hkey="$(get_tmux_option @ssh-split-h-key)"
  vkey="$(get_tmux_option @ssh-split-v-key)"
  wkey="$(get_tmux_option @ssh-split-w-key)"
  rkey="$(get_tmux_option @ssh-split-r-key)"

  case "$keep_cwd" in
    true|1|yes)
      # Double quote path since it may contain spaces.
      # Especially when the current dir gets deleted, tmux then
      # appends " (removed)"
      extra_args+=(-c "'#{pane_current_path}'")
      ;;
  esac

  case "$keep_remote_cwd" in
    true|1|yes)
      extra_args+=(--keep-remote-cwd)
      ;;
  esac

  case "$fail" in
    true|1|yes)
      extra_args+=(--fail)
      ;;
  esac

  case "$noenv" in
    true|1|yes)
      extra_args+=(--no-env)
      ;;
  esac

  case "$noshell" in
    true|1|yes)
      extra_args+=(--no-shell)
      ;;
  esac

  case "$stripcmd" in
    true|1|yes)
      extra_args+=(--strip-cmd)
      ;;
  esac

  case "$verbose" in
    true|1|yes)
      extra_args+=(--verbose)
      ;;
  esac

  case "$debug" in
    true|1|yes)
      extra_args+=(--debug)
      ;;
  esac

  current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  script_path="${current_dir}/scripts/tmux-ssh-split.sh"

  if [[ -n "$hkey" ]]
  then
    tmux unbind "$hkey"
    tmux bind-key "$hkey" run "${script_path} ${extra_args[*]} -h"
  fi

  if [[ -n "$vkey" ]]
  then
    tmux unbind "$vkey"
    tmux bind-key "$vkey" run "${script_path} ${extra_args[*]} -v"
  fi

  if [[ -n "$wkey" ]]
  then
    tmux unbind "$wkey"
    tmux bind-key "$wkey" run "${script_path} ${extra_args[*]} --window"
  fi

  if [[ -n "$rkey" ]]
  then
    tmux unbind "$rkey"
    tmux bind-key "$rkey" run "${script_path} ${extra_args[*]} --respawn"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  main
fi

# vim: set ft=bash et ts=2 sw=2 :
