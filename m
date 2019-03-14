From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:51 +1100
Subject: [lustre-devel] [PATCH 27/32] lustre: don't call unshare_fs_struct()
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231148.26912.899667623955916563.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A kthread runs with the same fs_struct as init.
It is only helpful to unshare this if the thread
will change one of the fields in the fs_struct:
 root directory
 current working directory
 umask.

No lustre kthread changes any of these, so there is
no need to call unshare_fs_struct().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/llog.c  |    3 ---
 drivers/staging/lustre/lustre/ptlrpc/import.c  |    3 ---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c |    2 --
 drivers/staging/lustre/lustre/ptlrpc/service.c |    4 ----
 4 files changed, 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index a34b1a7108b7..ebb6c03ef038 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -45,7 +45,6 @@
 #define DEBUG_SUBSYSTEM S_LOG
 
 #include <linux/kthread.h>
-#include <linux/fs_struct.h>
 #include <llog_swab.h>
 #include <lustre_log.h>
 #include <obd_class.h>
@@ -399,8 +398,6 @@ static int llog_process_thread_daemonize(void *arg)
 	struct lu_env env;
 	int rc;
 
-	unshare_fs_struct();
-
 	/* client env has no keys, tags is just 0 */
 	rc = lu_env_init(&env, LCT_LOCAL | LCT_MG_THREAD);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 26a976865fbd..b2a57d2bdde7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -38,7 +38,6 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
-#include <linux/fs_struct.h>
 #include <obd_support.h>
 #include <lustre_ha.h>
 #include <lustre_net.h>
@@ -1328,8 +1327,6 @@ static int ptlrpc_invalidate_import_thread(void *data)
 {
 	struct obd_import *imp = data;
 
-	unshare_fs_struct();
-
 	CDEBUG(D_HA, "thread invalidate import %s to %s@%s\n",
 	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_connection->c_remote_uuid.uuid);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index c295e9943bf7..b02e6c50bae1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -53,7 +53,6 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
-#include <linux/fs_struct.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_cpu.h>
 #include <linux/libcfs/libcfs_string.h>
@@ -389,7 +388,6 @@ static int ptlrpcd(void *arg)
 	int rc = 0;
 	int exit = 0;
 
-	unshare_fs_struct();
 	if (cfs_cpt_bind(cfs_cpt_tab, pc->pc_cpt) != 0)
 		CWARN("Failed to bind %s on CPT %d\n", pc->pc_name, pc->pc_cpt);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index c6b95c721167..571f0455e7b0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -34,7 +34,6 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
-#include <linux/fs_struct.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
@@ -2029,7 +2028,6 @@ static int ptlrpc_main(void *arg)
 	int counter = 0, rc = 0;
 
 	thread->t_pid = current->pid;
-	unshare_fs_struct();
 
 	/* NB: we will call cfs_cpt_bind() for all threads, because we
 	 * might want to run lustre server only on a subset of system CPUs,
@@ -2230,8 +2228,6 @@ static int ptlrpc_hr_main(void *arg)
 	LIST_HEAD(replies);
 	int rc;
 
-	unshare_fs_struct();
-
 	rc = cfs_cpt_bind(ptlrpc_hr.hr_cpt_table, hrp->hrp_cpt);
 	if (rc != 0) {
 		char threadname[20];
