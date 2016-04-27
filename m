From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:54 -0400
Subject: [lustre-devel] [PATCH 02/15] staging: lustre: llite: NFS reexport
	issue
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Suppress erroneous/confusing messages when NFS
is out of sync and requests old data.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4050
Reviewed-on: http://review.whamcloud.com/7850
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_nfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 193aab8..2c26815 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -119,7 +119,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	kfree(op_data);
 	if (rc) {
-		CERROR("can't get object attrs, fid "DFID", rc %d\n",
+		CDEBUG(D_INFO, "can't get object attrs, fid "DFID", rc %d\n",
 		       PFID(fid), rc);
 		return ERR_PTR(rc);
 	}
-- 
1.7.1
