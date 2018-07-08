From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:14 -0400
Subject: [lustre-devel] [PATCH v4 00/14] lustre: libcfs: tracefile cleanups
Message-ID: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The 4th version of a patch series aimed to cleanup the lustre tracefile
handling. This set is mainly a repost of the 3rd set with the addition
of a bug fix, patch number 2, that added proper range checking for the
debugfs parameter debug_mb. The 6th patch has been updated based on
Andreas Dilger's feedback to resolve the brokeness of cfs_print_to_console().
This patch series has been reposted to allow anyone interested in testing
the the major changes are in the 6th and 7th patch which was rebased due
to changes in the code.

James Simmons (6):
  lustre: libcfs: properly handle failure paths in cfs_tracefile_init_arch()
  lustre: libcfs: fix cfs_print_to_console()
  lustre: libcfs: remove cfs_trace_refill_stack()
  lustre: libcfs: move cfs_trace_data data to tracefile.c
  lustre: libcfs: cleanup tracefile.h
  lustre: libcfs: format macros in tracefile.h

NeilBrown (8):
  lustre: libcfs: move tracefile locking from linux-tracefile.c to tracefile.c
  lustre: libcfs: always range-check libcfs_debug_mb setting.
  lustre: libcfs: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
  lustre: libcfs: move tcd locking across to tracefile.c
  lustre: libcfs: merge linux-tracefile.c into tracefile.c
  lustre: libcfs: fold cfs_tracefile_*_arch into their only callers.
  lustre: libcfs: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
  lustre: libcfs: discard TCD_MAX_TYPES

 drivers/staging/lustre/lnet/libcfs/Makefile        |   2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |  22 +-
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 258 -------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 279 +++++++++++++++++----
 drivers/staging/lustre/lnet/libcfs/tracefile.h     | 117 +--------
 5 files changed, 255 insertions(+), 423 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c

-- 
1.8.3.1
