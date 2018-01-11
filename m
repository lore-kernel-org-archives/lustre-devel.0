From: NeilBrown <neilb@suse.com>
Date: Thu, 11 Jan 2018 15:06:40 +1100
Subject: [lustre-devel] [PATCH 0/2] staging: lustre: finish removal of
 workitem code.
Message-ID: <151564345630.21794.1667069238139184132.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tejun Heo <tj@kernel.org>

This is a resend of the last two patches of my "remove workitem code",
which resolve a merge conflict and add and 'Ack-by' from Tejun.
The first two patches have already been merged.

Thanks,
NeilBrown

Original intro:
Lustre has a "workitem" subsystem with much the same
functionality as the Linux workqueue subsystem.
This patch converts all users of workitem to workqueue,
then removes workitem.


---

NeilBrown (2):
      staging: lustre: lnet: convert selftest to use workqueues
      staging: lustre: libcfs: remove workitem code.


 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |  104 ----
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/module.c        |   11 
 drivers/staging/lustre/lnet/libcfs/workitem.c      |  466 --------------------
 drivers/staging/lustre/lnet/selftest/framework.c   |   10 
 drivers/staging/lustre/lnet/selftest/module.c      |   39 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   61 +--
 drivers/staging/lustre/lnet/selftest/selftest.h    |   40 +-
 kernel/workqueue.c                                 |    1 
 10 files changed, 71 insertions(+), 664 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/workitem.c

--
Signature
