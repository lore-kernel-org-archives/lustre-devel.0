From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:49 -0500
Subject: [lustre-devel] [PATCH 601/622] lustre: handle: use hlist for hash
 lists.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-602-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

hlist_head/hlist_node is the preferred data structure
for hash tables. Not only does it make the 'head' smaller,
but is also provides hlist_unhashed() which can be used to
check if an object is in the list.  This means that
we don't need h_in any more.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: 9c9ea6584cfb ("LU-12542 handle: use hlist for hash lists.")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35862
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_handles.h  |  3 +--
 fs/lustre/ldlm/ldlm_lock.c          |  2 +-
 fs/lustre/obdclass/genops.c         |  2 +-
 fs/lustre/obdclass/lustre_handles.c | 20 +++++++++-----------
 4 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 55f9a09..afdade7 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -58,7 +58,7 @@
  * to compute the start of the structure based on the handle field.
  */
 struct portals_handle {
-	struct list_head		h_link;
+	struct hlist_node		h_link;
 	u64				h_cookie;
 	const char			*h_owner;
 	refcount_t			h_ref;
@@ -66,7 +66,6 @@ struct portals_handle {
 	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
 	spinlock_t			h_lock;
-	unsigned int			h_in:1;
 };
 
 /* handles.c */
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 2c19636..396bf53 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -404,7 +404,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
 			     LDLM_NSS_LOCKS);
-	INIT_LIST_HEAD(&lock->l_handle.h_link);
+	INIT_HLIST_NODE(&lock->l_handle.h_link);
 	class_handle_hash(&lock->l_handle, lock_handle_owner);
 
 	lu_ref_init(&lock->l_reference);
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 0fbe03e..146e735 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -813,7 +813,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 	spin_lock_init(&export->exp_uncommitted_replies_lock);
 	INIT_LIST_HEAD(&export->exp_uncommitted_replies);
 	INIT_LIST_HEAD(&export->exp_req_replay_queue);
-	INIT_LIST_HEAD_RCU(&export->exp_handle.h_link);
+	INIT_HLIST_NODE(&export->exp_handle.h_link);
 	INIT_LIST_HEAD(&export->exp_hp_rpcs);
 	class_handle_hash(&export->exp_handle, export_handle_owner);
 	spin_lock_init(&export->exp_lock);
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index acee2db..0048036 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -48,7 +48,7 @@
 
 static struct handle_bucket {
 	spinlock_t		lock;
-	struct list_head	head;
+	struct hlist_head	head;
 } *handle_hash;
 
 #define HANDLE_HASH_SIZE (1 << 16)
@@ -63,7 +63,7 @@ void class_handle_hash(struct portals_handle *h, const char *owner)
 	struct handle_bucket *bucket;
 
 	LASSERT(h);
-	LASSERT(list_empty(&h->h_link));
+	LASSERT(hlist_unhashed(&h->h_link));
 
 	/*
 	 * This is fast, but simplistic cookie generation algorithm, it will
@@ -89,8 +89,7 @@ void class_handle_hash(struct portals_handle *h, const char *owner)
 
 	bucket = &handle_hash[h->h_cookie & HANDLE_HASH_MASK];
 	spin_lock(&bucket->lock);
-	list_add_rcu(&h->h_link, &bucket->head);
-	h->h_in = 1;
+	hlist_add_head_rcu(&h->h_link, &bucket->head);
 	spin_unlock(&bucket->lock);
 
 	CDEBUG(D_INFO, "added object %p with handle %#llx to hash\n",
@@ -100,7 +99,7 @@ void class_handle_hash(struct portals_handle *h, const char *owner)
 
 static void class_handle_unhash_nolock(struct portals_handle *h)
 {
-	if (list_empty(&h->h_link)) {
+	if (hlist_unhashed(&h->h_link)) {
 		CERROR("removing an already-removed handle (%#llx)\n",
 		       h->h_cookie);
 		return;
@@ -110,13 +109,12 @@ static void class_handle_unhash_nolock(struct portals_handle *h)
 	       h, h->h_cookie);
 
 	spin_lock(&h->h_lock);
-	if (h->h_in == 0) {
+	if (hlist_unhashed(&h->h_link)) {
 		spin_unlock(&h->h_lock);
 		return;
 	}
-	h->h_in = 0;
+	hlist_del_init_rcu(&h->h_link);
 	spin_unlock(&h->h_lock);
-	list_del_rcu(&h->h_link);
 }
 
 void class_handle_unhash(struct portals_handle *h)
@@ -145,7 +143,7 @@ void *class_handle2object(u64 cookie, const char *owner)
 	bucket = handle_hash + (cookie & HANDLE_HASH_MASK);
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(h, &bucket->head, h_link) {
+	hlist_for_each_entry_rcu(h, &bucket->head, h_link) {
 		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
@@ -177,7 +175,7 @@ int class_handle_init(void)
 	spin_lock_init(&handle_base_lock);
 	for (bucket = handle_hash + HANDLE_HASH_SIZE - 1; bucket >= handle_hash;
 	     bucket--) {
-		INIT_LIST_HEAD(&bucket->head);
+		INIT_HLIST_HEAD(&bucket->head);
 		spin_lock_init(&bucket->lock);
 	}
 
@@ -196,7 +194,7 @@ static int cleanup_all_handles(void)
 		struct portals_handle *h;
 
 		spin_lock(&handle_hash[i].lock);
-		list_for_each_entry_rcu(h, &handle_hash[i].head, h_link) {
+		hlist_for_each_entry_rcu(h, &handle_hash[i].head, h_link) {
 			CERROR("force clean handle %#llx addr %p owner %p\n",
 			       h->h_cookie, h, h->h_owner);
 
-- 
1.8.3.1
