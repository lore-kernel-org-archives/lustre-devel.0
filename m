From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:25:19 +1100
Subject: [lustre-devel] [PATCH SERIES 3: 0/4] staging:lustre: remove
 workitem code
Message-ID: <151356013394.15912.9645528414310488005.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Lustre has a "workitem" subsystem with much the same
functionality as the Linux workqueue subsystem.
This patch converts all users of workitem to workqueue,
then removes workitem.

This requires that "apply_workqueue_attrs" be exported
to modules, so this intro and the patch which does
the EXPORT_SYMBOL_GPL are cc:ed to Tejun and Lai.

Thanks,
NeilBrown


---

NeilBrown (4):
      staging: lustre: libcfs: use a workqueue for rehash work.
      staging: lustre: libcfs: remove wi_data from cfs_workitem
      staging: lustre: lnet: convert selftest to use workqueues
      staging: lustre: libcfs: remove workitem code.


 .../staging/lustre/include/linux/libcfs/libcfs.h   |    3 
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    6 
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |  107 -----
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/hash.c          |   82 +---
 drivers/staging/lustre/lnet/libcfs/module.c        |   27 -
 drivers/staging/lustre/lnet/libcfs/workitem.c      |  466 --------------------
 drivers/staging/lustre/lnet/selftest/framework.c   |   14 -
 drivers/staging/lustre/lnet/selftest/module.c      |   39 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   71 +--
 drivers/staging/lustre/lnet/selftest/selftest.h    |   44 +-
 kernel/workqueue.c                                 |    1 
 12 files changed, 111 insertions(+), 751 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/workitem.c

--
Signature
