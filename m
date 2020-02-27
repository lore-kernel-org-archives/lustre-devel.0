From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:08 -0500
Subject: [lustre-devel] [PATCH 620/622] lustre: handle: discard h_lock.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-621-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The h_lock spinlock is now only taken while bucket->lock
is held.  As a handle is associated with precisely one bucket,
this means that h_lock can never be contended, so it isn't needed.

So discard h_lock.

Also discard an increasingly irrelevant comment in the declaration
of struct portals_handle.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: 6acafe7ac4ef ("LU-12542 handle: discard h_lock.")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35863
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_handles.h  | 3 ---
 fs/lustre/obdclass/lustre_handles.c | 7 -------
 2 files changed, 10 deletions(-)

diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index afdade7..9dbe7c9 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -62,10 +62,7 @@ struct portals_handle {
 	u64				h_cookie;
 	const char			*h_owner;
 	refcount_t			h_ref;
-
-	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
-	spinlock_t			h_lock;
 };
 
 /* handles.c */
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 0048036..7ecd15ad3 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -85,7 +85,6 @@ void class_handle_hash(struct portals_handle *h, const char *owner)
 	spin_unlock(&handle_base_lock);
 
 	h->h_owner = owner;
-	spin_lock_init(&h->h_lock);
 
 	bucket = &handle_hash[h->h_cookie & HANDLE_HASH_MASK];
 	spin_lock(&bucket->lock);
@@ -108,13 +107,7 @@ static void class_handle_unhash_nolock(struct portals_handle *h)
 	CDEBUG(D_INFO, "removing object %p with handle %#llx from hash\n",
 	       h, h->h_cookie);
 
-	spin_lock(&h->h_lock);
-	if (hlist_unhashed(&h->h_link)) {
-		spin_unlock(&h->h_lock);
-		return;
-	}
 	hlist_del_init_rcu(&h->h_link);
-	spin_unlock(&h->h_lock);
 }
 
 void class_handle_unhash(struct portals_handle *h)
-- 
1.8.3.1
