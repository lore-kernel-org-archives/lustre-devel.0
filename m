From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 15/37] lustre: llog_obd: Convert loc_refcount
 to refcount_t
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494563.24125.5471194386420442456.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Make this a refcount_t for clarity, and also
use refcount_dec_and_lock() rather than having separate
lock and dec calls.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_log.h |   11 ++++++-----
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   12 +++++-------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 83fc9374d7f0..ab0262c20278 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -243,7 +243,7 @@ struct llog_ctxt {
 	struct llog_operations  *loc_logops;
 	struct llog_handle      *loc_handle;
 	struct mutex		 loc_mutex; /* protect loc_imp */
-	atomic_t		 loc_refcount;
+	refcount_t		 loc_refcount;
 	long			 loc_flags; /* flags, see above defines */
 	/*
 	 * llog chunk size, and llog record size can not be bigger than
@@ -267,9 +267,9 @@ static inline int llog_handle2ops(struct llog_handle *loghandle,
 
 static inline struct llog_ctxt *llog_ctxt_get(struct llog_ctxt *ctxt)
 {
-	atomic_inc(&ctxt->loc_refcount);
+	refcount_inc(&ctxt->loc_refcount);
 	CDEBUG(D_INFO, "GETting ctxt %p : new refcount %d\n", ctxt,
-	       atomic_read(&ctxt->loc_refcount));
+	       refcount_read(&ctxt->loc_refcount));
 	return ctxt;
 }
 
@@ -277,9 +277,10 @@ static inline void llog_ctxt_put(struct llog_ctxt *ctxt)
 {
 	if (!ctxt)
 		return;
-	LASSERT_ATOMIC_GT_LT(&ctxt->loc_refcount, 0, LI_POISON);
+	LASSERT(refcount_read(&ctxt->loc_refcount) > 0);
+	LASSERT(refcount_read(&ctxt->loc_refcount) < LI_POISON);
 	CDEBUG(D_INFO, "PUTting ctxt %p : new refcount %d\n", ctxt,
-	       atomic_read(&ctxt->loc_refcount) - 1);
+	       refcount_read(&ctxt->loc_refcount) - 1);
 	__llog_ctxt_put(NULL, ctxt);
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index e074b6ee50e6..2b6489e2632d 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -47,7 +47,7 @@ static struct llog_ctxt *llog_new_ctxt(struct obd_device *obd)
 		return NULL;
 
 	ctxt->loc_obd = obd;
-	atomic_set(&ctxt->loc_refcount, 1);
+	refcount_set(&ctxt->loc_refcount, 1);
 
 	return ctxt;
 }
@@ -71,11 +71,9 @@ int __llog_ctxt_put(const struct lu_env *env, struct llog_ctxt *ctxt)
 	struct obd_device *obd;
 	int rc = 0;
 
-	spin_lock(&olg->olg_lock);
-	if (!atomic_dec_and_test(&ctxt->loc_refcount)) {
-		spin_unlock(&olg->olg_lock);
+	if (!refcount_dec_and_lock(&ctxt->loc_refcount, &olg->olg_lock))
 		return rc;
-	}
+
 	olg->olg_ctxts[ctxt->loc_idx] = NULL;
 	spin_unlock(&olg->olg_lock);
 
@@ -116,8 +114,8 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 	/*
 	 * Banlance the ctxt get when calling llog_cleanup()
 	 */
-	LASSERT(atomic_read(&ctxt->loc_refcount) < LI_POISON);
-	LASSERT(atomic_read(&ctxt->loc_refcount) > 1);
+	LASSERT(refcount_read(&ctxt->loc_refcount) < LI_POISON);
+	LASSERT(refcount_read(&ctxt->loc_refcount) > 1);
 	llog_ctxt_put(ctxt);
 
 	/*
