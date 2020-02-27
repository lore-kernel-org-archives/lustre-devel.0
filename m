From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:52 -0500
Subject: [lustre-devel] [PATCH 484/622] lustre: osc: glimpse - search for
 active lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-485-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When there are lock-ahead write locks on a file, the server
sends one glimpse AST RPC to each client having such (it
may have many) locks. This callback is sent to the lock
having the highest offset.

Client's glimpse callback goes up to the clio layers and
gets the global (not lock-specific) view of size.  The clio
layers are connected to the extent lock through the
l_ast_data (which points to the OSC object).

Speculative locks (AGL, lockahead) do not have l_ast_data
initialised until an IO happens under the lock. Thus, some
speculative locks may not have l_ast_data initialized.

It is possible for the client to do a write using one lock
(changing file size), but for the glimpse AST to be sent to
another lock without l_ast_data initialized.  Currently, a
lock with no l_ast_data set returns ELDLM_NO_LOCK_DATA to
the server.  In this case, this means we do not return the
updated size.

The solution is to search the granted lock tree for any lock
with initialized l_ast_data (it points to the OSC object
which is the same for all the extent locks) and to reach the
clio layers for the size through this lock instead.

cray-bug-id: LUS-6747
WC-bug-id: https://jira.whamcloud.com/browse/LU-11670
Lustre-commit: b3461d11dcb0 ("LU-11670 osc: glimpse - search for active lock")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33660
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h  | 17 ++++++++++++++++-
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ldlm/ldlm_lock.c      | 39 ++++++++++++++++++++-------------------
 fs/lustre/osc/osc_lock.c        | 41 ++++++++++++++++++++++++++++++++++++-----
 4 files changed, 73 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 4060bb4..f7d2d9c 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -809,6 +809,20 @@ struct ldlm_lock {
 };
 
 /**
+ * Describe the overlap between two locks.  itree_overlap_cb data.
+ */
+struct ldlm_match_data {
+	struct ldlm_lock	*lmd_old;
+	struct ldlm_lock	*lmd_lock;
+	enum ldlm_mode		*lmd_mode;
+	union ldlm_policy_data	*lmd_policy;
+	u64			 lmd_flags;
+	u64			 lmd_skip_flags;
+	int			 lmd_unref;
+	bool			 lmd_has_ast_data;
+};
+
+/**
  * LDLM resource description.
  * Basically, resource is a representation for a single object.
  * Object has a name which is currently 4 64-bit integers. LDLM user is
@@ -1163,7 +1177,8 @@ static inline enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns,
 	return ldlm_lock_match_with_skip(ns, flags, 0, res_id, type, policy,
 					 mode, lh, unref);
 }
-
+struct ldlm_lock *search_itree(struct ldlm_resource *res,
+			       struct ldlm_match_data *data);
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 506535b..acfd098 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -330,6 +330,7 @@
 #define OBD_FAIL_OSC_DELAY_SETTIME			0x412
 #define OBD_FAIL_OSC_CONNECT_GRANT_PARAM		0x413
 #define OBD_FAIL_OSC_DELAY_IO				0x414
+#define OBD_FAIL_OSC_NO_SIZE_DATA			0x415
 
 #define OBD_FAIL_PTLRPC					0x500
 #define OBD_FAIL_PTLRPC_ACK				0x501
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index b6c49c5..d14221a 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1045,19 +1045,6 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 }
 
 /**
- * Describe the overlap between two locks.  itree_overlap_cb data.
- */
-struct lock_match_data {
-	struct ldlm_lock	*lmd_old;
-	struct ldlm_lock	*lmd_lock;
-	enum ldlm_mode		*lmd_mode;
-	union ldlm_policy_data	*lmd_policy;
-	u64			 lmd_flags;
-	u64			 lmd_skip_flags;
-	int			 lmd_unref;
-};
-
-/**
  * Check if the given @lock meets the criteria for a match.
  * A reference on the lock is taken if matched.
  *
@@ -1066,9 +1053,9 @@ struct lock_match_data {
  */
 static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 {
-	struct lock_match_data *data = vdata;
+	struct ldlm_match_data *data = vdata;
 	union ldlm_policy_data *lpol = &lock->l_policy_data;
-	enum ldlm_mode match;
+	enum ldlm_mode match = LCK_MINMODE;
 
 	if (lock == data->lmd_old)
 		return true;
@@ -1098,6 +1085,17 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 
 	if (!(lock->l_req_mode & *data->lmd_mode))
 		return false;
+
+	/* When we search for ast_data, we are not doing a traditional match,
+	 * so we don't worry about IBITS or extent matching.
+	 */
+	if (data->lmd_has_ast_data) {
+		if (!lock->l_ast_data)
+			return false;
+
+		goto matched;
+	}
+
 	match = lock->l_req_mode;
 
 	switch (lock->l_resource->lr_type) {
@@ -1138,6 +1136,7 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	if (data->lmd_skip_flags & lock->l_flags)
 		return false;
 
+matched:
 	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
 		LDLM_LOCK_GET(lock);
 		ldlm_lock_touch_in_lru(lock);
@@ -1159,8 +1158,8 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
  *
  * Return:	a referenced lock or NULL.
  */
-static struct ldlm_lock *search_itree(struct ldlm_resource *res,
-				      struct lock_match_data *data)
+struct ldlm_lock *search_itree(struct ldlm_resource *res,
+			       struct ldlm_match_data *data)
 {
 	int idx;
 
@@ -1185,6 +1184,7 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 
 	return NULL;
 }
+EXPORT_SYMBOL(search_itree);
 
 /*
  * Search for a lock with given properties in a queue.
@@ -1195,7 +1195,7 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
  * Return:	a referenced lock or NULL.
  */
 static struct ldlm_lock *search_queue(struct list_head *queue,
-				      struct lock_match_data *data)
+				      struct ldlm_match_data *data)
 {
 	struct ldlm_lock *lock;
 
@@ -1280,7 +1280,7 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 					 enum ldlm_mode mode,
 					 struct lustre_handle *lockh, int unref)
 {
-	struct lock_match_data data = {
+	struct ldlm_match_data data = {
 		.lmd_old	= NULL,
 		.lmd_lock	= NULL,
 		.lmd_mode	= &mode,
@@ -1288,6 +1288,7 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 		.lmd_flags	= flags,
 		.lmd_skip_flags	= skip_flags,
 		.lmd_unref	= unref,
+		.lmd_has_ast_data = false,
 	};
 	struct ldlm_resource *res;
 	struct ldlm_lock *lock;
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index c748e58..dcddf17 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -549,6 +549,10 @@ int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	struct ost_lvb *lvb;
 	struct req_capsule *cap;
 	struct cl_object *obj = NULL;
+	struct ldlm_resource *res = dlmlock->l_resource;
+	struct ldlm_match_data matchdata = { 0 };
+	union ldlm_policy_data policy;
+	enum ldlm_mode mode = LCK_PW | LCK_GROUP | LCK_PR;
 	int result;
 	u16 refcheck;
 
@@ -559,13 +563,40 @@ int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 		result = PTR_ERR(env);
 		goto out;
 	}
+	policy.l_extent.start = 0;
+	policy.l_extent.end = LUSTRE_EOF;
 
-	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_ast_data) {
-		obj = osc2cl(dlmlock->l_ast_data);
-		cl_object_get(obj);
+	matchdata.lmd_mode = &mode;
+	matchdata.lmd_policy = &policy;
+	matchdata.lmd_flags = LDLM_FL_TEST_LOCK | LDLM_FL_CBPENDING;
+	matchdata.lmd_unref = 1;
+	matchdata.lmd_has_ast_data = true;
+
+	LDLM_LOCK_GET(dlmlock);
+
+	/* If any dlmlock has l_ast_data set, we must find it or we risk
+	 * missing a size update done under a different lock.
+	 */
+	while (dlmlock) {
+		lock_res_and_lock(dlmlock);
+		if (dlmlock->l_ast_data) {
+			obj = osc2cl(dlmlock->l_ast_data);
+			cl_object_get(obj);
+		}
+		unlock_res_and_lock(dlmlock);
+		LDLM_LOCK_PUT(dlmlock);
+
+		dlmlock = NULL;
+
+		if (!obj && res->lr_type == LDLM_EXTENT) {
+			if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_SIZE_DATA))
+				break;
+
+			lock_res(res);
+			dlmlock = search_itree(res, &matchdata);
+			unlock_res(res);
+		}
 	}
-	unlock_res_and_lock(dlmlock);
 
 	if (obj) {
 		/* Do not grab the mutex of cl_lock for glimpse.
-- 
1.8.3.1
