From: James Simmons <jsimmons@infradead.org>
Date: Tue,  8 Mar 2016 17:35:25 -0500
Subject: [lustre-devel] [PATCH 0/4] Support lustre routers with stand alone
	LNet stack
Message-ID: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Often lustre file systems will employ LNet routers in their
set ups. Those routers tend to be very light weight so we want
to avoid installing additional software that will burden the
system. Installing the entire lustre client can be pretty heavy
so we want to give the ability to only enable the LNet stack for
the routers which is all that is needed anyways. This patch series
allows that option for users of the upstream client.

James Simmons (4):
  staging: lustre: move libcfs to lnet layer
  staging: lustre: fixup kernel Kconfig option LNET_MAX_PAYLOAD
  staging: lustre: add help section of Kconfig config LNET
  staging: lustre: make lustre dependent on LNet

 drivers/staging/Makefile                           |    2 +-
 drivers/staging/lustre/Kconfig                     |    4 ++--
 drivers/staging/lustre/lnet/Kconfig                |   14 ++++++++++----
 drivers/staging/lustre/lnet/Makefile               |    2 +-
 .../lustre/{lustre => lnet}/libcfs/Makefile        |    2 +-
 .../staging/lustre/{lustre => lnet}/libcfs/debug.c |    0
 .../staging/lustre/{lustre => lnet}/libcfs/fail.c  |    0
 .../staging/lustre/{lustre => lnet}/libcfs/hash.c  |    0
 .../lustre/{lustre => lnet}/libcfs/libcfs_cpu.c    |    0
 .../lustre/{lustre => lnet}/libcfs/libcfs_lock.c   |    0
 .../lustre/{lustre => lnet}/libcfs/libcfs_mem.c    |    0
 .../lustre/{lustre => lnet}/libcfs/libcfs_string.c |    0
 .../{lustre => lnet}/libcfs/linux/linux-cpu.c      |    0
 .../libcfs/linux/linux-crypto-adler.c              |    0
 .../{lustre => lnet}/libcfs/linux/linux-crypto.c   |    0
 .../{lustre => lnet}/libcfs/linux/linux-crypto.h   |    0
 .../{lustre => lnet}/libcfs/linux/linux-curproc.c  |    0
 .../{lustre => lnet}/libcfs/linux/linux-debug.c    |    0
 .../{lustre => lnet}/libcfs/linux/linux-mem.c      |    0
 .../{lustre => lnet}/libcfs/linux/linux-module.c   |    0
 .../{lustre => lnet}/libcfs/linux/linux-prim.c     |    0
 .../libcfs/linux/linux-tracefile.c                 |    0
 .../lustre/{lustre => lnet}/libcfs/module.c        |    0
 .../staging/lustre/{lustre => lnet}/libcfs/prng.c  |    0
 .../lustre/{lustre => lnet}/libcfs/tracefile.c     |    0
 .../lustre/{lustre => lnet}/libcfs/tracefile.h     |    0
 .../lustre/{lustre => lnet}/libcfs/workitem.c      |    0
 drivers/staging/lustre/lustre/Kconfig              |    2 +-
 drivers/staging/lustre/lustre/Makefile             |    2 +-
 29 files changed, 17 insertions(+), 11 deletions(-)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/Makefile (93%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/debug.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/fail.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/hash.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/libcfs_cpu.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/libcfs_lock.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/libcfs_mem.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/libcfs_string.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-cpu.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-crypto-adler.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-crypto.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-crypto.h (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-curproc.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-debug.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-mem.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-module.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-prim.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/linux/linux-tracefile.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/module.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/prng.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/tracefile.c (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/tracefile.h (100%)
 rename drivers/staging/lustre/{lustre => lnet}/libcfs/workitem.c (100%)
