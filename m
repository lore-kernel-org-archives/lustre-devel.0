From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:28 -0700
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for rate-limiting
	Quality of Service (RLQOS)
In-Reply-To: <cover.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
Message-ID: <99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch enables rate-limiting quality of service (RLQOS) support as
talked in the ASCAR paper [1]. The purpose of RLQOS is to provide a
client-side rate limiting mechanism that controls max_rpcs_in_flight
and minimal gap between brw RPC requests (called tau in the code and
paper).

RLQOS can be enabled by passing --enable-rlqos to configure. It then
can be controlled by tunables in procfs of each osc.

[1] http://storageconference.us/2015/Papers/14.Li.pdf

Signed-off-by: Yan Li <yanli@ascar.io>
---
 lustre/autoconf/lustre-core.m4 | 17 +++++++++++++++++
 lustre/include/Makefile.am     |  3 ++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/lustre/autoconf/lustre-core.m4 b/lustre/autoconf/lustre-core.m4
index 0578325..7f1828e 100644
--- a/lustre/autoconf/lustre-core.m4
+++ b/lustre/autoconf/lustre-core.m4
@@ -369,6 +369,22 @@ AC_COMPILE_IFELSE([AC_LANG_SOURCE([
 AC_MSG_RESULT([$enable_ssk])
 ]) # LC_OPENSSL_SSK
 
+#
+# LC_CONFIG_RLQOS
+#
+# Rate-limiting Quality of Service support
+#
+AC_DEFUN([LC_CONFIG_RLQOS], [
+AC_MSG_CHECKING([whether to enable rate-limiting quality of service support])
+AC_ARG_ENABLE([rlqos],
+	AC_HELP_STRING([--enable-rlqos],
+		[enable rate-limiting quality of service support]),
+	[], [enable_rlqos="no"])
+AC_MSG_RESULT([$enable_rlqos])
+AS_IF([test "x$enable_rlqos" != xno],
+	[AC_DEFINE(ENABLE_RLQOS, 1, [enable rate-limiting quality of service support])])
+]) # LC_CONFIG_RLQOS
+
 # LC_INODE_PERMISION_2ARGS
 #
 # up to v2.6.27 had a 3 arg version (inode, mask, nameidata)
@@ -2241,6 +2257,7 @@ AC_DEFUN([LC_PROG_LINUX], [
 	LC_GLIBC_SUPPORT_FHANDLES
 	LC_CONFIG_GSS
 	LC_OPENSSL_SSK
+	LC_CONFIG_RLQOS
 
 	# 2.6.32
 	LC_BLK_QUEUE_MAX_SEGMENTS
diff --git a/lustre/include/Makefile.am b/lustre/include/Makefile.am
index 9074ca4..6d72b6e 100644
--- a/lustre/include/Makefile.am
+++ b/lustre/include/Makefile.am
@@ -98,4 +98,5 @@ EXTRA_DIST = \
 	upcall_cache.h \
 	lustre_kernelcomm.h \
 	seq_range.h \
-	uapi_kernelcomm.h
+	uapi_kernelcomm.h \
+	rlqos.h
-- 
1.8.3.1
