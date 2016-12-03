From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:27 -0500
Subject: [lustre-devel] [PATCH 20/22] staging: lustre: osc: set lock data
	for readahead lock
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

If osc_io_readahead() finds a lock that belongs to the previous
instance of osc_object, the lock data pointer will be null. It has
to instantiate with new instance otherwise those pages won't be
destroyed at lock cancel, and then finally hit the assertion in
osc_req_attr_set().

This patch revised dlmlock_at_pgoff() to call osc_match_base() to
find caching locks for readahead. And new osc_object will be set
to the lock if it doesn't have one yet.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8005
Reviewed-on: http://review.whamcloud.com/19453
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_io.c      |    1 +
 drivers/staging/lustre/lustre/osc/osc_lock.c    |    7 +--
 drivers/staging/lustre/lustre/osc/osc_request.c |   49 ++++++----------------
 3 files changed, 18 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 369761f..d96f4f2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -88,6 +88,7 @@ static int osc_io_read_ahead(const struct lu_env *env,
 
 	dlmlock = osc_dlmlock_at_pgoff(env, osc, start, 0);
 	if (dlmlock) {
+		LASSERT(dlmlock->l_ast_data == osc);
 		if (dlmlock->l_req_mode != LCK_PR) {
 			struct lustre_handle lockh;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 130460d..001fe75 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1205,10 +1205,9 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 	 * with a uniq gid and it conflicts with all other lock modes too
 	 */
 again:
-	mode = ldlm_lock_match(osc_export(obj)->exp_obd->obd_namespace,
-			       flags, resname, LDLM_EXTENT, policy,
-			       LCK_PR | LCK_PW | LCK_GROUP, &lockh,
-			       dap_flags & OSC_DAP_FL_CANCELING);
+	mode = osc_match_base(osc_export(obj), resname, LDLM_EXTENT, policy,
+			      LCK_PR | LCK_PW | LCK_GROUP, &flags, obj, &lockh,
+			      dap_flags & OSC_DAP_FL_CANCELING);
 	if (mode != 0) {
 		lock = ldlm_handle2lock(&lockh);
 		/* RACE: the lock is cancelled so let's try again */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index bc698d3..0977127 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1813,16 +1813,11 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	return rc;
 }
 
-static int osc_set_lock_data_with_check(struct ldlm_lock *lock,
-					struct ldlm_enqueue_info *einfo)
+static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 {
-	void *data = einfo->ei_cbdata;
 	int set = 0;
 
-	LASSERT(lock->l_blocking_ast == einfo->ei_cb_bl);
-	LASSERT(lock->l_resource->lr_type == einfo->ei_type);
-	LASSERT(lock->l_completion_ast == einfo->ei_cb_cp);
-	LASSERT(lock->l_glimpse_ast == einfo->ei_cb_gl);
+	LASSERT(lock);
 
 	lock_res_and_lock(lock);
 
@@ -1836,21 +1831,6 @@ static int osc_set_lock_data_with_check(struct ldlm_lock *lock,
 	return set;
 }
 
-static int osc_set_data_with_check(struct lustre_handle *lockh,
-				   struct ldlm_enqueue_info *einfo)
-{
-	struct ldlm_lock *lock = ldlm_handle2lock(lockh);
-	int set = 0;
-
-	if (lock) {
-		set = osc_set_lock_data_with_check(lock, einfo);
-		LDLM_LOCK_PUT(lock);
-	} else
-		CERROR("lockh %p, data %p - client evicted?\n",
-		       lockh, einfo->ei_cbdata);
-	return set;
-}
-
 static int osc_enqueue_fini(struct ptlrpc_request *req,
 			    osc_enqueue_upcall_f upcall, void *cookie,
 			    struct lustre_handle *lockh, enum ldlm_mode mode,
@@ -2016,7 +1996,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return -ECANCELED;
-		} else if (osc_set_lock_data_with_check(matched, einfo)) {
+		} else if (osc_set_lock_data(matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
 			/* We already have a lock, and it's referenced. */
 			(*upcall)(cookie, &lockh, ELDLM_LOCK_MATCHED);
@@ -2128,19 +2108,18 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		rc |= LCK_PW;
 	rc = ldlm_lock_match(obd->obd_namespace, lflags,
 			     res_id, type, policy, rc, lockh, unref);
-	if (rc) {
-		if (data) {
-			if (!osc_set_data_with_check(lockh, data)) {
-				if (!(lflags & LDLM_FL_TEST_LOCK))
-					ldlm_lock_decref(lockh, rc);
-				return 0;
-			}
-		}
-		if (!(lflags & LDLM_FL_TEST_LOCK) && mode != rc) {
-			ldlm_lock_addref(lockh, LCK_PR);
-			ldlm_lock_decref(lockh, LCK_PW);
-		}
+	if (!rc || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
+
+	if (data) {
+		struct ldlm_lock *lock = ldlm_handle2lock(lockh);
+
+		LASSERT(lock);
+		if (!osc_set_lock_data(lock, data)) {
+			ldlm_lock_decref(lockh, rc);
+			rc = 0;
+		}
+		LDLM_LOCK_PUT(lock);
 	}
 	return rc;
 }
-- 
1.7.1
