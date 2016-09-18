From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:09 -0400
Subject: [lustre-devel] [PATCH 070/124] staging: lustre: statahead: small
	fixes and cleanup
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-71-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

small fixes:
 * when 'unplug' is set for ll_statahead(), sa_put() shouldn't kill
   the entry found, because its inflight RPC may not finish yet.
 * remove 'sai_generation', add 'lli_sa_generation' because the
   former one is not safe to access without lock.
 * revalidate_statahead_dentry() may fail to wait for statahead
   entry to become ready, in this case it should not release this
   entry, because it may be used by inflight statahead RPC.

cleanups:
 * rename ll_statahead_enter() to ll_statahead().
 * move dentry 'lld_sa_generation' update to ll_statahead() to
   simplify code and logic.
 * other small cleanups.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3270
Reviewed-on: http://review.whamcloud.com/9667
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6222
Reviewed-on: http://review.whamcloud.com/13708
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dcache.c       |    5 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  137 +++-----
 drivers/staging/lustre/lustre/llite/namei.c        |   11 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  353 +++++++++++---------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 5 files changed, 250 insertions(+), 258 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 8500080..0e45d8f 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -278,14 +278,13 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	if (lookup_flags & (LOOKUP_PARENT | LOOKUP_OPEN | LOOKUP_CREATE))
 		return 1;
 
-	if (!dentry_need_statahead(dir, dentry))
+	if (!dentry_may_statahead(dir, dentry))
 		return 1;
 
 	if (lookup_flags & LOOKUP_RCU)
 		return -ECHILD;
 
-	do_statahead_enter(dir, &dentry, !d_inode(dentry));
-	ll_statahead_mark(dir, dentry);
+	ll_statahead(dir, &dentry, !d_inode(dentry));
 	return 1;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index a68bea1..bdfdff5 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -161,7 +161,7 @@ struct ll_inode_info {
 		/* for directory */
 		struct {
 			/* serialize normal readdir and statahead-readdir. */
-			struct mutex			d_readdir_mutex;
+			struct mutex			lli_readdir_mutex;
 
 			/* metadata statahead */
 			/* since parent-child threads can share the same @file
@@ -169,44 +169,35 @@ struct ll_inode_info {
 			 * case of parent exit before child -- it is me should
 			 * cleanup the dir readahead.
 			 */
-			void			   *d_opendir_key;
-			struct ll_statahead_info       *d_sai;
+			void			       *lli_opendir_key;
+			struct ll_statahead_info       *lli_sai;
 			/* protect statahead stuff. */
-			spinlock_t			d_sa_lock;
+			spinlock_t			lli_sa_lock;
 			/* "opendir_pid" is the token when lookup/revalidate
 			 * -- I am the owner of dir statahead.
 			 */
-			pid_t			   d_opendir_pid;
+			pid_t				lli_opendir_pid;
 			/* stat will try to access statahead entries or start
 			 * statahead if this flag is set, and this flag will be
 			 * set upon dir open, and cleared when dir is closed,
 			 * statahead hit ratio is too low, or start statahead
 			 * thread failed.
 			 */
-			unsigned int			d_sa_enabled:1;
+			unsigned int			lli_sa_enabled:1;
+			/* generation for statahead */
+			unsigned int			lli_sa_generation;
 			/* directory stripe information */
-			struct lmv_stripe_md		*d_lsm_md;
+			struct lmv_stripe_md	       *lli_lsm_md;
 			/* striped directory size */
-			loff_t				d_stripe_size;
-			/* striped directory nlink */
-			__u64				d_stripe_nlink;
-		} d;
-
-#define lli_readdir_mutex       u.d.d_readdir_mutex
-#define lli_opendir_key	 u.d.d_opendir_key
-#define lli_sai		 u.d.d_sai
-#define lli_sa_lock	     u.d.d_sa_lock
-#define lli_sa_enabled		u.d.d_sa_enabled
-#define lli_opendir_pid	 u.d.d_opendir_pid
-#define lli_lsm_md		u.d.d_lsm_md
-#define lli_stripe_dir_size	u.d.d_stripe_size
-#define lli_stripe_dir_nlink	u.d.d_stripe_nlink
+			loff_t				lli_stripe_dir_size;
+			u64				lli_stripe_dir_nlink;
+		};
 
 		/* for non-directory */
 		struct {
-			struct mutex			f_size_mutex;
-			char				*f_symlink_name;
-			__u64				f_maxbytes;
+			struct mutex			lli_size_mutex;
+			char			       *lli_symlink_name;
+			__u64				lli_maxbytes;
 			/*
 			 * struct rw_semaphore {
 			 *    signed long	count;     // align d.d_def_acl
@@ -214,16 +205,16 @@ struct ll_inode_info {
 			 *    struct list_head wait_list;
 			 * }
 			 */
-			struct rw_semaphore		f_trunc_sem;
-			struct range_lock_tree		f_write_tree;
+			struct rw_semaphore		lli_trunc_sem;
+			struct range_lock_tree		lli_write_tree;
 
-			struct rw_semaphore		f_glimpse_sem;
-			unsigned long			f_glimpse_time;
-			struct list_head			f_agl_list;
-			__u64				f_agl_index;
+			struct rw_semaphore		lli_glimpse_sem;
+			unsigned long			lli_glimpse_time;
+			struct list_head		lli_agl_list;
+			__u64				lli_agl_index;
 
 			/* for writepage() only to communicate to fsync */
-			int				f_async_rc;
+			int				lli_async_rc;
 
 			/*
 			 * whenever a process try to read/write the file, the
@@ -233,22 +224,9 @@ struct ll_inode_info {
 			 * so the read/write statistics for jobid will not be
 			 * accurate if the file is shared by different jobs.
 			 */
-			char		     f_jobid[LUSTRE_JOBID_SIZE];
-		} f;
-
-#define lli_size_mutex          u.f.f_size_mutex
-#define lli_symlink_name	u.f.f_symlink_name
-#define lli_maxbytes	    u.f.f_maxbytes
-#define lli_trunc_sem	   u.f.f_trunc_sem
-#define lli_write_tree		u.f.f_write_tree
-#define lli_glimpse_sem		u.f.f_glimpse_sem
-#define lli_glimpse_time	u.f.f_glimpse_time
-#define lli_agl_list		u.f.f_agl_list
-#define lli_agl_index		u.f.f_agl_index
-#define lli_async_rc		u.f.f_async_rc
-#define lli_jobid		u.f.f_jobid
-
-	} u;
+			char				lli_jobid[LUSTRE_JOBID_SIZE];
+		};
+	};
 
 	/* XXX: For following frequent used members, although they maybe special
 	 *      used for non-directory object, it is some time-wasting to check
@@ -1095,11 +1073,10 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
 /* per inode struct, for dir only */
 struct ll_statahead_info {
-	struct inode	   *sai_inode;
+	struct dentry	   *sai_dentry;
 	atomic_t	    sai_refcount;   /* when access this struct, hold
 					     * refcount
 					     */
-	unsigned int	    sai_generation; /* generation for statahead */
 	unsigned int	    sai_max;	/* max ahead of lookup */
 	__u64		   sai_sent;       /* stat requests sent count */
 	__u64		   sai_replied;    /* stat requests which received
@@ -1142,8 +1119,7 @@ struct ll_statahead_info {
 	atomic_t		sai_cache_count; /* entry count in cache */
 };
 
-int do_statahead_enter(struct inode *dir, struct dentry **dentry,
-		       int only_unplug);
+int ll_statahead(struct inode *dir, struct dentry **dentry, bool unplug);
 void ll_authorize_statahead(struct inode *dir, void *key);
 void ll_deauthorize_statahead(struct inode *dir, void *key);
 
@@ -1175,24 +1151,12 @@ static inline int ll_glimpse_size(struct inode *inode)
 	return rc;
 }
 
-static inline void
-ll_statahead_mark(struct inode *dir, struct dentry *dentry)
-{
-	struct ll_inode_info     *lli = ll_i2info(dir);
-	struct ll_statahead_info *sai = lli->lli_sai;
-	struct ll_dentry_data    *ldd = ll_d2d(dentry);
-
-	/* not the same process, don't mark */
-	if (lli->lli_opendir_pid != current_pid())
-		return;
-
-	LASSERT(ldd);
-	if (sai)
-		ldd->lld_sa_generation = sai->sai_generation;
-}
-
+/*
+ * dentry may statahead when statahead is enabled and current process has opened
+ * parent directory, and this dentry hasn't accessed statahead cache before
+ */
 static inline bool
-dentry_need_statahead(struct inode *dir, struct dentry *dentry)
+dentry_may_statahead(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_inode_info  *lli;
 	struct ll_dentry_data *ldd;
@@ -1215,38 +1179,27 @@ dentry_need_statahead(struct inode *dir, struct dentry *dentry)
 	if (lli->lli_opendir_pid != current_pid())
 		return false;
 
-	ldd = ll_d2d(dentry);
 	/*
-	 * When stats a dentry, the system trigger more than once "revalidate"
-	 * or "lookup", for "getattr", for "getxattr", and maybe for others.
-	 * Under patchless client mode, the operation intent is not accurate,
-	 * which maybe misguide the statahead thread. For example:
-	 * The "revalidate" call for "getattr" and "getxattr" of a dentry maybe
-	 * have the same operation intent -- "IT_GETATTR".
-	 * In fact, one dentry should has only one chance to interact with the
-	 * statahead thread, otherwise the statahead windows will be confused.
+	 * When stating a dentry, kernel may trigger 'revalidate' or 'lookup'
+	 * multiple times, eg. for 'getattr', 'getxattr' and etc.
+	 * For patchless client, lookup intent is not accurate, which may
+	 * misguide statahead. For example:
+	 * The 'revalidate' call for 'getattr' and 'getxattr' of a dentry will
+	 * have the same intent -- IT_GETATTR, while one dentry should access
+	 * statahead cache once, otherwise statahead windows is messed up.
 	 * The solution is as following:
-	 * Assign "lld_sa_generation" with "sai_generation" when a dentry
-	 * "IT_GETATTR" for the first time, and the subsequent "IT_GETATTR"
-	 * will bypass interacting with statahead thread for checking:
-	 * "lld_sa_generation == lli_sai->sai_generation"
+	 * Assign 'lld_sa_generation' with 'lli_sa_generation' when a dentry
+	 * IT_GETATTR for the first time, and subsequent IT_GETATTR will
+	 * bypass interacting with statahead cache by checking
+	 * 'lld_sa_generation == lli->lli_sa_generation'.
 	 */
-	if (ldd && lli->lli_sai &&
-	    ldd->lld_sa_generation == lli->lli_sai->sai_generation)
+	ldd = ll_d2d(dentry);
+	if (ldd && ldd->lld_sa_generation == lli->lli_sa_generation)
 		return false;
 
 	return true;
 }
 
-static inline int
-ll_statahead_enter(struct inode *dir, struct dentry **dentryp, int only_unplug)
-{
-	if (!dentry_need_statahead(dir, *dentryp))
-		return -EAGAIN;
-
-	return do_statahead_enter(dir, dentryp, only_unplug);
-}
-
 /* llite ioctl register support routine */
 enum llioc_iter {
 	LLIOC_CONT = 0,
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 85f8ce7..494140a 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -522,8 +522,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (!it || it->it_op == IT_GETXATTR)
 		it = &lookup_it;
 
-	if (it->it_op == IT_GETATTR) {
-		rc = ll_statahead_enter(parent, &dentry, 0);
+	if (it->it_op == IT_GETATTR && dentry_may_statahead(parent, dentry)) {
+		rc = ll_statahead(parent, &dentry, 0);
 		if (rc == 1) {
 			if (dentry == save)
 				retval = NULL;
@@ -574,11 +574,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		retval = NULL;
 	else
 		retval = dentry;
- out:
-	if (req)
-		ptlrpc_req_finished(req);
-	if (it->it_op == IT_GETATTR && (!retval || retval == dentry))
-		ll_statahead_mark(parent, dentry);
+out:
+	ptlrpc_req_finished(req);
 	return retval;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 323a175..9e76a68 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -54,12 +54,12 @@ enum se_stat {
 /*
  * sa_entry is not refcounted: statahead thread allocates it and do async stat,
  * and in async stat callback ll_statahead_interpret() will add it into
- * sai_cb_entries, later statahead thread will call sa_handle_callback() to
+ * sai_interim_entries, later statahead thread will call sa_handle_callback() to
  * instantiate entry and move it into sai_entries, and then only scanner process
  * can access and free it.
  */
 struct sa_entry {
-	/* link into sai_cb_entries or sai_entries */
+	/* link into sai_interim_entries or sai_entries */
 	struct list_head	      se_list;
 	/* link into sai hash table locally */
 	struct list_head	      se_hash;
@@ -84,23 +84,20 @@ struct sa_entry {
 static unsigned int sai_generation;
 static DEFINE_SPINLOCK(sai_generation_lock);
 
-/*
- * The entry only can be released by the caller, it is necessary to hold lock.
- */
+/* sa_entry is ready to use */
 static inline int sa_ready(struct sa_entry *entry)
 {
 	smp_rmb();
 	return (entry->se_state != SA_ENTRY_INIT);
 }
 
+/* hash value to put in sai_cache */
 static inline int sa_hash(int val)
 {
 	return val & LL_SA_CACHE_MASK;
 }
 
-/*
- * Insert entry to hash SA table.
- */
+/* hash entry into sai_cache */
 static inline void
 sa_rehash(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
@@ -130,11 +127,13 @@ static inline int agl_should_run(struct ll_statahead_info *sai,
 	return (inode && S_ISREG(inode->i_mode) && sai->sai_agl_valid);
 }
 
+/* statahead window is full */
 static inline int sa_sent_full(struct ll_statahead_info *sai)
 {
 	return atomic_read(&sai->sai_cache_count) >= sai->sai_max;
 }
 
+/* got async stat replies */
 static inline int sa_has_callback(struct ll_statahead_info *sai)
 {
 	return !list_empty(&sai->sai_interim_entries);
@@ -158,7 +157,7 @@ static inline int sa_low_hit(struct ll_statahead_info *sai)
 }
 
 /*
- * If the given index is behind of statahead window more than
+ * if the given index is behind of statahead window more than
  * SA_OMITTED_ENTRY_MAX, then it is old.
  */
 static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
@@ -167,9 +166,7 @@ static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
 		 sai->sai_index);
 }
 
-/*
- * Insert it into sai_entries tail when init.
- */
+/* allocate sa_entry and hash it to allow scanner process to find it */
 static struct sa_entry *
 sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, __u64 index,
 	 const char *name, int len)
@@ -198,7 +195,7 @@ sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, __u64 index,
 	entry->se_qstr.len = len;
 	entry->se_qstr.name = dname;
 
-	lli = ll_i2info(sai->sai_inode);
+	lli = ll_i2info(sai->sai_dentry->d_inode);
 	spin_lock(&lli->lli_sa_lock);
 	INIT_LIST_HEAD(&entry->se_list);
 	sa_rehash(sai, entry);
@@ -246,7 +243,7 @@ sa_get(struct ll_statahead_info *sai, const struct qstr *qstr)
 static inline void
 sa_kill(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
-	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
+	struct ll_inode_info *lli = ll_i2info(sai->sai_dentry->d_inode);
 
 	LASSERT(!list_empty(&entry->se_hash));
 	LASSERT(!list_empty(&entry->se_list));
@@ -271,7 +268,7 @@ sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
 	struct sa_entry *tmp, *next;
 
 	if (entry && entry->se_state == SA_ENTRY_SUCC) {
-		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
+		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_dentry->d_inode);
 
 		sai->sai_hit++;
 		sai->sai_consecutive_miss = 0;
@@ -293,6 +290,7 @@ sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
 			break;
 		sa_kill(sai, tmp);
 	}
+
 	wake_up(&sai->sai_thread.t_ctl_waitq);
 }
 
@@ -329,7 +327,7 @@ __sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 static void
 sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
-	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
+	struct ll_inode_info *lli = ll_i2info(sai->sai_dentry->d_inode);
 	struct md_enqueue_info *minfo = entry->se_minfo;
 	struct ptlrpc_request *req = entry->se_req;
 	bool wakeup;
@@ -355,14 +353,12 @@ sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 		wake_up(&sai->sai_waitq);
 }
 
-/*
- * Insert inode into the list of sai_agls.
- */
+/* Insert inode into the list of sai_agls. */
 static void ll_agl_add(struct ll_statahead_info *sai,
 		       struct inode *inode, int index)
 {
 	struct ll_inode_info *child  = ll_i2info(inode);
-	struct ll_inode_info *parent = ll_i2info(sai->sai_inode);
+	struct ll_inode_info *parent = ll_i2info(sai->sai_dentry->d_inode);
 	int		   added  = 0;
 
 	spin_lock(&child->lli_agl_lock);
@@ -387,8 +383,9 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 }
 
 /* allocate sai */
-static struct ll_statahead_info *ll_sai_alloc(void)
+static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 {
+	struct ll_inode_info *lli = ll_i2info(dentry->d_inode);
 	struct ll_statahead_info *sai;
 	int		       i;
 
@@ -396,14 +393,9 @@ static struct ll_statahead_info *ll_sai_alloc(void)
 	if (!sai)
 		return NULL;
 
+	sai->sai_dentry = dget(dentry);
 	atomic_set(&sai->sai_refcount, 1);
 
-	spin_lock(&sai_generation_lock);
-	sai->sai_generation = ++sai_generation;
-	if (unlikely(sai_generation == 0))
-		sai->sai_generation = ++sai_generation;
-	spin_unlock(&sai_generation_lock);
-
 	sai->sai_max = LL_SA_RPC_MIN;
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
@@ -420,9 +412,27 @@ static struct ll_statahead_info *ll_sai_alloc(void)
 	}
 	atomic_set(&sai->sai_cache_count, 0);
 
+	spin_lock(&sai_generation_lock);
+	lli->lli_sa_generation = ++sai_generation;
+	if (unlikely(!sai_generation))
+		lli->lli_sa_generation = ++sai_generation;
+	spin_unlock(&sai_generation_lock);
+
 	return sai;
 }
 
+/* free sai */
+static inline void ll_sai_free(struct ll_statahead_info *sai)
+{
+	LASSERT(sai->sai_dentry);
+	dput(sai->sai_dentry);
+	kfree(sai);
+}
+
+/*
+ * take refcount of sai if sai for @dir exists, which means statahead is on for
+ * this directory.
+ */
 static inline struct ll_statahead_info *ll_sai_get(struct inode *dir)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
@@ -437,12 +447,16 @@ static inline struct ll_statahead_info *ll_sai_get(struct inode *dir)
 	return sai;
 }
 
+/*
+ * put sai refcount after use, if refcount reaches zero, free sai and sa_entries
+ * attached to it.
+ */
 static void ll_sai_put(struct ll_statahead_info *sai)
 {
-	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
+	struct ll_inode_info *lli = ll_i2info(sai->sai_dentry->d_inode);
 
 	if (atomic_dec_and_lock(&sai->sai_refcount, &lli->lli_sa_lock)) {
-		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
+		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_dentry->d_inode);
 		struct sa_entry *entry, *next;
 
 		lli->lli_sai = NULL;
@@ -460,8 +474,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		LASSERT(atomic_read(&sai->sai_cache_count) == 0);
 		LASSERT(list_empty(&sai->sai_agls));
 
-		iput(sai->sai_inode);
-		kfree(sai);
+		ll_sai_free(sai);
 		atomic_dec(&sbi->ll_sa_running);
 	}
 }
@@ -533,7 +546,7 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 static void sa_instantiate(struct ll_statahead_info *sai,
 			   struct sa_entry *entry)
 {
-	struct inode	   *dir   = sai->sai_inode;
+	struct inode *dir = sai->sai_dentry->d_inode;
 	struct inode	   *child;
 	struct md_enqueue_info *minfo;
 	struct lookup_intent   *it;
@@ -609,12 +622,12 @@ out:
 	sa_make_ready(sai, entry, rc);
 }
 
-/* once there are async stat replies, instantiate sa_entry */
+/* once there are async stat replies, instantiate sa_entry from replies */
 static void sa_handle_callback(struct ll_statahead_info *sai)
 {
 	struct ll_inode_info *lli;
 
-	lli = ll_i2info(sai->sai_inode);
+	lli = ll_i2info(sai->sai_dentry->d_inode);
 
 	while (sa_has_callback(sai)) {
 		struct sa_entry *entry;
@@ -631,21 +644,6 @@ static void sa_handle_callback(struct ll_statahead_info *sai)
 
 		sa_instantiate(sai, entry);
 	}
-
-	spin_lock(&lli->lli_agl_lock);
-	while (!agl_list_empty(sai)) {
-		struct ll_inode_info *clli;
-
-		clli = list_entry(sai->sai_agls.next,
-				  struct ll_inode_info, lli_agl_list);
-		list_del_init(&clli->lli_agl_list);
-		spin_unlock(&lli->lli_agl_lock);
-
-		ll_agl_trigger(&clli->lli_vfs_inode, sai);
-
-		spin_lock(&lli->lli_agl_lock);
-	}
-	spin_unlock(&lli->lli_agl_lock);
 }
 
 /*
@@ -718,6 +716,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	return rc;
 }
 
+/* finish async stat RPC arguments */
 static void sa_fini_data(struct md_enqueue_info *minfo,
 			 struct ldlm_enqueue_info *einfo)
 {
@@ -775,6 +774,7 @@ static int sa_prep_data(struct inode *dir, struct inode *child,
 	return 0;
 }
 
+/* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
 	struct md_enqueue_info   *minfo;
@@ -786,17 +786,18 @@ static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 		return rc;
 
 	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo, einfo);
-	if (rc < 0)
+	if (rc)
 		sa_fini_data(minfo, einfo);
 
 	return rc;
 }
 
 /**
- * similar to ll_revalidate_it().
- * \retval      1 -- dentry valid
- * \retval      0 -- will send stat-ahead request
- * \retval others -- prepare stat-ahead request failed
+ * async stat for file found in dcache, similar to .revalidate
+ *
+ * \retval	1 dentry valid, no RPC sent
+ * \retval	0 dentry invalid, will send async stat RPC
+ * \retval	negative number upon error
  */
 static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 			 struct dentry *dentry)
@@ -831,7 +832,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	}
 
 	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo, einfo);
-	if (rc < 0) {
+	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
 		sa_fini_data(minfo, einfo);
@@ -840,6 +841,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	return rc;
 }
 
+/* async stat for file with @name */
 static void sa_statahead(struct dentry *parent, const char *name, int len)
 {
 	struct inode	     *dir    = d_inode(parent);
@@ -873,6 +875,7 @@ static void sa_statahead(struct dentry *parent, const char *name, int len)
 	sai->sai_index++;
 }
 
+/* async glimpse (agl) thread main function */
 static int ll_agl_thread(void *arg)
 {
 	struct dentry	    *parent = arg;
@@ -946,6 +949,7 @@ static int ll_agl_thread(void *arg)
 	return 0;
 }
 
+/* start agl thread */
 static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 {
 	struct ptlrpc_thread *thread = &sai->sai_agl_thread;
@@ -970,6 +974,7 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 		     &lwi);
 }
 
+/* statahead thread main function */
 static int ll_statahead_thread(void *arg)
 {
 	struct dentry	    *parent = arg;
@@ -977,7 +982,7 @@ static int ll_statahead_thread(void *arg)
 	struct ll_inode_info     *lli   = ll_i2info(dir);
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
 	struct ll_statahead_info *sai;
-	struct ptlrpc_thread *thread;
+	struct ptlrpc_thread *sa_thread;
 	struct ptlrpc_thread *agl_thread;
 	struct page	      *page = NULL;
 	__u64		     pos    = 0;
@@ -987,9 +992,9 @@ static int ll_statahead_thread(void *arg)
 	struct l_wait_info	lwi    = { 0 };
 
 	sai = ll_sai_get(dir);
-	thread = &sai->sai_thread;
+	sa_thread = &sai->sai_thread;
 	agl_thread = &sai->sai_agl_thread;
-	thread->t_pid = current_pid();
+	sa_thread->t_pid = current_pid();
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
 
@@ -1007,16 +1012,16 @@ static int ll_statahead_thread(void *arg)
 
 	atomic_inc(&sbi->ll_sa_total);
 	spin_lock(&lli->lli_sa_lock);
-	if (thread_is_init(thread))
+	if (thread_is_init(sa_thread))
 		/* If someone else has changed the thread state
 		 * (e.g. already changed to SVC_STOPPING), we can't just
 		 * blindly overwrite that setting.
 		 */
-		thread_set_flags(thread, SVC_RUNNING);
+		thread_set_flags(sa_thread, SVC_RUNNING);
 	spin_unlock(&lli->lli_sa_lock);
-	wake_up(&thread->t_ctl_waitq);
+	wake_up(&sa_thread->t_ctl_waitq);
 
-	while (pos != MDS_DIR_END_OFF && thread_is_running(thread)) {
+	while (pos != MDS_DIR_END_OFF && thread_is_running(sa_thread)) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
 
@@ -1033,7 +1038,7 @@ static int ll_statahead_thread(void *arg)
 
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp);
-		     ent && thread_is_running(thread) && !sa_low_hit(sai);
+		     ent && thread_is_running(sa_thread) && !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
 			__u64 hash;
 			int namelen;
@@ -1082,15 +1087,32 @@ static int ll_statahead_thread(void *arg)
 
 			/* wait for spare statahead window */
 			do {
-				l_wait_event(thread->t_ctl_waitq,
+				l_wait_event(sa_thread->t_ctl_waitq,
 					     !sa_sent_full(sai) ||
 					     sa_has_callback(sai) ||
 					     !list_empty(&sai->sai_agls) ||
-					     !thread_is_running(thread),
+					     !thread_is_running(sa_thread),
 					     &lwi);
 				sa_handle_callback(sai);
+
+				spin_lock(&lli->lli_agl_lock);
+				while (sa_sent_full(sai) &&
+				       !agl_list_empty(sai)) {
+					struct ll_inode_info *clli;
+
+					clli = list_entry(sai->sai_agls.next,
+							  struct ll_inode_info, lli_agl_list);
+					list_del_init(&clli->lli_agl_list);
+					spin_unlock(&lli->lli_agl_lock);
+
+					ll_agl_trigger(&clli->lli_vfs_inode,
+						       sai);
+
+					spin_lock(&lli->lli_agl_lock);
+				}
+				spin_unlock(&lli->lli_agl_lock);
 			} while (sa_sent_full(sai) &&
-				 thread_is_running(thread));
+				 thread_is_running(sa_thread));
 
 			sa_statahead(parent, name, namelen);
 		}
@@ -1113,7 +1135,7 @@ static int ll_statahead_thread(void *arg)
 
 	if (rc < 0) {
 		spin_lock(&lli->lli_sa_lock);
-		thread_set_flags(thread, SVC_STOPPING);
+		thread_set_flags(sa_thread, SVC_STOPPING);
 		lli->lli_sa_enabled = 0;
 		spin_unlock(&lli->lli_sa_lock);
 	}
@@ -1122,11 +1144,11 @@ static int ll_statahead_thread(void *arg)
 	 * statahead is finished, but statahead entries need to be cached, wait
 	 * for file release to stop me.
 	 */
-	while (thread_is_running(thread)) {
-		l_wait_event(thread->t_ctl_waitq,
+	while (thread_is_running(sa_thread)) {
+		l_wait_event(sa_thread->t_ctl_waitq,
 			     sa_has_callback(sai) ||
 			     !agl_list_empty(sai) ||
-			     !thread_is_running(thread),
+			     !thread_is_running(sa_thread),
 			     &lwi);
 
 		sa_handle_callback(sai);
@@ -1156,7 +1178,7 @@ out:
 		/* in case we're not woken up, timeout wait */
 		lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
 				  NULL, NULL);
-		l_wait_event(thread->t_ctl_waitq,
+		l_wait_event(sa_thread->t_ctl_waitq,
 			     sai->sai_sent == sai->sai_replied, &lwi);
 	}
 
@@ -1164,19 +1186,20 @@ out:
 	sa_handle_callback(sai);
 
 	spin_lock(&lli->lli_sa_lock);
-	thread_set_flags(thread, SVC_STOPPED);
+	thread_set_flags(sa_thread, SVC_STOPPED);
 	spin_unlock(&lli->lli_sa_lock);
 
-	wake_up(&sai->sai_waitq);
-	wake_up(&thread->t_ctl_waitq);
-	ll_sai_put(sai);
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
-	dput(parent);
+
+	wake_up(&sai->sai_waitq);
+	wake_up(&sa_thread->t_ctl_waitq);
+	ll_sai_put(sai);
+
 	return rc;
 }
 
-/* authorize opened dir handle @key to statahead later */
+/* authorize opened dir handle @key to statahead */
 void ll_authorize_statahead(struct inode *dir, void *key)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
@@ -1230,7 +1253,7 @@ enum {
 	/**
 	 * not first dirent, or is "."
 	 */
-	LS_NONE_FIRST_DE = 0,
+	LS_NOT_FIRST_DE = 0,
 	/**
 	 * the first non-hidden dirent
 	 */
@@ -1241,6 +1264,7 @@ enum {
 	LS_FIRST_DOT_DE
 };
 
+/* file is first dirent under @dir */
 static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 {
 	const struct qstr  *target = &dentry->d_name;
@@ -1248,7 +1272,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 	struct page	  *page;
 	__u64		 pos    = 0;
 	int		   dot_de;
-	int		   rc     = LS_NONE_FIRST_DE;
+	int rc = LS_NOT_FIRST_DE;
 
 	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, dir);
@@ -1324,7 +1348,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 
 			if (target->len != namelen ||
 			    memcmp(target->name, name, namelen) != 0)
-				rc = LS_NONE_FIRST_DE;
+				rc = LS_NOT_FIRST_DE;
 			else if (!dot_de)
 				rc = LS_FIRST_DE;
 			else
@@ -1356,13 +1380,27 @@ out:
 	return rc;
 }
 
+/**
+ * revalidate @dentryp from statahead cache
+ *
+ * \param[in]  dir	parent directory
+ * \param[in]  sai	sai structure
+ * \param[out] dentryp	pointer to dentry which will be revalidated
+ * \param[in]  unplug	unplug statahead window only (normally for negative
+ *			dentry)
+ * \retval		1 on success, dentry is saved in @dentryp
+ * \retval		0 if revalidation failed (no proper lock on client)
+ * \retval		negative number upon error
+ */
 static int revalidate_statahead_dentry(struct inode *dir,
 				       struct ll_statahead_info *sai,
 				       struct dentry **dentryp,
-				       int only_unplug)
+				       bool unplug)
 {
 	struct sa_entry *entry = NULL;
 	struct l_wait_info lwi = { 0 };
+	struct ll_dentry_data *ldd;
+	struct ll_inode_info *lli;
 	int rc = 0;
 
 	if ((*dentryp)->d_name.name[0] == '.') {
@@ -1392,10 +1430,15 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		}
 	}
 
+	if (unplug) {
+		rc = 1;
+		goto out_unplug;
+	}
+
 	entry = sa_get(sai, &(*dentryp)->d_name);
-	if (!entry || only_unplug) {
-		sa_put(sai, entry);
-		return entry ? 1 : -EAGAIN;
+	if (!entry) {
+		rc = -EAGAIN;
+		goto out_unplug;
 	}
 
 	/* if statahead is busy in readdir, help it do post-work */
@@ -1406,13 +1449,15 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		sai->sai_index_wait = entry->se_index;
 		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
 				       LWI_ON_SIGNAL_NOOP, NULL);
-		rc = l_wait_event(sai->sai_waitq,
-				  sa_ready(entry) ||
-				  thread_is_stopped(&sai->sai_thread),
-				  &lwi);
+		rc = l_wait_event(sai->sai_waitq, sa_ready(entry), &lwi);
 		if (rc < 0) {
-			sa_put(sai, entry);
-			return -EAGAIN;
+			/*
+			 * entry may not be ready, so it may be used by inflight
+			 * statahead RPC, don't free it.
+			 */
+			entry = NULL;
+			rc = -EAGAIN;
+			goto out_unplug;
 		}
 	}
 
@@ -1430,10 +1475,15 @@ static int revalidate_statahead_dentry(struct inode *dir,
 
 				alias = ll_splice_alias(inode, *dentryp);
 				if (IS_ERR(alias)) {
-					sa_put(sai, entry);
-					return PTR_ERR(alias);
+					rc = PTR_ERR(alias);
+					goto out_unplug;
 				}
 				*dentryp = alias;
+				/**
+				 * statahead prepared this inode, transfer inode
+				 * refcount from sa_entry to dentry
+				 */
+				entry->se_inode = NULL;
 			} else if ((*dentryp)->d_inode != inode) {
 				/* revalidate, but inode is recreated */
 				CDEBUG(D_READA,
@@ -1445,10 +1495,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 				       PFID(ll_inode2fid(inode)));
 				rc = -ESTALE;
 				goto out_unplug;
-			} else {
-				iput(inode);
 			}
-			entry->se_inode = NULL;
 
 			if ((bits & MDS_INODELOCK_LOOKUP) &&
 			    d_lustre_invalid(*dentryp))
@@ -1457,10 +1504,34 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		}
 	}
 out_unplug:
+	/*
+	 * statahead cached sa_entry can be used only once, and will be killed
+	 * right after use, so if lookup/revalidate accessed statahead cache,
+	 * set dentry ldd_sa_generation to parent lli_sa_generation, later if we
+	 * stat this file again, we know we've done statahead before, see
+	 * dentry_may_statahead().
+	 */
+	ldd = ll_d2d(*dentryp);
+	lli = ll_i2info(dir);
+	/* ldd can be NULL if llite lookup failed. */
+	if (ldd)
+		ldd->lld_sa_generation = lli->lli_sa_generation;
 	sa_put(sai, entry);
 	return rc;
 }
 
+/**
+ * start statahead thread
+ *
+ * \param[in] dir	parent directory
+ * \param[in] dentry	dentry that triggers statahead, normally the first
+ *			dirent under @dir
+ * \retval		-EAGAIN on success, because when this function is
+ *			called, it's already in lookup call, so client should
+ *			do it itself instead of waiting for statahead thread
+ *			to do it asynchronously.
+ * \retval		negative number upon error
+ */
 static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
@@ -1468,60 +1539,34 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
 	struct task_struct *task;
-	struct dentry *parent;
+	struct dentry *parent = dentry->d_parent;
 	int rc;
 
 	/* I am the "lli_opendir_pid" owner, only me can set "lli_sai". */
 	rc = is_first_dirent(dir, dentry);
-	if (rc == LS_NONE_FIRST_DE) {
+	if (rc == LS_NOT_FIRST_DE) {
 		/* It is not "ls -{a}l" operation, no need statahead for it. */
-		rc = -EAGAIN;
+		rc = -EFAULT;
 		goto out;
 	}
 
-	sai = ll_sai_alloc();
+	sai = ll_sai_alloc(parent);
 	if (!sai) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	sai->sai_ls_all = (rc == LS_FIRST_DOT_DE);
-	sai->sai_inode = igrab(dir);
-	if (unlikely(!sai->sai_inode)) {
-		CWARN("Do not start stat ahead on dying inode "DFID"\n",
-		      PFID(&lli->lli_fid));
-		rc = -ESTALE;
-		goto out;
-	}
-
-	/* get parent reference count here, and put it in ll_statahead_thread */
-	parent = dget(dentry->d_parent);
-	if (unlikely(sai->sai_inode != d_inode(parent))) {
-		struct ll_inode_info *nlli = ll_i2info(d_inode(parent));
-
-		CWARN("Race condition, someone changed %pd just now: old parent "DFID", new parent "DFID"\n",
-		      dentry, PFID(&lli->lli_fid), PFID(&nlli->lli_fid));
-		dput(parent);
-		iput(sai->sai_inode);
-		rc = -EAGAIN;
-		goto out;
-	}
-
-	CDEBUG(D_READA, "start statahead thread: sai %p, parent %pd\n",
-	       sai, parent);
-
 	/*
-	 * if another process started statahead thread, or deauthorized current
-	 * lli_opendir_key, don't start statahead.
+	 * if current lli_opendir_key was deauthorized, or dir re-opened by
+	 * another process, don't start statahead, otherwise the newly spawned
+	 * statahead thread won't be notified to quit.
 	 */
 	spin_lock(&lli->lli_sa_lock);
 	if (unlikely(lli->lli_sai || lli->lli_opendir_key ||
 		     lli->lli_opendir_pid != current->pid)) {
 		spin_unlock(&lli->lli_sa_lock);
-
-		dput(parent);
-		iput(sai->sai_inode);
-		rc = -EAGAIN;
+		rc = -EPERM;
 		goto out;
 	}
 	lli->lli_sai = sai;
@@ -1529,22 +1574,16 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 
 	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_running);
 
+	CDEBUG(D_READA, "start statahead thread: [pid %d] [parent %pd]\n",
+	       current_pid(), parent);
+
 	task = kthread_run(ll_statahead_thread, parent, "ll_sa_%u",
 			   lli->lli_opendir_pid);
 	thread = &sai->sai_thread;
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
-		CERROR("cannot start ll_sa thread: rc = %d\n", rc);
-		dput(parent);
-
-		spin_lock(&lli->lli_sa_lock);
-		thread_set_flags(thread, SVC_STOPPED);
-		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
-		spin_unlock(&lli->lli_sa_lock);
-
-		ll_sai_put(sai);
-		LASSERT(!lli->lli_sai);
-		return -EAGAIN;
+		CERROR("can't start ll_sa thread, rc : %d\n", rc);
+		goto out;
 	}
 
 	l_wait_event(thread->t_ctl_waitq,
@@ -1559,29 +1598,35 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	return -EAGAIN;
 
 out:
-	kfree(sai);
 	/*
 	 * once we start statahead thread failed, disable statahead so
-	 * subsequent won't waste time to try it.
+	 * that subsequent stat won't waste time to try it.
 	 */
 	spin_lock(&lli->lli_sa_lock);
 	lli->lli_sa_enabled = 0;
+	lli->lli_sai = NULL;
 	spin_unlock(&lli->lli_sa_lock);
-
+	if (sai)
+		ll_sai_free(sai);
 	return rc;
 }
 
 /**
- * Start statahead thread if this is the first dir entry.
- * Otherwise if a thread is started already, wait it until it is ahead of me.
- * \retval 1       -- find entry with lock in cache, the caller needs to do
- *		      nothing.
- * \retval 0       -- find entry in cache, but without lock, the caller needs
- *		      refresh from MDS.
- * \retval others  -- the caller need to process as non-statahead.
+ * statahead entry function, this is called when client getattr on a file, it
+ * will start statahead thread if this is the first dir entry, else revalidate
+ * dentry from statahead cache.
+ *
+ * \param[in]  dir	parent directory
+ * \param[out] dentryp	dentry to getattr
+ * \param[in]  unplug	unplug statahead window only (normally for negative
+ *			dentry)
+ * \retval		1 on success
+ * \retval		0 revalidation from statahead cache failed, caller needs
+ *			to getattr from server directly
+ * \retval		negative number on error, caller often ignores this and
+ *			then getattr from server
  */
-int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
-		       int only_unplug)
+int ll_statahead(struct inode *dir, struct dentry **dentryp, bool unplug)
 {
 	struct ll_statahead_info *sai;
 
@@ -1589,13 +1634,11 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	if (sai) {
 		int rc;
 
-		rc = revalidate_statahead_dentry(dir, sai, dentryp,
-						 only_unplug);
+		rc = revalidate_statahead_dentry(dir, sai, dentryp, unplug);
 		CDEBUG(D_READA, "revalidate statahead %pd: %d.\n",
 		       *dentryp, rc);
 		ll_sai_put(sai);
 		return rc;
 	}
-
 	return start_statahead_thread(dir, *dentryp);
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 166f0c4..125d882 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1367,7 +1367,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	page = mdc_page_locate(mapping, &rp_param.rp_off, &start, &end,
 			       rp_param.rp_hash64);
 	if (IS_ERR(page)) {
-		CERROR("%s: dir page locate: "DFID" at %llu: rc %ld\n",
+		CDEBUG(D_INFO, "%s: dir page locate: " DFID " at %llu: rc %ld\n",
 		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
 		       rp_param.rp_off, PTR_ERR(page));
 		rc = PTR_ERR(page);
-- 
1.7.1
