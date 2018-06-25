From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:49 -0400
Subject: [lustre-devel] [PATCH v2 0/7] lustre: libcfs: tracefile cleanups
Message-ID: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The first three patches in this series are a repost of Neil's patches.
The 4th patch fixed the brokeness of cfs_print_to_console() which shows
up in my testing. Besides the fixing more cleanups of tracefile.h was
done. The rest of the patches are Neil's work rebased due the changes
of the 4th patch.

NeilBrown (7):
  lustre: libcfs: discard TCD_MAX_TYPES
  lustre: libcfs: move tracefile locking from linux-tracefile.c to tracefile.c
  lustre: libcfs: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
  lustre: libcfs: move tcd locking across to tracefile.c
  lustre: libcfs: merge linux-tracefile.c into tracefile.c
  lustre: libcfs: fold cfs_tracefile_*_arch into their only callers.
  lustre: libcfs: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT

 drivers/staging/lustre/lnet/libcfs/Makefile        |   2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |   6 +-
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 258 --------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 266 +++++++++++++++++----
 drivers/staging/lustre/lnet/libcfs/tracefile.h     | 112 +--------
 5 files changed, 234 insertions(+), 410 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c

-- 
1.8.3.1
