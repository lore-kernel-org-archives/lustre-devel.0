From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:38 -0400
Subject: [lustre-devel] [PATCH 099/124] staging: lustre: llite: unlock inode
	size in ll_lov_setstripe_ea_info()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-100-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In ll_lov_setstripe_ea_info() release the inode size lock on all
appropriate exit paths.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6059
Reviewed-on: http://review.whamcloud.com/13167
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 2cb0b65..ce96c9f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1301,7 +1301,10 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     int lum_size)
 {
 	struct lov_stripe_md *lsm = NULL;
-	struct lookup_intent oit = {.it_op = IT_OPEN, .it_flags = flags};
+	struct lookup_intent oit = {
+		.it_op = IT_OPEN,
+		.it_flags = flags | MDS_OPEN_BY_FID,
+	};
 	int rc = 0;
 
 	lsm = ccc_inode_lsm_get(inode);
@@ -1314,13 +1317,12 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	}
 
 	ll_inode_size_lock(inode);
-	oit.it_flags |= MDS_OPEN_BY_FID;
 	rc = ll_intent_file_open(dentry, lum, lum_size, &oit);
-	if (rc)
+	if (rc < 0)
 		goto out_unlock;
 	rc = oit.it_status;
 	if (rc < 0)
-		goto out_req_free;
+		goto out_unlock;
 
 	ll_release_openhandle(inode, &oit);
 
@@ -1330,9 +1332,6 @@ out_unlock:
 	ccc_inode_lsm_put(inode, lsm);
 out:
 	return rc;
-out_req_free:
-	ptlrpc_req_finished((struct ptlrpc_request *)oit.it_request);
-	goto out;
 }
 
 int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
-- 
1.7.1
