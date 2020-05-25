From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:40 -0400
Subject: [lustre-devel] [PATCH 03/45] lustre: cleanups and bug fixes
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix various bugs in the Linux Lustre client. Small styles fixes
as well.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_request.c         |  2 +-
 fs/lustre/fld/fld_cache.c           | 40 -------------------------------------
 fs/lustre/fld/fld_internal.h        |  7 -------
 fs/lustre/llite/llite_internal.h    |  2 +-
 fs/lustre/llite/llite_lib.c         |  2 --
 fs/lustre/llite/lproc_llite.c       | 10 +++++-----
 fs/lustre/llite/statahead.c         |  2 +-
 fs/lustre/llite/xattr.c             |  1 +
 fs/lustre/mdc/mdc_changelog.c       |  1 +
 fs/lustre/mgc/mgc_request.c         |  8 +++++---
 fs/lustre/obdclass/cl_page.c        |  1 -
 fs/lustre/obdclass/class_obd.c      | 23 ++++++++++-----------
 fs/lustre/obdclass/lprocfs_status.c |  6 +++---
 fs/lustre/osc/osc_cache.c           |  2 +-
 fs/lustre/osc/osc_request.c         |  5 ++---
 fs/lustre/ptlrpc/import.c           |  2 +-
 16 files changed, 33 insertions(+), 81 deletions(-)

diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index a1c3bd9..a7013d1 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -179,7 +179,7 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 		rc = seq_client_alloc_meta(env, seq);
 		if (rc) {
 			if (rc != -EINPROGRESS)
-				CERROR("%s: Can't allocate new meta-sequence, rc = %d\n",
+				CERROR("%s: Cannot allocate new meta-sequence, rc = %d\n",
 				       seq->lcs_name, rc);
 			*seqnr = U64_MAX;
 			return rc;
diff --git a/fs/lustre/fld/fld_cache.c b/fs/lustre/fld/fld_cache.c
index 79b10bb..f288907 100644
--- a/fs/lustre/fld/fld_cache.c
+++ b/fs/lustre/fld/fld_cache.c
@@ -431,46 +431,6 @@ int fld_cache_insert(struct fld_cache *cache,
 }
 
 /**
- * Delete FLD entry in FLD cache.
- *
- */
-
-struct fld_cache_entry
-*fld_cache_entry_lookup_nolock(struct fld_cache *cache,
-			      struct lu_seq_range *range)
-{
-	struct fld_cache_entry *flde;
-	struct fld_cache_entry *got = NULL;
-	struct list_head *head;
-
-	head = &cache->fci_entries_head;
-	list_for_each_entry(flde, head, fce_list) {
-		if (range->lsr_start == flde->fce_range.lsr_start ||
-		    (range->lsr_end == flde->fce_range.lsr_end &&
-		     range->lsr_flags == flde->fce_range.lsr_flags)) {
-			got = flde;
-			break;
-		}
-	}
-
-	return got;
-}
-
-/**
- * lookup @seq sequence for range in fld cache.
- */
-struct fld_cache_entry
-*fld_cache_entry_lookup(struct fld_cache *cache, struct lu_seq_range *range)
-{
-	struct fld_cache_entry *got = NULL;
-
-	read_lock(&cache->fci_lock);
-	got = fld_cache_entry_lookup_nolock(cache, range);
-	read_unlock(&cache->fci_lock);
-	return got;
-}
-
-/**
  * lookup @seq sequence for range in fld cache.
  */
 int fld_cache_lookup(struct fld_cache *cache,
diff --git a/fs/lustre/fld/fld_internal.h b/fs/lustre/fld/fld_internal.h
index 53648d2..d44e378 100644
--- a/fs/lustre/fld/fld_internal.h
+++ b/fs/lustre/fld/fld_internal.h
@@ -151,13 +151,6 @@ struct fld_cache_entry
 int fld_cache_lookup(struct fld_cache *cache,
 		     const u64 seq, struct lu_seq_range *range);
 
-struct fld_cache_entry*
-fld_cache_entry_lookup(struct fld_cache *cache, struct lu_seq_range *range);
-
-struct fld_cache_entry
-*fld_cache_entry_lookup_nolock(struct fld_cache *cache,
-			      struct lu_seq_range *range);
-
 static inline const char *
 fld_target_name(struct lu_fld_target *tar)
 {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 671bceb..c3f60bb 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -417,7 +417,7 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 /* default readahead on a given system. */
 #define SBI_DEFAULT_READ_AHEAD_MAX		MiB_TO_PAGES(64UL)
 
-/* default read-ahead full files smaller than 2MB on the second read */
+/* default read-ahead full files smaller than limit on the second read */
 #define SBI_DEFAULT_READ_AHEAD_WHOLE_MAX	MiB_TO_PAGES(2UL)
 
 enum ra_stat {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 89e0428..84ec734 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2347,8 +2347,6 @@ void ll_umount_begin(struct super_block *sb)
 		ssleep(1);
 		cnt++;
 	}
-
-	schedule();
 }
 
 int ll_remount_fs(struct super_block *sb, int *flags, char *data)
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index a38b25e..5b10ed0 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -349,9 +349,9 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
+	pages_number = round_up(ra_max_mb, 1024 * 1024) >> PAGE_SHIFT;
 	CDEBUG(D_INFO, "%s: set max_read_ahead_mb=%llu (%llu pages)\n",
 	       sbi->ll_fsname, PAGES_TO_MiB(pages_number), pages_number);
-	pages_number = round_up(ra_max_mb, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number > totalram_pages() / 2) {
 		/* 1/2 of RAM */
 		CERROR("%s: cannot set max_read_ahead_mb=%llu > totalram/2=%luMB\n",
@@ -571,7 +571,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 			break;
 
 		if (!sbi->ll_dt_exp) { /* being initialized */
-			rc = 0;
+			rc = -ENODEV;
 			goto out;
 		}
 
@@ -1111,9 +1111,9 @@ static ssize_t max_read_ahead_async_active_show(struct kobject *kobj,
 }
 
 static ssize_t max_read_ahead_async_active_store(struct kobject *kobj,
-						struct attribute *attr,
-						const char *buffer,
-						size_t count)
+						 struct attribute *attr,
+						 const char *buffer,
+						 size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index ba7ebab..04e013f 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1568,7 +1568,7 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	 * statahead thread won't be notified to quit.
 	 */
 	spin_lock(&lli->lli_sa_lock);
-	if (unlikely(lli->lli_sai || lli->lli_opendir_key ||
+	if (unlikely(lli->lli_sai || !lli->lli_opendir_key ||
 		     lli->lli_opendir_pid != current->pid)) {
 		spin_unlock(&lli->lli_sa_lock);
 		rc = -EPERM;
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 5d0f7b2..9e7ba21 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -264,6 +264,7 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 		 */
 		return -ERANGE;
 	}
+
 	rc = ll_adjust_lum(inode, lump);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 61f3d29..3aace7e 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -840,6 +840,7 @@ int mdc_changelog_cdev_init(struct obd_device *obd)
 	entry->ced_device = device;
 
 	entry = NULL;	/* prevent it from being freed below */
+	rc = 0;
 	goto out_unlock;
 
 out_cdev:
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index eb7d22e..81f3873 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -970,9 +970,11 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		       imp->imp_deactive, imp->imp_invalid,
 		       imp->imp_replayable, imp->imp_obd->obd_replayable,
 		       ptlrpc_import_state_name(imp->imp_state));
-		/* Resurrect if we previously died */
-		if ((imp->imp_state != LUSTRE_IMP_FULL &&
-		     imp->imp_state != LUSTRE_IMP_NEW) || value > 1)
+		/* Resurrect the import immediately if
+		 * 1. we previously got disconnected,
+		 * 2. value > 1 (at the same node with MGS)
+		 */
+		if (imp->imp_state != LUSTRE_IMP_NEW || value > 1)
 			ptlrpc_reconnect_import(imp);
 		return 0;
 	}
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 3ed8e73..d5be0c5 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -200,7 +200,6 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 	struct cl_page *page;
 	struct cl_object *o2;
 
-	page = kzalloc(cl_object_header(o)->coh_page_bufsize, GFP_NOFS);
 	page = __cl_page_alloc(o);
 	if (page) {
 		int result = 0;
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 0e07fea..038ee62 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -512,7 +512,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 	u64 __size;							       \
 	int __ret;							       \
 									       \
-	BUILD_BUG_ON(strlen(value) >= 23);				       \
+	BUILD_BUG_ON(sizeof(value) >= 23);				       \
 	__ret = sysfs_memparse(value, sizeof(value) - 1, &__size, def_unit);   \
 	if (__ret != __rc)						       \
 		CERROR("string_helper: parsing '%s' expect rc %d != got %d\n", \
@@ -531,9 +531,6 @@ static int __init obd_init_checks(void)
 	char buf[64];
 	int len, ret = 0;
 
-	CDEBUG(D_INFO, "LPU64=%s, LPD64=%s, LPX64=%s\n", "%llu", "%lld",
-	       "%#llx");
-
 	CDEBUG(D_INFO, "OBD_OBJECT_EOF = %#llx\n", (u64)OBD_OBJECT_EOF);
 
 	u64val = OBD_OBJECT_EOF;
@@ -545,7 +542,7 @@ static int __init obd_init_checks(void)
 	}
 	len = snprintf(buf, sizeof(buf), "%#llx", u64val);
 	if (len != 18) {
-		CWARN("LPX64 wrong length! strlen(%s)=%d != 18\n", buf, len);
+		CERROR("LPX64 wrong length! strlen(%s)=%d != 18\n", buf, len);
 		ret = -EINVAL;
 	}
 
@@ -559,37 +556,39 @@ static int __init obd_init_checks(void)
 	if (u64val >> 8 != OBD_OBJECT_EOF >> 8) {
 		CERROR("u64 %#llx(%d) != 0xffffffffffffffff\n",
 		       u64val, (int)sizeof(u64val));
-		return -EOVERFLOW;
+		ret = -EOVERFLOW;
 	}
 	if (do_div(div64val, 256) != (u64val & 255)) {
 		CERROR("do_div(%#llx,256) != %llu\n", u64val, u64val & 255);
-		return -EOVERFLOW;
+		ret = -EOVERFLOW;
 	}
 	if (u64val >> 8 != div64val) {
 		CERROR("do_div(%#llx,256) %llu != %llu\n",
 		       u64val, div64val, u64val >> 8);
-		return -EOVERFLOW;
+		ret = -EOVERFLOW;
 	}
 	len = snprintf(buf, sizeof(buf), "%#llx", u64val);
 	if (len != 18) {
-		CWARN("LPX64 wrong length! strlen(%s)=%d != 18\n", buf, len);
+		CERROR("LPX64 wrong length! strlen(%s)=%d != 18\n", buf, len);
 		ret = -EINVAL;
 	}
 	len = snprintf(buf, sizeof(buf), "%llu", u64val);
 	if (len != 20) {
-		CWARN("LPU64 wrong length! strlen(%s)=%d != 20\n", buf, len);
+		CERROR("LPU64 wrong length! strlen(%s)=%d != 20\n", buf, len);
 		ret = -EINVAL;
 	}
 	len = snprintf(buf, sizeof(buf), "%lld", u64val);
 	if (len != 2) {
-		CWARN("LPD64 wrong length! strlen(%s)=%d != 2\n", buf, len);
+		CERROR("LPD64 wrong length! strlen(%s)=%d != 2\n", buf, len);
 		ret = -EINVAL;
 	}
 	if ((u64val & ~PAGE_MASK) >= PAGE_SIZE) {
-		CWARN("mask failed: u64val %llu >= %llu\n", u64val,
+		CERROR("mask failed: u64val %llu >= %llu\n", u64val,
 		      (u64)PAGE_SIZE);
 		ret = -EINVAL;
 	}
+	if (ret)
+		return ret;
 
 	/* invalid string */
 	if (!test_string_to_size_err("256B34", 256, "B", -EINVAL)) {
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index e2b74cf..5f94669 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -236,7 +236,7 @@ static void obd_connect_data_seqprint(struct seq_file *m,
  *
  *  - ``-EINVAL``: @buffer is not a proper numerical string
  *  - ``-EOVERFLOW``: results does not fit into 64 bits.
- *  - ``-E2BIG ``: @buffer is not large (not a valid number)
+ *  - ``-E2BIG ``: @buffer is too large (not a valid number)
  */
 int string_to_size(u64 *size, const char *buffer, size_t count)
 {
@@ -1057,8 +1057,8 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 	int rc;
 
 	with_imp_locked(obd, imp, rc) {
-		flags = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags;
-		flags2 = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags2;
+		flags = imp->imp_connect_data.ocd_connect_flags;
+		flags2 = imp->imp_connect_data.ocd_connect_flags2;
 		seq_printf(m, "flags=%#llx\n", flags);
 		seq_printf(m, "flags2=%#llx\n", flags2);
 		obd_connect_seq_flags2str(m, flags, flags2, "\n");
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 4df4202..9e28ff6 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1655,7 +1655,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	 * run out of grants. In both cases we should write dirty pages out.
 	 * Adding a cache waiter will trigger urgent write-out no matter what
 	 * RPC size will be.
-	 * The exiting condition (other then success) is no avail grants
+	 * The exiting condition (other than success) is no avail grants
 	 * and no dirty pages caching, that really means there is no space
 	 * on the OST.
 	 */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index d499e26..4db249e 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1295,7 +1295,6 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				struct obdo *oa, u32 page_count,
 				struct brw_page **pga,
 				struct ptlrpc_request **reqp,
-				int reserve,
 				int resend)
 {
 	struct ptlrpc_request *req;
@@ -1948,7 +1947,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 				   OST_WRITE) ? OBD_BRW_WRITE : OBD_BRW_READ,
 				  aa->aa_cli, aa->aa_oa,
 				  aa->aa_page_count, aa->aa_ppga,
-				  &new_req, 0, 1);
+				  &new_req, 1);
 	if (rc)
 		return rc;
 
@@ -2298,7 +2297,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	sort_brw_pages(pga, page_count);
-	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 1, 0);
+	rc = osc_brw_prep_request(cmd, cli, oa, page_count, pga, &req, 0);
 	if (rc != 0) {
 		CERROR("prep_req failed: %d\n", rc);
 		goto out;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 805be82..709b9fd 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1879,7 +1879,7 @@ timeout_t at_measured(struct adaptive_timeout *at, timeout_t timeout)
 				       at_min);
 	if (at->at_current_timeout != old_timeout)
 		CDEBUG(D_OTHER,
-		       "AT %p change: old=%u new=%u delta=%d (val=%u) hist %u %u %u %u\n",
+		       "AT %p change: old=%u new=%u delta=%d (val=%d) hist %u %u %u %u\n",
 		       at, old_timeout, at->at_current_timeout,
 		       at->at_current_timeout - old_timeout, timeout,
 		       at->at_hist[0], at->at_hist[1], at->at_hist[2],
-- 
1.8.3.1
