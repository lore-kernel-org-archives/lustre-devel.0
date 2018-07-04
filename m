From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 10/11] lustre: iput() accepts NULL.
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943090.30111.16321038675119336031.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

iput(NULL) does nothing, so any code like

  if (x)
      iput(x);

can become

  iput(x);

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/dir.c       |    3 +--
 drivers/staging/lustre/lustre/llite/statahead.c |    3 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |    2 +-
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 987f4b252c40..f352fab51726 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -480,8 +480,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		err = ll_inode_init_security(&dentry, inode, parent);
 
 out_inode:
-	if (inode)
-		iput(inode);
+	iput(inode);
 out_request:
 	ptlrpc_req_finished(request);
 out_op_data:
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index d864f5f36d85..ea2a00230eaf 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -259,8 +259,7 @@ sa_kill(struct ll_statahead_info *sai, struct sa_entry *entry)
 	list_del_init(&entry->se_list);
 	spin_unlock(&lli->lli_sa_lock);
 
-	if (entry->se_inode)
-		iput(entry->se_inode);
+	iput(entry->se_inode);
 
 	sa_free(sai, entry);
 }
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 32aa664385fe..3da5a0a6db4d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2702,7 +2702,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 			 * ll_update_lsm_md
 			 */
 			if (!(lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION &&
-			      !i) && lsm->lsm_md_oinfo[i].lmo_root)
+			      !i))
 				iput(lsm->lsm_md_oinfo[i].lmo_root);
 		}
 
