From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:15 -0500
Subject: [lustre-devel] [PATCH v2 20/33] lustre: ldlm: Transfer layout only
 if layout lock is granted
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: wang di <di.wang@intel.com>

Make sure that only valid layout is transferred;
Client also checks if lock is granted before trusting the layout;
Restore change LU-3299 commit e2335e5d because it breaks the
assumption that l_lvb_data is immutable once assigned;

Fixes: e2335e5d52b2 ("staging/lustre/llite: force lvb_data update after layout change")
Signed-off-by: wang di <di.wang@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6581
Reviewed-on: http://review.whamcloud.com/14726
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 18 ------------------
 drivers/staging/lustre/lustre/llite/file.c      | 15 +++++++++------
 drivers/staging/lustre/lustre/mdc/mdc_locks.c   | 10 ++++++++--
 3 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 986c378..e766f798 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -187,24 +187,6 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 				rc = -EINVAL;
 				goto out;
 			}
-		} else if (ldlm_has_layout(lock)) { /* for layout lock, lvb has
-						     * variable length
-						     */
-			void *lvb_data;
-
-			lvb_data = kzalloc(lvb_len, GFP_NOFS);
-			if (!lvb_data) {
-				LDLM_ERROR(lock, "No memory: %d.\n", lvb_len);
-				rc = -ENOMEM;
-				goto out;
-			}
-
-			lock_res_and_lock(lock);
-			LASSERT(!lock->l_lvb_data);
-			lock->l_lvb_type = LVB_T_LAYOUT;
-			lock->l_lvb_data = lvb_data;
-			lock->l_lvb_len = lvb_len;
-			unlock_res_and_lock(lock);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a976e15..6a0a468 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3641,7 +3641,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	       PFID(ll_inode2fid(inode)), ldlm_is_lvb_ready(lock),
 	       lock->l_lvb_data, lock->l_lvb_len);
 
-	if (lock->l_lvb_data && ldlm_is_lvb_ready(lock))
+	if (lock->l_lvb_data)
 		return 0;
 
 	/* if layout lock was granted right away, the layout is returned
@@ -3683,13 +3683,16 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 
 	memcpy(lvbdata, lmm, lmmsize);
 	lock_res_and_lock(lock);
-	if (lock->l_lvb_data)
-		kvfree(lock->l_lvb_data);
-
-	lock->l_lvb_data = lvbdata;
-	lock->l_lvb_len = lmmsize;
+	if (!lock->l_lvb_data) {
+		lock->l_lvb_type = LVB_T_LAYOUT;
+		lock->l_lvb_data = lvbdata;
+		lock->l_lvb_len = lmmsize;
+		lvbdata = NULL;
+	}
 	unlock_res_and_lock(lock);
 
+	if (lvbdata)
+		kvfree(lvbdata);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 0abe426..a60959d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -692,9 +692,15 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		}
 	}
 
-	/* fill in stripe data for layout lock */
+	/* fill in stripe data for layout lock.
+	 * LU-6581: trust layout data only if layout lock is granted. The MDT
+	 * has stopped sending layout unless the layout lock is granted. The
+	 * client still does this checking in case it's talking with an old
+	 * server. - Jinshan
+	 */
 	lock = ldlm_handle2lock(lockh);
-	if (lock && ldlm_has_layout(lock) && lvb_data) {
+	if (lock && ldlm_has_layout(lock) && lvb_data &&
+	    !(lockrep->lock_flags & LDLM_FL_BLOCKED_MASK)) {
 		void *lmm;
 
 		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d",
-- 
1.8.3.1
