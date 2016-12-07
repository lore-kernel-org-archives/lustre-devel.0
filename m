From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:38 -0500
Subject: [lustre-devel] [PATCH 3/5] staging/lustre: Convert all bare
	unsigned to unsigned int
In-Reply-To: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
References: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481086660-1610943-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Highlighted by relatively new checkpatch test, warnings like:
WARNING: Prefer 'unsigned int' to bare use of 'unsigned'

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  6 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  8 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  4 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  6 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  3 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |  3 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  6 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  2 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |  4 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 92 +++++++++++-----------
 17 files changed, 83 insertions(+), 80 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 78f825d..8a84888 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -244,7 +244,7 @@ typedef struct {
 	int		 lstio_ses_timeout;	/* IN: session timeout */
 	int		 lstio_ses_force;	/* IN: force create ? */
 	/** IN: session features */
-	unsigned	 lstio_ses_feats;
+	unsigned int	 lstio_ses_feats;
 	lst_sid_t __user *lstio_ses_idp;	/* OUT: session id */
 	int		 lstio_ses_nmlen;	/* IN: name length */
 	char __user	 *lstio_ses_namep;	/* IN: session name */
@@ -255,7 +255,7 @@ typedef struct {
 	lst_sid_t __user	*lstio_ses_idp;		/* OUT: session id */
 	int __user		*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
-	unsigned __user		*lstio_ses_featp;
+	unsigned int __user	*lstio_ses_featp;
 	lstcon_ndlist_ent_t __user *lstio_ses_ndinfo;	/* OUT: */
 	int			 lstio_ses_nmlen;	/* IN: name length */
 	char __user		*lstio_ses_namep;	/* OUT: session name */
@@ -328,7 +328,7 @@ typedef struct {
 	char __user		*lstio_grp_namep;	/* IN: group name */
 	int			 lstio_grp_count;	/* IN: # of nodes */
 	/** OUT: session features */
-	unsigned __user		*lstio_grp_featp;
+	unsigned int __user	*lstio_grp_featp;
 	lnet_process_id_t __user *lstio_grp_idsp;	/* IN: nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index adef2d2..62753da 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -542,7 +542,8 @@ lprocfs_alloc_stats(unsigned int num, enum lprocfs_stats_flags flags);
 void lprocfs_clear_stats(struct lprocfs_stats *stats);
 void lprocfs_free_stats(struct lprocfs_stats **stats);
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
-			  unsigned conf, const char *name, const char *units);
+			  unsigned int conf, const char *name,
+			  const char *units);
 struct obd_export;
 int lprocfs_exp_cleanup(struct obd_export *exp);
 struct dentry *ldebugfs_add_simple(struct dentry *root,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 1095331..b22f5ba 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -445,8 +445,8 @@ static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
 	return res;
 }
 
-static unsigned ldlm_res_hop_hash(struct cfs_hash *hs,
-				  const void *key, unsigned mask)
+static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
+				      const void *key, unsigned int mask)
 {
 	const struct ldlm_res_id     *id  = key;
 	unsigned int		val = 0;
@@ -457,8 +457,8 @@ static unsigned ldlm_res_hop_hash(struct cfs_hash *hs,
 	return val & mask;
 }
 
-static unsigned ldlm_res_hop_fid_hash(struct cfs_hash *hs,
-				      const void *key, unsigned mask)
+static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
+					  const void *key, unsigned int mask)
 {
 	const struct ldlm_res_id *id = key;
 	struct lu_fid       fid;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 7092305..c632365 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -226,7 +226,7 @@ static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
 
 static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
 				   int namelen, loff_t hash, u64 ino,
-				   unsigned type)
+				   unsigned int type)
 {
 	/* It is hack to access lde_fid for comparison with lgd_fid.
 	 * So the input 'name' must be part of the 'lu_dirent'.
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index c1b7409..21e06e5 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -460,7 +460,7 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 }
 
 static int ll_write_begin(struct file *file, struct address_space *mapping,
-			  loff_t pos, unsigned len, unsigned flags,
+			  loff_t pos, unsigned int len, unsigned int flags,
 			  struct page **pagep, void **fsdata)
 {
 	struct ll_cl_context *lcc;
@@ -577,7 +577,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	struct cl_io *io;
 	struct vvp_io *vio;
 	struct cl_page *page;
-	unsigned from = pos & (PAGE_SIZE - 1);
+	unsigned int from = pos & (PAGE_SIZE - 1);
 	bool unplug = false;
 	int result = 0;
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 198b051..38f75f6 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -26,8 +26,8 @@ struct ll_xattr_entry {
 					     */
 	char			*xe_name;   /* xattr name, \0-terminated */
 	char			*xe_value;  /* xattr value */
-	unsigned		xe_namelen; /* strlen(xe_name) + 1 */
-	unsigned		xe_vallen;  /* xattr value length */
+	unsigned int		xe_namelen; /* strlen(xe_name) + 1 */
+	unsigned int		xe_vallen;  /* xattr value length */
 };
 
 static struct kmem_cache *xattr_kmem;
@@ -104,7 +104,7 @@ static int ll_xattr_cache_find(struct list_head *cache,
 static int ll_xattr_cache_add(struct list_head *cache,
 			      const char *xattr_name,
 			      const char *xattr_val,
-			      unsigned xattr_val_len)
+			      unsigned int xattr_val_len)
 {
 	struct ll_xattr_entry *xattr;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index f8c8a36..7daa867 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -81,7 +81,8 @@ static void lov_pool_putref_locked(struct pool_desc *pool)
  * Chapter 6.4.
  * Addison Wesley, 1973
  */
-static __u32 pool_hashfn(struct cfs_hash *hash_body, const void *key, unsigned mask)
+static __u32 pool_hashfn(struct cfs_hash *hash_body, const void *key,
+			 unsigned int mask)
 {
 	int i;
 	__u32 result;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 2f2e8fcb..2c99717 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1289,7 +1289,8 @@ int ldebugfs_register_stats(struct dentry *parent, const char *name,
 EXPORT_SYMBOL_GPL(ldebugfs_register_stats);
 
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
-			  unsigned conf, const char *name, const char *units)
+			  unsigned int conf, const char *name,
+			  const char *units)
 {
 	struct lprocfs_counter_header	*header;
 	struct lprocfs_counter		*percpu_cntr;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 80e0984..7971562 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -914,8 +914,8 @@ static unsigned long lu_htable_order(struct lu_device *top)
 	return clamp_t(typeof(bits), bits, LU_SITE_BITS_MIN, bits_max);
 }
 
-static unsigned lu_obj_hop_hash(struct cfs_hash *hs,
-				const void *key, unsigned mask)
+static unsigned int lu_obj_hop_hash(struct cfs_hash *hs,
+				    const void *key, unsigned int mask)
 {
 	struct lu_fid  *fid = (struct lu_fid *)key;
 	__u32	   hash;
@@ -1324,7 +1324,7 @@ static atomic_t lu_key_initing_cnt = ATOMIC_INIT(0);
  * lu_context_refill(). No locking is provided, as initialization and shutdown
  * are supposed to be externally serialized.
  */
-static unsigned key_set_version;
+static unsigned int key_set_version;
 
 /**
  * Register new key.
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 0a55d79..9ca84c7 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1450,8 +1450,8 @@ EXPORT_SYMBOL(class_manual_cleanup);
  * uuid<->export lustre hash operations
  */
 
-static unsigned
-uuid_hash(struct cfs_hash *hs, const void *key, unsigned mask)
+static unsigned int
+uuid_hash(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
 	return cfs_hash_djb2_hash(((struct obd_uuid *)key)->uuid,
 				  sizeof(((struct obd_uuid *)key)->uuid), mask);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 001fe75..5f799a4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -188,7 +188,7 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 	struct cl_object *obj = osc2cl(osc);
 	struct lov_oinfo *oinfo = osc->oo_oinfo;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
-	unsigned valid;
+	unsigned int valid;
 
 	valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME | CAT_SIZE;
 	if (!lvb)
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 4bb3b45..fed4da6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -134,8 +134,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 /*
  * Hash operations for uid/gid <-> osc_quota_info
  */
-static unsigned
-oqi_hashfn(struct cfs_hash *hs, const void *key, unsigned mask)
+static unsigned int
+oqi_hashfn(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
 	return cfs_hash_u32_hash(*((__u32 *)key), mask);
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7b6fda5..7143564 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -908,9 +908,9 @@ static int check_write_rcs(struct ptlrpc_request *req,
 static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 {
 	if (p1->flag != p2->flag) {
-		unsigned mask = ~(OBD_BRW_FROM_GRANT | OBD_BRW_NOCACHE |
-				  OBD_BRW_SYNC | OBD_BRW_ASYNC |
-				  OBD_BRW_NOQUOTA | OBD_BRW_SOFT_SYNC);
+		unsigned int mask = ~(OBD_BRW_FROM_GRANT | OBD_BRW_NOCACHE |
+				      OBD_BRW_SYNC | OBD_BRW_ASYNC |
+				      OBD_BRW_NOQUOTA | OBD_BRW_SOFT_SYNC);
 
 		/* warn if we try to combine flags that we don't know to be
 		 * safe to combine
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 7b020d6..6c7c8b6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -152,8 +152,8 @@ void ptlrpc_connection_fini(void)
 /*
  * Hash operations for net_peer<->connection
  */
-static unsigned
-conn_hashfn(struct cfs_hash *hs, const void *key, unsigned mask)
+static unsigned int
+conn_hashfn(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
 	return cfs_hash_djb2_hash(key, sizeof(lnet_process_id_t), mask);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 9bad57d..f874781 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -479,8 +479,8 @@ static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
 	struct ptlrpc_nrs_policy *policy;
 	struct ptlrpc_nrs_pol_info *infos;
 	struct ptlrpc_nrs_pol_info tmp;
-	unsigned num_pols;
-	unsigned pol_idx = 0;
+	unsigned int num_pols;
+	unsigned int pol_idx = 0;
 	bool hp = false;
 	int i;
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index fc754e7..70c7055 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -343,9 +343,9 @@ ptlrpc_server_nthreads_check(struct ptlrpc_service *svc,
 			     struct ptlrpc_service_conf *conf)
 {
 	struct ptlrpc_service_thr_conf *tc = &conf->psc_thr;
-	unsigned init;
-	unsigned total;
-	unsigned nthrs;
+	unsigned int init;
+	unsigned int total;
+	unsigned int nthrs;
 	int weight;
 
 	/*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index e12eb83..a04e36c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -195,25 +195,25 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(REINT_MAX == 10, "found %lld\n",
 		 (long long)REINT_MAX);
 	LASSERTF(DISP_IT_EXECD == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_IT_EXECD);
+		 (unsigned int)DISP_IT_EXECD);
 	LASSERTF(DISP_LOOKUP_EXECD == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_LOOKUP_EXECD);
+		 (unsigned int)DISP_LOOKUP_EXECD);
 	LASSERTF(DISP_LOOKUP_NEG == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_LOOKUP_NEG);
+		 (unsigned int)DISP_LOOKUP_NEG);
 	LASSERTF(DISP_LOOKUP_POS == 0x00000008UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_LOOKUP_POS);
+		 (unsigned int)DISP_LOOKUP_POS);
 	LASSERTF(DISP_OPEN_CREATE == 0x00000010UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_OPEN_CREATE);
+		 (unsigned int)DISP_OPEN_CREATE);
 	LASSERTF(DISP_OPEN_OPEN == 0x00000020UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_OPEN_OPEN);
+		 (unsigned int)DISP_OPEN_OPEN);
 	LASSERTF(DISP_ENQ_COMPLETE == 0x00400000UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_ENQ_COMPLETE);
+		 (unsigned int)DISP_ENQ_COMPLETE);
 	LASSERTF(DISP_ENQ_OPEN_REF == 0x00800000UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_ENQ_OPEN_REF);
+		 (unsigned int)DISP_ENQ_OPEN_REF);
 	LASSERTF(DISP_ENQ_CREATE_REF == 0x01000000UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_ENQ_CREATE_REF);
+		 (unsigned int)DISP_ENQ_CREATE_REF);
 	LASSERTF(DISP_OPEN_LOCK == 0x02000000UL, "found 0x%.8xUL\n",
-		 (unsigned)DISP_OPEN_LOCK);
+		 (unsigned int)DISP_OPEN_LOCK);
 	LASSERTF(MDS_STATUS_CONN == 1, "found %lld\n",
 		 (long long)MDS_STATUS_CONN);
 	LASSERTF(MDS_STATUS_LOV == 2, "found %lld\n",
@@ -400,13 +400,13 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid));
 	LASSERTF(LMAI_RELEASED == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)LMAI_RELEASED);
+		 (unsigned int)LMAI_RELEASED);
 	LASSERTF(LMAC_HSM == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)LMAC_HSM);
+		 (unsigned int)LMAC_HSM);
 	LASSERTF(LMAC_NOT_IN_OI == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)LMAC_NOT_IN_OI);
+		 (unsigned int)LMAC_NOT_IN_OI);
 	LASSERTF(LMAC_FID_ON_OST == 0x00000008UL, "found 0x%.8xUL\n",
-		 (unsigned)LMAC_FID_ON_OST);
+		 (unsigned int)LMAC_FID_ON_OST);
 
 	/* Checks for struct ost_id */
 	LASSERTF((int)sizeof(struct ost_id) == 16, "found %lld\n",
@@ -456,11 +456,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(FID_SEQ_LOV_DEFAULT == 0xffffffffffffffffULL, "found 0x%.16llxULL\n",
 		 (long long)FID_SEQ_LOV_DEFAULT);
 	LASSERTF(FID_OID_SPECIAL_BFL == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)FID_OID_SPECIAL_BFL);
+		 (unsigned int)FID_OID_SPECIAL_BFL);
 	LASSERTF(FID_OID_DOT_LUSTRE == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)FID_OID_DOT_LUSTRE);
+		 (unsigned int)FID_OID_DOT_LUSTRE);
 	LASSERTF(FID_OID_DOT_LUSTRE_OBF == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)FID_OID_DOT_LUSTRE_OBF);
+		 (unsigned int)FID_OID_DOT_LUSTRE_OBF);
 
 	/* Checks for struct lu_dirent */
 	LASSERTF((int)sizeof(struct lu_dirent) == 32, "found %lld\n",
@@ -490,11 +490,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lu_dirent *)0)->lde_name[0]) == 1, "found %lld\n",
 		 (long long)(int)sizeof(((struct lu_dirent *)0)->lde_name[0]));
 	LASSERTF(LUDA_FID == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)LUDA_FID);
+		 (unsigned int)LUDA_FID);
 	LASSERTF(LUDA_TYPE == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)LUDA_TYPE);
+		 (unsigned int)LUDA_TYPE);
 	LASSERTF(LUDA_64BITHASH == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)LUDA_64BITHASH);
+		 (unsigned int)LUDA_64BITHASH);
 
 	/* Checks for struct luda_type */
 	LASSERTF((int)sizeof(struct luda_type) == 2, "found %lld\n",
@@ -820,41 +820,41 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(MSGHDR_CKSUM_INCOMPAT18 == 2, "found %lld\n",
 		 (long long)MSGHDR_CKSUM_INCOMPAT18);
 	LASSERTF(MSG_OP_FLAG_MASK == 0xffff0000UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_OP_FLAG_MASK);
+		 (unsigned int)MSG_OP_FLAG_MASK);
 	LASSERTF(MSG_OP_FLAG_SHIFT == 16, "found %lld\n",
 		 (long long)MSG_OP_FLAG_SHIFT);
 	LASSERTF(MSG_GEN_FLAG_MASK == 0x0000ffffUL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_GEN_FLAG_MASK);
+		 (unsigned int)MSG_GEN_FLAG_MASK);
 	LASSERTF(MSG_LAST_REPLAY == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_LAST_REPLAY);
+		 (unsigned int)MSG_LAST_REPLAY);
 	LASSERTF(MSG_RESENT == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_RESENT);
+		 (unsigned int)MSG_RESENT);
 	LASSERTF(MSG_REPLAY == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_REPLAY);
+		 (unsigned int)MSG_REPLAY);
 	LASSERTF(MSG_DELAY_REPLAY == 0x00000010UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_DELAY_REPLAY);
+		 (unsigned int)MSG_DELAY_REPLAY);
 	LASSERTF(MSG_VERSION_REPLAY == 0x00000020UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_VERSION_REPLAY);
+		 (unsigned int)MSG_VERSION_REPLAY);
 	LASSERTF(MSG_REQ_REPLAY_DONE == 0x00000040UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_REQ_REPLAY_DONE);
+		 (unsigned int)MSG_REQ_REPLAY_DONE);
 	LASSERTF(MSG_LOCK_REPLAY_DONE == 0x00000080UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_LOCK_REPLAY_DONE);
+		 (unsigned int)MSG_LOCK_REPLAY_DONE);
 	LASSERTF(MSG_CONNECT_RECOVERING == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_RECOVERING);
+		 (unsigned int)MSG_CONNECT_RECOVERING);
 	LASSERTF(MSG_CONNECT_RECONNECT == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_RECONNECT);
+		 (unsigned int)MSG_CONNECT_RECONNECT);
 	LASSERTF(MSG_CONNECT_REPLAYABLE == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_REPLAYABLE);
+		 (unsigned int)MSG_CONNECT_REPLAYABLE);
 	LASSERTF(MSG_CONNECT_LIBCLIENT == 0x00000010UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_LIBCLIENT);
+		 (unsigned int)MSG_CONNECT_LIBCLIENT);
 	LASSERTF(MSG_CONNECT_INITIAL == 0x00000020UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_INITIAL);
+		 (unsigned int)MSG_CONNECT_INITIAL);
 	LASSERTF(MSG_CONNECT_ASYNC == 0x00000040UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_ASYNC);
+		 (unsigned int)MSG_CONNECT_ASYNC);
 	LASSERTF(MSG_CONNECT_NEXT_VER == 0x00000080UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_NEXT_VER);
+		 (unsigned int)MSG_CONNECT_NEXT_VER);
 	LASSERTF(MSG_CONNECT_TRANSNO == 0x00000100UL, "found 0x%.8xUL\n",
-		 (unsigned)MSG_CONNECT_TRANSNO);
+		 (unsigned int)MSG_CONNECT_TRANSNO);
 
 	/* Checks for struct obd_connect_data */
 	LASSERTF((int)sizeof(struct obd_connect_data) == 192, "found %lld\n",
@@ -1114,11 +1114,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(OBD_CONNECT_FLAGS2 == 0x8000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_FLAGS2);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)OBD_CKSUM_CRC32);
+		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)OBD_CKSUM_ADLER);
+		 (unsigned int)OBD_CKSUM_ADLER);
 	LASSERTF(OBD_CKSUM_CRC32C == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)OBD_CKSUM_CRC32C);
+		 (unsigned int)OBD_CKSUM_CRC32C);
 
 	/* Checks for struct obdo */
 	LASSERTF((int)sizeof(struct obdo) == 208, "found %lld\n",
@@ -1428,13 +1428,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]));
 	CLASSERT(LOV_MAGIC_V3 == (0x0BD30000 | 0x0BD0));
 	LASSERTF(LOV_PATTERN_RAID0 == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)LOV_PATTERN_RAID0);
+		 (unsigned int)LOV_PATTERN_RAID0);
 	LASSERTF(LOV_PATTERN_RAID1 == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)LOV_PATTERN_RAID1);
+		 (unsigned int)LOV_PATTERN_RAID1);
 	LASSERTF(LOV_PATTERN_FIRST == 0x00000100UL, "found 0x%.8xUL\n",
-		 (unsigned)LOV_PATTERN_FIRST);
+		 (unsigned int)LOV_PATTERN_FIRST);
 	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
-		 (unsigned)LOV_PATTERN_CMOBD);
+		 (unsigned int)LOV_PATTERN_CMOBD);
 
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
@@ -4133,9 +4133,9 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct hsm_request *)0)->hr_data_len) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_request *)0)->hr_data_len));
 	LASSERTF(HSM_FORCE_ACTION == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)HSM_FORCE_ACTION);
+		 (unsigned int)HSM_FORCE_ACTION);
 	LASSERTF(HSM_GHOST_COPY == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)HSM_GHOST_COPY);
+		 (unsigned int)HSM_GHOST_COPY);
 
 	/* Checks for struct hsm_user_request */
 	LASSERTF((int)sizeof(struct hsm_user_request) == 24, "found %lld\n",
-- 
2.7.4
