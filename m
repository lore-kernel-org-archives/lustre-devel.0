From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:38 -0500
Subject: [lustre-devel] [PATCH 00/19] LNet/libcfs checkpatch and style
	cleanups
Message-ID: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Sweep of the LNet/libcfs layer to cleanup various
checkpatch issues. Also more cleanups to match
the kernel coding style.

James Simmons (19):
  staging: lustre: lnet: don't use bare unsigned
  staging: lustre: lnet: resolve trailing */ checkpatch errors
  staging: lustre: libcfs: use static const char const * for a suffixes array
  staging: lustre: libcfs: remove explict test of NULL variable
  staging: lustre: libcfs: fix aligment issue
  staging: lustre: lnet: fix misspelled word destroy
  staging: lustre: lnet: remove unused lib_me_dump
  staging: lustre: lnet: missing blank line after declaration
  staging: lustre: lnet: fill in real lnet_md_t
  staging: lustre: lnet: replace uninitialized_var
  staging: lustre: libcfs: remove != 0 testing
  staging: lustre: libcfs: remove == 0 testing
  staging: lustre: libcfs: white space cleanup
  staging: lustre: libcfs: fix misspelling of descriptor
  staging: lustre: libcfs: Make char * array envp static constant
  staging: lustre: libcfs: use pr_* instead of printk
  staging: lustre: libcfs: remove use of __u* types
  staging: lustre: lnet: use BIT macro in LNet selftest
  staging: lustre: lnet: cleanup some of the > 80 line issues

 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   31 +++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  132 +++++++++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   40 ++++--
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    6 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   26 +++-
 drivers/staging/lustre/lnet/libcfs/debug.c         |   36 +++---
 drivers/staging/lustre/lnet/libcfs/fail.c          |    4 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |  117 +++++++++---------
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   20 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   22 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   58 +++++-----
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |  132 ++++++++++----------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   32 +++---
 .../lustre/lnet/libcfs/linux/linux-crypto.h        |    2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |   20 ++--
 .../lustre/lnet/libcfs/linux/linux-module.c        |    2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   10 +-
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |   28 ++--
 drivers/staging/lustre/lnet/libcfs/module.c        |   18 ++--
 drivers/staging/lustre/lnet/libcfs/prng.c          |    2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |  108 ++++++++--------
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   28 ++--
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   50 ++++----
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    8 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   18 ---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    1 +
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   17 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c      |    2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   28 +++--
 drivers/staging/lustre/lnet/selftest/conrpc.h      |   23 ++--
 drivers/staging/lustre/lnet/selftest/console.c     |   27 +++--
 drivers/staging/lustre/lnet/selftest/console.h     |   25 ++--
 drivers/staging/lustre/lnet/selftest/framework.c   |   23 ++--
 drivers/staging/lustre/lnet/selftest/ping_test.c   |    4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    3 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         |    6 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   25 +++--
 drivers/staging/lustre/lnet/selftest/timer.c       |    7 +-
 40 files changed, 621 insertions(+), 526 deletions(-)
