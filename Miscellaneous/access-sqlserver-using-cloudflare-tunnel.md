# Access SQLMonitor Server from Internet

## SQLMonitor server details

```bash
Connection Endpoint to Use -> sqlmonitor-db.ajaydwivedi.com
Domain managed on Cloudflare -> ajaydwivedi.com
SQLMonitor DB Server (KVM VM) -> SQLMonitor on host-only ip 192.168.100.10 (fixed)
LAN ip 192.168.29.10 (may change with ISP; do not use)
DB Port: 1433
DB User: grafana
DB Password: <Secret>

```

## Approach

Cloudflare Tunnel on the KVM host `ryzen9` forwards `sqlmonitor-db.ajaydwivedi.com` straight to SQL Server's TCP port 1433 on the VM, with Cloudflare Access in front. No router ports are opened and nothing is installed in the VM.

Do **not** create a plain proxied (orange-cloud) DNS record pointing at `192.168.100.10`. Cloudflare's HTTP proxy does not carry SQL Server's TCP traffic, and a bare A record exposes your home IP.

Never commit the real DB password to this file. Keep `<Secret>` as a placeholder and store the password in a password manager.

---

## Setup: Cloudflare Tunnel on the KVM host `ryzen9`

`cloudflared` runs on the KVM host, not inside the VM. The host reaches the VM over the host-only network at `192.168.100.10`, a fixed address that does not change when the ISP or LAN changes, so the tunnel forwards `sqlmonitor-db.ajaydwivedi.com` → `tcp://192.168.100.10:1433`. The tunnel is outbound-only, so no inbound ports are opened, and nothing is installed in the VM. Cloudflare Access requires your identity before any connection reaches SQL Server.

### A1. Prerequisites

- `ajaydwivedi.com` is active in your Cloudflare account (already true).
- A Cloudflare Zero Trust team name exists. Verified: team name `ajaydwivedi` (team domain `ajaydwivedi.cloudflareaccess.com`) on the Zero Trust Free plan, with Super Administrator access. Check it at Zero Trust → Overview → Account details.
- A tunnel may already exist (the "Deploy a tunnel" recommendation is checked). Run `cloudflared tunnel list` on `ryzen9` before A3, and reuse an existing tunnel if one is listed.
- Verify the host can reach SQL Server on the VM (run on `ryzen9`):
  ```bash
  nc -zv 192.168.100.10 1433      # or: timeout 3 bash -c '</dev/tcp/192.168.100.10/1433' && echo open
  ```
  Expected: `succeeded` / `open`. If this fails, fix the VM's SQL listener or the host-only network first (see A6).
- Confirm `ryzen9` has a route to the host-only subnet (run on `ryzen9`):
  ```bash
  ip route get 192.168.100.10     # should show a device such as virbr1 or vboxnet0, not the LAN interface
  ```

### A2. Confirm the existing tunnel on `ryzen9`

The tunnel on this host is **token-managed**: the service runs `cloudflared tunnel run --token-file /etc/cloudflared/token`, and its routes are set in the Cloudflare dashboard. Do not create a second tunnel, and do not use `/etc/cloudflared/config.yml` for this setup. Routes are not read from a local file.

```bash
cloudflared --version
systemctl status cloudflared --no-pager
```

### A3. Add the SQL route in the dashboard

The tunnel's **Routes** page (the one with the diagram and the table of `sqlmonitor`, `cockpit`, `prometheus`, `resume`) is where you add the route.

1. Go to **Zero Trust → Networks → Connectors → Cloudflare Tunnels**, and click the tunnel `ryzen9_desktop_ub...`.
2. Click **Add route** (top right of the Routes page).
3. Choose the **Published application** type. This is the same type as the existing four routes.
4. Fill in the form. There is no separate service-type field. The protocol goes in the **Service URL**:

   | Field | Value |
   |---|---|
   | Subdomain | `sqlmonitor-db` |
   | Domain | `ajaydwivedi.com` |
   | Path | leave empty |
   | Service URL | `tcp://192.168.100.10:1433` |

5. Leave **Additional application settings** collapsed, and click **Add route**. Cloudflare creates the DNS record for `sqlmonitor-db.ajaydwivedi.com`.

The form shows `Full hostname: sqlmonitor-db.ajaydwivedi.com` once the subdomain is filled in. Check that before you click **Add route**.

The `tcp://` prefix is what makes this a raw TCP route. Without it, the route would be treated as HTTP and SQL Server would not work.

Do not use `sqlmonitor.ajaydwivedi.com` for this route. It already points to `localhost:3000`.

### A4. Check that the route works

1. In the Routes table, confirm the new row shows `sqlmonitor-db.ajaydwivedi.com` with service `192.168.100.10:1433`.
2. On `ryzen9`, check that the tunnel reports no origin errors:
   ```bash
   sudo journalctl -u cloudflared -n 50 --no-pager | grep -i 'error' || echo "no errors in recent log"
   ```
   If you see `Unable to reach the origin service`, the route points to a service that isn't reachable. Re-run the A1 `nc` test and check the URL in the route.
3. Test from a client as described in A7.

### A5. Protect the hostname with Cloudflare Access

Without this step anyone who learns the hostname can reach your SQL login prompt.

1. In the Zero Trust sidebar, open **Access controls → Applications**, then click **Add an application**.
   - In the dialog, keep the **Self-hosted and private** tab selected.
   - Keep the **Public DNS** sub-tab selected, because `sqlmonitor-db.ajaydwivedi.com` is a public hostname.
   - Click **Continue with Self-hosted and private**.

   Note: the **Application library** page (under Team & Resources) is a different page that lists third-party apps. Don't use it for this step.
2. **Destinations → Public hostnames:** set **Subdomain** to `sqlmonitor-db`, **Domain** to `ajaydwivedi.com` (pick it from the dropdown), and leave **Path** empty.
   - Leave **Allow access through browser-based RDP, SSH, or VNC sessions** off.
3. **Access policies:** click **Create new policy** and set:
   - **Policy name:** `Owner only`
   - **Action:** **Allow**
   - **Include → Emails:** `<your-email>`
   - Leave the other sections empty, then save the policy. It should then appear under Access policies, and the Preview section should list it.
4. **Authentication:** under **Choose available identity providers for this application**, select **One-time PIN**. If it isn't listed, enable it under Settings → Authentication first.
5. **Details:**
   - **Name:** `SQLMonitor DB`
   - **Session Duration:** `24 hours` (the default; change it if you want).
6. Scroll to the bottom of the page and click **Save** (or **Add application**). The bottom of the page is below the visible area in your screenshot.

Only the listed email can open a session, and only after a one-time PIN.

### A6. Confirm SQL Server listens on TCP 1433 (inside the VM, config only)

No software is installed in the VM. The host connects to the VM's SQL Server on TCP 1433, so SQL Server must listen on TCP 1433. Grafana already uses this port, so this is usually already true. Verify it with the test in A1 and, if you want, check it on the VM with its existing tools.

Optional hardening (a configuration change inside the VM, not an install): require encryption.

**Windows SQL Server (inside the VM):**
1. Open **SQL Server Configuration Manager → SQL Server Network Configuration → Protocols for MSSQLSERVER**.
2. Enable **TCP/IP**. Properties → **IP Addresses** tab → under `IPAll`, set **TCP Port** to `1433` and clear **TCP Dynamic Ports**.
3. On the **Flags** tab, set **Force Encryption** to `Yes`.
4. Restart the SQL Server service.

**Linux SQL Server (inside the VM):**
```bash
sudo /opt/mssql/bin/mssql-conf set network.tcpport 1433
sudo /opt/mssql/bin/mssql-conf set network.forceencryption 1
sudo systemctl restart mssql-server
```

Do **not** open 1433 in the VM or host firewall to the internet. The tunnel reaches SQL through the host-only network, so no inbound rule is needed.

### A7. Connect from a client machine

Install `cloudflared` on the client (for example `winget install Cloudflare.cloudflared` on Windows, or the same apt repo steps as on the host on Linux), then start a local listener:

```bash
cloudflared access tcp --hostname sqlmonitor-db.ajaydwivedi.com --url 127.0.0.1:1433
```

The first run opens a browser for the Access one-time PIN. Leave the command running while you work.

In SSMS, Azure Data Studio, or your application, connect to:

```
Server:   127.0.0.1,1433
Login:    grafana
Password: <Secret>
Options:  Encrypt = Mandatory  (set TrustServerCertificate=True only if the server certificate is not trusted)
```

Run this only while `cloudflared access tcp` is running in another terminal. Do **not** point `sqlcmd` at `sqlmonitor-db.ajaydwivedi.com` directly: that name resolves to Cloudflare's edge, not to SQL Server, so the connection times out. A successful `ping` to that name does not prove port 1433 works.

Quick test from a client shell (replace `<Secret>` with the password from your password manager):
```bash
sqlcmd -S 127.0.0.1,1433 -C -U grafana -P '<Secret>' -Q "SELECT @@VERSION"
```

Notes:
- The client must keep `cloudflared access tcp` running; closing it drops the connection.
- If local port 1433 is already in use on the client, use another local port (for example `--url 127.0.0.1:1434`) and connect to `127.0.0.1,1434`.

---

## Troubleshooting

| Symptom | Check |
|---|---|
| `cloudflared` service won't start | `sudo journalctl -u cloudflared -n 50 --no-pager`; confirm `/etc/cloudflared/token` exists and the service is enabled. |
| Host cannot reach `192.168.100.10:1433` (A1 test fails) | Check the VM is running, SQL listens on TCP 1433 (A6), and the libvirt network allows host-to-VM traffic. |
| Access page loops or denies | Confirm the email in the policy matches exactly and the application domain matches the hostname. |
| `cloudflared access tcp` connects but SSMS times out | Confirm the dashboard route URL is `192.168.100.10:1433` with service type TCP, and the A1 host test passes. |
| "The server closed the connection" / TLS errors | Usually a Force Encryption mismatch. Use `Encrypt=Mandatory`; `TrustServerCertificate=True` for testing only. |
| Login failed for user `grafana` | Verify the login exists, is enabled, and has rights on the target database. |
| Local port 1433 already in use | Use another local port (`--url 127.0.0.1:1434`). |

Logs (on `ryzen9`):
```bash
journalctl -u cloudflared -f
```

## Security checklist

- [ ] No router port forward to 192.168.100.10 and no inbound 1433 rule on the host firewall.
- [ ] Cloudflare Access policy limited to your email.
- [ ] SQL Force Encryption enabled.
- [ ] `sa` disabled or password rotated; `grafana` login has least privilege.
- [ ] Tunnel credentials JSON readable only by root (`chmod 600`).
- [ ] DB password kept out of git (the `<Secret>` placeholder stays in this file).
- [ ] Access logs reviewed periodically (Zero Trust → Logs → Access).

## Revert / remove access

This tunnel is shared with other hostnames, so do not stop or uninstall the `cloudflared` service. To remove SQL access:

1. In the dashboard, open **Zero Trust → Networks → Connectors → Cloudflare Tunnels → (your tunnel) → Routes** and delete the `sqlmonitor-db.ajaydwivedi.com` route.
2. Delete the `sqlmonitor-db` DNS record under the `ajaydwivedi.com` zone.
3. Delete the `SQLMonitor DB` Access application under **Access → Applications**.
