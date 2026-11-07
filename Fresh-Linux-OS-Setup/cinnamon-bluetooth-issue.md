# Cinnamon freezes / falls into fallback mode when a Bluetooth headset connects (Ubuntu 26.04)

## Symptom

- Connecting a Bluetooth headset (pTron TWS earphones) makes the Cinnamon desktop freeze and then show the
  "You are currently running in fallback mode" dialog.
- Calls (Google Meet, Zoom) need the earphone microphone, so disabling the headset profile is not an option.

## Root cause

Cinnamon aborts (SIGABRT) inside its sound-mixer library, `libcvc`, when PipeWire reports a port change on the
Bluetooth audio device.

Crash backtrace (from `/var/crash/_usr_lib_x86_64-linux-gnu_cinnamon-settings-daemon_csd-media-keys.1000.crash`):

```
#6  g_assertion_message_expr () from libglib-2.0.so.0
#7  gvc_mixer_stream_get_port () from libcvc.so.0
#8  gvc_mixer_control_lookup_device_from_stream () from libcvc.so.0
...
#17 gvc_mixer_stream_set_port () from libcvc.so.0
#19 libpulse.so.0 (pulse event dispatch)
```

Log message: `Cvc:ERROR:../libcvc/gvc-mixer-stream.c:541:gvc_mixer_stream_get_port: code should not be reached`

`gvc_mixer_stream_get_port()` ends with `g_assert_not_reached()`. The stream's active port name can briefly not match
any port in its list while PipeWire updates the device, and the assertion kills the process.

Related upstream reports (same function, GNOME/Fedora side):
- https://bugzilla.redhat.com/show_bug.cgi?id=2433346
- https://bugzilla.redhat.com/show_bug.cgi?id=2432825
- https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/452

Checked and ruled out:
- `libcvc` 6.4.2 (installed) and 6.6.2 (in the Ubuntu pool) both contain the same assertion. 6.6.2 only adds
  NULL checks elsewhere, so upgrading does not fix it.
- Disabling the media-keys daemon, or the WirePlumber headset-profile setting, did not stop the crash.

## Fix

Build `libcvc` 6.4.2 from the Ubuntu source with the assertion replaced by a NULL return, and install it in
`/usr/local`. `/usr/local/lib/x86_64-linux-gnu` is searched before `/usr/lib/x86_64-linux-gnu`, so the patched
library takes precedence and the Ubuntu package stays installed.

Verified on this machine: the rebuilt library has the same SONAME (`libcvc.so.0`), the same 148 exported symbols,
and all its dependencies resolve. Earphone connection test passed after restarting Cinnamon.

## Build and install

### 1. Install build dependencies

```bash
sudo apt install -y meson ninja-build libglib2.0-dev libpulse-dev
```

### 2. Get the source

Use a permanent location (not `/tmp`, which is cleared on reboot).

```bash
mkdir -p ~/build/libcvc && cd ~/build/libcvc
curl -sSfLO http://in.archive.ubuntu.com/ubuntu/pool/universe/c/cinnamon-desktop/cinnamon-desktop_6.4.2.orig.tar.gz
tar -xzf cinnamon-desktop_6.4.2.orig.tar.gz
mv cinnamon-desktop_6.4.2 src
```

Confirm the version matches the installed package first:

```bash
dpkg -s libcvc0t64 | grep ^Version      # expect 6.4.2-1
```

### 3. Apply the patch

Save the following as `~/build/libcvc/libcvc-nopen-port.patch`:

```diff
--- src/libcvc/gvc-mixer-control.c
+++ src/libcvc/gvc-mixer-control.c
@@ -271,7 +271,8 @@
                         const GvcMixerStreamPort *port;
                         port = gvc_mixer_stream_get_port (stream);
 
-                        if (stream_id == gvc_mixer_stream_get_id (stream) &&
+                        if (port != NULL &&
+                            stream_id == gvc_mixer_stream_get_id (stream) &&
                             g_strcmp0 (gvc_mixer_ui_device_get_port (device),
                                        port->port) == 0) {
                                 g_debug ("lookup-device-from-stream found device: device description '%s', device port = '%s', device stream id %i AND stream port = '%s' stream id '%u' and stream description '%s'",
@@ -632,7 +633,7 @@
         active_port = gvc_mixer_stream_get_port (stream);
         output_port = gvc_mixer_ui_device_get_port (output);
         /* First ensure the correct port is active on the sink */
-        if (g_strcmp0 (active_port->port, output_port) != 0) {
+        if (active_port == NULL || g_strcmp0 (active_port->port, output_port) != 0) {
                 g_debug ("Port change, switch to = %s", output_port);
                 if (gvc_mixer_stream_change_port (stream, output_port) == FALSE) {
                         g_warning ("Could not change port !");
@@ -715,7 +716,7 @@
         active_port = gvc_mixer_stream_get_port (stream);
         input_port = gvc_mixer_ui_device_get_port (input);
         /* First ensure the correct port is active on the sink */
-        if (g_strcmp0 (active_port->port, input_port) != 0) {
+        if (active_port == NULL || g_strcmp0 (active_port->port, input_port) != 0) {
                 g_debug ("Port change, switch to = %s", input_port);
                 if (gvc_mixer_stream_change_port (stream, input_port) == FALSE) {
                         g_warning ("Could not change port!");
--- src/libcvc/gvc-mixer-stream.c
+++ src/libcvc/gvc-mixer-stream.c
@@ -538,8 +538,11 @@
                 }
         }
 
-        g_assert_not_reached ();
-
+        /* The stream's active port name can briefly not match any port in
+         * its list while PipeWire is updating the device. Report "no port"
+         * to the caller instead of aborting the whole process. */
+        g_debug ("gvc_mixer_stream_get_port: active port '%s' not in port list",
+                 stream->priv->port ? stream->priv->port : "(null)");
         return NULL;
 }
```

Apply it:

```bash
cd ~/build/libcvc
patch -p0 --dry-run < libcvc-nopen-port.patch   # check it applies cleanly
```

If the dry run is clean, apply it with `patch -p0 < libcvc-nopen-port.patch`. (Hunk paths are relative to
`~/build/libcvc`; if `patch` cannot find the files, run it from the directory that contains `src/`.)

### 4. Add the standalone build files

The upstream build needs the full cinnamon-desktop tree. These two small files build only `libcvc`.

Save as `~/build/libcvc/src/libcvc/config.h`:

```c
/* Minimal config.h for building libcvc standalone (no ALSA, matching the Ubuntu build). */
#define PACKAGE_VERSION "6.4.2"
#define GETTEXT_PACKAGE "cinnamon-desktop"
```

Save as `~/build/libcvc/src/libcvc/meson.build`:

```meson
project('cvc', 'c', version: '6.4.2', meson_version: '>=0.56.0')

gnome = import('gnome')

cvc_deps = [
  dependency('gio-2.0'),
  dependency('gobject-2.0'),
  dependency('libpulse', version: '>= 12.99.3'),
  dependency('libpulse-mainloop-glib'),
]

headers = [
  'gvc-channel-map.h', 'gvc-mixer-card.h', 'gvc-mixer-control.h',
  'gvc-mixer-event-role.h', 'gvc-mixer-sink.h', 'gvc-mixer-sink-input.h',
  'gvc-mixer-source.h', 'gvc-mixer-source-output.h', 'gvc-mixer-stream.h',
  'gvc-mixer-ui-device.h',
]

sources = [
  'gvc-channel-map.c', 'gvc-mixer-card.c', 'gvc-mixer-control.c',
  'gvc-mixer-event-role.c', 'gvc-mixer-sink.c', 'gvc-mixer-sink-input.c',
  'gvc-mixer-source.c', 'gvc-mixer-source-output.c', 'gvc-mixer-stream.c',
  'gvc-mixer-ui-device.c',
]

enums = gnome.mkenums_simple('gvc-enum-types', sources: headers)

# version 0.0.0 gives libcvc.so.0.0.0 with SONAME libcvc.so.0, same as the packaged library
libcvc = shared_library('cvc', sources + enums,
  dependencies: cvc_deps,
  c_args: ['-DG_LOG_DOMAIN="Cvc"', '-DHAVE_CONFIG_H'],
  install: true,
  version: '0.0.0',
)
```

### 5. Build

```bash
cd ~/build/libcvc/src/libcvc
meson setup ~/build/libcvc/bld --prefix=/usr/local
meson compile -C ~/build/libcvc/bld
```

### 6. Verify before installing

```bash
B=~/build/libcvc/bld
objdump -p $B/libcvc.so.0.0.0 | grep SONAME                              # SONAME libcvc.so.0
diff <(nm -D --defined-only /usr/lib/x86_64-linux-gnu/libcvc.so.0.0.0 | awk '{print $3}' | sort) \
     <(nm -D --defined-only $B/libcvc.so.0.0.0 | awk '{print $3}' | sort) && echo "symbols identical"
ldd $B/libcvc.so.0.0.0 | grep 'not found' || echo "all dependencies resolve"
```

### 7. Install into /usr/local

```bash
sudo meson install -C ~/build/libcvc/bld
sudo ldconfig
ldconfig -p | grep libcvc        # should list /usr/local/lib/x86_64-linux-gnu/libcvc.so.0
```

### 8. Apply it

The running Cinnamon process keeps the old library loaded, so restart it:

```bash
cinnamon --replace &
```

Or log out and back in. Then confirm the running session uses the new library:

```bash
grep libcvc /proc/$(pgrep -n cinnamon)/maps | head -2    # should show /usr/local/lib/x86_64-linux-gnu/libcvc.so.0.0.0
```

## Keeping the custom build from being removed or replaced by apt

What apt does and does not touch:

- **`/usr/local` is not managed by dpkg or apt.** `apt upgrade`, `apt full-upgrade`, `apt autoremove`, and
  `apt purge` never delete or overwrite files there. The custom library survives all of them.
- **The loader prefers it.** `/etc/ld.so.conf.d/libc.conf` lists `/usr/local/lib` before the system directories,
  so after an upgrade of `libcvc0t64` the patched library is still the one loaded.
- **Shared-library version check.** `apt` installs the packaged `libcvc.so.0.0.0` in `/usr/lib`. Only the loader's
  search order decides which copy wins, and the verify step in section 6 confirms it.

What *can* still go wrong:

1. **Ubuntu ships a fixed `libcvc` later.** The override keeps running the old code, so the fix never reaches you
   until you rebuild. Check after upgrades (see the check below), and rebuild from the new source if the packaged
   version changes.
2. **A Cinnamon upgrade needs newer `libcvc` symbols.** The override exports only 6.4.2 symbols, so Cinnamon may
   fail to start or crash on load. If that happens, remove the override (below) and rebuild from the matching source.
3. **You re-run `apt` to reinstall `libcvc0t64` with `--reinstall`.** This is harmless; the override still wins.

Optional: stop apt from changing the packaged library at all. This keeps the packaged version frozen, including its
bugs and security fixes, so only do it if you accept that trade-off:

```bash
sudo apt-mark hold libcvc0t64
apt-mark showhold                  # confirm
sudo apt-mark unhold libcvc0t64    # to undo
```

Quick check to run after any `apt upgrade`:

```bash
dpkg -s libcvc0t64 | grep ^Version                          # packaged version
ldconfig -p | grep libcvc                                    # should show /usr/local/lib/x86_64-linux-gnu/...
grep libcvc /proc/$(pgrep -n cinnamon)/maps | head -1        # running session uses the override
```

If the packaged version changed, compare it with the source version you built from. If they differ, rebuild
from the new source.

## Undo

Remove the custom build and fall back to the Ubuntu library:

```bash
sudo rm /usr/local/lib/x86_64-linux-gnu/libcvc.so.0*
sudo ldconfig
cinnamon --replace &
```

## Earlier attempts (optional cleanup)

These did not fix the crash. They are harmless, but can be removed:

- `~/.config/wireplumber/wireplumber.conf.d/51-ptron.conf`: forced the headset profile. Remove with
  `rm ~/.config/wireplumber/wireplumber.conf.d/51-ptron.conf && systemctl --user restart wireplumber`.
- `~/.config/autostart/cinnamon-settings-daemon-media-keys.desktop`: disabled the media-keys daemon. Remove with
  `rm ~/.config/autostart/cinnamon-settings-daemon-media-keys.desktop`. The media keys work again at next login.

## Useful commands

```bash
journalctl -b 0 | grep -iE 'bluetooth|SIGABRT|fallback'     # Bluetooth and crash events this boot
ls -lt /var/crash | head                                     # recent crash dumps
coredumpctl list 2>/dev/null                                 # if systemd coredumps are enabled
```
