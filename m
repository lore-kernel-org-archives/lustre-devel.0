From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:36 -0400
Subject: [lustre-devel] [PATCH 02/29] staging: lustre: llite: remove
	IS_ERR(master_inode) check
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The kernel function ilookup5_nowait never returns
IS_ERR so we can remove the IS_ERR check in the
ll_md_blocking_ast() function.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8697
Reviewed-on: http://review.whamcloud.com/23151
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a69c8af..9b4095f 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -283,7 +283,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				master_inode = ilookup5(inode->i_sb, hash,
 							ll_test_inode_by_fid,
 							(void *)&lli->lli_pfid);
-				if (master_inode && !IS_ERR(master_inode)) {
+				if (master_inode) {
 					ll_invalidate_negative_children(master_inode);
 					iput(master_inode);
 				}
-- 
1.7.1
