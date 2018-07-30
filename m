From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:40 +1000
Subject: [lustre-devel] [PATCH 01/22] Revert "staging: lustre: lnet: api-ni:
 Use list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186042.13840.10901014935265304451.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit c997866cd27495ae28bc07596457e2bd83fb3275.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.  In this case, the first loop is
currently buggy.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index d21bceeaceda..51a81075f8d5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1077,17 +1077,18 @@ lnet_clear_zombies_nis_locked(void)
 	int i;
 	int islo;
 	struct lnet_ni *ni;
-	struct lnet_ni *temp;
 
 	/*
 	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
 	 * and shut them down in guaranteed thread context
 	 */
 	i = 2;
-	list_for_each_entry_safe(ni, temp, &the_lnet.ln_nis_zombie, ni_list) {
+	while (!list_empty(&the_lnet.ln_nis_zombie)) {
 		int *ref;
 		int j;
 
+		ni = list_entry(the_lnet.ln_nis_zombie.next,
+				struct lnet_ni, ni_list);
 		list_del_init(&ni->ni_list);
 		cfs_percpt_for_each(ref, j, ni->ni_refs) {
 			if (!*ref)
@@ -1137,7 +1138,6 @@ static void
 lnet_shutdown_lndnis(void)
 {
 	struct lnet_ni *ni;
-	struct lnet_ni *temp;
 	int i;
 
 	/* NB called holding the global mutex */
@@ -1151,7 +1151,9 @@ lnet_shutdown_lndnis(void)
 	the_lnet.ln_shutdown = 1;	/* flag shutdown */
 
 	/* Unlink NIs from the global table */
-	list_for_each_entry_safe(ni, temp, &the_lnet.ln_nis, ni_list) {
+	while (!list_empty(&the_lnet.ln_nis)) {
+		ni = list_entry(the_lnet.ln_nis.next,
+				struct lnet_ni, ni_list);
 		lnet_ni_unlink_locked(ni);
 	}
 
