From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Jun 2018 15:38:29 -0400
Subject: [lustre-devel] [PATCH v3 00/13] lustre: libcfs: tracefile cleanups
Message-ID: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The first three patches in this series are a repost of Neil's patches.
I updated the 4th patch but it contained to many changes so I broke
it into 6 smaller patches for easier review. It address all the
brokeness of cfs_print_to_console() which shows up in my testing.
Besides the fixing more cleanups of tracefile.h was done in the
new patches. The rest of the patches are Neil's work rebased due
the changes I introduced.

James Simmons (6):
  lustre: libcfs: fix cfs_print_to_console()
  lustre: libcfs: properly handle failure paths in cfs_tracefile_init_arch()
  lustre: libcfs: remove cfs_trace_refill_stack()
  lustre: libcfs: move cfs_trace_data data to tracefile.c
  lustre: libcfs: cleanup tracefile.h
  lustre: libcfs: format macros in tracefile.h

NeilBrown (7):
  lustre: libcfs: move tracefile locking from linux-tracefile.c to tracefile.c
  lustre: libcfs: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
  lustre: libcfs: move tcd locking across to tracefile.c
  lustre: libcfs: merge linux-tracefile.c into tracefile.c
  lustre: libcfs: fold cfs_tracefile_*_arch into their only callers.
  lustre: libcfs: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
  lustre: libcfs: discard TCD_MAX_TYPES

-------------
Changelog

1) Initial patches from Neil Brown

2) Neil's patches pushed with the 4th patch heavly updated.

3) Broke up the 4th patch I pushed into smaller patches for
   easier review.

 drivers/staging/lustre/lnet/libcfs/Makefile        |   2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |   6 +-
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 258 --------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 267 +++++++++++++++++----
 drivers/staging/lustre/lnet/libcfs/tracefile.h     | 117 +--------
 5 files changed, 237 insertions(+), 413 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c

-- 
1.8.3.1
