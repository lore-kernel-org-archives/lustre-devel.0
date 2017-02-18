From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:08 -0500
Subject: [lustre-devel] [PATCH 07/14] staging: lustre: lov: trying smaller
	memory allocations
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

Reduce struct lov_io_sub to smaller memory usage
on wide-stripe file systems.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7085
Reviewed-on: http://review.whamcloud.com/17476
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 ++--
 drivers/staging/lustre/lustre/llite/file.c         | 16 ++++-----
 drivers/staging/lustre/lustre/llite/glimpse.c      |  4 +--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  8 ++---
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 +--
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 10 +++---
 drivers/staging/lustre/lustre/llite/xattr.c        |  2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    | 41 +++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_object.c     |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  6 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |  6 ++--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 12 +++----
 drivers/staging/lustre/lustre/osc/osc_page.c       |  4 +--
 drivers/staging/lustre/lustre/osc/osc_request.c    |  2 +-
 20 files changed, 67 insertions(+), 68 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 12b3222..2bc3ee5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2437,9 +2437,9 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
  * @{
  */
 
-struct lu_env *cl_env_get(int *refcheck);
-struct lu_env *cl_env_alloc(int *refcheck, __u32 tags);
-void cl_env_put(struct lu_env *env, int *refcheck);
+struct lu_env *cl_env_get(u16 *refcheck);
+struct lu_env *cl_env_alloc(u16 *refcheck, __u32 tags);
+void cl_env_put(struct lu_env *env, u16 *refcheck);
 unsigned int cl_env_cache_purge(unsigned int nr);
 struct lu_env *cl_env_percpu_get(void);
 void cl_env_percpu_put(struct lu_env *env);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 10adfcd..b1c9573 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1159,7 +1159,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	struct lu_env      *env;
 	struct vvp_io_args *args;
 	ssize_t	     result;
-	int		 refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -1183,7 +1183,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct lu_env      *env;
 	struct vvp_io_args *args;
 	ssize_t	     result;
-	int		 refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -1340,7 +1340,7 @@ static int ll_file_getstripe(struct inode *inode,
 			     struct lov_user_md __user *lum)
 {
 	struct lu_env *env;
-	int refcheck;
+	u16 refcheck;
 	int rc;
 
 	env = cl_env_get(&refcheck);
@@ -1517,7 +1517,7 @@ static int ll_do_fiemap(struct inode *inode, struct fiemap *fiemap,
 {
 	struct ll_fiemap_info_key fmkey = { .lfik_name = KEY_FIEMAP, };
 	struct lu_env *env;
-	int refcheck;
+	u16 refcheck;
 	int rc = 0;
 
 	/* Checks for fiemap flags */
@@ -1623,7 +1623,7 @@ int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
 	struct cl_object *obj = ll_i2info(inode)->lli_clob;
 	struct lu_env *env;
 	struct cl_io *io;
-	int refcheck;
+	u16 refcheck;
 	int result;
 
 	/* If no file object initialized, we consider its version is 0. */
@@ -1668,7 +1668,7 @@ int ll_hsm_release(struct inode *inode)
 	struct obd_client_handle *och = NULL;
 	__u64 data_version = 0;
 	int rc;
-	int refcheck;
+	u16 refcheck;
 
 	CDEBUG(D_INODE, "%s: Releasing file "DFID".\n",
 	       ll_get_fsname(inode->i_sb, NULL, 0),
@@ -2324,7 +2324,7 @@ int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 	struct cl_io *io;
 	struct cl_fsync_io *fio;
 	int result;
-	int refcheck;
+	u16 refcheck;
 
 	if (mode != CL_FSYNC_NONE && mode != CL_FSYNC_LOCAL &&
 	    mode != CL_FSYNC_DISCARD && mode != CL_FSYNC_ALL)
@@ -3271,7 +3271,7 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 	struct cl_object *obj = lli->lli_clob;
 	struct lu_env *env;
 	int rc;
-	int refcheck;
+	u16 refcheck;
 
 	if (!obj)
 		return 0;
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 504498d..0143112 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -138,7 +138,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 }
 
 static int cl_io_get(struct inode *inode, struct lu_env **envout,
-		     struct cl_io **ioout, int *refcheck)
+		     struct cl_io **ioout, u16 *refcheck)
 {
 	struct lu_env	  *env;
 	struct cl_io	   *io;
@@ -178,7 +178,7 @@ int cl_glimpse_size0(struct inode *inode, int agl)
 	struct lu_env	  *env = NULL;
 	struct cl_io	   *io  = NULL;
 	int		     result;
-	int		     refcheck;
+	u16 refcheck;
 
 	result = cl_io_get(inode, &env, &io, &refcheck);
 	if (result > 0) {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index f1036f4..8af6110 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -72,7 +72,7 @@
  * mutex.
  */
 struct lu_env *cl_inode_fini_env;
-int cl_inode_fini_refcheck;
+u16 cl_inode_fini_refcheck;
 
 /**
  * A mutex serializing calls to slp_inode_fini() under extreme memory
@@ -86,7 +86,7 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	struct lu_env *env;
 	struct cl_io  *io;
 	int	    result;
-	int	    refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -149,7 +149,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		}
 	};
 	int result = 0;
-	int refcheck;
+	u16 refcheck;
 
 	LASSERT(md->body->mbo_valid & OBD_MD_FLID);
 	LASSERT(S_ISREG(inode->i_mode));
@@ -237,7 +237,7 @@ void cl_inode_fini(struct inode *inode)
 	struct lu_env	   *env;
 	struct ll_inode_info    *lli  = ll_i2info(inode);
 	struct cl_object	*clob = lli->lli_clob;
-	int refcheck;
+	u16 refcheck;
 	int emergency;
 
 	if (clob) {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index f0c132e..7f7f3f1 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -124,7 +124,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 	struct cl_lock	 *lock;
 	struct cl_lock_descr   *descr;
 	__u32		   enqflags;
-	int		     refcheck;
+	u16 refcheck;
 	int		     rc;
 
 	env = cl_env_get(&refcheck);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ecdfd0c..99fb852 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1329,7 +1329,7 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 		   unsigned int attr_flags);
 
 extern struct lu_env *cl_inode_fini_env;
-extern int cl_inode_fini_refcheck;
+extern u16 cl_inode_fini_refcheck;
 
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
 void cl_inode_fini(struct inode *inode);
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index ee01f20..33dc935 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -150,7 +150,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	struct cl_io	    *io;
 	struct vvp_io	   *vio;
 	int		      result;
-	int refcheck;
+	u16 refcheck;
 	sigset_t	     set;
 	struct inode	     *inode;
 	struct ll_inode_info     *lli;
@@ -268,7 +268,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	unsigned long	    ra_flags;
 	int		      result = 0;
 	int		      fault_ret = 0;
-	int refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index f3ee584..40f1fcf 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -386,7 +386,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	struct lu_env *env;
 	long diff = 0;
 	long nrpages = 0;
-	int refcheck;
+	u16 refcheck;
 	long pages_number;
 	int mult;
 	long rc;
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 50d027e..1bac51f 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -905,7 +905,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 	bool redirtied = false;
 	bool unlocked = false;
 	int result;
-	int refcheck;
+	u16 refcheck;
 
 	LASSERT(PageLocked(vmpage));
 	LASSERT(!PageWriteback(vmpage));
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 3669ea7..6cb2db2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -313,7 +313,7 @@ int cl_sb_init(struct super_block *sb)
 	struct cl_device  *cl;
 	struct lu_env     *env;
 	int rc = 0;
-	int refcheck;
+	u16 refcheck;
 
 	sbi  = ll_s2sbi(sb);
 	env = cl_env_get(&refcheck);
@@ -336,7 +336,7 @@ int cl_sb_fini(struct super_block *sb)
 	struct ll_sb_info *sbi;
 	struct lu_env     *env;
 	struct cl_device  *cld;
-	int		refcheck;
+	u16 refcheck;
 	int		result;
 
 	sbi = ll_s2sbi(sb);
@@ -535,7 +535,7 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 	struct cl_object	*clob;
 	struct lu_env	   *env;
 	struct vvp_pgcache_id    id;
-	int		      refcheck;
+	u16 refcheck;
 	int		      result;
 
 	env = cl_env_get(&refcheck);
@@ -584,7 +584,7 @@ static void *vvp_pgcache_start(struct seq_file *f, loff_t *pos)
 {
 	struct ll_sb_info *sbi;
 	struct lu_env     *env;
-	int		refcheck;
+	u16 refcheck;
 
 	sbi = f->private;
 
@@ -608,7 +608,7 @@ static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 {
 	struct ll_sb_info *sbi;
 	struct lu_env     *env;
-	int		refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (!IS_ERR(env)) {
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 421cc04..3ef0291 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -427,7 +427,7 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 			.cl_buf.lb_len = buf_size,
 		};
 		struct lu_env *env;
-		int refcheck;
+		u16 refcheck;
 
 		if (!obj)
 			return -ENODATA;
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index c49a34b..391c632 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -118,7 +118,7 @@ struct lov_device_emerg {
 	 *
 	 * \see cl_env_get()
 	 */
-	int		 emrg_refcheck;
+	u16		 emrg_refcheck;
 };
 
 struct lov_device {
@@ -378,40 +378,39 @@ struct lov_thread_info {
  * State that lov_io maintains for every sub-io.
  */
 struct lov_io_sub {
-	int		  sub_stripe;
-	/**
-	 * sub-io for a stripe. Ideally sub-io's can be stopped and resumed
-	 * independently, with lov acting as a scheduler to maximize overall
-	 * throughput.
-	 */
-	struct cl_io	*sub_io;
+	u16		 sub_stripe;
 	/**
-	 * Linkage into a list (hanging off lov_io::lis_active) of all
-	 * sub-io's active for the current IO iteration.
+	 * environment's refcheck.
+	 *
+	 * \see cl_env_get()
 	 */
-	struct list_head	   sub_linkage;
+	u16			 sub_refcheck;
+	u16			 sub_reenter;
 	/**
 	 * true, iff cl_io_init() was successfully executed against
 	 * lov_io_sub::sub_io.
 	 */
-	int		  sub_io_initialized;
+	u16			 sub_io_initialized:1,
 	/**
 	 * True, iff lov_io_sub::sub_io and lov_io_sub::sub_env weren't
 	 * allocated, but borrowed from a per-device emergency pool.
 	 */
-	int		  sub_borrowed;
+				 sub_borrowed:1;
 	/**
-	 * environment, in which sub-io executes.
+	 * Linkage into a list (hanging off lov_io::lis_active) of all
+	 * sub-io's active for the current IO iteration.
 	 */
-	struct lu_env *sub_env;
+	struct list_head	 sub_linkage;
 	/**
-	 * environment's refcheck.
-	 *
-	 * \see cl_env_get()
+	 * sub-io for a stripe. Ideally sub-io's can be stopped and resumed
+	 * independently, with lov acting as a scheduler to maximize overall
+	 * throughput.
+	 */
+	struct cl_io	*sub_io;
+	/**
+	 * environment, in which sub-io executes.
 	 */
-	int		  sub_refcheck;
-	int		  sub_refcheck2;
-	int		  sub_reenter;
+	struct lu_env *sub_env;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 977579c..ab3ecfe 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -746,7 +746,7 @@ static int lov_layout_change(const struct lu_env *unused,
 	const struct lov_layout_operations *old_ops;
 	const struct lov_layout_operations *new_ops;
 	struct lu_env *env;
-	int refcheck;
+	u16 refcheck;
 	int rc;
 
 	LASSERT(0 <= lov->lo_type && lov->lo_type < ARRAY_SIZE(lov_dispatch));
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 703cb67..08e55d4 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -688,7 +688,7 @@ static inline struct cl_env *cl_env_container(struct lu_env *env)
  *
  * \see cl_env_put()
  */
-struct lu_env *cl_env_get(int *refcheck)
+struct lu_env *cl_env_get(u16 *refcheck)
 {
 	struct lu_env *env;
 
@@ -709,7 +709,7 @@ struct lu_env *cl_env_get(int *refcheck)
  *
  * \see cl_env_get()
  */
-struct lu_env *cl_env_alloc(int *refcheck, __u32 tags)
+struct lu_env *cl_env_alloc(u16 *refcheck, u32 tags)
 {
 	struct lu_env *env;
 
@@ -769,7 +769,7 @@ unsigned int cl_env_cache_purge(unsigned int nr)
  * this thread is using environment and it is returned to the allocation
  * cache, or freed straight away, if cache is large enough.
  */
-void cl_env_put(struct lu_env *env, int *refcheck)
+void cl_env_put(struct lu_env *env, u16 *refcheck)
 {
 	struct cl_env *cle;
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 5490761..77b4c55 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -816,7 +816,7 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
 	struct echo_object *eco;
 	struct cl_object   *obj;
 	struct lu_fid *fid;
-	int refcheck;
+	u16 refcheck;
 	int rc;
 
 	LASSERTF(ostid_id(oi), DOSTID "\n", POSTID(oi));
@@ -882,7 +882,7 @@ static int cl_echo_object_put(struct echo_object *eco)
 {
 	struct lu_env *env;
 	struct cl_object *obj = echo_obj2cl(eco);
-	int refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -999,7 +999,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	struct cl_page	  *clp;
 	struct lustre_handle    lh = { 0 };
 	size_t page_size = cl_page_size(obj);
-	int refcheck;
+	u16 refcheck;
 	int rc;
 	int i;
 
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 575b296..86f252d 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -229,7 +229,7 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 	rc = atomic_long_read(&cli->cl_lru_in_list) - pages_number;
 	if (rc > 0) {
 		struct lu_env *env;
-		int refcheck;
+		u16 refcheck;
 
 		env = cl_env_get(&refcheck);
 		if (!IS_ERR(env)) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6445bbe..f8c5fc0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -988,7 +988,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	int grants = 0;
 	int nr_pages = 0;
 	int rc = 0;
-	int refcheck;
+	u16 refcheck;
 
 	LASSERT(sanity_check(ext) == 0);
 	EASSERT(ext->oe_state == OES_TRUNC, ext);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 5f7c030..940c10c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -297,7 +297,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	struct cl_lock_slice *slice = &oscl->ols_cl;
 	struct lu_env *env;
 	int rc;
-	int refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	/* should never happen, similar to osc_ldlm_blocking_ast(). */
@@ -349,7 +349,7 @@ static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
 	struct osc_object *osc = cookie;
 	struct ldlm_lock *dlmlock;
 	struct lu_env *env;
-	int refcheck;
+	u16 refcheck;
 
 	env = cl_env_get(&refcheck);
 	LASSERT(!IS_ERR(env));
@@ -384,7 +384,7 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
 			  enum cl_lock_mode mode, int discard)
 {
 	struct lu_env *env;
-	int refcheck;
+	u16 refcheck;
 	int rc = 0;
 	int rc2 = 0;
 
@@ -538,7 +538,7 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 	}
 	case LDLM_CB_CANCELING: {
 		struct lu_env *env;
-		int refcheck;
+		u16 refcheck;
 
 		/*
 		 * This can be called in the context of outer IO, e.g.,
@@ -575,7 +575,7 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	struct req_capsule *cap;
 	struct cl_object *obj = NULL;
 	int result;
-	int refcheck;
+	u16 refcheck;
 
 	LASSERT(lustre_msg_get_opc(req->rq_reqmsg) == LDLM_GL_CALLBACK);
 
@@ -686,7 +686,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 	struct osc_lock		*oscl;
 	unsigned long            weight;
 	bool			 found = false;
-	int refcheck;
+	u16 refcheck;
 
 	might_sleep();
 	/*
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 03ee340..ed8a0dc 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -681,7 +681,7 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
 	int max_scans;
-	int refcheck;
+	u16 refcheck;
 	long rc = 0;
 
 	LASSERT(cache);
@@ -1045,7 +1045,7 @@ unsigned long osc_cache_shrink_scan(struct shrinker *sk,
 	struct client_obd *cli;
 	struct lu_env *env;
 	long shrank = 0;
-	int refcheck;
+	u16 refcheck;
 	int rc;
 
 	if (!sc->nr_to_scan)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 8e22807..4cf0664 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2538,7 +2538,7 @@ static int osc_import_event(struct obd_device *obd,
 	case IMP_EVENT_INVALIDATE: {
 		struct ldlm_namespace *ns = obd->obd_namespace;
 		struct lu_env *env;
-		int refcheck;
+		u16 refcheck;
 
 		ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
 
-- 
1.8.3.1
