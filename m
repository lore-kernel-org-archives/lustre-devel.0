From: James Simmons <jsimmons@infradead.org>
Date: Sat, 11 Feb 2017 12:12:38 -0500
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: llite: root inode
	checking for migration
In-Reply-To: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
References: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1486833159-16251-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Do not migrate root inode.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7577
Reviewed-on: http://review.whamcloud.com/17669
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 0c83bd7..271608d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2626,18 +2626,18 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		       ll_get_fsname(parent->i_sb, NULL, 0), name,
 		       PFID(&op_data->op_fid3));
 		rc = -EINVAL;
-		goto out_free;
+		goto out_unlock;
 	}
 
 	rc = ll_get_mdt_idx_by_fid(ll_i2sbi(parent), &op_data->op_fid3);
 	if (rc < 0)
-		goto out_free;
+		goto out_unlock;
 
 	if (rc == mdtidx) {
 		CDEBUG(D_INFO, "%s:"DFID" is already on MDT%d.\n", name,
 		       PFID(&op_data->op_fid3), mdtidx);
 		rc = 0;
-		goto out_free;
+		goto out_unlock;
 	}
 again:
 	if (S_ISREG(child_inode->i_mode)) {
@@ -2645,13 +2645,13 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		if (IS_ERR(och)) {
 			rc = PTR_ERR(och);
 			och = NULL;
-			goto out_free;
+			goto out_unlock;
 		}
 
 		rc = ll_data_version(child_inode, &data_version,
 				     LL_DV_WR_FLUSH);
 		if (rc)
-			goto out_free;
+			goto out_close;
 
 		op_data->op_handle = och->och_fh;
 		op_data->op_data = och->och_mod;
@@ -2671,12 +2671,12 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 		if (!body) {
 			rc = -EPROTO;
-			goto out_free;
+			goto out_close;
 		}
 
 		/*
 		 * If the server does release layout lock, then we cleanup
-		 * the client och here, otherwise release it in out_free:
+		 * the client och here, otherwise release it in out_close:
 		 */
 		if (och && body->mbo_valid & OBD_MD_CLOSE_INTENT_EXECED) {
 			obd_mod_put(och->och_mod);
@@ -2694,15 +2694,15 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		request = NULL;
 		goto again;
 	}
-out_free:
-	if (child_inode) {
-		if (och) /* close the file */
-			ll_lease_close(och, child_inode, NULL);
+out_close:
+	if (och) /* close the file */
+		ll_lease_close(och, child_inode, NULL);
+	if (!rc)
 		clear_nlink(child_inode);
-		inode_unlock(child_inode);
-		iput(child_inode);
-	}
-
+out_unlock:
+	inode_unlock(child_inode);
+	iput(child_inode);
+out_free:
 	ll_finish_md_op_data(op_data);
 	return rc;
 }
-- 
1.8.3.1
