From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:55 -0400
Subject: [lustre-devel] [PATCH 42/80] staging: lustre: llite: validate names
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In ll_prep_md_op_data() validate names according to the same formula
used in mdd_name_check(). Add mdc_pack_name() to validate the name
actually packed in the request.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4992
Reviewed-on: http://review.whamcloud.com/10198
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    9 ---
 drivers/staging/lustre/lustre/include/lu_object.h  |   16 +++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   13 +++-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   67 +++++++++++++-------
 4 files changed, 70 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 4daa382..d401ae1 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -360,13 +360,4 @@ do {							    \
 	ptr += cfs_size_round(len);			     \
 } while (0)
 
-#define LOGL0(var, len, ptr)			      \
-do {						    \
-	if (!len)				       \
-		break;				  \
-	memcpy((char *)ptr, (const char *)var, len);    \
-	*((char *)(ptr) + len) = 0;		     \
-	ptr += cfs_size_round(len + 1);		 \
-} while (0)
-
 #endif
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 25c12d8..6ab1782 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1263,6 +1263,22 @@ struct lu_name {
 };
 
 /**
+ * Validate names (path components)
+ *
+ * To be valid \a name must be non-empty, '\0' terminated of length \a
+ * name_len, and not contain '/'. The maximum length of a name (before
+ * say -ENAMETOOLONG will be returned) is really controlled by llite
+ * and the server. We only check for something insane coming from bad
+ * integer handling here.
+ */
+static inline bool lu_name_is_valid_2(const char *name, size_t name_len)
+{
+	return name && name_len > 0 && name_len < INT_MAX &&
+	       name[name_len] == '\0' && strlen(name) == name_len &&
+	       !memchr(name, '/', name_len);
+}
+
+/**
  * Common buffer structure to be passed around for various xattr_{s,g}et()
  * methods.
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 2f6e770..a3b4c97 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2304,8 +2304,17 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      const char *name, int namelen,
 				      int mode, __u32 opc, void *data)
 {
-	if (namelen > ll_i2sbi(i1)->ll_namelen)
-		return ERR_PTR(-ENAMETOOLONG);
+	if (!name) {
+		/* Do not reuse namelen for something else. */
+		if (namelen)
+			return ERR_PTR(-EINVAL);
+	} else {
+		if (namelen > ll_i2sbi(i1)->ll_namelen)
+			return ERR_PTR(-ENAMETOOLONG);
+
+		if (!lu_name_is_valid_2(name, namelen))
+			return ERR_PTR(-EINVAL);
+	}
 
 	if (!op_data)
 		op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index b532623..16c3571 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -87,6 +87,37 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 	}
 }
 
+/**
+ * Pack a name (path component) into a request
+ *
+ * \param[in] req	request
+ * \param[in] field	request field (usually RMF_NAME)
+ * \param[in] name	path component
+ * \param[in] name_len	length of path component
+ *
+ * \a field must be present in \a req and of size \a name_len + 1.
+ *
+ * \a name must be '\0' terminated of length \a name_len and represent
+ * a single path component (not contain '/').
+ */
+static void mdc_pack_name(struct ptlrpc_request *req,
+			  const struct req_msg_field *field,
+			  const char *name, size_t name_len)
+{
+	size_t buf_size;
+	size_t cpy_len;
+	char *buf;
+
+	buf = req_capsule_client_get(&req->rq_pill, field);
+	buf_size = req_capsule_get_size(&req->rq_pill, field, RCL_CLIENT);
+
+	LASSERT(name && name_len && buf && buf_size == name_len + 1);
+
+	cpy_len = strlcpy(buf, name, buf_size);
+
+	LASSERT(cpy_len == name_len && lu_name_is_valid_2(buf, cpy_len));
+}
+
 void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff,
 		      __u32 size, const struct lu_fid *fid)
 {
@@ -130,9 +161,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_bias     = op_data->op_bias;
 	rec->cr_umask    = current_umask();
 
-	tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-	LOGL0(op_data->op_name, op_data->op_namelen, tmp);
-
+	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 	if (data) {
 		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
 		memcpy(tmp, data, datalen);
@@ -200,8 +229,9 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_old_handle = op_data->op_handle;
 
 	if (op_data->op_name) {
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-		LOGL0(op_data->op_name, op_data->op_namelen, tmp);
+		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
+			      op_data->op_namelen);
+
 		if (op_data->op_bias & MDS_CREATE_VOLATILE)
 			cr_flags |= MDS_OPEN_VOLATILE;
 	}
@@ -334,7 +364,6 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_unlink *rec;
-	char *tmp;
 
 	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
@@ -352,15 +381,12 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->ul_time     = op_data->op_mod_time;
 	rec->ul_bias     = op_data->op_bias;
 
-	tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-	LASSERT(tmp);
-	LOGL0(op_data->op_name, op_data->op_namelen, tmp);
+	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
 
 void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_link *rec;
-	char *tmp;
 
 	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
@@ -376,15 +402,13 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->lk_time     = op_data->op_mod_time;
 	rec->lk_bias     = op_data->op_bias;
 
-	tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-	LOGL0(op_data->op_name, op_data->op_namelen, tmp);
+	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
 
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const char *old, int oldlen, const char *new, int newlen)
 {
 	struct mdt_rec_rename *rec;
-	char *tmp;
 
 	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_rename));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
@@ -404,13 +428,10 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->rn_mode     = op_data->op_mode;
 	rec->rn_bias     = op_data->op_bias;
 
-	tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-	LOGL0(old, oldlen, tmp);
+	mdc_pack_name(req, &RMF_NAME, old, oldlen);
 
-	if (new) {
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_SYMTGT);
-		LOGL0(new, newlen, tmp);
-	}
+	if (new)
+		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
 }
 
 void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
@@ -432,11 +453,9 @@ void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
 	b->fid2 = op_data->op_fid2;
 	b->valid |= OBD_MD_FLID;
 
-	if (op_data->op_name) {
-		char *tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
-
-		LOGL0(op_data->op_name, op_data->op_namelen, tmp);
-	}
+	if (op_data->op_name)
+		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
+			      op_data->op_namelen);
 }
 
 static void mdc_hsm_release_pack(struct ptlrpc_request *req,
-- 
1.7.1
