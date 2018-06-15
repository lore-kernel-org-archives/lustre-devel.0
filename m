From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 06/24] lustre: build ldlm in the ldlm
 directory.
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669026.10587.12104937101821160060.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

ldlm code is currently build from the ptlrpc directory,
with files listed in the Makefile of that directory.
This is because both need to be in the same module.
This make partial builds such as
  make drivers/staging/lustre/lustre/ldlm/

ineffective.
kbuild recently gained the ability to build modules
from multiple directories.  Use that ability to
allow ldlm code to be built in the correct directory.

Note that we need to set KBUILD_MODNAME for ldlm to
build correctly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/Makefile   |   11 +++++++++++
 drivers/staging/lustre/lustre/ptlrpc/Makefile |   12 +++---------
 2 files changed, 14 insertions(+), 9 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/ldlm/Makefile

diff --git a/drivers/staging/lustre/lustre/ldlm/Makefile b/drivers/staging/lustre/lustre/ldlm/Makefile
new file mode 100644
index 000000000000..413943230572
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ldlm/Makefile
@@ -0,0 +1,11 @@
+# SPDX-License-Identifier: GPL-2.0
+ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+ccflags-y += -DKBUILD_MODNAME='"ptlrpc"'
+
+modobj-$(CONFIG_LUSTRE_FS) += l_lock.o ldlm_lock.o
+modobj-$(CONFIG_LUSTRE_FS) += ldlm_resource.o ldlm_lib.o
+modobj-$(CONFIG_LUSTRE_FS) += ldlm_plain.o ldlm_extent.o
+modobj-$(CONFIG_LUSTRE_FS) += ldlm_request.o ldlm_lockd.o
+modobj-$(CONFIG_LUSTRE_FS) += ldlm_flock.o ldlm_inodebits.o
+modobj-$(CONFIG_LUSTRE_FS) += ldlm_pool.o
diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
index e0a482712d8e..9c27b850c52d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/Makefile
+++ b/drivers/staging/lustre/lustre/ptlrpc/Makefile
@@ -3,20 +3,14 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += ptlrpc.o
-LDLM := ../../lustre/ldlm/
 
-ldlm_objs := $(LDLM)l_lock.o $(LDLM)ldlm_lock.o
-ldlm_objs += $(LDLM)ldlm_resource.o $(LDLM)ldlm_lib.o
-ldlm_objs += $(LDLM)ldlm_plain.o $(LDLM)ldlm_extent.o
-ldlm_objs += $(LDLM)ldlm_request.o $(LDLM)ldlm_lockd.o
-ldlm_objs += $(LDLM)ldlm_flock.o $(LDLM)ldlm_inodebits.o
-ldlm_objs += $(LDLM)ldlm_pool.o
-ptlrpc_objs := client.o recover.o connection.o niobuf.o pack_generic.o
+ptlrpc_objs += ../ldlm/
+ptlrpc_objs += client.o recover.o connection.o niobuf.o pack_generic.o
 ptlrpc_objs += events.o ptlrpc_module.o service.o pinger.o
 ptlrpc_objs += llog_net.o llog_client.o import.o ptlrpcd.o
 ptlrpc_objs += pers.o lproc_ptlrpc.o wiretest.o layout.o
 ptlrpc_objs += sec.o sec_bulk.o sec_gc.o sec_config.o
 ptlrpc_objs += sec_null.o sec_plain.o nrs.o nrs_fifo.o
 
-ptlrpc-y := $(ldlm_objs) $(ptlrpc_objs) sec_lproc.o
+ptlrpc-y := $(ptlrpc_objs) sec_lproc.o
 ptlrpc-$(CONFIG_LUSTRE_TRANSLATE_ERRNOS) += errno.o
