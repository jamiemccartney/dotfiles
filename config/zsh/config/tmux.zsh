tmux-dev() {
  local session="dev"
  local dir="$PWD"

  if [[ -n "$TMUX" ]]; then
    tmux new-window -n "$session" -c "$dir"
  fi

  if tmux has-session -t "$session" 2>/dev/null; then
    tmux attach-session -t "$session"
    return
  fi

  tmux new-session -d -s "$session" -c "$dir" -n main
  tmux send-keys -t "$session":0 'nvim .' C-m
  tmux split-window -h -p 25 -t "$session":0 -c "$dir"
  tmux send-keys -t "$session":0.1 'claude' C-m
  tmux split-window -v -p 20 -t "$session":0 -c "$dir"
  tmux split-window -h -t "$session":0.2 -c "$dir"
  tmux select-pane -t "$session":0.0
  tmux attach-session -t "$session"
}
