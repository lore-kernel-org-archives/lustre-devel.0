From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 14/37] lustre: llog: change lgh_refcount to
 struct kref.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494558.24125.11270061933248014691.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is a refcount that perfectly fits the
pattern for kref, so change it to a kref.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_log.h |    9 +--------
 drivers/staging/lustre/lustre/obdclass/llog.c      |   16 +++++++++-------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index e96bd6ab0fa4..83fc9374d7f0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -226,7 +226,7 @@ struct llog_handle {
 	char			*lgh_name;
 	void			*private_data;
 	struct llog_operations	*lgh_logops;
-	atomic_t		 lgh_refcount;
+	struct kref		 lgh_refcount;
 };
 
 #define LLOG_CTXT_FLAG_UNINITIALIZED     0x00000001
@@ -365,13 +365,6 @@ static inline int llog_next_block(const struct lu_env *env,
 }
 
 /* llog.c */
-int llog_declare_write_rec(const struct lu_env *env,
-			   struct llog_handle *handle,
-			   struct llog_rec_hdr *rec, int idx,
-			   struct thandle *th);
-int llog_write_rec(const struct lu_env *env, struct llog_handle *handle,
-		   struct llog_rec_hdr *rec, struct llog_cookie *logcookies,
-		   int numcookies, void *buf, int idx, struct thandle *th);
 int lustre_process_log(struct super_block *sb, char *logname,
 		       struct config_llog_instance *cfg);
 int lustre_end_log(struct super_block *sb, char *logname,
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 9d161c16c2f9..a34b1a7108b7 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -65,7 +65,7 @@ static struct llog_handle *llog_alloc_handle(void)
 
 	init_rwsem(&loghandle->lgh_lock);
 	INIT_LIST_HEAD(&loghandle->u.phd.phd_entry);
-	atomic_set(&loghandle->lgh_refcount, 1);
+	kref_init(&loghandle->lgh_refcount);
 
 	return loghandle;
 }
@@ -73,8 +73,11 @@ static struct llog_handle *llog_alloc_handle(void)
 /*
  * Free llog handle and header data if exists. Used in llog_close() only
  */
-static void llog_free_handle(struct llog_handle *loghandle)
+static void llog_free_handle(struct kref *kref)
 {
+	struct llog_handle *loghandle = container_of(kref, struct llog_handle,
+						     lgh_refcount);
+
 	/* failed llog_init_handle */
 	if (!loghandle->lgh_hdr)
 		goto out;
@@ -90,14 +93,13 @@ static void llog_free_handle(struct llog_handle *loghandle)
 
 void llog_handle_get(struct llog_handle *loghandle)
 {
-	atomic_inc(&loghandle->lgh_refcount);
+	kref_get(&loghandle->lgh_refcount);
 }
 
 void llog_handle_put(struct llog_handle *loghandle)
 {
-	LASSERT(atomic_read(&loghandle->lgh_refcount) > 0);
-	if (atomic_dec_and_test(&loghandle->lgh_refcount))
-		llog_free_handle(loghandle);
+	LASSERT(kref_read(&loghandle->lgh_refcount) > 0);
+	kref_put(&loghandle->lgh_refcount, llog_free_handle);
 }
 
 static int llog_read_header(const struct lu_env *env,
@@ -497,7 +499,7 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 		revert_creds(old_cred);
 
 	if (rc) {
-		llog_free_handle(*lgh);
+		llog_free_handle(&(*lgh)->lgh_refcount);
 		*lgh = NULL;
 	}
 	return rc;
