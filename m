From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:56:58 -0700
Subject: [lustre-devel] [PATCH 00/12] Delete CURRENT_TIME,
	CURRENT_TIME_SEC and current_fs_time
Message-ID: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

The series contains the last unmerged uses of CURRENT_TIME,
CURRENT_TIME_SEC, and current_fs_time().
The series also deletes these apis.

All the patches except [PATCH 9/12] and [PATCH 10/12] are resend patches.
These patches fix new instances of CURRENT_TIME.
cifs and ceph patches have been squashed so that we have one patch per
filesystem.

We want to get these merged onto 4.12 release so that I can post the series
that changes vfs timestamps to use 64 bits for 4.13 release.

I'm proposing these to be merged through Andrew's tree.

Filesystem maintainers, please let Andrew know if you will be picking up
the patch in your trees.

Let me know if anybody has other preferences for merging.

Deepa Dinamani (12):
  fs: f2fs: Use ktime_get_real_seconds for sit_info times
  trace: Make trace_hwlat timestamp y2038 safe
  fs: cifs: Replace CURRENT_TIME by other appropriate apis
  fs: ceph: CURRENT_TIME with ktime_get_real_ts()
  fs: ufs: Use ktime_get_real_ts64() for birthtime
  audit: Use timespec64 to represent audit timestamps
  fs: btrfs: Use ktime_get_real_ts for root ctime
  fs: ubifs: Replace CURRENT_TIME_SEC with current_time
  lustre: Replace CURRENT_TIME macro
  apparmorfs: Replace CURRENT_TIME with current_time()
  time: Delete CURRENT_TIME_SEC and CURRENT_TIME
  time: Delete current_fs_time() function

 drivers/block/rbd.c                             |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c |  6 +++---
 drivers/staging/lustre/lustre/osc/osc_io.c      |  4 ++--
 fs/btrfs/root-tree.c                            |  3 ++-
 fs/ceph/mds_client.c                            |  4 +++-
 fs/cifs/cifsencrypt.c                           |  4 +++-
 fs/cifs/cifssmb.c                               | 10 ++++-----
 fs/cifs/inode.c                                 | 28 +++++++++++++------------
 fs/f2fs/segment.c                               |  2 +-
 fs/f2fs/segment.h                               |  5 +++--
 fs/ubifs/dir.c                                  | 12 +++++------
 fs/ubifs/file.c                                 | 12 +++++------
 fs/ubifs/ioctl.c                                |  2 +-
 fs/ubifs/misc.h                                 | 10 ---------
 fs/ubifs/sb.c                                   | 14 +++++++++----
 fs/ubifs/xattr.c                                |  6 +++---
 fs/ufs/ialloc.c                                 |  6 ++++--
 include/linux/audit.h                           |  4 ++--
 include/linux/fs.h                              |  1 -
 include/linux/time.h                            |  3 ---
 kernel/audit.c                                  | 10 ++++-----
 kernel/audit.h                                  |  2 +-
 kernel/auditsc.c                                |  6 +++---
 kernel/time/time.c                              | 14 -------------
 kernel/trace/trace_entries.h                    |  6 +++---
 kernel/trace/trace_hwlat.c                      | 14 ++++++-------
 kernel/trace/trace_output.c                     |  9 ++++----
 net/ceph/messenger.c                            |  6 ++++--
 net/ceph/osd_client.c                           |  4 ++--
 security/apparmor/apparmorfs.c                  |  2 +-
 30 files changed, 100 insertions(+), 111 deletions(-)

-- 
2.7.4
