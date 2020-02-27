From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:18 -0500
Subject: [lustre-devel] [PATCH 270/622] lustre: llite: switch to use
 ll_fsname directly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-271-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

There are many places which try to access filesystem
fsname, instead of parsing it everytime, just store
it into @sbi, we could use @ll_fsname directly whenever we need.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: 506b68a35904 ("LU-12043 llite: switch to use ll_fsname directly")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34602
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            |  7 ++--
 fs/lustre/llite/file.c           | 42 ++++++++++------------
 fs/lustre/llite/lcommon_cl.c     |  5 ++-
 fs/lustre/llite/llite_internal.h |  4 ++-
 fs/lustre/llite/llite_lib.c      | 76 ++++++++++++++--------------------------
 fs/lustre/llite/llite_nfs.c      |  8 ++---
 fs/lustre/llite/lproc_llite.c    | 10 +++---
 fs/lustre/llite/statahead.c      | 10 +++---
 fs/lustre/llite/symlink.c        |  9 +++--
 fs/lustre/llite/vvp_io.c         |  4 +--
 fs/lustre/llite/xattr.c          |  2 +-
 11 files changed, 72 insertions(+), 105 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index ef4fa36..8293a01 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -602,8 +602,8 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 
 		buf = param;
 		/* Get fsname and assume devname to be -MDT0000. */
-		ll_get_fsname(inode->i_sb, buf, MTI_NAME_MAXLEN);
-		strcat(buf, "-MDT0000.lov");
+		snprintf(buf, MGS_PARAM_MAXLEN, "%s-MDT0000.lov",
+			 sbi->ll_fsname);
 		buf += strlen(buf);
 
 		/* Set root stripesize */
@@ -1276,8 +1276,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		rc = ll_get_fid_by_name(inode, filename, namelen, NULL, NULL);
 		if (rc < 0) {
 			CERROR("%s: lookup %.*s failed: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), namelen,
-			       filename, rc);
+			       sbi->ll_fsname, namelen, filename, rc);
 			goto out_free;
 		}
 out_free:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f5b5eec..0f15ea8 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -135,8 +135,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 
 	if (!class_exp2obd(md_exp)) {
 		CERROR("%s: invalid MDC connection handle closing " DFID "\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(&lli->lli_fid));
+		       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
 		rc = 0;
 		goto out;
 	}
@@ -460,7 +459,7 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	 */
 	if (rnb->rnb_offset + rnb->rnb_len < i_size_read(inode)) {
 		CERROR("%s: server returns off/len %llu/%u < i_size %llu\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0), rnb->rnb_offset,
+		       ll_i2sbi(inode)->ll_fsname, rnb->rnb_offset,
 		       rnb->rnb_len, i_size_read(inode));
 		return;
 	}
@@ -486,8 +485,8 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 		if (IS_ERR(vmpage)) {
 			CWARN("%s: cannot fill page %lu for "DFID
 			      " with data: rc = %li\n",
-			      ll_get_fsname(inode->i_sb, NULL, 0),
-			      index + start, PFID(lu_object_fid(&obj->co_lu)),
+			      ll_i2sbi(inode)->ll_fsname, index + start,
+			      PFID(lu_object_fid(&obj->co_lu)),
 			      PTR_ERR(vmpage));
 			break;
 		}
@@ -1080,8 +1079,7 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 	rc2 = ll_close_inode_openhandle(inode, och, 0, NULL);
 	if (rc2 < 0)
 		CERROR("%s: error closing file " DFID ": %d\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(&ll_i2info(inode)->lli_fid), rc2);
+		       sbi->ll_fsname, PFID(&ll_i2info(inode)->lli_fid), rc2);
 	och = NULL; /* och has been freed in ll_close_inode_openhandle() */
 out_release_it:
 	ll_intent_release(&it);
@@ -1124,7 +1122,7 @@ static int ll_swap_layouts_close(struct obd_client_handle *och,
 	int rc;
 
 	CDEBUG(D_INODE, "%s: biased close of file " DFID "\n",
-	       ll_get_fsname(inode->i_sb, NULL, 0), PFID(fid1));
+	       ll_i2sbi(inode)->ll_fsname, PFID(fid1));
 
 	rc = ll_check_swap_layouts_validity(inode, inode2);
 	if (rc < 0)
@@ -2293,7 +2291,7 @@ int ll_hsm_release(struct inode *inode)
 	u16 refcheck;
 
 	CDEBUG(D_INODE, "%s: Releasing file " DFID ".\n",
-	       ll_get_fsname(inode->i_sb, NULL, 0),
+	       ll_i2sbi(inode)->ll_fsname,
 	       PFID(&ll_i2info(inode)->lli_fid));
 
 	och = ll_lease_open(inode, NULL, FMODE_WRITE, MDS_OPEN_RELEASE);
@@ -2716,6 +2714,7 @@ int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
 static int ll_ladvise_sanity(struct inode *inode,
 			     struct llapi_lu_ladvise *ladvise)
 {
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	enum lu_ladvise_type advice = ladvise->lla_advice;
 	/* Note the peradvice flags is a 32 bit field, so per advice flags must
 	 * be in the first 32 bits of enum ladvise_flags
@@ -2728,7 +2727,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 		rc = -EINVAL;
 		CDEBUG(D_VFSTRACE,
 		       "%s: advice with value '%d' not recognized, last supported advice is %s (value '%d'): rc = %d\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0), advice,
+		       sbi->ll_fsname, advice,
 		       ladvise_names[LU_LADVISE_MAX - 1], LU_LADVISE_MAX - 1,
 		       rc);
 		goto out;
@@ -2741,7 +2740,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 			rc = -EINVAL;
 			CDEBUG(D_VFSTRACE,
 			       "%s: Invalid flags (%x) for %s: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), flags,
+			       sbi->ll_fsname, flags,
 			       ladvise_names[advice], rc);
 			goto out;
 		}
@@ -2753,7 +2752,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 			rc = -EINVAL;
 			CDEBUG(D_VFSTRACE,
 			       "%s: Invalid mode (%d) for %s: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       sbi->ll_fsname,
 			       ladvise->lla_lockahead_mode,
 			       ladvise_names[advice], rc);
 			goto out;
@@ -2769,7 +2768,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 			rc = -EINVAL;
 			CDEBUG(D_VFSTRACE,
 			       "%s: Invalid flags (%x) for %s: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), flags,
+			       sbi->ll_fsname, flags,
 			       ladvise_names[advice], rc);
 			goto out;
 		}
@@ -2777,7 +2776,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 			rc = -EINVAL;
 			CDEBUG(D_VFSTRACE,
 			       "%s: Invalid range (%llu to %llu) for %s: rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       sbi->ll_fsname,
 			       ladvise->lla_start, ladvise->lla_end,
 			       ladvise_names[advice], rc);
 			goto out;
@@ -3970,7 +3969,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		if (le32_to_cpu(lum->lum_stripe_count) > 1 ||
 		    ll_i2info(child_inode)->lli_lsm_md) {
 			CERROR("%s: MDT doesn't support stripe directory migration!\n",
-			       ll_get_fsname(parent->i_sb, NULL, 0));
+			       ll_i2sbi(parent)->ll_fsname);
 			rc = -EOPNOTSUPP;
 			goto out_iput;
 		}
@@ -3997,7 +3996,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
 		CERROR("%s: migrate %s, but fid " DFID " is insane\n",
-		       ll_get_fsname(parent->i_sb, NULL, 0), name,
+		       ll_i2sbi(parent)->ll_fsname, name,
 		       PFID(&op_data->op_fid3));
 		rc = -EINVAL;
 		goto out_unlock;
@@ -4171,7 +4170,7 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 	} else if (rc != 0) {
 		CDEBUG_LIMIT((rc == -EACCES || rc == -EIDRM) ? D_INFO : D_ERROR,
 			     "%s: revalidate FID " DFID " error: rc = %d\n",
-			     ll_get_fsname(inode->i_sb, NULL, 0),
+			     ll_i2sbi(inode)->ll_fsname,
 			     PFID(ll_inode2fid(inode)), rc);
 	}
 
@@ -4677,8 +4676,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	/* wait for IO to complete if it's still being used. */
 	if (wait_layout) {
 		CDEBUG(D_INODE, "%s: " DFID "(%p) wait for layout reconf\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(&lli->lli_fid), inode);
+		       sbi->ll_fsname, PFID(&lli->lli_fid), inode);
 
 		memset(&conf, 0, sizeof(conf));
 		conf.coc_opc = OBJECT_CONF_WAIT;
@@ -4689,8 +4687,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 
 		CDEBUG(D_INODE,
 		       "%s: file=" DFID " waiting layout return: %d.\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(&lli->lli_fid), rc);
+		       sbi->ll_fsname, PFID(&lli->lli_fid), rc);
 	}
 	return rc;
 }
@@ -4727,8 +4724,7 @@ static int ll_layout_intent(struct inode *inode, struct layout_intent *intent)
 		it.it_flags = FMODE_WRITE;
 
 	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file " DFID "(%p)",
-			  ll_get_fsname(inode->i_sb, NULL, 0),
-			  PFID(&lli->lli_fid), inode);
+			  sbi->ll_fsname, PFID(&lli->lli_fid), inode);
 
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, &it, &req,
 			    &ll_md_blocking_ast, 0);
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 9ac80e0..3129316 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -174,8 +174,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		if (!(inode->i_state & I_NEW)) {
 			result = -EIO;
 			CERROR("%s: unexpected not-NEW inode "DFID": rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), PFID(fid),
-			       result);
+			       ll_i2sbi(inode)->ll_fsname, PFID(fid), result);
 			goto out;
 		}
 
@@ -202,7 +201,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 
 	if (result)
 		CERROR("%s: failed to initialize cl_object "DFID": rc = %d\n",
-			ll_get_fsname(inode->i_sb, NULL, 0), PFID(fid), result);
+		       ll_i2sbi(inode)->ll_fsname, PFID(fid), result);
 
 out:
 	cl_env_put(env, &refcheck);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 5a0a5ed..b9478f4d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -556,6 +556,9 @@ struct ll_sb_info {
 	/* File heat */
 	unsigned int		ll_heat_decay_weight;
 	unsigned int		ll_heat_period_second;
+
+	/* filesystem fsname */
+	char			ll_fsname[LUSTRE_MAXFSNAME + 1];
 };
 
 #define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
@@ -935,7 +938,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      u32 mode, u32 opc, void *data);
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
-char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req);
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index aadde3f..8e5cf0a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -586,9 +586,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	sb->s_root = d_make_root(root);
 	if (!sb->s_root) {
-		CERROR("%s: can't make root dentry\n",
-		       ll_get_fsname(sb, NULL, 0));
 		err = -ENOMEM;
+		CERROR("%s: can't make root dentry, rc = %d\n",
+		       sbi->ll_fsname, err);
 		goto out_lock_cn_cb;
 	}
 
@@ -614,7 +614,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 					sbi->ll_dt_obd->obd_type->typ_name);
 		if (err < 0) {
 			CERROR("%s: could not register %s in llite: rc = %d\n",
-			       dt, ll_get_fsname(sb, NULL, 0), err);
+			       dt, sbi->ll_fsname, err);
 			err = 0;
 		}
 	}
@@ -625,7 +625,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 					sbi->ll_md_obd->obd_type->typ_name);
 		if (err < 0) {
 			CERROR("%s: could not register %s in llite: rc = %d\n",
-			       md, ll_get_fsname(sb, NULL, 0), err);
+			       md, sbi->ll_fsname, err);
 			err = 0;
 		}
 	}
@@ -1004,6 +1004,19 @@ int ll_fill_super(struct super_block *sb)
 	if (ptr && (strcmp(ptr, "-client") == 0))
 		len -= 7;
 
+	if (len > LUSTRE_MAXFSNAME) {
+		if (unlikely(len >= MAX_OBD_NAME))
+			len = MAX_OBD_NAME - 1;
+		strncpy(name, profilenm, len);
+		name[len] = '\0';
+		err = -ENAMETOOLONG;
+		CERROR("%s: fsname longer than %u characters: rc = %d\n",
+		       name, LUSTRE_MAXFSNAME, err);
+		goto out_free;
+	}
+	strncpy(sbi->ll_fsname, profilenm, len);
+	sbi->ll_fsname[len] = '\0';
+
 	/* Mount info */
 	snprintf(name, sizeof(name), "%.*s-%px", len,
 		 lsi->lsi_lmd->lmd_profile, sb);
@@ -1014,7 +1027,7 @@ int ll_fill_super(struct super_block *sb)
 	err = ll_debugfs_register_super(sb, name);
 	if (err < 0) {
 		CERROR("%s: could not register mountpoint in llite: rc = %d\n",
-		       ll_get_fsname(sb, NULL, 0), err);
+		       sbi->ll_fsname, err);
 		err = 0;
 	}
 
@@ -1208,7 +1221,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 	inode = iget_locked(sb, ino);
 	if (!inode) {
 		CERROR("%s: failed get simple inode " DFID ": rc = -ENOENT\n",
-		       ll_get_fsname(sb, NULL, 0), PFID(fid));
+		       sbi->ll_fsname, PFID(fid));
 		return ERR_PTR(-ENOENT);
 	}
 
@@ -1252,8 +1265,7 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	LASSERT(lsm);
 
 	CDEBUG(D_INODE, "%s: "DFID" set dir layout:\n",
-		ll_get_fsname(inode->i_sb, NULL, 0),
-		PFID(&lli->lli_fid));
+	       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
 	lsm_md_dump(D_INODE, lsm);
 
 	/*
@@ -1322,7 +1334,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		if (lsm->lsm_md_layout_version <=
 		    lli->lli_lsm_md->lsm_md_layout_version) {
 			CERROR("%s: " DFID " dir layout mismatch:\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       ll_i2sbi(inode)->ll_fsname,
 			       PFID(&lli->lli_fid));
 			lsm_md_dump(D_ERROR, lli->lli_lsm_md);
 			lsm_md_dump(D_ERROR, lsm);
@@ -1529,7 +1541,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "%s: setattr inode " DFID "(%p) from %llu to %llu, valid %x, hsm_import %d\n",
-	       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid), inode,
+	       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid), inode,
 	       i_size_read(inode), attr->ia_size, attr->ia_valid, hsm_import);
 
 	if (attr->ia_valid & ATTR_SIZE) {
@@ -2046,7 +2058,7 @@ void ll_delete_inode(struct inode *inode)
 
 	LASSERTF(nrpages == 0,
 		 "%s: inode="DFID"(%p) nrpages=%lu, see https://jira.whamcloud.com/browse/LU-118\n",
-		 ll_get_fsname(inode->i_sb, NULL, 0),
+		 ll_i2sbi(inode)->ll_fsname,
 		 PFID(ll_inode2fid(inode)), inode, nrpages);
 
 	ll_clear_inode(inode);
@@ -2300,7 +2312,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		 */
 		if (!fid_is_sane(&md.body->mbo_fid1)) {
 			CERROR("%s: Fid is insane " DFID "\n",
-			       ll_get_fsname(sb, NULL, 0),
+			       sbi->ll_fsname,
 			       PFID(&md.body->mbo_fid1));
 			rc = -EINVAL;
 			goto out;
@@ -2570,40 +2582,6 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
 	return 0;
 }
 
-/**
- * Get lustre file system name by @sbi. If @buf is provided(non-NULL), the
- * fsname will be returned in this buffer; otherwise, a static buffer will be
- * used to store the fsname and returned to caller.
- */
-char *ll_get_fsname(struct super_block *sb, char *buf, int buflen)
-{
-	static char fsname_static[MTI_NAME_MAXLEN];
-	struct lustre_sb_info *lsi = s2lsi(sb);
-	char *ptr;
-	int len;
-
-	if (!buf) {
-		/* this means the caller wants to use static buffer
-		 * and it doesn't care about race. Usually this is
-		 * in error reporting path
-		 */
-		buf = fsname_static;
-		buflen = sizeof(fsname_static);
-	}
-
-	len = strlen(lsi->lsi_lmd->lmd_profile);
-	ptr = strrchr(lsi->lsi_lmd->lmd_profile, '-');
-	if (ptr && (strcmp(ptr, "-client") == 0))
-		len -= 7;
-
-	if (unlikely(len >= buflen))
-		len = buflen - 1;
-	strncpy(buf, lsi->lsi_lmd->lmd_profile, len);
-	buf[len] = '\0';
-
-	return buf;
-}
-
 void ll_dirty_page_discard_warn(struct page *page, int ioret)
 {
 	char *buf, *path = NULL;
@@ -2613,15 +2591,15 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	/* this can be called inside spin lock so use GFP_ATOMIC. */
 	buf = (char *)__get_free_page(GFP_ATOMIC);
 	if (buf) {
-		dentry = d_find_alias(page->mapping->host);
+		dentry = d_find_alias(inode);
 		if (dentry)
 			path = dentry_path_raw(dentry, buf, PAGE_SIZE);
 	}
 
 	CDEBUG(D_WARNING,
 	       "%s: dirty page discard: %s/fid: " DFID "/%s may get corrupted (rc %d)\n",
-	       ll_get_fsname(page->mapping->host->i_sb, NULL, 0),
-	       s2lsi(page->mapping->host->i_sb)->lsi_lmd->lmd_dev,
+	       ll_i2sbi(inode)->ll_fsname,
+	       s2lsi(inode->i_sb)->lsi_lmd->lmd_dev,
 	       PFID(ll_inode2fid(inode)),
 	       (path && !IS_ERR(path)) ? path : "", ioret);
 
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index de8f707..2ac5ad9 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -181,7 +181,7 @@ static int ll_encode_fh(struct inode *inode, u32 *fh, int *plen,
 	struct lustre_nfs_fid *nfs_fid = (void *)fh;
 
 	CDEBUG(D_INFO, "%s: encoding for (" DFID ") maxlen=%d minlen=%d\n",
-	       ll_get_fsname(inode->i_sb, NULL, 0),
+	       ll_i2sbi(inode)->ll_fsname,
 	       PFID(ll_inode2fid(inode)), *plen, fileid_len);
 
 	if (*plen < fileid_len) {
@@ -298,8 +298,7 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 	sbi = ll_s2sbi(dir->i_sb);
 
 	CDEBUG(D_INFO, "%s: getting parent for (" DFID ")\n",
-	       ll_get_fsname(dir->i_sb, NULL, 0),
-	       PFID(ll_inode2fid(dir)));
+	       sbi->ll_fsname, PFID(ll_inode2fid(dir)));
 
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc != 0)
@@ -315,8 +314,7 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid)
 	ll_finish_md_op_data(op_data);
 	if (rc) {
 		CERROR("%s: failure inode " DFID " get parent: rc = %d\n",
-		       ll_get_fsname(dir->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(dir)), rc);
+		       sbi->ll_fsname, PFID(ll_inode2fid(dir)), rc);
 		return rc;
 	}
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 596aad8..197c09c 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -523,7 +523,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 
 	if (pages_number < 0 || pages_number > totalram_pages()) {
 		CERROR("%s: can't set max cache more than %lu MB\n",
-		       ll_get_fsname(sb, NULL, 0),
+		       sbi->ll_fsname,
 		       totalram_pages() >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
@@ -977,7 +977,7 @@ static int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
 	while (flags != 0) {
 		if (ARRAY_SIZE(str) <= i) {
 			CERROR("%s: Revise array LL_SBI_FLAGS to match sbi flags please.\n",
-			       ll_get_fsname(sb, NULL, 0));
+			       ll_s2sbi(sb)->ll_fsname);
 			return -EINVAL;
 		}
 
@@ -1273,8 +1273,7 @@ static ssize_t ll_root_squash_seq_write(struct file *file,
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct root_squash_info *squash = &sbi->ll_squash;
 
-	return lprocfs_wr_root_squash(buffer, count, squash,
-				      ll_get_fsname(sb, NULL, 0));
+	return lprocfs_wr_root_squash(buffer, count, squash, sbi->ll_fsname);
 }
 LPROC_SEQ_FOPS(ll_root_squash);
 
@@ -1309,8 +1308,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	struct root_squash_info *squash = &sbi->ll_squash;
 	int rc;
 
-	rc = lprocfs_wr_nosquash_nids(buffer, count, squash,
-				      ll_get_fsname(sb, NULL, 0));
+	rc = lprocfs_wr_nosquash_nids(buffer, count, squash, sbi->ll_fsname);
 	if (rc < 0)
 		return rc;
 
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 1de62b5..7dfb045 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -663,9 +663,8 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 		goto out;
 
 	CDEBUG(D_READA, "%s: setting %.*s" DFID " l_data to inode %p\n",
-	       ll_get_fsname(child->i_sb, NULL, 0),
-	       entry->se_qstr.len, entry->se_qstr.name,
-	       PFID(ll_inode2fid(child)), child);
+	       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
+	       entry->se_qstr.name, PFID(ll_inode2fid(child)), child);
 	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
 
 	entry->se_inode = child;
@@ -1270,7 +1269,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 
 			rc = PTR_ERR(page);
 			CERROR("%s: error reading dir " DFID " at %llu: opendir_pid = %u : rc = %d\n",
-			       ll_get_fsname(dir->i_sb, NULL, 0),
+			       ll_i2sbi(dir)->ll_fsname,
 			       PFID(ll_inode2fid(dir)), pos,
 			       lli->lli_opendir_pid, rc);
 			break;
@@ -1472,8 +1471,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 				/* revalidate, but inode is recreated */
 				CDEBUG(D_READA,
 				       "%s: stale dentry %pd inode " DFID ", statahead inode " DFID "\n",
-				       ll_get_fsname((*dentryp)->d_inode->i_sb,
-						     NULL, 0),
+				       ll_i2sbi(inode)->ll_fsname,
 				       *dentryp,
 				       PFID(ll_inode2fid((*dentryp)->d_inode)),
 				       PFID(ll_inode2fid(inode)));
diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index d2922d1..aae449c 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -75,7 +75,7 @@ static int ll_readlink_internal(struct inode *inode,
 	if (rc) {
 		if (rc != -ENOENT)
 			CERROR("%s: inode " DFID ": rc = %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       ll_i2sbi(inode)->ll_fsname,
 			       PFID(ll_inode2fid(inode)), rc);
 		goto failed;
 	}
@@ -90,9 +90,8 @@ static int ll_readlink_internal(struct inode *inode,
 	LASSERT(symlen != 0);
 	if (body->mbo_eadatasize != symlen) {
 		CERROR("%s: inode " DFID ": symlink length %d not expected %d\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)), body->mbo_eadatasize - 1,
-		       symlen - 1);
+		       sbi->ll_fsname, PFID(ll_inode2fid(inode)),
+		       body->mbo_eadatasize - 1, symlen - 1);
 		rc = -EPROTO;
 		goto failed;
 	}
@@ -101,7 +100,7 @@ static int ll_readlink_internal(struct inode *inode,
 	if (!*symname || strnlen(*symname, symlen) != symlen - 1) {
 		/* not full/NULL terminated */
 		CERROR("%s: inode " DFID ": symlink not NULL terminated string of length %d\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       ll_i2sbi(inode)->ll_fsname,
 		       PFID(ll_inode2fid(inode)), symlen - 1);
 		rc = -EPROTO;
 		goto failed;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index ad4b39e..43f4088 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1012,7 +1012,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 	if (pos + cnt > ll_file_maxbytes(inode)) {
 		CDEBUG(D_INODE,
 		       "%s: file " DFID " offset %llu > maxbytes %llu\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       ll_i2sbi(inode)->ll_fsname,
 		       PFID(ll_inode2fid(inode)), pos + cnt,
 		       ll_file_maxbytes(inode));
 		return -EFBIG;
@@ -1440,7 +1440,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 			result = 0;
 		if (result < 0)
 			CERROR("%s: refresh file layout " DFID " error %d.\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       ll_i2sbi(inode)->ll_fsname,
 			       PFID(lu_object_fid(&obj->co_lu)), result);
 	}
 
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 948aaf6..aa61a5a 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -381,7 +381,7 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	if (rc == -EOPNOTSUPP && type == XATTR_USER_T) {
 		LCONSOLE_INFO(
 			"%s: disabling user_xattr feature because it is not supported on the server: rc = %d\n",
-			ll_get_fsname(inode->i_sb, NULL, 0), rc);
+			sbi->ll_fsname, rc);
 		spin_lock(&sbi->ll_lock);
 		sbi->ll_flags &= ~LL_SBI_USER_XATTR;
 		spin_unlock(&sbi->ll_lock);
-- 
1.8.3.1
