From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:25 -0400
Subject: [lustre-devel] [PATCH 026/124] staging: lustre: statahead:
	statahead thread wait for RPCs to finish
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Statahead thread should wait for inflight stat RPCs to finish in
case statahead RPC callback may access data allocated in statahead
thread context.

ll_sa_entry_fini() should keep old entry if stat RPC is not
finished yet.

Simplify sai refcounting:
* newly allocated sai will hold one refcount, and it will put it
  after starting statahead thread.
* statahead thread holds one refcount.
* agl thread holds one refcount.
* stat process calls do_statahead_enter() which will try to get
  sai, and if it's valid, it will revalidate from statahead cache,
  and put refcount after use.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3270
Reviewed-on: http://review.whamcloud.com/9663
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    1 -
 drivers/staging/lustre/lustre/llite/dcache.c       |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |   31 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   49 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +
 drivers/staging/lustre/lustre/llite/statahead.c    |  849 +++++++++-----------
 6 files changed, 434 insertions(+), 506 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 838a428..89633f7 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -806,7 +806,6 @@ struct md_enqueue_info {
 	int (*mi_cb)(struct ptlrpc_request *req,
 		     struct md_enqueue_info *minfo, int rc);
 	__u64		   mi_cbdata;
-	unsigned int	    mi_generation;
 };
 
 struct obd_ops {
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index f4b6f38..8c00cc6 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -279,7 +279,7 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	if (lookup_flags & (LOOKUP_PARENT | LOOKUP_OPEN | LOOKUP_CREATE))
 		return 1;
 
-	if (d_need_statahead(dir, dentry) <= 0)
+	if (!dentry_need_statahead(dir, dentry))
 		return 1;
 
 	if (lookup_flags & LOOKUP_RCU)
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index e9791e3..273b563 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -351,13 +351,11 @@ int ll_file_release(struct inode *inode, struct file *file)
 	fd = LUSTRE_FPRIVATE(file);
 	LASSERT(fd);
 
-	/* The last ref on @file, maybe not be the owner pid of statahead.
-	 * Different processes can open the same dir, "ll_opendir_key" means:
-	 * it is me that should stop the statahead thread.
+	/* The last ref on @file, maybe not be the owner pid of statahead,
+	 * because parent and child process can share the same file handle.
 	 */
-	if (S_ISDIR(inode->i_mode) && lli->lli_opendir_key == fd &&
-	    lli->lli_opendir_pid != 0)
-		ll_stop_statahead(inode, lli->lli_opendir_key);
+	if (S_ISDIR(inode->i_mode) && lli->lli_opendir_key == fd)
+		ll_deauthorize_statahead(inode, fd);
 
 	if (is_root_inode(inode)) {
 		LUSTRE_FPRIVATE(file) = NULL;
@@ -530,7 +528,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct obd_client_handle **och_p = NULL;
 	__u64 *och_usecount = NULL;
 	struct ll_file_data *fd;
-	int rc = 0, opendir_set = 0;
+	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), flags %o\n",
 	       PFID(ll_inode2fid(inode)), inode, file->f_flags);
@@ -545,16 +543,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 	}
 
 	fd->fd_file = file;
-	if (S_ISDIR(inode->i_mode)) {
-		spin_lock(&lli->lli_sa_lock);
-		if (!lli->lli_opendir_key && !lli->lli_sai &&
-		    lli->lli_opendir_pid == 0) {
-			lli->lli_opendir_key = fd;
-			lli->lli_opendir_pid = current_pid();
-			opendir_set = 1;
-		}
-		spin_unlock(&lli->lli_sa_lock);
-	}
+	if (S_ISDIR(inode->i_mode))
+		ll_authorize_statahead(inode, fd);
 
 	if (is_root_inode(inode)) {
 		LUSTRE_FPRIVATE(file) = fd;
@@ -713,9 +703,10 @@ out_och_free:
 		mutex_unlock(&lli->lli_och_mutex);
 
 out_openerr:
-		if (opendir_set != 0)
-			ll_stop_statahead(inode, lli->lli_opendir_key);
-		ll_file_data_put(fd);
+		if (lli->lli_opendir_key == fd)
+			ll_deauthorize_statahead(inode, fd);
+		if (fd)
+			ll_file_data_put(fd);
 	} else {
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_OPEN, 1);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cbd5bc5..f903f2a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -172,6 +172,13 @@ struct ll_inode_info {
 			 * -- I am the owner of dir statahead.
 			 */
 			pid_t			   d_opendir_pid;
+			/* stat will try to access statahead entries or start
+			 * statahead if this flag is set, and this flag will be
+			 * set upon dir open, and cleared when dir is closed,
+			 * statahead hit ratio is too low, or start statahead
+			 * thread failed.
+			 */
+			unsigned int			d_sa_enabled:1;
 			/* directory stripe information */
 			struct lmv_stripe_md		*d_lsm_md;
 			/* striped directory size */
@@ -184,6 +191,7 @@ struct ll_inode_info {
 #define lli_opendir_key	 u.d.d_opendir_key
 #define lli_sai		 u.d.d_sai
 #define lli_sa_lock	     u.d.d_sa_lock
+#define lli_sa_enabled		u.d.d_sa_enabled
 #define lli_opendir_pid	 u.d.d_opendir_pid
 #define lli_lsm_md		u.d.d_lsm_md
 #define lli_stripe_dir_size	u.d.d_stripe_size
@@ -495,6 +503,9 @@ struct ll_sb_info {
 	atomic_t		  ll_sa_wrong;   /* statahead thread stopped for
 						  * low hit ratio
 						  */
+	atomic_t		ll_sa_running;	/* running statahead thread
+						 * count
+						 */
 	atomic_t		  ll_agl_total;  /* AGL thread started count */
 
 	dev_t			  ll_sdev_orig; /* save s_dev before assign for
@@ -1040,7 +1051,8 @@ struct ll_statahead_info {
 
 int do_statahead_enter(struct inode *dir, struct dentry **dentry,
 		       int only_unplug);
-void ll_stop_statahead(struct inode *dir, void *key);
+void ll_authorize_statahead(struct inode *dir, void *key);
+void ll_deauthorize_statahead(struct inode *dir, void *key);
 
 blkcnt_t dirty_cnt(struct inode *inode);
 
@@ -1086,25 +1098,31 @@ ll_statahead_mark(struct inode *dir, struct dentry *dentry)
 		ldd->lld_sa_generation = sai->sai_generation;
 }
 
-static inline int
-d_need_statahead(struct inode *dir, struct dentry *dentryp)
+static inline bool
+dentry_need_statahead(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_inode_info  *lli;
 	struct ll_dentry_data *ldd;
 
 	if (ll_i2sbi(dir)->ll_sa_max == 0)
-		return -EAGAIN;
+		return false;
 
 	lli = ll_i2info(dir);
+
+	/*
+	 * statahead is not allowed for this dir, there may be three causes:
+	 * 1. dir is not opened.
+	 * 2. statahead hit ratio is too low.
+	 * 3. previous stat started statahead thread failed.
+	 */
+	if (!lli->lli_sa_enabled)
+		return false;
+
 	/* not the same process, don't statahead */
 	if (lli->lli_opendir_pid != current_pid())
-		return -EAGAIN;
-
-	/* statahead has been stopped */
-	if (!lli->lli_opendir_key)
-		return -EAGAIN;
+		return false;
 
-	ldd = ll_d2d(dentryp);
+	ldd = ll_d2d(dentry);
 	/*
 	 * When stats a dentry, the system trigger more than once "revalidate"
 	 * or "lookup", for "getattr", for "getxattr", and maybe for others.
@@ -1122,19 +1140,16 @@ d_need_statahead(struct inode *dir, struct dentry *dentryp)
 	 */
 	if (ldd && lli->lli_sai &&
 	    ldd->lld_sa_generation == lli->lli_sai->sai_generation)
-		return -EAGAIN;
+		return false;
 
-	return 1;
+	return true;
 }
 
 static inline int
 ll_statahead_enter(struct inode *dir, struct dentry **dentryp, int only_unplug)
 {
-	int ret;
-
-	ret = d_need_statahead(dir, *dentryp);
-	if (ret <= 0)
-		return ret;
+	if (!dentry_need_statahead(dir, *dentryp))
+		return -EAGAIN;
 
 	return do_statahead_enter(dir, dentryp, only_unplug);
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 99aba6b..93fd69b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -116,6 +116,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	sbi->ll_sa_max = LL_SA_RPC_DEF;
 	atomic_set(&sbi->ll_sa_total, 0);
 	atomic_set(&sbi->ll_sa_wrong, 0);
+	atomic_set(&sbi->ll_sa_running, 0);
 	atomic_set(&sbi->ll_agl_total, 0);
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 
@@ -630,6 +631,12 @@ void ll_kill_super(struct super_block *sb)
 	if (sbi) {
 		sb->s_dev = sbi->ll_sdev_orig;
 		sbi->ll_umounting = 1;
+
+		/* wait running statahead threads to quit */
+		while (atomic_read(&sbi->ll_sa_running) > 0) {
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC >> 3));
+		}
 	}
 }
 
@@ -795,6 +802,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_sai = NULL;
 		spin_lock_init(&lli->lli_sa_lock);
 		lli->lli_opendir_pid = 0;
+		lli->lli_sa_enabled = 0;
 	} else {
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 016463b..6577a66 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -281,25 +281,6 @@ ll_sa_entry_get_byindex(struct ll_statahead_info *sai, __u64 index)
 	return NULL;
 }
 
-static void ll_sa_entry_cleanup(struct ll_statahead_info *sai,
-				struct ll_sa_entry *entry)
-{
-	struct md_enqueue_info *minfo = entry->se_minfo;
-	struct ptlrpc_request  *req   = entry->se_req;
-
-	if (minfo) {
-		entry->se_minfo = NULL;
-		ll_intent_release(&minfo->mi_it);
-		iput(minfo->mi_dir);
-		kfree(minfo);
-	}
-
-	if (req) {
-		entry->se_req = NULL;
-		ptlrpc_req_finished(req);
-	}
-}
-
 static void ll_sa_entry_put(struct ll_statahead_info *sai,
 			    struct ll_sa_entry *entry)
 {
@@ -312,7 +293,6 @@ static void ll_sa_entry_put(struct ll_statahead_info *sai,
 		LASSERT(list_empty(&entry->se_list));
 		LASSERT(list_empty(&entry->se_hash));
 
-		ll_sa_entry_cleanup(sai, entry);
 		iput(entry->se_inode);
 
 		kfree(entry);
@@ -355,7 +335,10 @@ ll_sa_entry_fini(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
 	list_for_each_entry_safe(pos, next, &sai->sai_entries, se_link) {
 		if (!is_omitted_entry(sai, pos->se_index))
 			break;
-		do_sa_entry_fini(sai, pos);
+		/* keep those whose statahead RPC not finished */
+		if (pos->se_stat == SA_ENTRY_SUCC ||
+		    pos->se_stat == SA_ENTRY_INVA)
+			do_sa_entry_fini(sai, pos);
 	}
 }
 
@@ -363,12 +346,14 @@ ll_sa_entry_fini(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
  * Inside lli_sa_lock.
  */
 static void
-do_sa_entry_to_stated(struct ll_statahead_info *sai,
-		      struct ll_sa_entry *entry, enum se_stat stat)
+__sa_entry_post_stat(struct ll_statahead_info *sai, struct ll_sa_entry *entry,
+		     enum se_stat stat)
 {
 	struct ll_sa_entry *se;
 	struct list_head	 *pos = &sai->sai_entries_stated;
 
+	LASSERT(entry->se_stat == SA_ENTRY_INIT);
+
 	if (!list_empty(&entry->se_list))
 		list_del_init(&entry->se_list);
 
@@ -388,23 +373,30 @@ do_sa_entry_to_stated(struct ll_statahead_info *sai,
  * \retval 1    -- entry to be destroyed.
  * \retval 0    -- entry is inserted into stated list.
  */
-static int
-ll_sa_entry_to_stated(struct ll_statahead_info *sai,
-		      struct ll_sa_entry *entry, enum se_stat stat)
+static void
+sa_entry_post_stat(struct ll_statahead_info *sai, struct ll_sa_entry *entry,
+		   enum se_stat stat)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
-	int		   ret = 1;
+	struct md_enqueue_info *minfo = entry->se_minfo;
+	struct ptlrpc_request *req = entry->se_req;
+
+	/* release resources used in RPC */
+	if (minfo) {
+		entry->se_minfo = NULL;
+		ll_intent_release(&minfo->mi_it);
+		iput(minfo->mi_dir);
+		kfree(minfo);
+	}
 
-	ll_sa_entry_cleanup(sai, entry);
+	if (req) {
+		entry->se_req = NULL;
+		ptlrpc_req_finished(req);
+	}
 
 	spin_lock(&lli->lli_sa_lock);
-	if (likely(entry->se_stat != SA_ENTRY_DEST)) {
-		do_sa_entry_to_stated(sai, entry, stat);
-		ret = 0;
-	}
+	__sa_entry_post_stat(sai, entry, stat);
 	spin_unlock(&lli->lli_sa_lock);
-
-	return ret;
 }
 
 /*
@@ -475,56 +467,46 @@ static struct ll_statahead_info *ll_sai_alloc(void)
 	return sai;
 }
 
-static inline struct ll_statahead_info *
-ll_sai_get(struct ll_statahead_info *sai)
+static inline struct ll_statahead_info *ll_sai_get(struct inode *dir)
 {
-	atomic_inc(&sai->sai_refcount);
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = NULL;
+
+	spin_lock(&lli->lli_sa_lock);
+	sai = lli->lli_sai;
+	if (sai)
+		atomic_inc(&sai->sai_refcount);
+	spin_unlock(&lli->lli_sa_lock);
+
 	return sai;
 }
 
 static void ll_sai_put(struct ll_statahead_info *sai)
 {
-	struct inode	 *inode = sai->sai_inode;
-	struct ll_inode_info *lli   = ll_i2info(inode);
+	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
 
 	if (atomic_dec_and_lock(&sai->sai_refcount, &lli->lli_sa_lock)) {
+		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
 		struct ll_sa_entry *entry, *next;
 
-		if (unlikely(atomic_read(&sai->sai_refcount) > 0)) {
-			/* It is race case, the interpret callback just hold
-			 * a reference count
-			 */
-			spin_unlock(&lli->lli_sa_lock);
-			return;
-		}
-
-		LASSERT(!lli->lli_opendir_key);
-		LASSERT(thread_is_stopped(&sai->sai_thread));
-		LASSERT(thread_is_stopped(&sai->sai_agl_thread));
-
 		lli->lli_sai = NULL;
-		lli->lli_opendir_pid = 0;
 		spin_unlock(&lli->lli_sa_lock);
 
-		if (sai->sai_sent > sai->sai_replied)
-			CDEBUG(D_READA, "statahead for dir "DFID
-			      " does not finish: [sent:%llu] [replied:%llu]\n",
-			      PFID(&lli->lli_fid),
-			      sai->sai_sent, sai->sai_replied);
+		LASSERT(thread_is_stopped(&sai->sai_thread));
+		LASSERT(thread_is_stopped(&sai->sai_agl_thread));
+		LASSERT(sai->sai_sent == sai->sai_replied);
 
 		list_for_each_entry_safe(entry, next, &sai->sai_entries,
 					 se_link)
 			do_sa_entry_fini(sai, entry);
 
-		LASSERT(list_empty(&sai->sai_entries));
-		LASSERT(list_empty(&sai->sai_entries_received));
-		LASSERT(list_empty(&sai->sai_entries_stated));
-
 		LASSERT(atomic_read(&sai->sai_cache_count) == 0);
 		LASSERT(list_empty(&sai->sai_entries_agl));
+		LASSERT(atomic_read(&sai->sai_refcount) == 0);
 
-		iput(inode);
+		iput(sai->sai_inode);
 		kfree(sai);
+		atomic_dec(&sbi->ll_sa_running);
 	}
 }
 
@@ -588,29 +570,18 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	iput(inode);
 }
 
-static void ll_post_statahead(struct ll_statahead_info *sai)
+/* prepare inode for received statahead entry, and add it into agl list */
+static void sa_post_one(struct ll_statahead_info *sai,
+			struct ll_sa_entry *entry)
 {
 	struct inode	   *dir   = sai->sai_inode;
 	struct inode	   *child;
-	struct ll_inode_info   *lli   = ll_i2info(dir);
-	struct ll_sa_entry     *entry;
 	struct md_enqueue_info *minfo;
 	struct lookup_intent   *it;
 	struct ptlrpc_request  *req;
 	struct mdt_body	*body;
 	int		     rc    = 0;
 
-	spin_lock(&lli->lli_sa_lock);
-	if (unlikely(list_empty(&sai->sai_entries_received))) {
-		spin_unlock(&lli->lli_sa_lock);
-		return;
-	}
-	entry = list_entry(sai->sai_entries_received.next,
-			   struct ll_sa_entry, se_list);
-	atomic_inc(&entry->se_refcount);
-	list_del_init(&entry->se_list);
-	spin_unlock(&lli->lli_sa_lock);
-
 	LASSERT(entry->se_handle != 0);
 
 	minfo = entry->se_minfo;
@@ -670,18 +641,56 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 		ll_agl_add(sai, child, entry->se_index);
 
 out:
-	/* The "ll_sa_entry_to_stated()" will drop related ldlm ibits lock
+	/* The "sa_entry_post_stat()" will drop related ldlm ibits lock
 	 * reference count by calling "ll_intent_drop_lock()" in spite of the
 	 * above operations failed or not. Do not worry about calling
 	 * "ll_intent_drop_lock()" more than once.
 	 */
-	rc = ll_sa_entry_to_stated(sai, entry,
-				   rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
-	if (rc == 0 && entry->se_index == sai->sai_index_wait)
+	sa_entry_post_stat(sai, entry, rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
+	if (entry->se_index == sai->sai_index_wait)
 		wake_up(&sai->sai_waitq);
 	ll_sa_entry_put(sai, entry);
 }
 
+static void ll_post_statahead(struct ll_statahead_info *sai)
+{
+	struct ll_inode_info *lli;
+
+	lli = ll_i2info(sai->sai_inode);
+
+	while (!sa_received_empty(sai)) {
+		struct ll_sa_entry *entry;
+
+		spin_lock(&lli->lli_sa_lock);
+		if (unlikely(sa_received_empty(sai))) {
+			spin_unlock(&lli->lli_sa_lock);
+			break;
+		}
+		entry = list_entry(sai->sai_entries_received.next,
+				   struct ll_sa_entry, se_list);
+		atomic_inc(&entry->se_refcount);
+		list_del_init(&entry->se_list);
+		spin_unlock(&lli->lli_sa_lock);
+
+		sa_post_one(sai, entry);
+	}
+
+	spin_lock(&lli->lli_agl_lock);
+	while (!agl_list_empty(sai)) {
+		struct ll_inode_info *clli;
+
+		clli = list_entry(sai->sai_entries_agl.next,
+				  struct ll_inode_info, lli_agl_list);
+		list_del_init(&clli->lli_agl_list);
+		spin_unlock(&lli->lli_agl_lock);
+
+		ll_agl_trigger(&clli->lli_vfs_inode, sai);
+
+		spin_lock(&lli->lli_agl_lock);
+	}
+	spin_unlock(&lli->lli_agl_lock);
+}
+
 static int ll_statahead_interpret(struct ptlrpc_request *req,
 				  struct md_enqueue_info *minfo, int rc)
 {
@@ -690,72 +699,43 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	struct ll_inode_info     *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = NULL;
 	struct ll_sa_entry       *entry;
-	__u64			  handle = 0;
 	int		       wakeup;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		rc = -ENOENT;
 
-	if (rc == 0) {
-		/* release ibits lock ASAP to avoid deadlock when statahead
-		 * thread enqueues lock on parent in readdir and another
-		 * process enqueues lock on child with parent lock held, eg.
-		 * unlink.
-		 */
-		handle = it->it_lock_handle;
-		ll_intent_drop_lock(it);
-	}
+	sai = ll_sai_get(dir);
+	LASSERT(sai);
+	LASSERT(!thread_is_stopped(&sai->sai_thread));
 
 	spin_lock(&lli->lli_sa_lock);
-	/* stale entry */
-	if (unlikely(!lli->lli_sai ||
-		     lli->lli_sai->sai_generation != minfo->mi_generation)) {
-		spin_unlock(&lli->lli_sa_lock);
-		rc = -ESTALE;
-		goto out;
+	entry = ll_sa_entry_get_byindex(sai, minfo->mi_cbdata);
+	LASSERT(entry);
+	if (rc) {
+		__sa_entry_post_stat(sai, entry, SA_ENTRY_INVA);
+		wakeup = (entry->se_index == sai->sai_index_wait);
 	} else {
-		sai = ll_sai_get(lli->lli_sai);
-		if (unlikely(!thread_is_running(&sai->sai_thread))) {
-			sai->sai_replied++;
-			spin_unlock(&lli->lli_sa_lock);
-			rc = -EBADFD;
-			goto out;
-		}
-
-		entry = ll_sa_entry_get_byindex(sai, minfo->mi_cbdata);
-		if (!entry) {
-			sai->sai_replied++;
-			spin_unlock(&lli->lli_sa_lock);
-			rc = -EIDRM;
-			goto out;
-		}
-
-		if (rc != 0) {
-			do_sa_entry_to_stated(sai, entry, SA_ENTRY_INVA);
-			wakeup = (entry->se_index == sai->sai_index_wait);
-		} else {
-			entry->se_minfo = minfo;
-			entry->se_req = ptlrpc_request_addref(req);
-			/* Release the async ibits lock ASAP to avoid deadlock
-			 * when statahead thread tries to enqueue lock on parent
-			 * for readpage and other tries to enqueue lock on child
-			 * with parent's lock held, for example: unlink.
-			 */
-			entry->se_handle = handle;
-			wakeup = list_empty(&sai->sai_entries_received);
-			list_add_tail(&entry->se_list,
-				      &sai->sai_entries_received);
-		}
-		sai->sai_replied++;
-		spin_unlock(&lli->lli_sa_lock);
-
-		ll_sa_entry_put(sai, entry);
-		if (wakeup)
-			wake_up(&sai->sai_thread.t_ctl_waitq);
+		entry->se_minfo = minfo;
+		entry->se_req = ptlrpc_request_addref(req);
+		/*
+		 * Release the async ibits lock ASAP to avoid deadlock
+		 * when statahead thread tries to enqueue lock on parent
+		 * for readpage and other tries to enqueue lock on child
+		 * with parent's lock held, for example: unlink.
+		 */
+		entry->se_handle = it->it_lock_handle;
+		ll_intent_drop_lock(it);
+		wakeup = sa_received_empty(sai);
+		list_add_tail(&entry->se_list, &sai->sai_entries_received);
 	}
+	sai->sai_replied++;
+	spin_unlock(&lli->lli_sa_lock);
 
-out:
-	if (rc != 0) {
+	ll_sa_entry_put(sai, entry);
+	if (wakeup)
+		wake_up(&sai->sai_thread.t_ctl_waitq);
+
+	if (rc) {
 		ll_intent_release(it);
 		iput(dir);
 		kfree(minfo);
@@ -782,7 +762,6 @@ static int sa_args_init(struct inode *dir, struct inode *child,
 			struct ldlm_enqueue_info **pei)
 {
 	const struct qstr      *qstr = &entry->se_qstr;
-	struct ll_inode_info     *lli  = ll_i2info(dir);
 	struct md_enqueue_info   *minfo;
 	struct ldlm_enqueue_info *einfo;
 	struct md_op_data	*op_data;
@@ -808,7 +787,6 @@ static int sa_args_init(struct inode *dir, struct inode *child,
 	minfo->mi_it.it_op = IT_GETATTR;
 	minfo->mi_dir = igrab(dir);
 	minfo->mi_cb = ll_statahead_interpret;
-	minfo->mi_generation = lli->lli_sai->sai_generation;
 	minfo->mi_cbdata = entry->se_index;
 
 	einfo->ei_type   = LDLM_IBITS;
@@ -889,8 +867,8 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 	return rc;
 }
 
-static void ll_statahead_one(struct dentry *parent, const char *entry_name,
-			     int entry_name_len)
+static void ll_statahead_one(struct dentry *parent, const char *name,
+			     const int name_len)
 {
 	struct inode	     *dir    = d_inode(parent);
 	struct ll_inode_info     *lli    = ll_i2info(dir);
@@ -898,10 +876,9 @@ static void ll_statahead_one(struct dentry *parent, const char *entry_name,
 	struct dentry	    *dentry = NULL;
 	struct ll_sa_entry       *entry;
 	int		       rc;
-	int		       rc1;
 
-	entry = ll_sa_entry_alloc(parent, sai, sai->sai_index, entry_name,
-				  entry_name_len);
+	entry = ll_sa_entry_alloc(parent, sai, sai->sai_index, name,
+				  name_len);
 	if (IS_ERR(entry))
 		return;
 
@@ -912,15 +889,15 @@ static void ll_statahead_one(struct dentry *parent, const char *entry_name,
 		rc = do_sa_revalidate(dir, entry, dentry);
 		if (rc == 1 && agl_should_run(sai, d_inode(dentry)))
 			ll_agl_add(sai, d_inode(dentry), entry->se_index);
+	}
 
+	if (dentry)
 		dput(dentry);
-	}
 
 	if (rc) {
-		rc1 = ll_sa_entry_to_stated(sai, entry,
-					    rc < 0 ? SA_ENTRY_INVA :
-					    SA_ENTRY_SUCC);
-		if (rc1 == 0 && entry->se_index == sai->sai_index_wait)
+		sa_entry_post_stat(sai, entry,
+				   rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
+		if (entry->se_index == sai->sai_index_wait)
 			wake_up(&sai->sai_waitq);
 	} else {
 		sai->sai_sent++;
@@ -938,10 +915,12 @@ static int ll_agl_thread(void *arg)
 	struct ll_inode_info     *plli   = ll_i2info(dir);
 	struct ll_inode_info     *clli;
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
-	struct ll_statahead_info *sai    = ll_sai_get(plli->lli_sai);
-	struct ptlrpc_thread     *thread = &sai->sai_agl_thread;
+	struct ll_statahead_info *sai;
+	struct ptlrpc_thread *thread;
 	struct l_wait_info	lwi    = { 0 };
 
+	sai = ll_sai_get(dir);
+	thread = &sai->sai_agl_thread;
 	thread->t_pid = current_pid();
 	CDEBUG(D_READA, "agl thread started: sai %p, parent %pd\n",
 	       sai, parent);
@@ -1030,12 +1009,11 @@ static int ll_statahead_thread(void *arg)
 {
 	struct dentry	    *parent = arg;
 	struct inode	     *dir    = d_inode(parent);
-	struct ll_inode_info     *plli   = ll_i2info(dir);
-	struct ll_inode_info     *clli;
+	struct ll_inode_info     *lli   = ll_i2info(dir);
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
-	struct ll_statahead_info *sai    = ll_sai_get(plli->lli_sai);
-	struct ptlrpc_thread     *thread = &sai->sai_thread;
-	struct ptlrpc_thread *agl_thread = &sai->sai_agl_thread;
+	struct ll_statahead_info *sai;
+	struct ptlrpc_thread *thread;
+	struct ptlrpc_thread *agl_thread;
 	struct page	      *page = NULL;
 	__u64		     pos    = 0;
 	int		       first  = 0;
@@ -1044,6 +1022,9 @@ static int ll_statahead_thread(void *arg)
 	struct ll_dir_chain       chain;
 	struct l_wait_info	lwi    = { 0 };
 
+	sai = ll_sai_get(dir);
+	thread = &sai->sai_thread;
+	agl_thread = &sai->sai_agl_thread;
 	thread->t_pid = current_pid();
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
@@ -1052,7 +1033,7 @@ static int ll_statahead_thread(void *arg)
 				     LUSTRE_OPC_ANY, dir);
 	if (IS_ERR(op_data)) {
 		rc = PTR_ERR(op_data);
-		goto out_put;
+		goto out;
 	}
 
 	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
@@ -1061,33 +1042,35 @@ static int ll_statahead_thread(void *arg)
 		ll_start_agl(parent, sai);
 
 	atomic_inc(&sbi->ll_sa_total);
-	spin_lock(&plli->lli_sa_lock);
+	spin_lock(&lli->lli_sa_lock);
 	if (thread_is_init(thread))
 		/* If someone else has changed the thread state
 		 * (e.g. already changed to SVC_STOPPING), we can't just
 		 * blindly overwrite that setting.
 		 */
 		thread_set_flags(thread, SVC_RUNNING);
-	spin_unlock(&plli->lli_sa_lock);
+	spin_unlock(&lli->lli_sa_lock);
 	wake_up(&thread->t_ctl_waitq);
 
 	ll_dir_chain_init(&chain);
-	page = ll_get_dir_page(dir, op_data, pos, &chain);
-
-	while (1) {
+	while (pos != MDS_DIR_END_OFF && thread_is_running(thread)) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
 
+		sai->sai_in_readpage = 1;
+		page = ll_get_dir_page(dir, op_data, pos, &chain);
+		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
 			CDEBUG(D_READA, "error reading dir "DFID" at %llu/%llu: opendir_pid = %u: rc = %d\n",
 			       PFID(ll_inode2fid(dir)), pos, sai->sai_index,
-			       plli->lli_opendir_pid, rc);
-			goto out;
+			       lli->lli_opendir_pid, rc);
+			break;
 		}
 
 		dp = page_address(page);
-		for (ent = lu_dirent_start(dp); ent;
+		for (ent = lu_dirent_start(dp);
+		     ent && thread_is_running(thread) && !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
 			__u64 hash;
 			int namelen;
@@ -1134,120 +1117,63 @@ static int ll_statahead_thread(void *arg)
 			if (unlikely(++first == 1))
 				continue;
 
-keep_it:
-			l_wait_event(thread->t_ctl_waitq,
-				     !sa_sent_full(sai) ||
-				     !list_empty(&sai->sai_entries_received) ||
-				     !list_empty(&sai->sai_entries_agl) ||
-				     !thread_is_running(thread),
-				     &lwi);
-
-interpret_it:
-			while (!list_empty(&sai->sai_entries_received))
+			/* wait for spare statahead window */
+			do {
+				l_wait_event(thread->t_ctl_waitq,
+					     !sa_sent_full(sai) ||
+					     !list_empty(&sai->sai_entries_received) ||
+					     !list_empty(&sai->sai_entries_agl) ||
+					     !thread_is_running(thread),
+					     &lwi);
 				ll_post_statahead(sai);
+			} while (sa_sent_full(sai) &&
+				 thread_is_running(thread));
 
-			if (unlikely(!thread_is_running(thread))) {
-				ll_release_page(dir, page, false);
-				rc = 0;
-				goto out;
-			}
-
-			/* If no window for metadata statahead, but there are
-			 * some AGL entries to be triggered, then try to help
-			 * to process the AGL entries.
-			 */
-			if (sa_sent_full(sai)) {
-				spin_lock(&plli->lli_agl_lock);
-				while (!list_empty(&sai->sai_entries_agl)) {
-					clli = list_entry(sai->sai_entries_agl.next,
-							  struct ll_inode_info, lli_agl_list);
-					list_del_init(&clli->lli_agl_list);
-					spin_unlock(&plli->lli_agl_lock);
-					ll_agl_trigger(&clli->lli_vfs_inode,
-						       sai);
-
-					if (!list_empty(&sai->sai_entries_received))
-						goto interpret_it;
-
-					if (unlikely(!thread_is_running(thread))) {
-						ll_release_page(dir, page, false);
-						rc = 0;
-						goto out;
-					}
-
-					if (!sa_sent_full(sai))
-						goto do_it;
-
-					spin_lock(&plli->lli_agl_lock);
-				}
-				spin_unlock(&plli->lli_agl_lock);
-
-				goto keep_it;
-			}
-do_it:
 			ll_statahead_one(parent, name, namelen);
 		}
 
 		pos = le64_to_cpu(dp->ldp_hash_end);
-		if (pos == MDS_DIR_END_OFF) {
-			/*
-			 * End of directory reached.
-			 */
-			ll_release_page(dir, page, false);
-			while (1) {
-				l_wait_event(thread->t_ctl_waitq,
-					     !list_empty(&sai->sai_entries_received) ||
-					     sai->sai_sent == sai->sai_replied ||
-					     !thread_is_running(thread),
-					     &lwi);
+		ll_release_page(dir, page,
+				le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
 
-				while (!list_empty(&sai->sai_entries_received))
-					ll_post_statahead(sai);
-
-				if (unlikely(!thread_is_running(thread))) {
-					rc = 0;
-					goto out;
-				}
+		if (sa_low_hit(sai)) {
+			rc = -EFAULT;
+			atomic_inc(&sbi->ll_sa_wrong);
+			CDEBUG(D_READA, "Statahead for dir "DFID" hit ratio too low: hit/miss %llu/%llu, sent/replied %llu/%llu, stopping statahead thread: pid %d\n",
+			       PFID(&lli->lli_fid), sai->sai_hit,
+			       sai->sai_miss, sai->sai_sent,
+			       sai->sai_replied, current_pid());
+			break;
+		}
+	}
+	ll_dir_chain_fini(&chain);
+	ll_finish_md_op_data(op_data);
 
-				if (sai->sai_sent == sai->sai_replied &&
-				    list_empty(&sai->sai_entries_received))
-					break;
-			}
+	if (rc < 0) {
+		spin_lock(&lli->lli_sa_lock);
+		thread_set_flags(thread, SVC_STOPPING);
+		lli->lli_sa_enabled = 0;
+		spin_unlock(&lli->lli_sa_lock);
+	}
 
-			spin_lock(&plli->lli_agl_lock);
-			while (!list_empty(&sai->sai_entries_agl) &&
-			       thread_is_running(thread)) {
-				clli = list_entry(sai->sai_entries_agl.next,
-						  struct ll_inode_info, lli_agl_list);
-				list_del_init(&clli->lli_agl_list);
-				spin_unlock(&plli->lli_agl_lock);
-				ll_agl_trigger(&clli->lli_vfs_inode, sai);
-				spin_lock(&plli->lli_agl_lock);
-			}
-			spin_unlock(&plli->lli_agl_lock);
+	/*
+	 * statahead is finished, but statahead entries need to be cached, wait
+	 * for file release to stop me.
+	 */
+	while (thread_is_running(thread)) {
+		l_wait_event(thread->t_ctl_waitq,
+			     !sa_received_empty(sai) ||
+			     !agl_list_empty(sai) ||
+			     !thread_is_running(thread),
+			     &lwi);
 
-			rc = 0;
-			goto out;
-		} else {
-			/*
-			 * chain is exhausted.
-			 * Normal case: continue to the next page.
-			 */
-			ll_release_page(dir, page,
-					le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
-			sai->sai_in_readpage = 1;
-			page = ll_get_dir_page(dir, op_data, pos, &chain);
-			sai->sai_in_readpage = 0;
-		}
+		ll_post_statahead(sai);
 	}
 out:
-	ll_dir_chain_fini(&chain);
-	ll_finish_md_op_data(op_data);
-out_put:
 	if (sai->sai_agl_valid) {
-		spin_lock(&plli->lli_agl_lock);
+		spin_lock(&lli->lli_agl_lock);
 		thread_set_flags(agl_thread, SVC_STOPPING);
-		spin_unlock(&plli->lli_agl_lock);
+		spin_unlock(&lli->lli_agl_lock);
 		wake_up(&agl_thread->t_ctl_waitq);
 
 		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
@@ -1257,21 +1183,27 @@ out_put:
 			     &lwi);
 	} else {
 		/* Set agl_thread flags anyway. */
-		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
+		thread_set_flags(agl_thread, SVC_STOPPED);
 	}
-	spin_lock(&plli->lli_sa_lock);
-	if (!list_empty(&sai->sai_entries_received)) {
-		thread_set_flags(thread, SVC_STOPPING);
-		spin_unlock(&plli->lli_sa_lock);
-
-		/* To release the resources held by received entries. */
-		while (!list_empty(&sai->sai_entries_received))
-			ll_post_statahead(sai);
 
-		spin_lock(&plli->lli_sa_lock);
+	/*
+	 * wait for inflight statahead RPCs to finish, and then we can free sai
+	 * safely because statahead RPC will access sai data
+	 */
+	while (sai->sai_sent != sai->sai_replied) {
+		/* in case we're not woken up, timeout wait */
+		lwi = LWI_TIMEOUT(HZ >> 3, NULL, NULL);
+		l_wait_event(thread->t_ctl_waitq,
+			     sai->sai_sent == sai->sai_replied, &lwi);
 	}
+
+	/* release resources held by received entries. */
+	ll_post_statahead(sai);
+
+	spin_lock(&lli->lli_sa_lock);
 	thread_set_flags(thread, SVC_STOPPED);
-	spin_unlock(&plli->lli_sa_lock);
+	spin_unlock(&lli->lli_sa_lock);
+
 	wake_up(&sai->sai_waitq);
 	wake_up(&thread->t_ctl_waitq);
 	ll_sai_put(sai);
@@ -1281,52 +1213,54 @@ out_put:
 	return rc;
 }
 
-/**
- * called in ll_file_release().
- */
-void ll_stop_statahead(struct inode *dir, void *key)
+/* authorize opened dir handle @key to statahead later */
+void ll_authorize_statahead(struct inode *dir, void *key)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 
-	if (unlikely(!key))
-		return;
-
 	spin_lock(&lli->lli_sa_lock);
-	if (lli->lli_opendir_key != key || lli->lli_opendir_pid == 0) {
-		spin_unlock(&lli->lli_sa_lock);
-		return;
+	if (!lli->lli_opendir_key && !lli->lli_sai) {
+		/*
+		 * if lli_sai is not NULL, it means previous statahead is not
+		 * finished yet, we'd better not start a new statahead for now.
+		 */
+		LASSERT(!lli->lli_opendir_pid);
+		lli->lli_opendir_key = key;
+		lli->lli_opendir_pid = current_pid();
+		lli->lli_sa_enabled = 1;
 	}
+	spin_unlock(&lli->lli_sa_lock);
+}
 
-	lli->lli_opendir_key = NULL;
+/*
+ * deauthorize opened dir handle @key to statahead, but statahead thread may
+ * still be running, notify it to quit.
+ */
+void ll_deauthorize_statahead(struct inode *dir, void *key)
+{
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai;
 
-	if (lli->lli_sai) {
-		struct l_wait_info lwi = { 0 };
-		struct ptlrpc_thread *thread = &lli->lli_sai->sai_thread;
+	LASSERT(lli->lli_opendir_key == key);
+	LASSERT(lli->lli_opendir_pid);
 
-		if (!thread_is_stopped(thread)) {
-			thread_set_flags(thread, SVC_STOPPING);
-			spin_unlock(&lli->lli_sa_lock);
-			wake_up(&thread->t_ctl_waitq);
-
-			CDEBUG(D_READA, "stop statahead thread: sai %p pid %u\n",
-			       lli->lli_sai, (unsigned int)thread->t_pid);
-			l_wait_event(thread->t_ctl_waitq,
-				     thread_is_stopped(thread),
-				     &lwi);
-		} else {
-			spin_unlock(&lli->lli_sa_lock);
-		}
+	CDEBUG(D_READA, "deauthorize statahead for "DFID"\n",
+	       PFID(&lli->lli_fid));
 
+	spin_lock(&lli->lli_sa_lock);
+	lli->lli_opendir_key = NULL;
+	lli->lli_opendir_pid = 0;
+	lli->lli_sa_enabled = 0;
+	sai = lli->lli_sai;
+	if (sai && thread_is_running(&sai->sai_thread)) {
 		/*
-		 * Put the ref which was held when first statahead_enter.
-		 * It maybe not the last ref for some statahead requests
-		 * maybe inflight.
+		 * statahead thread may not quit yet because it needs to cache
+		 * stated entries, now it's time to tell it to quit.
 		 */
-		ll_sai_put(lli->lli_sai);
-	} else {
-		lli->lli_opendir_pid = 0;
-		spin_unlock(&lli->lli_sa_lock);
+		thread_set_flags(&sai->sai_thread, SVC_STOPPING);
+		wake_up(&sai->sai_thread.t_ctl_waitq);
 	}
+	spin_unlock(&lli->lli_sa_lock);
 }
 
 enum {
@@ -1465,175 +1399,137 @@ out:
 static void
 ll_sai_unplug(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
 {
-	struct ptlrpc_thread *thread = &sai->sai_thread;
-	struct ll_sb_info    *sbi    = ll_i2sbi(sai->sai_inode);
-	int		   hit;
+	if (entry && entry->se_stat == SA_ENTRY_SUCC) {
+		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
 
-	if (entry && entry->se_stat == SA_ENTRY_SUCC)
-		hit = 1;
-	else
-		hit = 0;
-
-	ll_sa_entry_fini(sai, entry);
-	if (hit) {
 		sai->sai_hit++;
 		sai->sai_consecutive_miss = 0;
 		sai->sai_max = min(2 * sai->sai_max, sbi->ll_sa_max);
 	} else {
-		struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
-
 		sai->sai_miss++;
 		sai->sai_consecutive_miss++;
-		if (sa_low_hit(sai) && thread_is_running(thread)) {
-			atomic_inc(&sbi->ll_sa_wrong);
-			CDEBUG(D_READA, "Statahead for dir " DFID " hit ratio too low: hit/miss %llu/%llu, sent/replied %llu/%llu, stopping statahead thread\n",
-			       PFID(&lli->lli_fid), sai->sai_hit,
-			       sai->sai_miss, sai->sai_sent,
-			       sai->sai_replied);
-			spin_lock(&lli->lli_sa_lock);
-			if (!thread_is_stopped(thread))
-				thread_set_flags(thread, SVC_STOPPING);
-			spin_unlock(&lli->lli_sa_lock);
-		}
 	}
-
-	if (!thread_is_stopped(thread))
-		wake_up(&thread->t_ctl_waitq);
+	ll_sa_entry_fini(sai, entry);
+	wake_up(&sai->sai_thread.t_ctl_waitq);
 }
 
-/**
- * Start statahead thread if this is the first dir entry.
- * Otherwise if a thread is started already, wait it until it is ahead of me.
- * \retval 1       -- find entry with lock in cache, the caller needs to do
- *		    nothing.
- * \retval 0       -- find entry in cache, but without lock, the caller needs
- *		    refresh from MDS.
- * \retval others  -- the caller need to process as non-statahead.
- */
-int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
-		       int only_unplug)
+static int revalidate_statahead_dentry(struct inode *dir,
+				       struct ll_statahead_info *sai,
+				       struct dentry **dentryp,
+				       int only_unplug)
 {
-	struct ll_inode_info     *lli   = ll_i2info(dir);
-	struct ll_statahead_info *sai   = lli->lli_sai;
-	struct dentry	    *parent;
-	struct ll_sa_entry       *entry;
-	struct ptlrpc_thread     *thread;
-	struct l_wait_info	lwi   = { 0 };
-	struct task_struct *task;
-	int		       rc    = 0;
-	struct ll_inode_info     *plli;
-
-	LASSERT(lli->lli_opendir_pid == current_pid());
-
-	if (sai) {
-		thread = &sai->sai_thread;
-		if (unlikely(thread_is_stopped(thread) &&
-			     list_empty(&sai->sai_entries_stated))) {
-			/* to release resource */
-			ll_stop_statahead(dir, lli->lli_opendir_key);
-			return -EAGAIN;
-		}
+	struct ll_sa_entry *entry = NULL;
+	struct l_wait_info lwi = { 0 };
+	int rc = 0;
 
-		if ((*dentryp)->d_name.name[0] == '.') {
-			if (sai->sai_ls_all ||
-			    sai->sai_miss_hidden >= sai->sai_skip_hidden) {
+	if ((*dentryp)->d_name.name[0] == '.') {
+		if (sai->sai_ls_all ||
+		    sai->sai_miss_hidden >= sai->sai_skip_hidden) {
+			/*
+			 * Hidden dentry is the first one, or statahead
+			 * thread does not skip so many hidden dentries
+			 * before "sai_ls_all" enabled as below.
+			 */
+		} else {
+			if (!sai->sai_ls_all)
 				/*
-				 * Hidden dentry is the first one, or statahead
-				 * thread does not skip so many hidden dentries
-				 * before "sai_ls_all" enabled as below.
+				 * It maybe because hidden dentry is not
+				 * the first one, "sai_ls_all" was not
+				 * set, then "ls -al" missed. Enable
+				 * "sai_ls_all" for such case.
 				 */
-			} else {
-				if (!sai->sai_ls_all)
-					/*
-					 * It maybe because hidden dentry is not
-					 * the first one, "sai_ls_all" was not
-					 * set, then "ls -al" missed. Enable
-					 * "sai_ls_all" for such case.
-					 */
-					sai->sai_ls_all = 1;
+				sai->sai_ls_all = 1;
 
-				/*
-				 * Such "getattr" has been skipped before
-				 * "sai_ls_all" enabled as above.
-				 */
-				sai->sai_miss_hidden++;
-				return -EAGAIN;
-			}
+			/*
+			 * Such "getattr" has been skipped before
+			 * "sai_ls_all" enabled as above.
+			 */
+			sai->sai_miss_hidden++;
+			return -EAGAIN;
 		}
+	}
 
-		entry = ll_sa_entry_get_byname(sai, &(*dentryp)->d_name);
-		if (!entry || only_unplug) {
+	entry = ll_sa_entry_get_byname(sai, &(*dentryp)->d_name);
+	if (!entry || only_unplug) {
+		ll_sai_unplug(sai, entry);
+		return entry ? 1 : -EAGAIN;
+	}
+
+	/* if statahead is busy in readdir, help it do post-work */
+	if (!ll_sa_entry_stated(entry) && sai->sai_in_readpage)
+		ll_post_statahead(sai);
+
+	if (!ll_sa_entry_stated(entry)) {
+		sai->sai_index_wait = entry->se_index;
+		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
+				       LWI_ON_SIGNAL_NOOP, NULL);
+		rc = l_wait_event(sai->sai_waitq,
+				  ll_sa_entry_stated(entry) ||
+				  thread_is_stopped(&sai->sai_thread),
+				  &lwi);
+		if (rc < 0) {
 			ll_sai_unplug(sai, entry);
-			return entry ? 1 : -EAGAIN;
+			return -EAGAIN;
 		}
+	}
 
-		/* if statahead is busy in readdir, help it do post-work */
-		while (!ll_sa_entry_stated(entry) && sai->sai_in_readpage &&
-		       !sa_received_empty(sai))
-			ll_post_statahead(sai);
-
-		if (!ll_sa_entry_stated(entry)) {
-			sai->sai_index_wait = entry->se_index;
-			lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
-					       LWI_ON_SIGNAL_NOOP, NULL);
-			rc = l_wait_event(sai->sai_waitq,
-					  ll_sa_entry_stated(entry) ||
-					  thread_is_stopped(thread),
-					  &lwi);
-			if (rc < 0) {
-				ll_sai_unplug(sai, entry);
-				return -EAGAIN;
-			}
-		}
+	if (entry->se_stat == SA_ENTRY_SUCC && entry->se_inode) {
+		struct inode *inode = entry->se_inode;
+		struct lookup_intent it = { .it_op = IT_GETATTR,
+					    .it_lock_handle = entry->se_handle };
+		__u64 bits;
+
+		rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
+					ll_inode2fid(inode), &bits);
+		if (rc == 1) {
+			if (!(*dentryp)->d_inode) {
+				struct dentry *alias;
 
-		if (entry->se_stat == SA_ENTRY_SUCC && entry->se_inode) {
-			struct inode *inode = entry->se_inode;
-			struct lookup_intent it = { .it_op = IT_GETATTR,
-						    .it_lock_handle =
-						     entry->se_handle };
-			__u64 bits;
-
-			rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
-						ll_inode2fid(inode), &bits);
-			if (rc == 1) {
-				if (!d_inode(*dentryp)) {
-					struct dentry *alias;
-
-					alias = ll_splice_alias(inode,
-								*dentryp);
-					if (IS_ERR(alias)) {
-						ll_sai_unplug(sai, entry);
-						return PTR_ERR(alias);
-					}
-					*dentryp = alias;
-				} else if (d_inode(*dentryp) != inode) {
-					/* revalidate, but inode is recreated */
-					CDEBUG(D_READA, "%s: stale dentry %pd inode "DFID", statahead inode "DFID"\n",
-					       ll_get_fsname(d_inode(*dentryp)->i_sb, NULL, 0),
-					       *dentryp,
-					       PFID(ll_inode2fid(d_inode(*dentryp))),
-					       PFID(ll_inode2fid(inode)));
-					ll_intent_release(&it);
+				alias = ll_splice_alias(inode, *dentryp);
+				if (IS_ERR(alias)) {
 					ll_sai_unplug(sai, entry);
-					return -ESTALE;
-				} else {
-					iput(inode);
+					return PTR_ERR(alias);
 				}
-				entry->se_inode = NULL;
-
-				if ((bits & MDS_INODELOCK_LOOKUP) &&
-				    d_lustre_invalid(*dentryp))
-					d_lustre_revalidate(*dentryp);
-				ll_intent_release(&it);
+				*dentryp = alias;
+			} else if ((*dentryp)->d_inode != inode) {
+				/* revalidate, but inode is recreated */
+				CDEBUG(D_READA,
+				       "%s: stale dentry %pd inode "DFID", statahead inode "DFID"\n",
+				       ll_get_fsname((*dentryp)->d_inode->i_sb,
+						     NULL, 0),
+				       *dentryp,
+				       PFID(ll_inode2fid((*dentryp)->d_inode)),
+				       PFID(ll_inode2fid(inode)));
+				rc = -ESTALE;
+				goto out_unplug;
+			} else {
+				iput(inode);
 			}
-		}
+			entry->se_inode = NULL;
 
-		ll_sai_unplug(sai, entry);
-		return rc;
+			if ((bits & MDS_INODELOCK_LOOKUP) &&
+			    d_lustre_invalid(*dentryp))
+				d_lustre_revalidate(*dentryp);
+			ll_intent_release(&it);
+		}
 	}
+out_unplug:
+	ll_sai_unplug(sai, entry);
+	return rc;
+}
+
+static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
+{
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = NULL;
+	struct l_wait_info lwi = { 0 };
+	struct ptlrpc_thread *thread;
+	struct task_struct *task;
+	struct dentry *parent;
+	int rc;
 
 	/* I am the "lli_opendir_pid" owner, only me can set "lli_sai". */
-	rc = is_first_dirent(dir, *dentryp);
+	rc = is_first_dirent(dir, dentry);
 	if (rc == LS_NONE_FIRST_DE) {
 		/* It is not "ls -{a}l" operation, no need statahead for it. */
 		rc = -EAGAIN;
@@ -1656,13 +1552,12 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	}
 
 	/* get parent reference count here, and put it in ll_statahead_thread */
-	parent = dget((*dentryp)->d_parent);
+	parent = dget(dentry->d_parent);
 	if (unlikely(sai->sai_inode != d_inode(parent))) {
 		struct ll_inode_info *nlli = ll_i2info(d_inode(parent));
 
 		CWARN("Race condition, someone changed %pd just now: old parent "DFID", new parent "DFID"\n",
-		      *dentryp,
-		      PFID(&lli->lli_fid), PFID(&nlli->lli_fid));
+		      dentry, PFID(&lli->lli_fid), PFID(&nlli->lli_fid));
 		dput(parent);
 		iput(sai->sai_inode);
 		rc = -EAGAIN;
@@ -1672,30 +1567,18 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	CDEBUG(D_READA, "start statahead thread: sai %p, parent %pd\n",
 	       sai, parent);
 
-	/* The sai buffer already has one reference taken at allocation time,
-	 * but as soon as we expose the sai by attaching it to the lli that
-	 * default reference can be dropped by another thread calling
-	 * ll_stop_statahead. We need to take a local reference to protect
-	 * the sai buffer while we intend to access it.
-	 */
-	ll_sai_get(sai);
 	lli->lli_sai = sai;
 
-	plli = ll_i2info(d_inode(parent));
 	task = kthread_run(ll_statahead_thread, parent, "ll_sa_%u",
-			   plli->lli_opendir_pid);
+			   lli->lli_opendir_pid);
 	thread = &sai->sai_thread;
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
-		CERROR("can't start ll_sa thread, rc: %d\n", rc);
+		CERROR("cannot start ll_sa thread: rc = %d\n", rc);
 		dput(parent);
 		lli->lli_opendir_key = NULL;
 		thread_set_flags(thread, SVC_STOPPED);
 		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
-		/* Drop both our own local reference and the default
-		 * reference from allocation time.
-		 */
-		ll_sai_put(sai);
 		ll_sai_put(sai);
 		LASSERT(!lli->lli_sai);
 		return -EAGAIN;
@@ -1704,6 +1587,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	l_wait_event(thread->t_ctl_waitq,
 		     thread_is_running(thread) || thread_is_stopped(thread),
 		     &lwi);
+	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_sa_running);
 	ll_sai_put(sai);
 
 	/*
@@ -1717,6 +1601,37 @@ out:
 	spin_lock(&lli->lli_sa_lock);
 	lli->lli_opendir_key = NULL;
 	lli->lli_opendir_pid = 0;
+	lli->lli_sa_enabled = 0;
 	spin_unlock(&lli->lli_sa_lock);
+
 	return rc;
 }
+
+/**
+ * Start statahead thread if this is the first dir entry.
+ * Otherwise if a thread is started already, wait it until it is ahead of me.
+ * \retval 1       -- find entry with lock in cache, the caller needs to do
+ *		      nothing.
+ * \retval 0       -- find entry in cache, but without lock, the caller needs
+ *		      refresh from MDS.
+ * \retval others  -- the caller need to process as non-statahead.
+ */
+int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
+		       int only_unplug)
+{
+	struct ll_statahead_info *sai;
+
+	sai = ll_sai_get(dir);
+	if (sai) {
+		int rc;
+
+		rc = revalidate_statahead_dentry(dir, sai, dentryp,
+						 only_unplug);
+		CDEBUG(D_READA, "revalidate statahead %pd: %d.\n",
+		       *dentryp, rc);
+		ll_sai_put(sai);
+		return rc;
+	}
+
+	return start_statahead_thread(dir, *dentryp);
+}
-- 
1.7.1
