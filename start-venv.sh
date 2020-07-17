#!/usr/bin/env bash

source ~/.local/bin/shell-utils.sh

if [ "$1" == "" ]; then
  # export TMUX_SESSION="dev"
  export TMUX_SESSION=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1)
else
  export TMUX_SESSION=$1
fi
echo 'TMUX_SESSION='$TMUX_SESSION

# Cet WINDOW ID (Default: Active WINDOW)
if [ "$2" == "" ]; then
  export TMUX_WINDOW_ID=$(tmux display-message -p '#I')
else
  export TMUX_WINDOW_ID=$2
fi
echo 'TMUX_WINDOW_ID='$TMUX_WINDOW_ID

# Get Total Panes in window
if [ "$3" == "" ]; then
  export WINDOW_PANES=3
else
  export WINDOW_PANES=$3
fi
########################################################

tmux has-session -t $TMUX_SESSION
if [ $? == 0 ]; then

  #================================================================
  # editor window
  #================================================================
  # win_id=1
  # target="${TMUX_SESSION}:${win_id}"
  #
  # # startup venv
  # show_msg $target "Start VENV in editor window (${target})..."
  # start_venv $target

  #================================================================
  # run window
  #================================================================
  win_id=$TMUX_WINDOW_ID
  panes=$WINDOW_PANES
  clear
  for (( i=1; i<=${panes}; i++ ))
  do
    target="${TMUX_SESSION}:${win_id}.${i}"

    # startup venv
    show_msg $target "Start VENV in run window (${target})..."
    start_venv $target 
  done
fi

tmux attach -t $TMUX_SESSION
