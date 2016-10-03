From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:08 -0400
Subject: [lustre-devel] [PATCH 12/41] staging: lustre: clio: get rid of
	lov_stripe_md reference
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Get rid of lov_stripe_md reference in setting file's stripe info.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/12639
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 9ca933f..89a2841 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1225,37 +1225,22 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     __u64 flags, struct lov_user_md *lum,
 			     int lum_size)
 {
-	struct lov_stripe_md *lsm = NULL;
 	struct lookup_intent oit = {
 		.it_op = IT_OPEN,
 		.it_flags = flags | MDS_OPEN_BY_FID,
 	};
 	int rc = 0;
 
-	lsm = ccc_inode_lsm_get(inode);
-	if (lsm) {
-		ccc_inode_lsm_put(inode, lsm);
-		CDEBUG(D_IOCTL, "stripe already exists for inode "DFID"\n",
-		       PFID(ll_inode2fid(inode)));
-		rc = -EEXIST;
-		goto out;
-	}
-
 	ll_inode_size_lock(inode);
 	rc = ll_intent_file_open(dentry, lum, lum_size, &oit);
 	if (rc < 0)
 		goto out_unlock;
-	rc = oit.it_status;
-	if (rc < 0)
-		goto out_unlock;
 
 	ll_release_openhandle(inode, &oit);
 
 out_unlock:
 	ll_inode_size_unlock(inode);
 	ll_intent_release(&oit);
-	ccc_inode_lsm_put(inode, lsm);
-out:
 	return rc;
 }
 
-- 
1.7.1
