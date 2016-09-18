From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:59 -0400
Subject: [lustre-devel] [PATCH 060/124] staging: lustre: mdc: fix comparison
	between signed and unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change type of client_obd->*_mds_*size from int to __u32 and
argumanets of related create/rename/setattr functions.
Change type of op_data->op_namelen to size_t.
Change type of argument size for all mdc_*_pack() to size_t.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/11379
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   23 +++++++-------
 drivers/staging/lustre/lustre/include/obd_class.h  |   12 ++++----
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    5 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   29 +++++++++---------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   30 ++++++++++---------
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   27 +++++++++--------
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   19 ++++++------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   10 +++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   31 ++++++++++---------
 11 files changed, 101 insertions(+), 93 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6758bf4..8a7c803 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -220,10 +220,10 @@ struct client_obd {
 	/* max_mds_easize is purely a performance thing so we don't have to
 	 * call obd_size_diskmd() all the time.
 	 */
-	int			 cl_default_mds_easize;
-	int			 cl_max_mds_easize;
-	int			 cl_default_mds_cookiesize;
-	int			 cl_max_mds_cookiesize;
+	u32			 cl_default_mds_easize;
+	u32			 cl_max_mds_easize;
+	u32			 cl_default_mds_cookiesize;
+	u32			 cl_max_mds_cookiesize;
 
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
@@ -745,7 +745,7 @@ struct md_op_data {
 	struct lustre_handle    op_handle;
 	s64			op_mod_time;
 	const char	     *op_name;
-	int		     op_namelen;
+	size_t			op_namelen;
 	__u32		   op_mode;
 	struct lmv_stripe_md   *op_mea1;
 	struct lmv_stripe_md   *op_mea2;
@@ -976,8 +976,8 @@ struct md_ops {
 	int (*close)(struct obd_export *, struct md_op_data *,
 		     struct md_open_data *, struct ptlrpc_request **);
 	int (*create)(struct obd_export *, struct md_op_data *,
-		      const void *, int, int, __u32, __u32, cfs_cap_t,
-		      __u64, struct ptlrpc_request **);
+		      const void *, size_t, umode_t, uid_t, gid_t,
+		      cfs_cap_t, __u64, struct ptlrpc_request **);
 	int (*done_writing)(struct obd_export *, struct md_op_data  *,
 			    struct md_open_data *);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
@@ -995,10 +995,10 @@ struct md_ops {
 	int (*link)(struct obd_export *, struct md_op_data *,
 		    struct ptlrpc_request **);
 	int (*rename)(struct obd_export *, struct md_op_data *,
-		      const char *, int, const char *, int,
+		      const char *, size_t, const char *, size_t,
 		      struct ptlrpc_request **);
 	int (*setattr)(struct obd_export *, struct md_op_data *, void *,
-		       int, void *, int, struct ptlrpc_request **,
+		       size_t, void *, size_t, struct ptlrpc_request **,
 			 struct md_open_data **mod);
 	int (*sync)(struct obd_export *, const struct lu_fid *,
 		    struct ptlrpc_request **);
@@ -1016,7 +1016,7 @@ struct md_ops {
 			u64, const char *, const char *, int, int, int,
 			struct ptlrpc_request **);
 
-	int (*init_ea_size)(struct obd_export *, int, int, int, int);
+	int (*init_ea_size)(struct obd_export *, u32, u32, u32, u32);
 
 	int (*get_lustre_md)(struct obd_export *, struct ptlrpc_request *,
 			     struct obd_export *, struct obd_export *,
@@ -1139,7 +1139,8 @@ static inline const char *lu_dev_name(const struct lu_device *lu_dev)
 	return lu_dev->ld_obd->obd_name;
 }
 
-static inline bool filename_is_volatile(const char *name, int namelen, int *idx)
+static inline bool filename_is_volatile(const char *name, size_t namelen,
+					int *idx)
 {
 	const char	*start;
 	char		*end;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 6fc54bd..3d081cf 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1358,9 +1358,9 @@ static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
-			    const void *data, int datalen, int mode, __u32 uid,
-			    __u32 gid, cfs_cap_t cap_effective, __u64 rdev,
-			    struct ptlrpc_request **request)
+			    const void *data, size_t datalen, umode_t mode,
+			    uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+			    __u64 rdev, struct ptlrpc_request **request)
 {
 	int rc;
 
@@ -1440,8 +1440,8 @@ static inline int md_link(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
-			    const char *old, int oldlen, const char *new,
-			    int newlen, struct ptlrpc_request **request)
+			    const char *old, size_t oldlen, const char *new,
+			    size_t newlen, struct ptlrpc_request **request)
 {
 	int rc;
 
@@ -1453,7 +1453,7 @@ static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
-			     void *ea, int ealen, void *ea2, int ea2len,
+			     void *ea, size_t ealen, void *ea2, size_t ea2len,
 			     struct ptlrpc_request **request,
 			     struct md_open_data **mod)
 {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd639f4..a68bea1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -868,8 +868,8 @@ enum {
 
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
-				      const char *name, int namelen,
-				      int mode, __u32 opc, void *data);
+				      const char *name, size_t namelen,
+				      u32 mode, __u32 opc, void *data);
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index c498748..e46214f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2324,8 +2324,8 @@ int ll_process_config(struct lustre_cfg *lcfg)
 /* this function prepares md_op_data hint for passing ot down to MD stack. */
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
-				      const char *name, int namelen,
-				      int mode, __u32 opc, void *data)
+				      const char *name, size_t namelen,
+				      u32 mode, __u32 opc, void *data)
 {
 	if (!name) {
 		/* Do not reuse namelen for something else. */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 6845a5e..a96b49d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -520,8 +520,9 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(fid_is_sane(&op_data->op_fid1));
 
 	CDEBUG(D_INODE, "INTENT LOCK '%s' for "DFID" '%*s' on "DFID"\n",
-	       LL_IT2STR(it), PFID(&op_data->op_fid2), op_data->op_namelen,
-	       op_data->op_name, PFID(&op_data->op_fid1));
+	       LL_IT2STR(it), PFID(&op_data->op_fid2),
+	       (int)op_data->op_namelen, op_data->op_name,
+	       PFID(&op_data->op_fid1));
 
 	rc = lmv_check_connect(obd);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0ffb653..0337f05 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -245,8 +245,8 @@ static int lmv_connect(const struct lu_env *env,
 	return rc;
 }
 
-static int lmv_init_ea_size(struct obd_export *exp, int easize,
-			    int def_easize, int cookiesize, int def_cookiesize)
+static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
+			    u32 cookiesize, u32 def_cookiesize)
 {
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
@@ -1660,9 +1660,9 @@ lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 }
 
 static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
-		      const void *data, int datalen, int mode, __u32 uid,
-		      __u32 gid, cfs_cap_t cap_effective, __u64 rdev,
-		      struct ptlrpc_request **request)
+		      const void *data, size_t datalen, umode_t mode,
+		      uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+		      __u64 rdev, struct ptlrpc_request **request)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -1681,8 +1681,8 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(tgt);
 
 	CDEBUG(D_INODE, "CREATE name '%.*s' on "DFID" -> mds #%x\n",
-	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
-	       op_data->op_mds);
+	       (int)op_data->op_namelen, op_data->op_name,
+	       PFID(&op_data->op_fid1), op_data->op_mds);
 
 	rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 	if (rc)
@@ -1785,8 +1785,8 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		return PTR_ERR(tgt);
 
 	CDEBUG(D_INODE, "GETATTR_NAME for %*s on " DFID " -> mds #%u\n",
-	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
-	       tgt->ltd_idx);
+	       (int)op_data->op_namelen, op_data->op_name,
+	       PFID(&op_data->op_fid1), tgt->ltd_idx);
 
 	rc = md_getattr_name(tgt->ltd_exp, op_data, preq);
 	if (rc != 0)
@@ -1879,7 +1879,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(op_data->op_namelen != 0);
 
 	CDEBUG(D_INODE, "LINK "DFID":%*s to "DFID"\n",
-	       PFID(&op_data->op_fid2), op_data->op_namelen,
+	       PFID(&op_data->op_fid2), (int)op_data->op_namelen,
 	       op_data->op_name, PFID(&op_data->op_fid1));
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
@@ -1916,7 +1916,8 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
-		      const char *old, int oldlen, const char *new, int newlen,
+		      const char *old, size_t oldlen,
+		      const char *new, size_t newlen,
 		      struct ptlrpc_request **request)
 {
 	struct obd_device       *obd = exp->exp_obd;
@@ -1927,9 +1928,9 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(oldlen != 0);
 
 	CDEBUG(D_INODE, "RENAME %.*s in "DFID":%d to %.*s in "DFID":%d\n",
-	       oldlen, old, PFID(&op_data->op_fid1),
+	       (int)oldlen, old, PFID(&op_data->op_fid1),
 	       op_data->op_mea1 ? op_data->op_mea1->lsm_md_stripe_count : 0,
-	       newlen, new, PFID(&op_data->op_fid2),
+	       (int)newlen, new, PFID(&op_data->op_fid2),
 	       op_data->op_mea2 ? op_data->op_mea2->lsm_md_stripe_count : 0);
 
 	rc = lmv_check_connect(obd);
@@ -2035,7 +2036,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		       void *ea, int ealen, void *ea2, int ea2len,
+		       void *ea, size_t ealen, void *ea2, size_t ea2len,
 		       struct ptlrpc_request **request,
 		       struct md_open_data **mod)
 {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index c10441d..f446c1c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -38,25 +38,26 @@
 void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars);
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
-		   __u64 valid, int ea_size, __u32 suppgid, int flags);
+		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 			   struct md_op_data *op_data);
-void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, __u32 size,
+void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
 		      const struct lu_fid *fid);
-void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
-		      struct md_op_data *data, int ea_size);
+void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
+		      struct md_op_data *data, size_t ea_size);
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		      void *ea, int ealen, void *ea2, int ea2len);
+		      void *ea, size_t ealen, void *ea2, size_t ea2len);
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		     const void *data, int datalen, __u32 mode, __u32 uid,
-		     __u32 gid, cfs_cap_t capability, __u64 rdev);
+		     const void *data, size_t datalen, umode_t mode, uid_t uid,
+		     gid_t gid, cfs_cap_t capability, __u64 rdev);
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		   __u32 mode, __u64 rdev, __u64 flags, const void *data,
-		   int datalen);
+		   umode_t mode, __u64 rdev, __u64 flags, const void *data,
+		   size_t datalen);
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		     const char *old, int oldlen, const char *new, int newlen);
+		     const char *old, size_t oldlen,
+		     const char *new, size_t newlen);
 void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 
 /* mdc/mdc_locks.c */
@@ -94,16 +95,17 @@ void mdc_commit_open(struct ptlrpc_request *req);
 void mdc_replay_open(struct ptlrpc_request *req);
 
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
-	       const void *data, int datalen, int mode, __u32 uid, __u32 gid,
-	       cfs_cap_t capability, __u64 rdev,
+	       const void *data, size_t datalen, umode_t mode, uid_t uid,
+	       gid_t gid, cfs_cap_t capability, __u64 rdev,
 	       struct ptlrpc_request **request);
 int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	     struct ptlrpc_request **request);
 int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
-	       const char *old, int oldlen, const char *new, int newlen,
+	       const char *old, size_t oldlen,
+	       const char *new, size_t newlen,
 	       struct ptlrpc_request **request);
 int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		void *ea, int ealen, void *ea2, int ea2len,
+		void *ea, size_t ealen, void *ea2, size_t ea2len,
 		struct ptlrpc_request **request, struct md_open_data **mod);
 int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index ecfe13e..82d1c4d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -58,7 +58,7 @@ void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 }
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
-		   __u64 valid, int ea_size, __u32 suppgid, int flags)
+		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
@@ -103,8 +103,8 @@ static void mdc_pack_name(struct ptlrpc_request *req,
 	LASSERT(cpy_len == name_len && lu_name_is_valid_2(buf, cpy_len));
 }
 
-void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff,
-		      __u32 size, const struct lu_fid *fid)
+void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
+		      const struct lu_fid *fid)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
@@ -118,8 +118,8 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff,
 
 /* packing of MDS records */
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		     const void *data, int datalen, __u32 mode,
-		     __u32 uid, __u32 gid, cfs_cap_t cap_effective, __u64 rdev)
+		     const void *data, size_t datalen, umode_t mode,
+		     uid_t uid, gid_t gid, cfs_cap_t cap_effective, __u64 rdev)
 {
 	struct mdt_rec_create	*rec;
 	char			*tmp;
@@ -153,7 +153,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	}
 }
 
-static __u64 mds_pack_open_flags(__u64 flags, __u32 mode)
+static inline __u64 mds_pack_open_flags(__u64 flags)
 {
 	__u64 cr_flags = (flags & (FMODE_READ | FMODE_WRITE |
 				   MDS_OPEN_FL_INTERNAL));
@@ -182,8 +182,8 @@ static __u64 mds_pack_open_flags(__u64 flags, __u32 mode)
 
 /* packing of MDS records */
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		   __u32 mode, __u64 rdev, __u64 flags, const void *lmm,
-		   int lmmlen)
+		   umode_t mode, __u64 rdev, __u64 flags, const void *lmm,
+		   size_t lmmlen)
 {
 	struct mdt_rec_create *rec;
 	char *tmp;
@@ -201,7 +201,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_fid2 = op_data->op_fid2;
 
 	rec->cr_mode     = mode;
-	cr_flags = mds_pack_open_flags(flags, mode);
+	cr_flags = mds_pack_open_flags(flags);
 	rec->cr_rdev     = rdev;
 	rec->cr_time     = op_data->op_mod_time;
 	rec->cr_suppgid1 = op_data->op_suppgids[0];
@@ -307,7 +307,7 @@ static void mdc_ioepoch_pack(struct mdt_ioepoch *epoch,
 }
 
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		      void *ea, int ealen, void *ea2, int ea2len)
+		      void *ea, size_t ealen, void *ea2, size_t ea2len)
 {
 	struct mdt_rec_setattr *rec;
 	struct mdt_ioepoch *epoch;
@@ -388,7 +388,8 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 }
 
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		     const char *old, int oldlen, const char *new, int newlen)
+		     const char *old, size_t oldlen,
+		     const char *new, size_t newlen)
 {
 	struct mdt_rec_rename *rec;
 
@@ -416,8 +417,8 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
 }
 
-void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
-		      struct md_op_data *op_data, int ea_size)
+void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
+		      struct md_op_data *op_data, size_t ea_size)
 {
 	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
 						    &RMF_MDT_BODY);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 54de46b..f1f6c08 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -235,7 +235,7 @@ mdc_intent_open_pack(struct obd_export *exp, struct lookup_intent *it,
 	struct obd_device     *obddev = class_exp2obd(exp);
 	struct ldlm_intent    *lit;
 	const void *lmm = op_data->op_data;
-	int lmmsize = op_data->op_data_size;
+	u32 lmmsize = op_data->op_data_size;
 	LIST_HEAD(cancels);
 	int		    count = 0;
 	int		    mode;
@@ -317,7 +317,8 @@ mdc_intent_getxattr_pack(struct obd_export *exp,
 {
 	struct ptlrpc_request	*req;
 	struct ldlm_intent	*lit;
-	int			rc, count = 0, maxdata;
+	int rc, count = 0;
+	u32 maxdata;
 	LIST_HEAD(cancels);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -402,7 +403,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 				       OBD_MD_MEA | OBD_MD_FLACL;
 	struct ldlm_intent    *lit;
 	int		    rc;
-	int		    easize;
+	u32 easize;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_GETATTR);
@@ -507,7 +508,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	struct ldlm_reply   *lockrep;
 	struct ldlm_lock    *lock;
 	void		*lvb_data = NULL;
-	int		  lvb_len = 0;
+	u32 lvb_len = 0;
 
 	LASSERT(rc >= 0);
 	/* Similarly, if we're going to replay this request, we don't want to
@@ -952,8 +953,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	}
 	CDEBUG(D_DENTRY,
 	       "D_IT dentry %.*s intent: %s status %d disp %x rc %d\n",
-	       op_data->op_namelen, op_data->op_name, ldlm_it2str(it->it_op),
-	       it->it_status, it->it_disposition, rc);
+	       (int)op_data->op_namelen, op_data->op_name,
+	       ldlm_it2str(it->it_op), it->it_status, it->it_disposition, rc);
 	return rc;
 }
 
@@ -1067,7 +1068,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(it);
 
 	CDEBUG(D_DLMTRACE, "(name: %.*s,"DFID") in obj "DFID
-		", intent: %s flags %#Lo\n", op_data->op_namelen,
+		", intent: %s flags %#Lo\n", (int)op_data->op_namelen,
 		op_data->op_name, PFID(&op_data->op_fid2),
 		PFID(&op_data->op_fid1), ldlm_it2str(it->it_op),
 		it->it_flags);
@@ -1177,8 +1178,8 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 
 	CDEBUG(D_DLMTRACE,
 	       "name: %.*s in inode " DFID ", intent: %s flags %#Lo\n",
-	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
-	       ldlm_it2str(it->it_op), it->it_flags);
+	       (int)op_data->op_namelen, op_data->op_name,
+	       PFID(&op_data->op_fid1), ldlm_it2str(it->it_op), it->it_flags);
 
 	fid_build_reg_res_name(&op_data->op_fid1, &res_id);
 	req = mdc_intent_getattr_pack(exp, it, op_data);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index af5c92c..c921e47 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -99,7 +99,7 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 }
 
 int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		void *ea, int ealen, void *ea2, int ea2len,
+		void *ea, size_t ealen, void *ea2, size_t ea2len,
 		struct ptlrpc_request **request, struct md_open_data **mod)
 {
 	LIST_HEAD(cancels);
@@ -196,9 +196,9 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
-	       const void *data, int datalen, int mode, __u32 uid, __u32 gid,
-	       cfs_cap_t cap_effective, __u64 rdev,
-	       struct ptlrpc_request **request)
+	       const void *data, size_t datalen, umode_t mode,
+	       uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+	       __u64 rdev, struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int level, rc;
@@ -389,7 +389,7 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
-	       const char *old, int oldlen, const char *new, int newlen,
+	       const char *old, size_t oldlen, const char *new, size_t newlen,
 	       struct ptlrpc_request **request)
 {
 	LIST_HEAD(cancels);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 157fdc0..e622b7a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -447,7 +447,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 		if (rc < 0)
 			goto out;
 
-		if (rc < sizeof(*md->lsm)) {
+		if (rc < (typeof(rc))sizeof(*md->lsm)) {
 			CDEBUG(D_INFO,
 			       "lsm size too small: rc < sizeof (*md->lsm) (%d < %d)\n",
 			       rc, (int)sizeof(*md->lsm));
@@ -485,7 +485,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			if (rc < 0)
 				goto out;
 
-			if (rc < sizeof(*md->lmv)) {
+			if (rc < (typeof(rc))sizeof(*md->lmv)) {
 				CDEBUG(D_INFO,
 				       "size too small: rc < sizeof(*md->lmv) (%d < %d)\n",
 					rc, (int)sizeof(*md->lmv));
@@ -1843,7 +1843,7 @@ out:
 	return rc;
 }
 
-static struct kuc_hdr *changelog_kuc_hdr(char *buf, int len, int flags)
+static struct kuc_hdr *changelog_kuc_hdr(char *buf, size_t len, u32 flags)
 {
 	struct kuc_hdr *lh = (struct kuc_hdr *)buf;
 
@@ -1876,7 +1876,8 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 	struct changelog_show *cs = data;
 	struct llog_changelog_rec *rec = (struct llog_changelog_rec *)hdr;
 	struct kuc_hdr *lh;
-	int len, rc;
+	size_t len;
+	int rc;
 
 	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
 		rc = -EINVAL;
@@ -1907,7 +1908,7 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 	memcpy(lh + 1, &rec->cr, len - sizeof(*lh));
 
 	rc = libcfs_kkuc_msg_put(cs->cs_fp, lh);
-	CDEBUG(D_HSM, "kucmsg fp %p len %d rc %d\n", cs->cs_fp, len, rc);
+	CDEBUG(D_HSM, "kucmsg fp %p len %zu rc %d\n", cs->cs_fp, len, rc);
 
 	return rc;
 }
@@ -2369,7 +2370,7 @@ static void lustre_swab_hai(struct hsm_action_item *h)
 static void lustre_swab_hal(struct hsm_action_list *h)
 {
 	struct hsm_action_item	*hai;
-	int			 i;
+	u32 i;
 
 	__swab32s(&h->hal_version);
 	__swab32s(&h->hal_count);
@@ -2418,14 +2419,14 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
  * @param val KUC message (kuc_hdr + hsm_action_list)
  * @param len total length of message
  */
-static int mdc_hsm_copytool_send(int len, void *val)
+static int mdc_hsm_copytool_send(size_t len, void *val)
 {
 	struct kuc_hdr		*lh = (struct kuc_hdr *)val;
 	struct hsm_action_list	*hal = (struct hsm_action_list *)(lh + 1);
 
 	if (len < sizeof(*lh) + sizeof(*hal)) {
-		CERROR("Short HSM message %d < %d\n", len,
-		       (int)(sizeof(*lh) + sizeof(*hal)));
+		CERROR("Short HSM message %zu < %zu\n", len,
+		       sizeof(*lh) + sizeof(*hal));
 		return -EPROTO;
 	}
 	if (lh->kuc_magic == __swab16(KUC_MAGIC)) {
@@ -2528,18 +2529,18 @@ static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
 	int rc = -EINVAL;
 
 	if (KEY_IS(KEY_MAX_EASIZE)) {
-		int mdsize, *max_easize;
+		u32 mdsize, *max_easize;
 
 		if (*vallen != sizeof(int))
 			return -EINVAL;
-		mdsize = *(int *)val;
+		mdsize = *(u32 *)val;
 		if (mdsize > exp->exp_obd->u.cli.cl_max_mds_easize)
 			exp->exp_obd->u.cli.cl_max_mds_easize = mdsize;
 		max_easize = val;
 		*max_easize = exp->exp_obd->u.cli.cl_max_mds_easize;
 		return 0;
 	} else if (KEY_IS(KEY_DEFAULT_EASIZE)) {
-		int *default_easize;
+		u32 *default_easize;
 
 		if (*vallen != sizeof(int))
 			return -EINVAL;
@@ -2556,7 +2557,7 @@ static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
 		*data = imp->imp_connect_data;
 		return 0;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
-		*((int *)val) = 1;
+		*((u32 *)val) = 1;
 		return 0;
 	}
 
@@ -2784,8 +2785,8 @@ err_rpc_lock:
  * a large number of stripes is possible.  If a larger reply buffer is
  * required it will be reallocated in the ptlrpc layer due to overflow.
  */
-static int mdc_init_ea_size(struct obd_export *exp, int easize,
-			    int def_easize, int cookiesize, int def_cookiesize)
+static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
+			    u32 cookiesize, u32 def_cookiesize)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct client_obd *cli = &obd->u.cli;
-- 
1.7.1
