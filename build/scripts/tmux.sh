#!/usr/bin/env bash
tmux new-session -s "$APPNAME" -d
#tmux split-window -h
#tmux split-window -v 
tmux split-window -v -p 80
tmux split-window -v -p 80
tmux split-window -v -p 80
tmux split-window -v -p 80
tmux send-keys -t 1 "tail -n 500 -f /var/log/ntpstats/rawstats" Enter
tmux send-keys -t 2 "tail -n 500 -f /var/log/ntpstats/peerstats" Enter
tmux send-keys -t 3 "tail -n 500 -f /var/log/ntpstats/loopstats" Enter
tmux send-keys -t 4 "tail -n 500 -f /var/log/ntpstats/clockstats" Enter
tmux send-keys -t 5 "tail -n 500 -f /var/log/ntpstats/sysstats" Enter
#tmux selectp -t 1 -d #disable user input in pane
#tmux selectp -t 1 -e #enable user input in pane
tmux select-layout even-vertical
tmux new-window
tmux send-keys -t 1 "tail -n 500 -f /var/log/syslog" Enter
echo '
  Welcome to the '"$APPNAME"' docker image.

  This application uses tmux to manage the windows/panes.
  Some useful tmux keyboard shortcuts are:
  Command                   | Function
  :-------------------------|:------------------
  Ctrl + b then [           | Enter copy/scroll mode
  Ctrl + b then Esc         | Exit copy/scroll mode
  Ctrl + b then q then 0-9  | Focus on pane number
  Ctrl + b then x           | Close current pane
  Ctrl + b then c           | Create a new window
  Ctrl + b then n           | Move to the next window
  Ctrl + b then p           | Move to the previous window
  Ctrl + b then w           | Show window list
  Ctrl + b then ?           | Show shortcuts
'
read -p 'Press `enter` to continue'
tmux attach-session -d