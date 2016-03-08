From: James Simmons <jsimmons@infradead.org>
Date: Tue,  8 Mar 2016 17:35:26 -0500
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: move libcfs to lnet
	layer
In-Reply-To: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
References: <1457476529-27708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457476529-27708-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The lustre file system has a layered architecture with
libcfs as the lowest layer and LNet layered on top. Then
on top of LNet we run the lustre client. This patch moves
the libcfs module code out of lustre into the lnet tree.
This fits into the long term goal of eventually merging
libcfs into LNet.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
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
 drivers/staging/lustre/lustre/Makefile             |    2 +-
 25 files changed, 3 insertions(+), 3 deletions(-)
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

diff --git a/drivers/staging/lustre/lnet/Makefile b/drivers/staging/lustre/lnet/Makefile
index f6f03e3..0a380fe 100644
--- a/drivers/staging/lustre/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_LNET) += lnet/ klnds/ selftest/
+obj-$(CONFIG_LNET) += libcfs/ lnet/ klnds/ selftest/
diff --git a/drivers/staging/lustre/lustre/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
similarity index 93%
rename from drivers/staging/lustre/lustre/libcfs/Makefile
rename to drivers/staging/lustre/lnet/libcfs/Makefile
index 277c123..8c89455 100644
--- a/drivers/staging/lustre/lustre/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_LUSTRE_FS) += libcfs.o
+obj-$(CONFIG_LNET) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
 libcfs-linux-objs += linux-prim.o linux-cpu.o
diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/debug.c
rename to drivers/staging/lustre/lnet/libcfs/debug.c
diff --git a/drivers/staging/lustre/lustre/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/fail.c
rename to drivers/staging/lustre/lnet/libcfs/fail.c
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/hash.c
rename to drivers/staging/lustre/lnet/libcfs/hash.c
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
rename to drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
rename to drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
rename to drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/libcfs_string.c
rename to drivers/staging/lustre/lnet/libcfs/libcfs_string.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto-adler.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-crypto-adler.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.h b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.h
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-prim.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
rename to drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/module.c
rename to drivers/staging/lustre/lnet/libcfs/module.c
diff --git a/drivers/staging/lustre/lustre/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/prng.c
rename to drivers/staging/lustre/lnet/libcfs/prng.c
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/tracefile.c
rename to drivers/staging/lustre/lnet/libcfs/tracefile.c
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/tracefile.h
rename to drivers/staging/lustre/lnet/libcfs/tracefile.h
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/workitem.c
rename to drivers/staging/lustre/lnet/libcfs/workitem.c
diff --git a/drivers/staging/lustre/lustre/Makefile b/drivers/staging/lustre/lustre/Makefile
index 35d8b0b..331e4fc 100644
--- a/drivers/staging/lustre/lustre/Makefile
+++ b/drivers/staging/lustre/lustre/Makefile
@@ -1,2 +1,2 @@
-obj-$(CONFIG_LUSTRE_FS) += libcfs/ obdclass/ ptlrpc/ fld/ osc/ mgc/ \
+obj-$(CONFIG_LUSTRE_FS) += obdclass/ ptlrpc/ fld/ osc/ mgc/ \
 			   fid/ lov/ mdc/ lmv/ llite/ obdecho/
-- 
1.7.1
