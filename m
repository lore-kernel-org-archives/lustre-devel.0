From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:44 -0500
Subject: [lustre-devel] [PATCH 536/622] lnet: remove pt_number from
 lnet_peer_table.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-537-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This fields is no longer used - except for an ASSERT().
It did have a use once, but that was removed in
Commit 21602c7db4cf ("staging: lustre: Dynamic LNet
                      Configuration (DLC)")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12936
Lustre-commit: e9c9e2103a78 ("LU-12936 lnet: remove pt_number from lnet_peer_table.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36671
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 3 ---
 net/lnet/lnet/peer.c           | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 18d4e4e..51cc9ce 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -765,7 +765,6 @@ struct lnet_peer_net {
  *
  * protected by lnet_net_lock/EX for update
  *    pt_version
- *    pt_number
  *    pt_hash[...]
  *    pt_peer_list
  *    pt_peers
@@ -778,8 +777,6 @@ struct lnet_peer_net {
 struct lnet_peer_table {
 	/* /proc validity stamp */
 	int			 pt_version;
-	/* # peers extant */
-	atomic_t		 pt_number;
 	/* peers */
 	struct list_head	 pt_peer_list;
 	/* # peers */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index a067136..4f0da4b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -354,8 +354,6 @@
 
 	/* decrement the ref count on the peer table */
 	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
-	LASSERT(atomic_read(&ptable->pt_number) > 0);
-	atomic_dec(&ptable->pt_number);
 
 	/*
 	 * The peer_ni can no longer be found with a lookup. But there
@@ -1246,7 +1244,6 @@ struct lnet_peer_net *
 		ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
 		list_add_tail(&lpni->lpni_hashlist, &ptable->pt_hash[hash]);
 		ptable->pt_version++;
-		atomic_inc(&ptable->pt_number);
 		/* This is the 1st refcount on lpni. */
 		atomic_inc(&lpni->lpni_refcount);
 	}
-- 
1.8.3.1
