From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:34 -0400
Subject: [lustre-devel] [PATCH 0/6] cleanup libcfs memory handling
Message-ID: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The libcfs module contains memory handling which needs to be
cleaned up. First cleanup is to merge linux-mem.h and libcfs_prim.h.
This is left over for when libcfs was both a kernel module
and a userspace library. Second cleanup is remove some wrappers
that are not needed. Just use kernel API's directly instead.
One last change is the move of add_wait_queue_exclusive_head
to the lustre layer since that is the only place it is used.
With these changes linux-mem.h can be deleted.

James Simmons (6):
  staging: lustre: libcfs: move add_wait_queue_exclusive_head to lustre layer
  staging: lustre: libcfs: move memory_pressure functions to libcfs_prim.h
  staging: lustre: libcfs: remove page_index() macro
  staging: lustre: libcfs: remove MMSPACE macros
  staging: lustre: libcfs: move NUM_CACHEPAGES to libcfs_prim.h
  staging: lustre: libcfs: delete linux-mem.h

 .../lustre/include/linux/libcfs/libcfs_prim.h      |   31 +++++---
 .../lustre/include/linux/libcfs/linux/libcfs.h     |    2 +-
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    2 +-
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |   79 --------------------
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   24 ------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   17 ++--
 drivers/staging/lustre/lustre/include/lustre_lib.h |   22 ++++++
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 9 files changed, 55 insertions(+), 126 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
