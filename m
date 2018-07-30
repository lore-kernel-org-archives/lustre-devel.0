From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:40 +1000
Subject: [lustre-devel] [PATCH 07/22] Revert "staging: lustre: lnet: peer:
 Use list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186088.13840.12536228855978938054.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit 3e47a1cfba5a8af7dc3c10a4705d8047abdc26c3.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/peer.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 6ce175d77d0f..7c303ef6bb34 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -176,7 +176,6 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 	struct lnet_peer_table *ptable;
 	struct list_head deathrow;
 	struct lnet_peer *lp;
-	struct lnet_peer *temp;
 	int i;
 
 	INIT_LIST_HEAD(&deathrow);
@@ -210,7 +209,8 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 		lnet_net_unlock(i);
 	}
 
-	list_for_each_entry_safe(lp, temp, &deathrow, lp_hashlist) {
+	while (!list_empty(&deathrow)) {
+		lp = list_entry(deathrow.next, struct lnet_peer, lp_hashlist);
 		list_del(&lp->lp_hashlist);
 		kfree(lp);
 	}
