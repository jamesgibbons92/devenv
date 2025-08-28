#!/bin/bash

PANE_NAME="opencode-pane"
WINDOW_NAME="opencode-hidden"

# Check if pane exists in current window

PANE_EXISTS=$(tmux list-panes -F "#{pane_title}" | grep -c "^$PANE_NAME$")

# Check if hidden window exists
HIDDEN_EXISTS=$(tmux list-windows -F "#{window_name}" | grep -c "^$WINDOW_NAME$")

if [ "$PANE_EXISTS" -gt 0 ]; then
  CURRENT_PANE=$(tmux display-message -p '#{pane_title}')
  if [ "$CURRENT_PANE" != "$PANE_NAME" ]; then
    TARGET_PANE=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | grep "${PANE_NAME}" | awk '{print $1}')
    tmux select-pane -t "$TARGET_PANE"
  fi
  tmux break-pane -d -n "$WINDOW_NAME"

elif [ "$HIDDEN_EXISTS" -gt 0 ]; then
  # Pane is hidden, bring it back
  tmux join-pane -hs ${WINDOW_NAME}.0

else
  # Pane doesn't exist, create it
  tmux split-window -h -c "#{pane_current_path}"
  tmux select-pane -T "$PANE_NAME"
  tmux send-keys "opencode ." Enter
fi
