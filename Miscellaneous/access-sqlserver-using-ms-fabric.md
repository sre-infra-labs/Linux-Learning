# Access SQL Server on sqlmonitor from Microsoft Fabric

Microsoft Fabric cloud reaches on-premises SQL Server through an **On-premises data gateway**. The gateway runs on a Windows machine and makes outbound HTTPS connections to Microsoft. No inbound ports are opened, and the Cloudflare tunnel is not used.

```
Fabric (cloud)
  → Microsoft service (outbound from gateway)
  → On-premises data gateway on sqlmonitor (Windows Server 2019)
  → SQL Server on sqlmonitor (localhost:1433)
```

| Item | Value |
|---|---|
| SQL Server host | `sqlmonitor` (Windows Server 2019, KVM VM with internet access) |
| SQL Server port | `1433` (TCP) |
| Gateway location | same VM as SQL Server |
| Gateway mode | Standard (required for Fabric cloud data sources) |
| SQL login | `grafana` (read-only on the `DBA` database, password: `<Secret>`) |
| Database | `DBA` |

---

## Prerequisites

- You are a **Fabric administrator**, or you can create gateways and connections in your tenant. Check at **Fabric → Settings → Admin portal**.
- The `sqlmonitor` VM can reach the internet on outbound HTTPS (443). No inbound rule is needed.
- SQL Server listens on TCP 1433 on `sqlmonitor`. Confirm this in SQL Server Configuration Manager (**SQL Server Network Configuration → Protocols → TCP/IP**, IPAll port `1433`).
- Your Fabric workspace has capacity assigned (Fabric trial or paid capacity).

## 1. Check the grafana login

The `grafana` login has read-only permission on the `DBA` database. Confirm this on `sqlmonitor` before you use it:

```sql
USE DBA;
SELECT dp.name, dp.type_desc, r.name AS role_name
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members rm ON dp.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE dp.name = 'grafana';
```

Expected: `grafana` with role `db_datareader` (or equivalent read-only access). Do not use `sa` for Fabric.

## 2. Install the On-premises data gateway on sqlmonitor

1. Sign in to the VM as an administrator.
2. Download **On-premises data gateway (standard mode)** from the Microsoft download page for on-premises data gateway. Run the installer.
3. When prompted, sign in with your Fabric account (the admin or gateway-admin account).
4. Choose **Register a new gateway on this computer**.
5. Name the gateway, for example `sqlmonitor-gw`.
6. Set a **recovery key** and store it securely. You need it to restore or move the gateway.
7. Finish the setup. The gateway appears in **Manage connections and gateways** in Fabric.

Installing the gateway on the database server works, but Microsoft recommends a separate machine for production. Use that option only for this lab or small setup.

## 3. Check gateway connectivity to SQL Server

Run on `sqlmonitor` in PowerShell:

```powershell
Test-NetConnection localhost -Port 1433
sqlcmd -S localhost,1433 -U grafana -P '<Secret>' -C -d DBA -Q "select @@version;"
```

Both must succeed before you create the Fabric connection.

## 4. Create the SQL Server connection in Fabric

1. In Fabric, select the **Settings** gear, then **Manage connections and gateways**.
2. Go to **Connections** (or **New connection**) and choose **New connection**.
3. Fill in:
   - **Connection type:** SQL Server
   - **Connection name:** `sqlmonitor-fabric`
   - **Gateway cluster:** `sqlmonitor-gw`
   - **Server:** `localhost,1433` (or `sqlmonitor,1433` if the name resolves)
   - **Database:** `DBA`
   - **Authentication method:** Basic
   - **Username:** `grafana`
   - **Password:** `<Secret>`
   - **Encrypt:** on. If the connection fails with a certificate error, enable **Trust server certificate** for the test.
4. Click **Create** and wait for the test to pass.

The label names may differ slightly in your Fabric version. Match the values, not the exact labels.

## 5. Query `dbo.instance_details` from Fabric

Use a **Dataflow Gen2**, which can run a native SQL query against an on-premises SQL Server through the gateway.

1. In your Fabric workspace, select **New item → Dataflow Gen2**.
2. Select **Get data → SQL Server database**. The **Connect to data source** panel opens.
3. Fill in **Connection settings** and **Connection credentials**:
   - **Server:** `localhost,1433`
   - **Database:** `DBA`
   - **Connection:** select `sqlmonitor-fabric` if it exists. Otherwise keep **Create new connection**.
   - **Connection name:** `sqlmonitor-fabric`
   - **Data gateway:** select `sqlmonitor-gw`. It shows **(none)** by default, and the connection fails without a gateway.
   - **Authentication kind:** Basic
   - **Username:** `grafana`
   - **Password:** `<Secret>`
   - **Privacy Level:** None (or your choice)
4. Expand **Advanced options** and paste this in **SQL statement**:

   ```sql
   select * from dbo.instance_details id
   ```

   `id` is a table alias, so the query is valid. It reads all columns from `dbo.instance_details`. If you meant to filter by an `id` column, use `select * from dbo.instance_details where id = <value>` instead.

5. Click **Next**, then review the preview in the Power Query editor. The rows should match what you see in SSMS.
6. Optional: set a destination (for example a Lakehouse table) on the **Query settings** panel. Without a destination, the data stays in the dataflow preview.
7. Click **Publish** or **Save & run** to refresh the data.

Native queries are only available in some connection types and Power Query versions. If you don't see **SQL statement** under **Advanced options**, use **Navigator**, select the `instance_details` table under `dbo`, then keep only the columns you need.

## Troubleshooting

| Symptom | Check |
|---|---|
| Gateway shows offline in Fabric | The `On-premises data gateway` Windows service must be running. Check outbound HTTPS 443 from `sqlmonitor`. |
| Connection test fails with "could not connect" | Run step 3. Confirm TCP 1433 is listening and the `grafana` login works. |
| "The certificate chain was issued by an authority that is not trusted" | SQL Server presents a self-signed certificate because Force Encryption is on, and the gateway doesn't trust it. The gateway and SQL Server share the VM, so set **Force Encryption** to **No** in SQL Server Configuration Manager (TCP/IP → Flags), restart SQL Server, then retry the connection. The alternative is to install a certificate that the VM trusts, with a name that matches the server name. |
| Login failed for `grafana` | Confirm the login is enabled and has read access on `DBA`. |
| Gateway not listed in the connection dialog | You must be a gateway admin for that gateway. Check **Manage connections and gateways → Gateways**. |
| Query returns "permission denied" | `grafana` needs `SELECT` on `dbo.instance_details`. Run the check in step 1. |

Logs for the gateway are in the gateway app (**Diagnostics**) and in the Windows Event Viewer under the gateway's event source.

## Security checklist

- [ ] `grafana` is read-only on `DBA` only and not `sa`.
- [ ] The gateway recovery key is stored in a password manager.
- [ ] The Fabric connection uses the gateway, not a public hostname.
- [ ] No inbound SQL or gateway port is opened on the router or host firewall.
- [ ] Access to the gateway is limited to a small set of admins.

## Remove the Fabric connection

1. In Fabric, delete the `sqlmonitor-fabric` connection under **Manage connections and gateways**.
2. Remove the gateway from the VM through the gateway app (**Remove gateway**) or the Windows Apps list.
