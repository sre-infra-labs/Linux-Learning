# Motherboard Firmware Update Guide
**Target System:** MSI MEG X570 UNIFY ATX  
**OS Environment:** Ubuntu 26.04.1 LTS (Linux Kernel 7.0)  
**Target Upgrades:** Local LLM Optimization & RTX 5000 Series Compatibility  

[Link - Download BIOS Driver](https://www.msi.com/Motherboard/meg-x570-unify/support)
[Manual - How_to_flash_the_BIOS.pdf](How_to_flash_the_BIOS.pdf)
[Youtube - MSI® HOW-TO update BIOS using M-FLASH ?](https://www.youtube.com/watch?v=sKMub20CUNI)

---

## Prerequisites
* A USB flash drive (8GB to 32GB recommended).
* An uninterrupted power supply (do not update during a storm or if power is unstable).
* Your current BIOS settings will be reset to default during this process.

---

## Step-by-Step Procedure

### Step 1: Format the USB Drive to FAT32 via Terminal
Motherboard flash utilities cannot read Linux Ext4 file systems natively. 

1. Plug in your USB flash drive.
2. Open your terminal and identify your USB drive's logical partition name:
   ```bash
   lsblk
   ```
   *Look for your USB size (e.g., `/dev/sdb` or `/dev/sdc`). Ensure you choose the correct letter to avoid wiping your internal system drives.*

3. Format the target partition cleanly to FAT32:
   ```bash
   sudo mkfs.vfat -F 32 -I /dev/sdX
   ```
   *(Replace `sdX` with your exact USB partition label, e.g., `/dev/sdb1`).*

---

### Step 2: Download and Extract the Firmware
1. Navigate to your Downloads directory:
   ```bash
   cd ~/Downloads
   ```
2. Download the stable production firmware archive directly from the MSI servers:
   ```bash
   wget https://msi.com
   ```
3. Extract the downloaded ZIP archive:
   ```bash
   unzip 7C35vAN3.zip
   ```
4. Copy the extracted BIOS payload file (`E7C35AMS.AN3`) directly onto the root folder of your newly formatted USB drive.

---

### Step 3: Flash the BIOS via M-Flash
1. Leave the USB drive plugged into the computer and **Reboot** your system.
2. As soon as the screen turns on, repeatedly tap the **Delete** key to log into the MSI Click BIOS panel.
3. Click on the **M-Flash** button located in the lower-left quadrant of the screen.
4. The system will prompt a secure soft-reboot to enter the dedicated flash utility environment. Select **Yes**.
5. Once inside the M-Flash UI:
   * Select your USB storage node from the left directory frame.
   * Highlight the firmware file **`E7C35AMS.AN3`** on the right panel.
   * Press **Enter** or click to authorize the deployment.
6. **Crucial:** Let the tracking progress indicator reach 100%. Do not turn off the PC or press any buttons. The system will automatically reboot back into Ubuntu when finished.

---

## Post-Update Optimizations for AI & Video Workloads
Once the flash completes, enter your BIOS one more time (by tapping **Delete** on reboot) to turn back on performance features that were reset to default:

* **Enable Resizable BAR / Above 4G Decoding:** Found under *Settings -> Advanced -> PCIe Subsystem Settings*. Set both to **Enabled**. This is critical for local LLM tokens-per-second processing speed.
* **Enable XMP / A-XMP:** Found on the main dashboard page. Click the **XMP Profile 1** button to ensure your system RAM runs at its rated speed for swift data fetching during video rendering.
