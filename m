From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:34 -0400
Subject: [lustre-devel] [PATCH 135/151] lustre: llite: Disable tiny writes
 for append
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-136-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Unfortunately, tiny writes do not work correctly with
appending to files.  When appending to a file, we must take
DLM locks to EOF on all stripes, in order to protect file
size so we can append correctly.

If we dirty a page with a normal write then append to it
with a tiny write, these DLM locks are not present, and we
can use an incorrect size if another client writes to a
different stripe, increasing the size without cancelling
the lock which is protecting our dirty page.

We could theoretically check to make sure the required DLM
locks are held, but this would be time consuming.

The simplest solution is to just not allow tiny writes when
appending.

Also add option to disable tiny writes at runtime.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10681
Cray-bug-id: LUS-5723
Lustre-commit: d79ffa3ff746 ("LU-10681 llite: Disable tiny writes for append")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31353
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           | 70 +++++++++-------------------------------
 fs/lustre/llite/llite_internal.h |  8 +++++
 fs/lustre/llite/llite_lib.c      |  1 +
 fs/lustre/llite/lproc_llite.c    | 36 +++++++++++++++++++++
 4 files changed, 61 insertions(+), 54 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 6732b68..fe4340d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1484,70 +1484,29 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
  * and will write it out.  This saves a lot of processing time.
  *
  * All writes here are within one page, so exclusion is handled by the page
- * lock on the vm page.  Exception is appending, which requires locking the
- * full file to handle size issues.  We do not do tiny writes for writes which
- * touch multiple pages because it's very unlikely multiple sequential pages
+ * lock on the vm page.  We do not do tiny writes for writes which touch
+ * multiple pages because it's very unlikely multiple sequential pages are
  * are already dirty.
  *
  * We limit these to < PAGE_SIZE because PAGE_SIZE writes are relatively common
  * and are unlikely to be to already dirty pages.
  *
- * Attribute updates are important here, we do it in ll_tiny_write_end.
+ * Attribute updates are important here, we do them in ll_tiny_write_end.
  */
 static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 {
 	ssize_t count = iov_iter_count(iter);
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file_inode(file);
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct range_lock range;
 	ssize_t result = 0;
-	bool append = false;
-
-	/* NB: we can't do direct IO for tiny writes because they use the page
-	 * cache, and we can't do sync writes because tiny writes can't flush
-	 * pages.
-	 */
-	if (file->f_flags & (O_DIRECT | O_SYNC))
-		return 0;
 
-	/* It is relatively unlikely we will overwrite a full dirty page, so
-	 * limit tiny writes to < PAGE_SIZE
+	/* Restrict writes to single page and < PAGE_SIZE.  See comment@top
+	 * of function for why.
 	 */
-	if (count >= PAGE_SIZE)
+	if (count >= PAGE_SIZE ||
+	    (iocb->ki_pos & (PAGE_SIZE-1)) + count > PAGE_SIZE)
 		return 0;
 
-	/* For append writes, we must take the range lock to protect size
-	 * and also move pos to current size before writing.
-	 */
-	if (file->f_flags & O_APPEND) {
-		struct lu_env *env;
-		u16 refcheck;
-
-		append = true;
-		range_lock_init(&range, 0, LUSTRE_EOF);
-		result = range_lock(&lli->lli_write_tree, &range);
-		if (result)
-			return result;
-		env = cl_env_get(&refcheck);
-		if (IS_ERR(env)) {
-			result = PTR_ERR(env);
-			goto out;
-		}
-		ll_merge_attr(env, inode);
-		cl_env_put(env, &refcheck);
-		iocb->ki_pos = i_size_read(inode);
-	}
-
-	/* Does this write touch multiple pages?
-	 *
-	 * This partly duplicates the PAGE_SIZE check above, but must come
-	 * after range locking for append writes because it depends on the
-	 * write position (ki_pos).
-	 */
-	if ((iocb->ki_pos & (PAGE_SIZE-1)) + count > PAGE_SIZE)
-		goto out;
-
 	result = __generic_file_write_iter(iocb, iter);
 
 	/* If the page is not already dirty, ll_tiny_write_begin returns
@@ -1562,10 +1521,6 @@ static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 		set_bit(LLIF_DATA_MODIFIED, &ll_i2info(inode)->lli_flags);
 	}
 
-out:
-	if (append)
-		range_unlock(&lli->lli_write_tree, &range);
-
 	CDEBUG(D_VFSTRACE, "result: %zu, original count %zu\n", result, count);
 
 	return result;
@@ -1578,10 +1533,17 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct lu_env *env;
 	struct vvp_io_args *args;
-	ssize_t rc_tiny, rc_normal;
+	ssize_t rc_tiny = 0, rc_normal;
 	u16 refcheck;
 
-	rc_tiny = ll_do_tiny_write(iocb, from);
+	/* NB: we can't do direct IO for tiny writes because they use the page
+	 * cache, we can't do sync writes because tiny writes can't flush
+	 * pages, and we can't do append writes because we can't guarantee the
+	 * required DLM locks are held to protect file size.
+	 */
+	if (ll_sbi_has_tiny_write(ll_i2sbi(file_inode(iocb->ki_filp))) &&
+	    !(iocb->ki_filp->f_flags & (O_DIRECT | O_SYNC | O_APPEND)))
+		rc_tiny = ll_do_tiny_write(iocb, from);
 
 	/* In case of error, go on and try normal write - Only stop if tiny
 	 * write completed I/O.
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index f23cf65..e067ba4 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -419,6 +419,7 @@ enum stats_track_type {
 #define LL_SBI_FILE_SECCTX	0x800000 /* set file security context at
 					  * create
 					  */
+#define LL_SBI_TINY_WRITE	0x2000000 /* tiny write support */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -445,6 +446,8 @@ enum stats_track_type {
 	"always_ping",	\
 	"fast_read",    \
 	"file_secctx",	\
+	"pio",		\
+	"tiny_write",	\
 }
 
 /*
@@ -705,6 +708,11 @@ static inline bool ll_sbi_has_fast_read(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_FAST_READ);
 }
 
+static inline bool ll_sbi_has_tiny_write(struct ll_sb_info *sbi)
+{
+	return !!(sbi->ll_flags & LL_SBI_TINY_WRITE);
+}
+
 void ll_ras_enter(struct file *f);
 
 /* llite/lcommon_misc.c */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c94bc65..4d14ce1 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -125,6 +125,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	atomic_set(&sbi->ll_agl_total, 0);
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 	sbi->ll_flags |= LL_SBI_FAST_READ;
+	sbi->ll_flags |= LL_SBI_TINY_WRITE;
 
 	/* root squash */
 	sbi->ll_squash.rsi_uid = 0;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index b69e5d7..e108326 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1024,6 +1024,41 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(xattr_cache);
 
+static ssize_t tiny_write_show(struct kobject *kobj,
+			       struct attribute *attr,
+			       char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return sprintf(buf, "%u\n", !!(sbi->ll_flags & LL_SBI_TINY_WRITE));
+}
+
+static ssize_t tiny_write_store(struct kobject *kobj,
+				struct attribute *attr,
+				const char *buffer,
+				size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	spin_lock(&sbi->ll_lock);
+	if (val)
+		sbi->ll_flags |= LL_SBI_TINY_WRITE;
+	else
+		sbi->ll_flags &= ~LL_SBI_TINY_WRITE;
+	spin_unlock(&sbi->ll_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(tiny_write);
+
 static ssize_t fast_read_show(struct kobject *kobj,
 			      struct attribute *attr,
 			      char *buf)
@@ -1225,6 +1260,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
 	&lustre_attr_fast_read.attr,
+	&lustre_attr_tiny_write.attr,
 	NULL,
 };
 
-- 
1.8.3.1
