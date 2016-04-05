From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:37:00 -0400
Subject: [lustre-devel] [PATCH 15/18] staging: lustre: llite: cancel open
	lock before closing file
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In error handling path of ll_lease_open(), och has already been
freed in ll_close_inode_openhandle() so the sequence of cancel
open lock and close open handle need adjusting.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/7346
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 000ea58..ac17360 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -875,16 +875,19 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	return och;
 
 out_close:
-	rc2 = ll_close_inode_openhandle(sbi->ll_md_exp, inode, och, NULL);
-	if (rc2)
-		CERROR("Close openhandle returned %d\n", rc2);
-
-	/* cancel open lock */
+	/* Cancel open lock */
 	if (it.d.lustre.it_lock_mode != 0) {
 		ldlm_lock_decref_and_cancel(&och->och_lease_handle,
 					    it.d.lustre.it_lock_mode);
 		it.d.lustre.it_lock_mode = 0;
+		och->och_lease_handle.cookie = 0ULL;
 	}
+	rc2 = ll_close_inode_openhandle(sbi->ll_md_exp, inode, och, NULL);
+	if (rc2 < 0)
+		CERROR("%s: error closing file "DFID": %d\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(&ll_i2info(inode)->lli_fid), rc2);
+	och = NULL; /* och has been freed in ll_close_inode_openhandle() */
 out_release_it:
 	ll_intent_release(&it);
 out:
-- 
1.7.1
