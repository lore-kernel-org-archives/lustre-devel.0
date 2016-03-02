From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:02 -0500
Subject: [lustre-devel] [PATCH 19/27] staging: lustre: corrected some typos
	and grammar errors
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

Cleanup various typos and grammar errors.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5710
Reviewed-on: http://review.whamcloud.com/12201
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    6 +++---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index bd3552e..c1ca8dc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -758,7 +758,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
 	if (rc) {
-		CERROR("Can't request completion notificiation: %d\n", rc);
+		CERROR("Can't request completion notification: %d\n", rc);
 		goto failed_2;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index bd88a3b..b3368d7 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -878,7 +878,7 @@ int ll_get_mdt_idx(struct inode *inode)
 /**
  * Generic handler to do any pre-copy work.
  *
- * It send a first hsm_progress (with extent length == 0) to coordinator as a
+ * It sends a first hsm_progress (with extent length == 0) to coordinator as a
  * first information for it that real work has started.
  *
  * Moreover, for a ARCHIVE request, it will sample the file data version and
@@ -930,7 +930,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 			goto progress;
 		}
 
-		/* Store it the hsm_copy for later copytool use.
+		/* Store in the hsm_copy for later copytool use.
 		 * Always modified even if no lsm.
 		 */
 		copy->hc_data_version = data_version;
@@ -1008,7 +1008,7 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 			goto progress;
 		}
 
-		/* Store it the hsm_copy for later copytool use.
+		/* Store in the hsm_copy for later copytool use.
 		 * Always modified even if no lsm.
 		 */
 		hpk.hpk_data_version = data_version;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0fa4bac..200d6e8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -134,7 +134,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	}
 
 	/*
-	 * If object is dying (will not be cached), removed it
+	 * If object is dying (will not be cached), then removed it
 	 * from hash table and LRU.
 	 *
 	 * This is done with hash table and LRU lists locked. As the only
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 70fcac1..5b33dd5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1360,7 +1360,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		{
 		struct task_struct *task;
 		/* bug 17802:  XXX client_disconnect_export vs connect request
-		 * race. if client will evicted at this time, we start
+		 * race. if client is evicted at this time, we start
 		 * invalidate thread without reference to import and import can
 		 * be freed at same time.
 		 */
-- 
1.7.1
