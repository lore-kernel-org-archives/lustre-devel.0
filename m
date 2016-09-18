From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:55 -0400
Subject: [lustre-devel] [PATCH 056/124] staging: lustre: statahead: use
	dcache-like interface for sa entry
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Rename ll_sa_entry to sa_entry, and manage sa_entry cache with
dcache-like interfaces.

sa_entry is not needed to be refcounted, because only scanner
can free it, so after it's put in stat list, statahead thread
shouldn't access it any longer.

ll_statahead_interpret() doesn't need to take sai refcount,
because statahead thread will wait for all inflight RPC to
finish.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3270
Reviewed-on: http://review.whamcloud.com/9664
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   10 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  461 +++++++++-----------
 3 files changed, 207 insertions(+), 266 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 1c884c0..6758bf4 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -812,7 +812,7 @@ struct md_enqueue_info {
 	struct inode	   *mi_dir;
 	int (*mi_cb)(struct ptlrpc_request *req,
 		     struct md_enqueue_info *minfo, int rc);
-	__u64		   mi_cbdata;
+	void			*mi_cbdata;
 };
 
 struct obd_ops {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 9a9fefd..cd639f4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1131,10 +1131,12 @@ struct ll_statahead_info {
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
 	struct ptlrpc_thread    sai_agl_thread; /* AGL thread */
-	struct list_head	sai_entries;    /* entry list */
-	struct list_head	sai_entries_received; /* entries returned */
-	struct list_head	sai_entries_stated;   /* entries stated */
-	struct list_head	sai_entries_agl; /* AGL entries to be sent */
+	struct list_head	sai_interim_entries; /* entries which got async
+						      * stat reply, but not
+						      * instantiated
+						      */
+	struct list_head	sai_entries;	/* completed entries */
+	struct list_head	sai_agls;	/* AGLs to be sent */
 	struct list_head	sai_cache[LL_SA_CACHE_SIZE];
 	spinlock_t		sai_cache_lock[LL_SA_CACHE_SIZE];
 	atomic_t		sai_cache_count; /* entry count in cache */
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 5760974..d041720 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -49,24 +49,26 @@ enum se_stat {
 	SA_ENTRY_INIT = 0,      /** init entry */
 	SA_ENTRY_SUCC = 1,      /** stat succeed */
 	SA_ENTRY_INVA = 2,      /** invalid entry */
-	SA_ENTRY_DEST = 3,      /** entry to be destroyed */
 };
 
-struct ll_sa_entry {
-	/* link into sai->sai_entries */
-	struct list_head	      se_link;
-	/* link into sai->sai_entries_{received,stated} */
+/*
+ * sa_entry is not refcounted: statahead thread allocates it and do async stat,
+ * and in async stat callback ll_statahead_interpret() will add it into
+ * sai_cb_entries, later statahead thread will call sa_handle_callback() to
+ * instantiate entry and move it into sai_entries, and then only scanner process
+ * can access and free it.
+ */
+struct sa_entry {
+	/* link into sai_cb_entries or sai_entries */
 	struct list_head	      se_list;
 	/* link into sai hash table locally */
 	struct list_head	      se_hash;
-	/* entry reference count */
-	atomic_t	    se_refcount;
 	/* entry index in the sai */
 	__u64		   se_index;
 	/* low layer ldlm lock handle */
 	__u64		   se_handle;
 	/* entry status */
-	enum se_stat	   se_stat;
+	enum se_stat		se_state;
 	/* entry size, contains name */
 	int		     se_size;
 	/* pointer to async getattr enqueue info */
@@ -85,13 +87,13 @@ static DEFINE_SPINLOCK(sai_generation_lock);
 /*
  * The entry only can be released by the caller, it is necessary to hold lock.
  */
-static inline int ll_sa_entry_stated(struct ll_sa_entry *entry)
+static inline int sa_ready(struct sa_entry *entry)
 {
 	smp_rmb();
-	return (entry->se_stat != SA_ENTRY_INIT);
+	return (entry->se_state != SA_ENTRY_INIT);
 }
 
-static inline int ll_sa_entry_hash(int val)
+static inline int sa_hash(int val)
 {
 	return val & LL_SA_CACHE_MASK;
 }
@@ -100,9 +102,9 @@ static inline int ll_sa_entry_hash(int val)
  * Insert entry to hash SA table.
  */
 static inline void
-ll_sa_entry_enhash(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
+sa_rehash(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
-	int i = ll_sa_entry_hash(entry->se_qstr.hash);
+	int i = sa_hash(entry->se_qstr.hash);
 
 	spin_lock(&sai->sai_cache_lock[i]);
 	list_add_tail(&entry->se_hash, &sai->sai_cache[i]);
@@ -113,9 +115,9 @@ ll_sa_entry_enhash(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
  * Remove entry from SA table.
  */
 static inline void
-ll_sa_entry_unhash(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
+sa_unhash(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
-	int i = ll_sa_entry_hash(entry->se_qstr.hash);
+	int i = sa_hash(entry->se_qstr.hash);
 
 	spin_lock(&sai->sai_cache_lock[i]);
 	list_del_init(&entry->se_hash);
@@ -133,14 +135,14 @@ static inline int sa_sent_full(struct ll_statahead_info *sai)
 	return atomic_read(&sai->sai_cache_count) >= sai->sai_max;
 }
 
-static inline int sa_received_empty(struct ll_statahead_info *sai)
+static inline int sa_has_callback(struct ll_statahead_info *sai)
 {
-	return list_empty(&sai->sai_entries_received);
+	return !list_empty(&sai->sai_interim_entries);
 }
 
 static inline int agl_list_empty(struct ll_statahead_info *sai)
 {
-	return list_empty(&sai->sai_entries_agl);
+	return list_empty(&sai->sai_agls);
 }
 
 /**
@@ -168,17 +170,16 @@ static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
 /*
  * Insert it into sai_entries tail when init.
  */
-static struct ll_sa_entry *
-ll_sa_entry_alloc(struct dentry *parent,
-		  struct ll_statahead_info *sai, __u64 index,
-		  const char *name, int len)
+static struct sa_entry *
+sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, __u64 index,
+	 const char *name, int len)
 {
 	struct ll_inode_info *lli;
-	struct ll_sa_entry   *entry;
+	struct sa_entry   *entry;
 	int		   entry_size;
 	char		 *dname;
 
-	entry_size = sizeof(struct ll_sa_entry) + (len & ~3) + 4;
+	entry_size = sizeof(struct sa_entry) + (len & ~3) + 4;
 	entry = kzalloc(entry_size, GFP_NOFS);
 	if (unlikely(!entry))
 		return ERR_PTR(-ENOMEM);
@@ -187,34 +188,9 @@ ll_sa_entry_alloc(struct dentry *parent,
 	       len, name, entry, index);
 
 	entry->se_index = index;
-
-	/*
-	 * Statahead entry reference rules:
-	 *
-	 * 1) When statahead entry is initialized, its reference is set as 2.
-	 *    One reference is used by the directory scanner. When the scanner
-	 *    searches the statahead cache for the given name, it can perform
-	 *    lockless hash lookup (only the scanner can remove entry from hash
-	 *    list), and once found, it needn't to call "atomic_inc()" for the
-	 *    entry reference. So the performance is improved. After using the
-	 *    statahead entry, the scanner will call "atomic_dec()" to drop the
-	 *    reference held when initialization. If it is the last reference,
-	 *    the statahead entry will be freed.
-	 *
-	 * 2) All other threads, including statahead thread and ptlrpcd thread,
-	 *    when they process the statahead entry, the reference for target
-	 *    should be held to guarantee the entry will not be released by the
-	 *    directory scanner. After processing the entry, these threads will
-	 *    drop the entry reference. If it is the last reference, the entry
-	 *    will be freed.
-	 *
-	 *    The second reference when initializes the statahead entry is used
-	 *    by the statahead thread, following the rule 2).
-	 */
-	atomic_set(&entry->se_refcount, 2);
-	entry->se_stat = SA_ENTRY_INIT;
+	entry->se_state = SA_ENTRY_INIT;
 	entry->se_size = entry_size;
-	dname = (char *)entry + sizeof(struct ll_sa_entry);
+	dname = (char *)entry + sizeof(struct sa_entry);
 	memcpy(dname, name, len);
 	dname[len] = 0;
 
@@ -224,9 +200,8 @@ ll_sa_entry_alloc(struct dentry *parent,
 
 	lli = ll_i2info(sai->sai_inode);
 	spin_lock(&lli->lli_sa_lock);
-	list_add_tail(&entry->se_link, &sai->sai_entries);
 	INIT_LIST_HEAD(&entry->se_list);
-	ll_sa_entry_enhash(sai, entry);
+	sa_rehash(sai, entry);
 	spin_unlock(&lli->lli_sa_lock);
 
 	atomic_inc(&sai->sai_cache_count);
@@ -234,151 +209,130 @@ ll_sa_entry_alloc(struct dentry *parent,
 	return entry;
 }
 
-/*
- * Used by the directory scanner to search entry with name.
- *
- * Only the caller can remove the entry from hash, so it is unnecessary to hold
- * hash lock. It is caller's duty to release the init refcount on the entry, so
- * it is also unnecessary to increase refcount on the entry.
- */
-static struct ll_sa_entry *
-ll_sa_entry_get_byname(struct ll_statahead_info *sai, const struct qstr *qstr)
+/* free sa_entry, which should have been unhashed and not in any list */
+static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
-	struct ll_sa_entry *entry;
-	int i = ll_sa_entry_hash(qstr->hash);
+	CDEBUG(D_READA, "free sa entry %.*s(%p) index %llu\n",
+	       entry->se_qstr.len, entry->se_qstr.name, entry,
+	       entry->se_index);
 
-	list_for_each_entry(entry, &sai->sai_cache[i], se_hash) {
-		if (entry->se_qstr.hash == qstr->hash &&
-		    entry->se_qstr.len == qstr->len &&
-		    memcmp(entry->se_qstr.name, qstr->name, qstr->len) == 0)
-			return entry;
-	}
-	return NULL;
+	LASSERT(list_empty(&entry->se_list));
+	LASSERT(list_empty(&entry->se_hash));
+
+	kfree(entry);
+	atomic_dec(&sai->sai_cache_count);
 }
 
 /*
- * Used by the async getattr request callback to find entry with index.
- *
- * Inside lli_sa_lock to prevent others to change the list during the search.
- * It needs to increase entry refcount before returning to guarantee that the
- * entry cannot be freed by others.
+ * find sa_entry by name, used by directory scanner, lock is not needed because
+ * only scanner can remove the entry from cache.
  */
-static struct ll_sa_entry *
-ll_sa_entry_get_byindex(struct ll_statahead_info *sai, __u64 index)
+static struct sa_entry *
+sa_get(struct ll_statahead_info *sai, const struct qstr *qstr)
 {
-	struct ll_sa_entry *entry;
+	struct sa_entry *entry;
+	int i = sa_hash(qstr->hash);
 
-	list_for_each_entry(entry, &sai->sai_entries, se_link) {
-		if (entry->se_index == index) {
-			LASSERT(atomic_read(&entry->se_refcount) > 0);
-			atomic_inc(&entry->se_refcount);
+	list_for_each_entry(entry, &sai->sai_cache[i], se_hash) {
+		if (entry->se_qstr.hash == qstr->hash &&
+		    entry->se_qstr.len == qstr->len &&
+		    memcmp(entry->se_qstr.name, qstr->name, qstr->len) == 0)
 			return entry;
-		}
-		if (entry->se_index > index)
-			break;
 	}
 	return NULL;
 }
 
-static void ll_sa_entry_put(struct ll_statahead_info *sai,
-			    struct ll_sa_entry *entry)
-{
-	if (atomic_dec_and_test(&entry->se_refcount)) {
-		CDEBUG(D_READA, "free sa entry %.*s(%p) index %llu\n",
-		       entry->se_qstr.len, entry->se_qstr.name, entry,
-		       entry->se_index);
-
-		LASSERT(list_empty(&entry->se_link));
-		LASSERT(list_empty(&entry->se_list));
-		LASSERT(list_empty(&entry->se_hash));
-
-		iput(entry->se_inode);
-
-		kfree(entry);
-		atomic_dec(&sai->sai_cache_count);
-	}
-}
-
+/* unhash and unlink sa_entry, and then free it */
 static inline void
-do_sa_entry_fini(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
+sa_kill(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
 
 	LASSERT(!list_empty(&entry->se_hash));
-	LASSERT(!list_empty(&entry->se_link));
+	LASSERT(!list_empty(&entry->se_list));
+	LASSERT(sa_ready(entry));
 
-	ll_sa_entry_unhash(sai, entry);
+	sa_unhash(sai, entry);
 
 	spin_lock(&lli->lli_sa_lock);
-	entry->se_stat = SA_ENTRY_DEST;
-	list_del_init(&entry->se_link);
-	if (likely(!list_empty(&entry->se_list)))
-		list_del_init(&entry->se_list);
+	list_del_init(&entry->se_list);
 	spin_unlock(&lli->lli_sa_lock);
 
-	ll_sa_entry_put(sai, entry);
+	if (entry->se_inode)
+		iput(entry->se_inode);
+
+	sa_free(sai, entry);
 }
 
-/*
- * Delete it from sai_entries_stated list when fini.
- */
+/* called by scanner after use, sa_entry will be killed */
 static void
-ll_sa_entry_fini(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
+sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
-	struct ll_sa_entry *pos, *next;
+	struct sa_entry *tmp, *next;
+
+	if (entry && entry->se_state == SA_ENTRY_SUCC) {
+		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
+
+		sai->sai_hit++;
+		sai->sai_consecutive_miss = 0;
+		sai->sai_max = min(2 * sai->sai_max, sbi->ll_sa_max);
+	} else {
+		sai->sai_miss++;
+		sai->sai_consecutive_miss++;
+	}
 
 	if (entry)
-		do_sa_entry_fini(sai, entry);
+		sa_kill(sai, entry);
 
-	/* drop old entry, only 'scanner' process does this, no need to lock */
-	list_for_each_entry_safe(pos, next, &sai->sai_entries, se_link) {
-		if (!is_omitted_entry(sai, pos->se_index))
+	/*
+	 * kill old completed entries, only scanner process does this, no need
+	 * to lock
+	 */
+	list_for_each_entry_safe(tmp, next, &sai->sai_entries, se_list) {
+		if (!is_omitted_entry(sai, tmp->se_index))
 			break;
-		/* keep those whose statahead RPC not finished */
-		if (pos->se_stat == SA_ENTRY_SUCC ||
-		    pos->se_stat == SA_ENTRY_INVA)
-			do_sa_entry_fini(sai, pos);
+		sa_kill(sai, tmp);
 	}
+	wake_up(&sai->sai_thread.t_ctl_waitq);
 }
 
 /*
- * Inside lli_sa_lock.
+ * update state and sort add entry to sai_entries by index, return true if
+ * scanner is waiting on this entry.
  */
-static void
-__sa_entry_post_stat(struct ll_statahead_info *sai, struct ll_sa_entry *entry,
-		     enum se_stat stat)
+static bool
+__sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
-	struct ll_sa_entry *se;
-	struct list_head	 *pos = &sai->sai_entries_stated;
-
-	LASSERT(entry->se_stat == SA_ENTRY_INIT);
+	struct list_head *pos = &sai->sai_entries;
+	__u64 index = entry->se_index;
+	struct sa_entry *se;
 
-	if (!list_empty(&entry->se_list))
-		list_del_init(&entry->se_list);
+	LASSERT(!sa_ready(entry));
+	LASSERT(list_empty(&entry->se_list));
 
-	list_for_each_entry_reverse(se, &sai->sai_entries_stated, se_list) {
+	list_for_each_entry_reverse(se, &sai->sai_entries, se_list) {
 		if (se->se_index < entry->se_index) {
 			pos = &se->se_list;
 			break;
 		}
 	}
-
 	list_add(&entry->se_list, pos);
-	entry->se_stat = stat;
+	entry->se_state = ret < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC;
+
+	return (index == sai->sai_index_wait);
 }
 
 /*
- * Move entry to sai_entries_stated and sort with the index.
- * \retval 1    -- entry to be destroyed.
- * \retval 0    -- entry is inserted into stated list.
+ * release resources used in async stat RPC, update entry state and wakeup if
+ * scanner process it waiting on this entry.
  */
 static void
-sa_entry_post_stat(struct ll_statahead_info *sai, struct ll_sa_entry *entry,
-		   enum se_stat stat)
+sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_inode);
 	struct md_enqueue_info *minfo = entry->se_minfo;
 	struct ptlrpc_request *req = entry->se_req;
+	bool wakeup;
 
 	/* release resources used in RPC */
 	if (minfo) {
@@ -394,12 +348,15 @@ sa_entry_post_stat(struct ll_statahead_info *sai, struct ll_sa_entry *entry,
 	}
 
 	spin_lock(&lli->lli_sa_lock);
-	__sa_entry_post_stat(sai, entry, stat);
+	wakeup = __sa_make_ready(sai, entry, ret);
 	spin_unlock(&lli->lli_sa_lock);
+
+	if (wakeup)
+		wake_up(&sai->sai_waitq);
 }
 
 /*
- * Insert inode into the list of sai_entries_agl.
+ * Insert inode into the list of sai_agls.
  */
 static void ll_agl_add(struct ll_statahead_info *sai,
 		       struct inode *inode, int index)
@@ -417,9 +374,9 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 
 		igrab(inode);
 		spin_lock(&parent->lli_agl_lock);
-		if (list_empty(&sai->sai_entries_agl))
+		if (list_empty(&sai->sai_agls))
 			added = 1;
-		list_add_tail(&child->lli_agl_list, &sai->sai_entries_agl);
+		list_add_tail(&child->lli_agl_list, &sai->sai_agls);
 		spin_unlock(&parent->lli_agl_lock);
 	} else {
 		spin_unlock(&child->lli_agl_lock);
@@ -429,6 +386,7 @@ static void ll_agl_add(struct ll_statahead_info *sai,
 		wake_up(&sai->sai_agl_thread.t_ctl_waitq);
 }
 
+/* allocate sai */
 static struct ll_statahead_info *ll_sai_alloc(void)
 {
 	struct ll_statahead_info *sai;
@@ -452,10 +410,9 @@ static struct ll_statahead_info *ll_sai_alloc(void)
 	init_waitqueue_head(&sai->sai_thread.t_ctl_waitq);
 	init_waitqueue_head(&sai->sai_agl_thread.t_ctl_waitq);
 
+	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
-	INIT_LIST_HEAD(&sai->sai_entries_received);
-	INIT_LIST_HEAD(&sai->sai_entries_stated);
-	INIT_LIST_HEAD(&sai->sai_entries_agl);
+	INIT_LIST_HEAD(&sai->sai_agls);
 
 	for (i = 0; i < LL_SA_CACHE_SIZE; i++) {
 		INIT_LIST_HEAD(&sai->sai_cache[i]);
@@ -486,7 +443,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 
 	if (atomic_dec_and_lock(&sai->sai_refcount, &lli->lli_sa_lock)) {
 		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
-		struct ll_sa_entry *entry, *next;
+		struct sa_entry *entry, *next;
 
 		lli->lli_sai = NULL;
 		spin_unlock(&lli->lli_sa_lock);
@@ -494,14 +451,14 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		LASSERT(thread_is_stopped(&sai->sai_thread));
 		LASSERT(thread_is_stopped(&sai->sai_agl_thread));
 		LASSERT(sai->sai_sent == sai->sai_replied);
+		LASSERT(!sa_has_callback(sai));
 
 		list_for_each_entry_safe(entry, next, &sai->sai_entries,
-					 se_link)
-			do_sa_entry_fini(sai, entry);
+					 se_list)
+			sa_kill(sai, entry);
 
 		LASSERT(atomic_read(&sai->sai_cache_count) == 0);
-		LASSERT(list_empty(&sai->sai_entries_agl));
-		LASSERT(atomic_read(&sai->sai_refcount) == 0);
+		LASSERT(list_empty(&sai->sai_agls));
 
 		iput(sai->sai_inode);
 		kfree(sai);
@@ -509,7 +466,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 	}
 }
 
-/* Do NOT forget to drop inode refcount when into sai_entries_agl. */
+/* Do NOT forget to drop inode refcount when into sai_agls. */
 static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 {
 	struct ll_inode_info *lli   = ll_i2info(inode);
@@ -569,9 +526,12 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	iput(inode);
 }
 
-/* prepare inode for received statahead entry, and add it into agl list */
-static void sa_post_one(struct ll_statahead_info *sai,
-			struct ll_sa_entry *entry)
+/*
+ * prepare inode for sa entry, add it into agl list, now sa_entry is ready
+ * to be used by scanner process.
+ */
+static void sa_instantiate(struct ll_statahead_info *sai,
+			   struct sa_entry *entry)
 {
 	struct inode	   *dir   = sai->sai_inode;
 	struct inode	   *child;
@@ -629,8 +589,9 @@ static void sa_post_one(struct ll_statahead_info *sai,
 	if (rc)
 		goto out;
 
-	CDEBUG(D_DLMTRACE, "%s: setting l_data to inode "DFID"%p\n",
+	CDEBUG(D_READA, "%s: setting %.*s" DFID " l_data to inode %p\n",
 	       ll_get_fsname(child->i_sb, NULL, 0),
+	       entry->se_qstr.len, entry->se_qstr.name,
 	       PFID(ll_inode2fid(child)), child);
 	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
 
@@ -640,45 +601,42 @@ static void sa_post_one(struct ll_statahead_info *sai,
 		ll_agl_add(sai, child, entry->se_index);
 
 out:
-	/* The "sa_entry_post_stat()" will drop related ldlm ibits lock
-	 * reference count by calling "ll_intent_drop_lock()" in spite of the
-	 * above operations failed or not. Do not worry about calling
-	 * "ll_intent_drop_lock()" more than once.
+	/*
+	 * sa_make_ready() will drop ldlm ibits lock refcount by calling
+	 * ll_intent_drop_lock() in spite of failures. Do not worry about
+	 * calling ll_intent_drop_lock() more than once.
 	 */
-	sa_entry_post_stat(sai, entry, rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
-	if (entry->se_index == sai->sai_index_wait)
-		wake_up(&sai->sai_waitq);
-	ll_sa_entry_put(sai, entry);
+	sa_make_ready(sai, entry, rc);
 }
 
-static void ll_post_statahead(struct ll_statahead_info *sai)
+/* once there are async stat replies, instantiate sa_entry */
+static void sa_handle_callback(struct ll_statahead_info *sai)
 {
 	struct ll_inode_info *lli;
 
 	lli = ll_i2info(sai->sai_inode);
 
-	while (!sa_received_empty(sai)) {
-		struct ll_sa_entry *entry;
+	while (sa_has_callback(sai)) {
+		struct sa_entry *entry;
 
 		spin_lock(&lli->lli_sa_lock);
-		if (unlikely(sa_received_empty(sai))) {
+		if (unlikely(!sa_has_callback(sai))) {
 			spin_unlock(&lli->lli_sa_lock);
 			break;
 		}
-		entry = list_entry(sai->sai_entries_received.next,
-				   struct ll_sa_entry, se_list);
-		atomic_inc(&entry->se_refcount);
+		entry = list_entry(sai->sai_interim_entries.next,
+				   struct sa_entry, se_list);
 		list_del_init(&entry->se_list);
 		spin_unlock(&lli->lli_sa_lock);
 
-		sa_post_one(sai, entry);
+		sa_instantiate(sai, entry);
 	}
 
 	spin_lock(&lli->lli_agl_lock);
 	while (!agl_list_empty(sai)) {
 		struct ll_inode_info *clli;
 
-		clli = list_entry(sai->sai_entries_agl.next,
+		clli = list_entry(sai->sai_agls.next,
 				  struct ll_inode_info, lli_agl_list);
 		list_del_init(&clli->lli_agl_list);
 		spin_unlock(&lli->lli_agl_lock);
@@ -690,29 +648,38 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 	spin_unlock(&lli->lli_agl_lock);
 }
 
+/*
+ * callback for async stat, because this is called in ptlrpcd context, we only
+ * put sa_entry in sai_cb_entries list, and let sa_handle_callback() to really
+ * prepare inode and instantiate sa_entry later.
+ */
 static int ll_statahead_interpret(struct ptlrpc_request *req,
 				  struct md_enqueue_info *minfo, int rc)
 {
 	struct lookup_intent     *it  = &minfo->mi_it;
 	struct inode	     *dir = minfo->mi_dir;
 	struct ll_inode_info     *lli = ll_i2info(dir);
-	struct ll_statahead_info *sai = NULL;
-	struct ll_sa_entry       *entry;
-	int		       wakeup;
+	struct ll_statahead_info *sai = lli->lli_sai;
+	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
+	bool wakeup;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		rc = -ENOENT;
 
-	sai = ll_sai_get(dir);
+	/*
+	 * because statahead thread will wait for all inflight RPC to finish,
+	 * sai should be always valid, no need to refcount
+	 */
 	LASSERT(sai);
 	LASSERT(!thread_is_stopped(&sai->sai_thread));
+	LASSERT(entry);
+
+	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
+	       entry->se_qstr.len, entry->se_qstr.name, rc);
 
 	spin_lock(&lli->lli_sa_lock);
-	entry = ll_sa_entry_get_byindex(sai, minfo->mi_cbdata);
-	LASSERT(entry);
 	if (rc) {
-		__sa_entry_post_stat(sai, entry, SA_ENTRY_INVA);
-		wakeup = (entry->se_index == sai->sai_index_wait);
+		wakeup = __sa_make_ready(sai, entry, rc);
 	} else {
 		entry->se_minfo = minfo;
 		entry->se_req = ptlrpc_request_addref(req);
@@ -724,27 +691,24 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 */
 		entry->se_handle = it->it_lock_handle;
 		ll_intent_drop_lock(it);
-		wakeup = sa_received_empty(sai);
-		list_add_tail(&entry->se_list, &sai->sai_entries_received);
+		wakeup = !sa_has_callback(sai);
+		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
 	}
 	sai->sai_replied++;
-	spin_unlock(&lli->lli_sa_lock);
 
-	ll_sa_entry_put(sai, entry);
 	if (wakeup)
 		wake_up(&sai->sai_thread.t_ctl_waitq);
+	spin_unlock(&lli->lli_sa_lock);
 
 	if (rc) {
 		ll_intent_release(it);
 		iput(dir);
 		kfree(minfo);
 	}
-	if (sai)
-		ll_sai_put(sai);
 	return rc;
 }
 
-static void sa_args_fini(struct md_enqueue_info *minfo,
+static void sa_fini_data(struct md_enqueue_info *minfo,
 			 struct ldlm_enqueue_info *einfo)
 {
 	LASSERT(minfo && einfo);
@@ -756,8 +720,8 @@ static void sa_args_fini(struct md_enqueue_info *minfo,
 /**
  * prepare arguments for async stat RPC.
  */
-static int sa_args_init(struct inode *dir, struct inode *child,
-			struct ll_sa_entry *entry, struct md_enqueue_info **pmi,
+static int sa_prep_data(struct inode *dir, struct inode *child,
+			struct sa_entry *entry, struct md_enqueue_info **pmi,
 			struct ldlm_enqueue_info **pei)
 {
 	const struct qstr      *qstr = &entry->se_qstr;
@@ -786,7 +750,7 @@ static int sa_args_init(struct inode *dir, struct inode *child,
 	minfo->mi_it.it_op = IT_GETATTR;
 	minfo->mi_dir = igrab(dir);
 	minfo->mi_cb = ll_statahead_interpret;
-	minfo->mi_cbdata = entry->se_index;
+	minfo->mi_cbdata = entry;
 
 	einfo->ei_type   = LDLM_IBITS;
 	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
@@ -801,19 +765,19 @@ static int sa_args_init(struct inode *dir, struct inode *child,
 	return 0;
 }
 
-static int do_sa_lookup(struct inode *dir, struct ll_sa_entry *entry)
+static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
 	struct md_enqueue_info   *minfo;
 	struct ldlm_enqueue_info *einfo;
 	int		       rc;
 
-	rc = sa_args_init(dir, NULL, entry, &minfo, &einfo);
+	rc = sa_prep_data(dir, NULL, entry, &minfo, &einfo);
 	if (rc)
 		return rc;
 
 	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo, einfo);
 	if (rc < 0)
-		sa_args_fini(minfo, einfo);
+		sa_fini_data(minfo, einfo);
 
 	return rc;
 }
@@ -824,8 +788,8 @@ static int do_sa_lookup(struct inode *dir, struct ll_sa_entry *entry)
  * \retval      0 -- will send stat-ahead request
  * \retval others -- prepare stat-ahead request failed
  */
-static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
-			    struct dentry *dentry)
+static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
+			 struct dentry *dentry)
 {
 	struct inode	     *inode = d_inode(dentry);
 	struct lookup_intent      it = { .it_op = IT_GETATTR,
@@ -849,7 +813,7 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 		return 1;
 	}
 
-	rc = sa_args_init(dir, inode, entry, &minfo, &einfo);
+	rc = sa_prep_data(dir, inode, entry, &minfo, &einfo);
 	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
@@ -860,32 +824,30 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 	if (rc < 0) {
 		entry->se_inode = NULL;
 		iput(inode);
-		sa_args_fini(minfo, einfo);
+		sa_fini_data(minfo, einfo);
 	}
 
 	return rc;
 }
 
-static void ll_statahead_one(struct dentry *parent, const char *name,
-			     const int name_len)
+static void sa_statahead(struct dentry *parent, const char *name, int len)
 {
 	struct inode	     *dir    = d_inode(parent);
 	struct ll_inode_info     *lli    = ll_i2info(dir);
 	struct ll_statahead_info *sai    = lli->lli_sai;
 	struct dentry	    *dentry = NULL;
-	struct ll_sa_entry       *entry;
+	struct sa_entry *entry;
 	int		       rc;
 
-	entry = ll_sa_entry_alloc(parent, sai, sai->sai_index, name,
-				  name_len);
+	entry = sa_alloc(parent, sai, sai->sai_index, name, len);
 	if (IS_ERR(entry))
 		return;
 
 	dentry = d_lookup(parent, &entry->se_qstr);
 	if (!dentry) {
-		rc = do_sa_lookup(dir, entry);
+		rc = sa_lookup(dir, entry);
 	} else {
-		rc = do_sa_revalidate(dir, entry, dentry);
+		rc = sa_revalidate(dir, entry, dentry);
 		if (rc == 1 && agl_should_run(sai, d_inode(dentry)))
 			ll_agl_add(sai, d_inode(dentry), entry->se_index);
 	}
@@ -893,18 +855,12 @@ static void ll_statahead_one(struct dentry *parent, const char *name,
 	if (dentry)
 		dput(dentry);
 
-	if (rc) {
-		sa_entry_post_stat(sai, entry,
-				   rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
-		if (entry->se_index == sai->sai_index_wait)
-			wake_up(&sai->sai_waitq);
-	} else {
+	if (rc)
+		sa_make_ready(sai, entry, rc);
+	else
 		sai->sai_sent++;
-	}
 
 	sai->sai_index++;
-	/* drop one refcount on entry by ll_sa_entry_alloc */
-	ll_sa_entry_put(sai, entry);
 }
 
 static int ll_agl_thread(void *arg)
@@ -938,7 +894,7 @@ static int ll_agl_thread(void *arg)
 
 	while (1) {
 		l_wait_event(thread->t_ctl_waitq,
-			     !list_empty(&sai->sai_entries_agl) ||
+			     !list_empty(&sai->sai_agls) ||
 			     !thread_is_running(thread),
 			     &lwi);
 
@@ -949,8 +905,8 @@ static int ll_agl_thread(void *arg)
 		/* The statahead thread maybe help to process AGL entries,
 		 * so check whether list empty again.
 		 */
-		if (!list_empty(&sai->sai_entries_agl)) {
-			clli = list_entry(sai->sai_entries_agl.next,
+		if (!list_empty(&sai->sai_agls)) {
+			clli = list_entry(sai->sai_agls.next,
 					  struct ll_inode_info, lli_agl_list);
 			list_del_init(&clli->lli_agl_list);
 			spin_unlock(&plli->lli_agl_lock);
@@ -962,8 +918,8 @@ static int ll_agl_thread(void *arg)
 
 	spin_lock(&plli->lli_agl_lock);
 	sai->sai_agl_valid = 0;
-	while (!list_empty(&sai->sai_entries_agl)) {
-		clli = list_entry(sai->sai_entries_agl.next,
+	while (!list_empty(&sai->sai_agls)) {
+		clli = list_entry(sai->sai_agls.next,
 				  struct ll_inode_info, lli_agl_list);
 		list_del_init(&clli->lli_agl_list);
 		spin_unlock(&plli->lli_agl_lock);
@@ -1118,15 +1074,15 @@ static int ll_statahead_thread(void *arg)
 			do {
 				l_wait_event(thread->t_ctl_waitq,
 					     !sa_sent_full(sai) ||
-					     !list_empty(&sai->sai_entries_received) ||
-					     !list_empty(&sai->sai_entries_agl) ||
+					     sa_has_callback(sai) ||
+					     !list_empty(&sai->sai_agls) ||
 					     !thread_is_running(thread),
 					     &lwi);
-				ll_post_statahead(sai);
+				sa_handle_callback(sai);
 			} while (sa_sent_full(sai) &&
 				 thread_is_running(thread));
 
-			ll_statahead_one(parent, name, namelen);
+			sa_statahead(parent, name, namelen);
 		}
 
 		pos = le64_to_cpu(dp->ldp_hash_end);
@@ -1158,12 +1114,12 @@ static int ll_statahead_thread(void *arg)
 	 */
 	while (thread_is_running(thread)) {
 		l_wait_event(thread->t_ctl_waitq,
-			     !sa_received_empty(sai) ||
+			     sa_has_callback(sai) ||
 			     !agl_list_empty(sai) ||
 			     !thread_is_running(thread),
 			     &lwi);
 
-		ll_post_statahead(sai);
+		sa_handle_callback(sai);
 	}
 out:
 	if (sai->sai_agl_valid) {
@@ -1193,8 +1149,8 @@ out:
 			     sai->sai_sent == sai->sai_replied, &lwi);
 	}
 
-	/* release resources held by received entries. */
-	ll_post_statahead(sai);
+	/* release resources held by statahead RPCs */
+	sa_handle_callback(sai);
 
 	spin_lock(&lli->lli_sa_lock);
 	thread_set_flags(thread, SVC_STOPPED);
@@ -1251,7 +1207,7 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
 	if (sai && thread_is_running(&sai->sai_thread)) {
 		/*
 		 * statahead thread may not quit yet because it needs to cache
-		 * stated entries, now it's time to tell it to quit.
+		 * entries, now it's time to tell it to quit.
 		 */
 		thread_set_flags(&sai->sai_thread, SVC_STOPPING);
 		wake_up(&sai->sai_thread.t_ctl_waitq);
@@ -1389,29 +1345,12 @@ out:
 	return rc;
 }
 
-static void
-ll_sai_unplug(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
-{
-	if (entry && entry->se_stat == SA_ENTRY_SUCC) {
-		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_inode);
-
-		sai->sai_hit++;
-		sai->sai_consecutive_miss = 0;
-		sai->sai_max = min(2 * sai->sai_max, sbi->ll_sa_max);
-	} else {
-		sai->sai_miss++;
-		sai->sai_consecutive_miss++;
-	}
-	ll_sa_entry_fini(sai, entry);
-	wake_up(&sai->sai_thread.t_ctl_waitq);
-}
-
 static int revalidate_statahead_dentry(struct inode *dir,
 				       struct ll_statahead_info *sai,
 				       struct dentry **dentryp,
 				       int only_unplug)
 {
-	struct ll_sa_entry *entry = NULL;
+	struct sa_entry *entry = NULL;
 	struct l_wait_info lwi = { 0 };
 	int rc = 0;
 
@@ -1442,31 +1381,31 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		}
 	}
 
-	entry = ll_sa_entry_get_byname(sai, &(*dentryp)->d_name);
+	entry = sa_get(sai, &(*dentryp)->d_name);
 	if (!entry || only_unplug) {
-		ll_sai_unplug(sai, entry);
+		sa_put(sai, entry);
 		return entry ? 1 : -EAGAIN;
 	}
 
 	/* if statahead is busy in readdir, help it do post-work */
-	if (!ll_sa_entry_stated(entry) && sai->sai_in_readpage)
-		ll_post_statahead(sai);
+	if (!sa_ready(entry) && sai->sai_in_readpage)
+		sa_handle_callback(sai);
 
-	if (!ll_sa_entry_stated(entry)) {
+	if (!sa_ready(entry)) {
 		sai->sai_index_wait = entry->se_index;
 		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
 				       LWI_ON_SIGNAL_NOOP, NULL);
 		rc = l_wait_event(sai->sai_waitq,
-				  ll_sa_entry_stated(entry) ||
+				  sa_ready(entry) ||
 				  thread_is_stopped(&sai->sai_thread),
 				  &lwi);
 		if (rc < 0) {
-			ll_sai_unplug(sai, entry);
+			sa_put(sai, entry);
 			return -EAGAIN;
 		}
 	}
 
-	if (entry->se_stat == SA_ENTRY_SUCC && entry->se_inode) {
+	if (entry->se_state == SA_ENTRY_SUCC && entry->se_inode) {
 		struct inode *inode = entry->se_inode;
 		struct lookup_intent it = { .it_op = IT_GETATTR,
 					    .it_lock_handle = entry->se_handle };
@@ -1480,7 +1419,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 
 				alias = ll_splice_alias(inode, *dentryp);
 				if (IS_ERR(alias)) {
-					ll_sai_unplug(sai, entry);
+					sa_put(sai, entry);
 					return PTR_ERR(alias);
 				}
 				*dentryp = alias;
@@ -1507,7 +1446,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		}
 	}
 out_unplug:
-	ll_sai_unplug(sai, entry);
+	sa_put(sai, entry);
 	return rc;
 }
 
-- 
1.7.1
