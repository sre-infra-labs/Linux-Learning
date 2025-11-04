# Install Ollama
https://github.com/ollama/ollama?tab=readme-ov-file

# Install open-webui
https://github.com/open-webui/open-webui
open-webui serve --port 8082

# Systemd Unit for open-webui
```
# Decide on a “run‑as” user
sudo adduser --system --no-create-home --group openwebui

# Locate binary
which open-webui
    /home/saanvi/anaconda3/bin/open-webui

# Create the systemd service unit file
sudo nano /etc/systemd/system/open-webui.service

    [Unit]
    Description=Open WebUI
    After=network.target

    [Service]
    # Use the user that owns the binary / data
    User=saanvi
    Group=saanvi
    WorkingDirectory=/home/saanvi
    ExecStart=/home/saanvi/anaconda3/bin/open-webui serve --port 8082
    Restart=always
    RestartSec=5

    # Make sure we get the correct PATH
    #Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    Environment="PATH=/home/saanvi/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

    [Install]
    WantedBy=multi-user.target


# Reload systemd, enable, and start
sudo systemctl daemon-reload
sudo systemctl enable open-webui
sudo systemctl start open-webui

# check errors
journalctl -u open-webui -f

# Verify service
curl http://localhost:8082


```
