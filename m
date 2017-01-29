From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:48 -0500
Subject: [lustre-devel] [PATCH 20/60] staging: lustre: llite: remove
	obsolete comment for ll_unlink()
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

Remove obsolete comments about the behavior of ll_unlink()

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8003
Reviewed-on: http://review.whamcloud.com/19881
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index f925656..fc17654 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -994,11 +994,6 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 	return rc;
 }
 
-/* ll_unlink() doesn't update the inode with the new link count.
- * Instead, ll_ddelete() and ll_d_iput() will update it based upon if there
- * is any lock existing. They will recycle dentries and inodes based upon locks
- * too. b=20433
- */
 static int ll_unlink(struct inode *dir, struct dentry *dchild)
 {
 	struct ptlrpc_request *request = NULL;
-- 
1.8.3.1
