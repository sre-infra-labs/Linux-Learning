# How to enable Google Authenticator to Cockpit for Ubuntu
https://www.reddit.com/r/Ubuntu/comments/1cjkv3j/guide_how_to_enable_google_authenticator_to/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

```
# install google auth
sudo apt-get install libpam-google-authenticator libqrencode-dev

# create qr codes that you can scan into your mobile // also make sure to save the scratch codes somewhere safe.
google-authenticator -t -d -f -r 3 -R 30 -W -Q UTF8

# Append the cockpit auth requirement
sudo bash -c 'echo "auth required pam_google_authenticator.so nullok" >> /etc/pam.d/cockpit'

# ((Complete the above before you run the below. ))
sudo systemctl restart cockpit
```

## Error/Fix - Connection failed when using https://cockpit.ajaydwivedi.com, but accessible on http://localhost:9090
![cockpit-post-auth-error](cockpit-post-auth-error.png)

```
# Enable cockpit-ws to trust proxied HTTPS headers
sudo loginctl enable-linger $USER

# Create/Edit /etc/cockpit/cockpit.conf

[WebService]
Origins = https://cockpit.ajaydwivedi.com
ProtocolHeader = X-Forwarded-Proto
ForwardedForHeader = X-Forwarded-For

# Restart cockpit
sudo systemctl restart cockpit

# Check logs
journalctl -u cockpit --no-pager --since "5 minutes ago"

```