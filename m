From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 19/22] lustre: fld_request: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186139.13840.14587588638167610162.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These loops are removing all elements from a list.
So using while(!list_empty()) makes the intent clearer.


Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fld/fld_request.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 97f7ea632346..7b0365b3e413 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -280,10 +280,12 @@ EXPORT_SYMBOL(fld_client_init);
 
 void fld_client_fini(struct lu_client_fld *fld)
 {
-	struct lu_fld_target *target, *tmp;
+	struct lu_fld_target *target;
 
 	spin_lock(&fld->lcf_lock);
-	list_for_each_entry_safe(target, tmp, &fld->lcf_targets, ft_chain) {
+	while (!list_empty(&fld->lcf_targets)) {
+		target = list_first_entry(&fld->lcf_targets,
+					  struct lu_fld_target, ft_chain);
 		fld->lcf_count--;
 		list_del(&target->ft_chain);
 		if (target->ft_exp)
