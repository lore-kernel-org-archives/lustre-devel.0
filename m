From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 11/22] Revert "staging: lustre: lnet:
 lib-move: Use list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186104.13840.12696227873574036682.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit 24f695909440b79b04bb75205384c9772e4c7d0a.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index e8092b1b6b27..2756e91b34bb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -49,7 +49,6 @@ int
 lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 {
 	struct lnet_test_peer *tp;
-	struct lnet_test_peer *temp;
 	struct list_head *el;
 	struct list_head *next;
 	struct list_head cull;
@@ -88,7 +87,9 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 
 	lnet_net_unlock(0);
 
-	list_for_each_entry_safe(tp, temp, &cull, tp_list) {
+	while (!list_empty(&cull)) {
+		tp = list_entry(cull.next, struct lnet_test_peer, tp_list);
+
 		list_del(&tp->tp_list);
 		kfree(tp);
 	}
@@ -99,7 +100,6 @@ static int
 fail_peer(lnet_nid_t nid, int outgoing)
 {
 	struct lnet_test_peer *tp;
-	struct lnet_test_peer *temp;
 	struct list_head *el;
 	struct list_head *next;
 	struct list_head cull;
@@ -146,7 +146,8 @@ fail_peer(lnet_nid_t nid, int outgoing)
 
 	lnet_net_unlock(0);
 
-	list_for_each_entry_safe(tp, temp, &cull, tp_list) {
+	while (!list_empty(&cull)) {
+		tp = list_entry(cull.next, struct lnet_test_peer, tp_list);
 		list_del(&tp->tp_list);
 
 		kfree(tp);
