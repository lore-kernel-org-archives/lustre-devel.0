From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:40 +1000
Subject: [lustre-devel] [PATCH 09/22] Revert "staging: lustre: lnet: router:
 Use list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186096.13840.6296110306335811050.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit 37cce1bcb750ac12773f1c53afe88a8433f53eb3.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 3f84df6cb3b1..965087b7359c 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1340,7 +1340,6 @@ lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
 	int npages = rbp->rbp_npages;
 	struct list_head tmp;
 	struct lnet_rtrbuf *rb;
-	struct lnet_rtrbuf *temp;
 
 	if (!rbp->rbp_nbuffers) /* not initialized or already freed */
 		return;
@@ -1357,7 +1356,8 @@ lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
 	lnet_net_unlock(cpt);
 
 	/* Free buffers on the free list. */
-	list_for_each_entry_safe(rb, temp, &tmp, rb_list) {
+	while (!list_empty(&tmp)) {
+		rb = list_entry(tmp.next, struct lnet_rtrbuf, rb_list);
 		list_del(&rb->rb_list);
 		lnet_destroy_rtrbuf(rb, npages);
 	}
