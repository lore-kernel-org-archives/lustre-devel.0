From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:09 -0500
Subject: [lustre-devel] [PATCH 04/13] staging: lustre: move
	kernel_user_comm.c from libcfs to lustre
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

Move the kernel portion from libcfs to obdclass. This code is
only used by lustre. This is broken out of the original patch
14270. The part covered by this change is as follows:

The original code in kernel_user_comm.c is split into two parts:

  * obdclass/kernelcomm.c for the kernel part. filp_user_write() was
    moved there, and linux-fs.c deleted;
  * liblustreapi_kernelconn.c for the user part. The calls to CDEBUG
    have been removed, and calls to CERROR have been transformed to
    llapi_err_noerrno. The type lustre_kernelcomm has been removed and
    replace by struct lustre_kernelcomm.

Various names and filenames have been harmonized to *kernelcomm*.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14270
Reviewed-by: Nathan Rutman <nathan.rutman@seagate.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/Makefile      |    5 ++---
 drivers/staging/lustre/lustre/obdclass/Makefile    |   10 +++++-----
 .../kernel_user_comm.c => obdclass/kernelcomm.c}   |    0
 3 files changed, 7 insertions(+), 8 deletions(-)
 rename drivers/staging/lustre/lustre/{libcfs/kernel_user_comm.c => obdclass/kernelcomm.c} (100%)

diff --git a/drivers/staging/lustre/lustre/libcfs/Makefile b/drivers/staging/lustre/lustre/libcfs/Makefile
index 03d3f3d..277c123 100644
--- a/drivers/staging/lustre/lustre/libcfs/Makefile
+++ b/drivers/staging/lustre/lustre/libcfs/Makefile
@@ -11,8 +11,7 @@ libcfs-linux-objs += linux-mem.o
 libcfs-linux-objs := $(addprefix linux/,$(libcfs-linux-objs))
 
 libcfs-all-objs := debug.o fail.o module.o tracefile.o \
-		   libcfs_string.o hash.o kernel_user_comm.o \
-		   prng.o workitem.o libcfs_cpu.o \
-		   libcfs_mem.o libcfs_lock.o
+		   libcfs_string.o hash.o prng.o workitem.o \
+		   libcfs_cpu.o libcfs_mem.o libcfs_lock.o
 
 libcfs-objs := $(libcfs-linux-objs) $(libcfs-all-objs)
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index acc6857..c404eb3 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -2,8 +2,8 @@ obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
 obdclass-y := linux/linux-module.o linux/linux-obdo.o linux/linux-sysctl.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
-	      genops.o uuid.o lprocfs_status.o \
-	      lustre_handles.o lustre_peer.o \
-	      statfs_pack.o obdo.o obd_config.o obd_mount.o \
-	      lu_object.o cl_object.o   \
-	      cl_page.o cl_lock.o cl_io.o lu_ref.o acl.o lprocfs_counters.o
+	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
+	      lustre_handles.o lustre_peer.o statfs_pack.o \
+	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
+	      cl_object.o cl_page.o cl_lock.o cl_io.o \
+	      acl.o kernelcomm.o
diff --git a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
similarity index 100%
rename from drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
rename to drivers/staging/lustre/lustre/obdclass/kernelcomm.c
-- 
1.7.1
