From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:20 -0400
Subject: [lustre-devel] [PATCH 0/9] bunch of small bug fixes for libcfs
Message-ID: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Various small miscellanous fixes that have gone into libcfs.

James Simmons (7):
  staging: lustre: libcfs: remove function declarations in libcfs.h
  staging: lustre: libcfs: remove cfs_signal_pending wrapper
  staging: lustre: libcfs: remove atomic cpt allocations
  staging: lustre: libcfs: remove cfs_percpt_[current|index]
  staging: lustre: libcfs: move all cpt handling to libcfs_cpu.h
  staging: lustre: libcfs: add CFS_FAULT_CHECK()
  staging: lustre: libcfs: remove cfs_workitem_t typedefs

Jian Yu (1):
  staging: lustre: libcfs: replace direct HZ access with kernel APIs

Liang Zhen (1):
  staging: lustre: libcfs: add lock-class for cfs_percpt_lock

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    8 --
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   79 ++++++++++++++++++++
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   15 +++-
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |   75 -------------------
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |   12 ++--
 .../lustre/include/linux/libcfs/linux/linux-time.h |    4 +-
 drivers/staging/lustre/lnet/libcfs/fail.c          |    3 +
 drivers/staging/lustre/lnet/libcfs/hash.c          |    6 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   54 +++-----------
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   28 -------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    5 +-
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |    7 --
 drivers/staging/lustre/lnet/libcfs/module.c        |    7 ++
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   12 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h    |    4 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    6 +-
 19 files changed, 139 insertions(+), 194 deletions(-)
