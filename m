From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:07 +1100
Subject: [lustre-devel] [PATCH 35/37] lustre: portals_handle: discard h_lock.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494690.24125.10261783071575748633.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The h_lock spinlock is now only taken while bucket->lock
is held.  As a handle is associated with precisely one bucket,
this means that h_lock can never be contended, so it isn't needed.

So discard h_lock.

Also discard and increasingly irrelevant comment in the declaration
of struct portals_handle.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_handles.h |    3 ---
 .../lustre/lustre/obdclass/lustre_handles.c        |    7 -------
 2 files changed, 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 17aee8ea63ac..d07b0a498bff 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -62,10 +62,7 @@ struct portals_handle {
 	u64				h_cookie;
 	void				*h_owner;
 	refcount_t			h_ref;
-
-	/* newly added fields to handle the RCU issue. -jxiong */
 	struct rcu_head			h_rcu;
-	spinlock_t			h_lock;
 };
 
 /* handles.c */
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 78c1ca52fc77..88a65a19785c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -85,7 +85,6 @@ void class_handle_hash(struct portals_handle *h, void *owner)
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
