From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:02 -0500
Subject: [lustre-devel] [PATCH 614/622] lustre: llog: keep llog handle alive
 until last reference
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-615-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Llog handle keeps related dt_object pinned until llog_close()
call, meanwhile llog handle can still have other users which
took llog handle via llog_cat_id2handle()

Patch changes llog_handle_put() to call lop_close() upon last
reference drop. So llog_osd_close() will put dt_object only
when llog_handle has no more references.
The llog_handle_get() checks and reports if llog_handle has
zero reference.
Also patch modifies checks for destroyed llogs, llog handle
has new lgh_destroyed flag which is set when llog is destroyed,
llog_osd_exist() checks dt_object_exist() and lgh_destroyed
flag, so destroyed llogs are considered as non-existent too.
Previously it uses lu_object_is_dying() check which is not
reliable because means only that object is not to be kept in
cache.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10198
Lustre-commit: d6bd5e9cc49b ("LU-10198 llog: keep llog handle alive until last reference")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37367
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h     |  3 ++-
 fs/lustre/obdclass/llog.c          | 49 +++++++++++++++++++-------------------
 fs/lustre/obdclass/llog_cat.c      | 19 +++++++++------
 fs/lustre/obdclass/llog_internal.h |  4 ++--
 4 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 9c784ac..6995414 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -226,7 +226,8 @@ struct llog_handle {
 	char			*lgh_name;
 	void			*private_data;
 	struct llog_operations	*lgh_logops;
-	struct kref		 lgh_refcount;
+	refcount_t		 lgh_refcount;
+	bool			 lgh_destroyed;
 };
 
 #define LLOG_CTXT_FLAG_UNINITIALIZED     0x00000001
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 620ebc6..5d828bd 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -65,7 +65,7 @@ static struct llog_handle *llog_alloc_handle(void)
 
 	init_rwsem(&loghandle->lgh_lock);
 	INIT_LIST_HEAD(&loghandle->u.phd.phd_entry);
-	kref_init(&loghandle->lgh_refcount);
+	refcount_set(&loghandle->lgh_refcount, 1);
 
 	return loghandle;
 }
@@ -73,11 +73,8 @@ static struct llog_handle *llog_alloc_handle(void)
 /*
  * Free llog handle and header data if exists. Used in llog_close() only
  */
-static void llog_free_handle(struct kref *kref)
+static void llog_free_handle(struct llog_handle *loghandle)
 {
-	struct llog_handle *loghandle = container_of(kref, struct llog_handle,
-						     lgh_refcount);
-
 	/* failed llog_init_handle */
 	if (!loghandle->lgh_hdr)
 		goto out;
@@ -91,15 +88,30 @@ static void llog_free_handle(struct kref *kref)
 	kfree(loghandle);
 }
 
-void llog_handle_get(struct llog_handle *loghandle)
+struct llog_handle *llog_handle_get(struct llog_handle *loghandle)
 {
-	kref_get(&loghandle->lgh_refcount);
+	if (refcount_inc_not_zero(&loghandle->lgh_refcount))
+		return loghandle;
+	return NULL;
 }
 
-void llog_handle_put(struct llog_handle *loghandle)
+int llog_handle_put(const struct lu_env *env, struct llog_handle *loghandle)
 {
-	LASSERT(kref_read(&loghandle->lgh_refcount) > 0);
-	kref_put(&loghandle->lgh_refcount, llog_free_handle);
+	int rc = 0;
+
+	if (refcount_dec_and_test(&loghandle->lgh_refcount)) {
+		struct llog_operations *lop;
+
+		rc = llog_handle2ops(loghandle, &lop);
+		if (!rc) {
+			if (lop->lop_close)
+				rc = lop->lop_close(env, loghandle);
+			else
+				rc = -EOPNOTSUPP;
+		}
+		llog_free_handle(loghandle);
+	}
+	return rc;
 }
 
 static int llog_read_header(const struct lu_env *env,
@@ -541,7 +553,7 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 		revert_creds(old_cred);
 
 	if (rc) {
-		llog_free_handle(&(*lgh)->lgh_refcount);
+		llog_free_handle(*lgh);
 		*lgh = NULL;
 	}
 	return rc;
@@ -550,19 +562,6 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 
 int llog_close(const struct lu_env *env, struct llog_handle *loghandle)
 {
-	struct llog_operations *lop;
-	int rc;
-
-	rc = llog_handle2ops(loghandle, &lop);
-	if (rc)
-		goto out;
-	if (!lop->lop_close) {
-		rc = -EOPNOTSUPP;
-		goto out;
-	}
-	rc = lop->lop_close(env, loghandle);
-out:
-	llog_handle_put(loghandle);
-	return rc;
+	return llog_handle_put(env, loghandle);
 }
 EXPORT_SYMBOL(llog_close);
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 75226f4..46636f8 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -85,10 +85,16 @@ static int llog_cat_id2handle(const struct lu_env *env,
 				      cgl->lgl_ogen, logid->lgl_ogen);
 				continue;
 			}
+			*res = llog_handle_get(loghandle);
+			if (!*res) {
+				CERROR("%s: log "DFID" refcount is zero!\n",
+				       loghandle->lgh_ctxt->loc_obd->obd_name,
+				       PFID(&logid->lgl_oi.oi_fid));
+				continue;
+			}
 			loghandle->u.phd.phd_cat_handle = cathandle;
 			up_write(&cathandle->lgh_lock);
-			rc = 0;
-			goto out;
+			return rc;
 		}
 	}
 	up_write(&cathandle->lgh_lock);
@@ -105,10 +111,12 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	rc = llog_init_handle(env, loghandle, fmt | LLOG_F_IS_PLAIN, NULL);
 	if (rc < 0) {
 		llog_close(env, loghandle);
-		loghandle = NULL;
+		*res = NULL;
 		return rc;
 	}
 
+	*res = llog_handle_get(loghandle);
+	LASSERT(*res);
 	down_write(&cathandle->lgh_lock);
 	list_add_tail(&loghandle->u.phd.phd_entry, &cathandle->u.chd.chd_head);
 	up_write(&cathandle->lgh_lock);
@@ -117,9 +125,6 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	loghandle->u.phd.phd_cookie.lgc_lgl = cathandle->lgh_id;
 	loghandle->u.phd.phd_cookie.lgc_index =
 				loghandle->lgh_hdr->llh_cat_idx;
-out:
-	llog_handle_get(loghandle);
-	*res = loghandle;
 	return 0;
 }
 
@@ -204,7 +209,7 @@ static int llog_cat_process_cb(const struct lu_env *env,
 	}
 
 out:
-	llog_handle_put(llh);
+	llog_handle_put(env, llh);
 
 	return rc;
 }
diff --git a/fs/lustre/obdclass/llog_internal.h b/fs/lustre/obdclass/llog_internal.h
index 365bac9..0376656 100644
--- a/fs/lustre/obdclass/llog_internal.h
+++ b/fs/lustre/obdclass/llog_internal.h
@@ -61,8 +61,8 @@ struct llog_thread_info {
 int llog_info_init(void);
 void llog_info_fini(void);
 
-void llog_handle_get(struct llog_handle *loghandle);
-void llog_handle_put(struct llog_handle *loghandle);
+struct llog_handle *llog_handle_get(struct llog_handle *loghandle);
+int llog_handle_put(const struct lu_env *env, struct llog_handle *loghandle);
 int class_config_dump_handler(const struct lu_env *env,
 			      struct llog_handle *handle,
 			      struct llog_rec_hdr *rec, void *data);
-- 
1.8.3.1
