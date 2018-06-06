From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:19 +1000
Subject: [lustre-devel] [PATCH 11/11] staging: lustre: centralize setting of
 subdir-ccflags-y
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511930.16761.12770722873423628004.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

We don't need to set subdir-ccflags-y in every Makefile.
The whole point of the "subdir-" bit is that the setting
can go once in the top-level Makefile.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/Makefile                    |    3 +++
 drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile |    2 --
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile |    2 --
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 --
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 --
 drivers/staging/lustre/lnet/selftest/Makefile      |    2 --
 drivers/staging/lustre/lustre/fid/Makefile         |    2 --
 drivers/staging/lustre/lustre/fld/Makefile         |    2 --
 drivers/staging/lustre/lustre/llite/Makefile       |    2 --
 drivers/staging/lustre/lustre/lmv/Makefile         |    2 --
 drivers/staging/lustre/lustre/lov/Makefile         |    2 --
 drivers/staging/lustre/lustre/mdc/Makefile         |    2 --
 drivers/staging/lustre/lustre/mgc/Makefile         |    2 --
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 --
 drivers/staging/lustre/lustre/obdecho/Makefile     |    2 --
 drivers/staging/lustre/lustre/osc/Makefile         |    2 --
 drivers/staging/lustre/lustre/ptlrpc/Makefile      |    2 --
 17 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/Makefile b/drivers/staging/lustre/Makefile
index 95ffe337a80a..a44086fa8668 100644
--- a/drivers/staging/lustre/Makefile
+++ b/drivers/staging/lustre/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET)		+= lnet/
 obj-$(CONFIG_LUSTRE_FS)		+= lustre/
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
index 4affe1d79948..e1a05ece130c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET_XPRT_IB) += ko2iblnd.o
 ko2iblnd-y := o2iblnd.o o2iblnd_cb.o o2iblnd_modparams.o
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
index a7da1abfc804..4d03cad997c1 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET) += ksocklnd.o
 
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 6a1b232da495..3d6b99c6e883 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET) += libcfs.o
 
diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 0a9d70924fe0..ba33e90e47ec 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET) += lnet.o
 
diff --git a/drivers/staging/lustre/lnet/selftest/Makefile b/drivers/staging/lustre/lnet/selftest/Makefile
index 3ccc8966b566..16f8efcd1531 100644
--- a/drivers/staging/lustre/lnet/selftest/Makefile
+++ b/drivers/staging/lustre/lnet/selftest/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET_SELFTEST) := lnet_selftest.o
 
diff --git a/drivers/staging/lustre/lustre/fid/Makefile b/drivers/staging/lustre/lustre/fid/Makefile
index 77b65b92667d..11f6e4046e61 100644
--- a/drivers/staging/lustre/lustre/fid/Makefile
+++ b/drivers/staging/lustre/lustre/fid/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
 
 obj-$(CONFIG_LUSTRE_FS) += fid.o
 fid-y := fid_request.o fid_lib.o lproc_fid.o
diff --git a/drivers/staging/lustre/lustre/fld/Makefile b/drivers/staging/lustre/lustre/fld/Makefile
index 426deba8b815..e7843d7aac9d 100644
--- a/drivers/staging/lustre/lustre/fld/Makefile
+++ b/drivers/staging/lustre/lustre/fld/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
 
 obj-$(CONFIG_LUSTRE_FS) += fld.o
 fld-y := fld_request.o fld_cache.o lproc_fld.o
diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 5200924182ae..f46b61770254 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
diff --git a/drivers/staging/lustre/lustre/lmv/Makefile b/drivers/staging/lustre/lustre/lmv/Makefile
index 91c99114aa13..7a392c31c508 100644
--- a/drivers/staging/lustre/lustre/lmv/Makefile
+++ b/drivers/staging/lustre/lustre/lmv/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += lmv.o
 lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
diff --git a/drivers/staging/lustre/lustre/lov/Makefile b/drivers/staging/lustre/lustre/lov/Makefile
index 1ebf0193f61a..6294769aca95 100644
--- a/drivers/staging/lustre/lustre/lov/Makefile
+++ b/drivers/staging/lustre/lustre/lov/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += lov.o
 lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
index c7bc3351ccb0..c3bc71f6596d 100644
--- a/drivers/staging/lustre/lustre/mdc/Makefile
+++ b/drivers/staging/lustre/lustre/mdc/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
diff --git a/drivers/staging/lustre/lustre/mgc/Makefile b/drivers/staging/lustre/lustre/mgc/Makefile
index 8abf108dbcf7..301cd7a1fa25 100644
--- a/drivers/staging/lustre/lustre/mgc/Makefile
+++ b/drivers/staging/lustre/lustre/mgc/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += mgc.o
 mgc-y := mgc_request.o lproc_mgc.o
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index e36ba2167d10..be118391b402 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
diff --git a/drivers/staging/lustre/lustre/obdecho/Makefile b/drivers/staging/lustre/lustre/obdecho/Makefile
index 6be66fbab872..4ae346f5ddcd 100644
--- a/drivers/staging/lustre/lustre/obdecho/Makefile
+++ b/drivers/staging/lustre/lustre/obdecho/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdecho.o
 obdecho-y := echo_client.o
diff --git a/drivers/staging/lustre/lustre/osc/Makefile b/drivers/staging/lustre/lustre/osc/Makefile
index 30dec90e64e8..ecdf07e925c7 100644
--- a/drivers/staging/lustre/lustre/osc/Makefile
+++ b/drivers/staging/lustre/lustre/osc/Makefile
@@ -1,5 +1,3 @@
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += osc.o
 osc-y := osc_request.o osc_dev.o osc_object.o \
diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
index aa152e652002..0fae7de09de2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/Makefile
+++ b/drivers/staging/lustre/lustre/ptlrpc/Makefile
@@ -1,6 +1,4 @@
 # SPDX-License-Identifier: GPL-2.0
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
-subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += ptlrpc.o
 
