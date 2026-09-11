# Terminal Multiplexer - tmux

**Prefix Key** -> `Ctrl b`

## Basic tmux commands

```
- Start a new session:
    tmux

- Start a new named [s]ession:
    tmux [new|new-session] -s name

- List existing sessions:
    tmux [ls|list-sessions]

- Attach to the most recently used session:
    tmux [a|attach]

- Detach from the current session (inside a tmux session):
    <Ctrl b><d>

- Create a new window (inside a tmux session):
    <Ctrl b><c>

- Switch between sessions and windows (inside a tmux session):
    <Ctrl b><w>

- Kill a session by [t]arget name:
    tmux kill-session -t name
```


## Configure `~/.tmux.conf` to allow mouse support and use vi keys in copy mode

```bash
set -g mouse on
setw -g mode-keys vi

```

### Working with Keyboard Based Copy Paste

```bash
# Start copy mode
Ctrl b [

# Navigate to the text you want to copy using vi keys (h, j, k, l)

# Enter visual mode to select text
Space

# Move to the end of the text you want to copy
# (use vi movement keys like w, e, b, etc.)

# Copy the selected text
Enter

# Paste the copied text
Ctrl b ]
```


## Install tmux

```bash
sudo apt install tmux -y

sudo dnf install tmux -y
```


## Working with tmux sessions

```bash
# Create a new session
tmux new -s session_name`

# List existing sessions:
tmux ls

# Detach from the current session (inside a tmux session):
Ctrl b d

# attach to the most recently used session
tmux a

# attach to a specific session
tmux a -t session_name

# Kill a session by [t]arget name:
tmux kill-session -t session_name

# Kill all servers
tmux kill-server
```


## Working with Windows
```bash
# Show all windows
Ctrl b w

# Create a new window (inside a tmux session):
Ctrl b c

# Rename the current window
Ctrl b ,

# Move to previous window
Ctrl b p

# Move to next window
Ctrl b n

# Switch between windows (inside a tmux session):
Ctrl b <window_number>

# Kill the current window
Ctrl b &

```


### Working with panes
```bash
# Split current window into vertical pane
Ctrl b %

# split current window into horizontal pane
Ctrl b "

# Show pane numbers
Ctrl b q

# Go to a specific pane
Ctrl b q <pane_number>

# Move pane boundaries
Ctrl b M{h,j,k,l}

# Resize pane
Ctrl b C{h,j,k,l}

# Kill the current pane
Ctrl b x
```




