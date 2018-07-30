From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:40 +1000
Subject: [lustre-devel] [PATCH 03/22] Revert "staging: lustre: lnet:
 o2iblnd: Use list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186073.13840.10228341482615967034.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit 995ae68c30a5d4947f7685f29b1e69b436ddcdb3.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a5ef4cc6c04f..9cf1f64e3d76 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3185,7 +3185,6 @@ kiblnd_check_conns(int idx)
 	struct list_head *ptmp;
 	struct kib_peer *peer;
 	struct kib_conn *conn;
-	struct kib_conn *temp;
 	struct kib_conn *tmp;
 	struct list_head *ctmp;
 	unsigned long flags;
@@ -3253,7 +3252,8 @@ kiblnd_check_conns(int idx)
 	 * NOOP, but there were no non-blocking tx descs
 	 * free to do it last time...
 	 */
-	list_for_each_entry_safe(conn, temp, &checksends, ibc_connd_list) {
+	while (!list_empty(&checksends)) {
+		conn = list_entry(checksends.next, struct kib_conn, ibc_connd_list);
 		list_del(&conn->ibc_connd_list);
 
 		spin_lock(&conn->ibc_lock);
