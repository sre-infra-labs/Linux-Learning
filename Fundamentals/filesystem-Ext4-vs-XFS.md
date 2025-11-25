# [Ext4 vs XFS – Which Filesystem Should You Use](https://linuxopsys.substack.com/p/ext4-vs-xfs-which-filesystem-should?publication_id=4995647&post_id=164561305&isFreemail=true&r=1tltv8&triedRedirect=true)

- XFS is default filesystem in RHEL based distros
- Ext4 is default filesystem in Debian/Ubuntu based distros

```
# get existing mounted volumes
df -hT
```

+---------------------------+----------------------------------------+-------------------------------------------------------+
|      Feature / Aspect     |                  EXT4                  |                          XFS                          |
+---------------------------+----------------------------------------+-------------------------------------------------------+
|            Type           | General-purpose journaling filesystem  |     High-performance 64-bit journaling filesystem     |
|         Stability         |        Extremely stable, mature        |             Very stable, enterprise-grade             |
|   Performance (General)   |        Good overall performance        | Excellent performance with large files & parallel I/O |
| Performance (Small files) |            Better than XFS             |       Weaker for tiny files & metadata-heavy ops      |
| Performance (Large files) |                  Good                  |    Outstanding (optimized for large sequential I/O)   |
|     Database Workloads    |     Good; predictable performance      |       Often better for write-heavy DB workloads       |
|    Scaling to large FS    |      Scales well (up to EB range)      |        Scales extremely well (TB–PB workloads)        |
|    Max Filesystem Size    |                  1 EiB                 |                       8 EiB                           |
|       Max File Size       |                  8 EiB                 |                      16 TiB                           |
|    Metadata operations    |                  Fast                  |              Slower for many small files              |
|         Snapshots         |          No native snapshots           |                  No native snapshots                  |
|    Online resize (grow)   |               Supported                |                       Supported                       |
|       Online shrink       |               Supported                |                     Not supported                     |
|      Journaling Mode      | Ordered (default), Writeback, Journal  |                Metadata journaling only               |
|        Concurrency        |                  Good                  |              Excellent — highly parallel              |
|  Filesystem check (fsck)  |       Slow on very large volumes       |              Very fast — avoids long fsck             |
|       Best Use Cases      | General servers, desktops, small files |        Databases, large volumes, video, backups       |
|      Worst Use Cases      |      Huge multi-TB HPC workloads       |       Small-file workloads (maildir, git repos)       |
|     Full Disk Behavior    |             Handles better             |      Performance degrades significantly >90% full     |
+---------------------------+----------------------------------------+-------------------------------------------------------+

