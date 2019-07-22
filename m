From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:13 -0400
Subject: [lustre-devel] [PATCH 06/11] lustre: mdc: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the mdc layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c | 15 ++++++++++-----
 fs/lustre/mdc/mdc_lib.c       | 15 ++++++++++-----
 fs/lustre/mdc/mdc_locks.c     |  2 +-
 fs/lustre/mdc/mdc_request.c   | 16 ++++++++++------
 4 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 45aef9c..011bcc9 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -112,7 +112,8 @@ enum {
  * @hdr:	Header of the current llog record
  * @data:	chlg_reader_state passed from caller
  *
- * Returns:	0 or LLOG_PROC_* control code on success, negated error on failure.
+ * Returns:	0 or LLOG_PROC_* control code on success,
+ *		negated error on failure.
  */
 static int chlg_read_cat_process_cb(const struct lu_env *env,
 				    struct llog_handle *llh,
@@ -276,7 +277,8 @@ static int chlg_load(void *args)
  * @ppos:	File position, updated with the index number of the next
  *		record to read.
  *
- * Returns:	number of copied bytes on success, negated error code on failure.
+ * Returns:	number of copied bytes on success,
+ *		negated error code on failure.
  */
 static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 			 loff_t *ppos)
@@ -377,7 +379,8 @@ static int chlg_set_start_offset(struct chlg_reader_state *crs, u64 offset)
  * @off:	Offset to skip, actually a record index, not byte count
  * @whence:	Relative/Absolute interpretation of the offset
  *
- * Returns:	the resulting position on success or negated error code on failure.
+ * Returns:	the resulting position on success or
+ *		negated error code on failure.
  */
 static loff_t chlg_llseek(struct file *file, loff_t off, int whence)
 {
@@ -434,7 +437,8 @@ static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
 	else
 		ret = obd_set_info_async(NULL, obd->obd_self_export,
 					 strlen(KEY_CHANGELOG_CLEAR),
-					 KEY_CHANGELOG_CLEAR, sizeof(cs), &cs, NULL);
+					 KEY_CHANGELOG_CLEAR, sizeof(cs),
+					 &cs, NULL);
 	mutex_unlock(&chlg_registered_dev_lock);
 	return ret;
 }
@@ -451,7 +455,8 @@ static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
  * @count:	Number of written bytes
  * @off:	(unused)
  *
- * Returns:	number of written bytes on success, negated error code on failure.
+ * Returns:	number of written bytes on success,
+ *		negated error code on failure.
  */
 static ssize_t chlg_write(struct file *file, const char __user *buff,
 			  size_t count, loff_t *off)
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 7680346..6aa9dc2 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -157,7 +157,8 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char *tmp;
 	u64 flags;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->cr_opcode = REINT_CREATE;
@@ -225,7 +226,8 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char *tmp;
 	u64 cr_flags;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
@@ -380,7 +382,8 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_unlink *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_unlink));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->ul_opcode = op_data->op_cli_flags & CLI_RM_ENTRY ?
@@ -403,7 +406,8 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_link *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_link));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->lk_opcode = REINT_LINK;
@@ -451,7 +455,8 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 {
 	struct mdt_rec_rename *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_rename));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_rename));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 430c422..4e6928e 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -630,7 +630,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			mdc_set_open_replay_data(NULL, NULL, it);
 		}
 
-		if ((body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) != 0) {
+		if (body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) {
 			void *eadata;
 
 			mdc_update_max_ea_from_body(exp, body);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 6f933b5..dd90e931 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -803,8 +803,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		mod->mod_open_req->rq_replay = 0;
 		spin_unlock(&mod->mod_open_req->rq_lock);
 	} else {
-		 CDEBUG(D_HA,
-			"couldn't find open req; expecting close error\n");
+		CDEBUG(D_HA,
+		       "couldn't find open req; expecting close error\n");
 	}
 	if (!req) {
 		/*
@@ -1019,9 +1019,11 @@ static struct page *mdc_page_locate(struct address_space *mapping, u64 *hash,
 			if (unlikely(*start == 1 && *hash == 0))
 				*hash = *start;
 			else
-				LASSERTF(*start <= *hash, "start = %#llx,end = %#llx,hash = %#llx\n",
+				LASSERTF(*start <= *hash,
+					 "start = %#llx,end = %#llx,hash = %#llx\n",
 					 *start, *end, *hash);
-			CDEBUG(D_VFSTRACE, "offset %lx [%#llx %#llx], hash %#llx\n",
+			CDEBUG(D_VFSTRACE,
+			       "offset %lx [%#llx %#llx], hash %#llx\n",
 			       offset, *start, *end, *hash);
 			if (*hash > *end) {
 				kunmap(page);
@@ -1258,7 +1260,8 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 		if (!ret)
 			unlock_page(page);
 		else
-			CDEBUG(D_VFSTRACE, "page %lu add to page cache failed: rc = %d\n",
+			CDEBUG(D_VFSTRACE,
+			       "page %lu add to page cache failed: rc = %d\n",
 			       offset, ret);
 		put_page(page);
 	}
@@ -1325,7 +1328,8 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	page = mdc_page_locate(mapping, &rp_param.rp_off, &start, &end,
 			       rp_param.rp_hash64);
 	if (IS_ERR(page)) {
-		CDEBUG(D_INFO, "%s: dir page locate: " DFID " at %llu: rc %ld\n",
+		CDEBUG(D_INFO,
+		       "%s: dir page locate: " DFID " at %llu: rc %ld\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
 		       rp_param.rp_off, PTR_ERR(page));
 		rc = PTR_ERR(page);
-- 
1.8.3.1
