From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:40 -0400
Subject: [lustre-devel] [PATCH 141/151] lustre: handles: discard h_owner in
 favour of h_ops
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-142-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

lustre_handles assigned a 64bit unique identifier (a 'cookie') to
objects of various types and stored them in a hash table, allowing
them to be accessed by the cookie.

There is a facility for type checking by recording an 'owner' for each
object, and checking the owner on lookup. Unfortunately this is not
used - owner is always zero for the client.

Each object also contains an h_ops pointer which can be used to
reliably identify an owner.

So discard h_owner, pass and 'ops' pointer to class_handle2object(),
and only return objects for which the h_ops matches.

Note: this h_owner is now quiet different from the similar h_owner
in the server code.  When the server code is merged the "med" pointer
should be stored in the "mfd" and validated separately.

This reduces the size of the portals_handle by one pointer, which
benefits various other structures including struct ldlm_lock which can
be very populous and so is best keep small.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: 9bda0a5cad19 ("LU-12542 handles: discard h_owner in favour of h_ops")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35739
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_handles.h  | 7 +++----
 fs/lustre/ldlm/ldlm_lock.c          | 2 +-
 fs/lustre/obdclass/genops.c         | 4 +++-
 fs/lustre/obdclass/lustre_handles.c | 6 +++---
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index d4ec795..0440970 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -65,8 +65,7 @@ struct portals_handle_ops {
 struct portals_handle {
 	struct list_head		h_link;
 	u64				h_cookie;
-	const void			*h_owner;
-	struct portals_handle_ops	*h_ops;
+	const struct portals_handle_ops	*h_ops;
 
 	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
@@ -79,9 +78,9 @@ struct portals_handle {
 
 /* Add a handle to the hash table */
 void class_handle_hash(struct portals_handle *,
-		       struct portals_handle_ops *ops);
+		       const struct portals_handle_ops *ops);
 void class_handle_unhash(struct portals_handle *);
-void *class_handle2object(u64 cookie, const void *owner);
+void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops);
 void class_handle_free_cb(struct rcu_head *rcu);
 int class_handle_init(void);
 void class_handle_cleanup(void);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index f0657d9..6eebf5f 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -518,7 +518,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(handle);
 
-	lock = class_handle2object(handle->cookie, NULL);
+	lock = class_handle2object(handle->cookie, &lock_handle_ops);
 	if (!lock)
 		return NULL;
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 5c9b3c4..fc50aba 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -680,6 +680,8 @@ int obd_init_caches(void)
 	return -ENOMEM;
 }
 
+static struct portals_handle_ops export_handle_ops;
+
 /* map connection to client */
 struct obd_export *class_conn2export(struct lustre_handle *conn)
 {
@@ -696,7 +698,7 @@ struct obd_export *class_conn2export(struct lustre_handle *conn)
 	}
 
 	CDEBUG(D_INFO, "looking for export cookie %#llx\n", conn->cookie);
-	export = class_handle2object(conn->cookie, NULL);
+	export = class_handle2object(conn->cookie, &export_handle_ops);
 	return export;
 }
 EXPORT_SYMBOL(class_conn2export);
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 7c63d9c..7fa3ef6 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -59,7 +59,7 @@
  * global (per-node) hash-table.
  */
 void class_handle_hash(struct portals_handle *h,
-		       struct portals_handle_ops *ops)
+		       const struct portals_handle_ops *ops)
 {
 	struct handle_bucket *bucket;
 
@@ -132,7 +132,7 @@ void class_handle_unhash(struct portals_handle *h)
 }
 EXPORT_SYMBOL(class_handle_unhash);
 
-void *class_handle2object(u64 cookie, const void *owner)
+void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
 {
 	struct handle_bucket *bucket;
 	struct portals_handle *h;
@@ -147,7 +147,7 @@ void *class_handle2object(u64 cookie, const void *owner)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(h, &bucket->head, h_link) {
-		if (h->h_cookie != cookie || h->h_owner != owner)
+		if (h->h_cookie != cookie || h->h_ops != ops)
 			continue;
 
 		spin_lock(&h->h_lock);
-- 
1.8.3.1
