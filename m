From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:08 -0400
Subject: [lustre-devel] [PATCH 15/58] staging: lustre: llite: clarify some
	debug messages for statahead
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Make some of the error reporting more clear for the statahead
thread startup and is_first_dirent() function.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 7a7b11c..fc24a65 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1073,9 +1073,9 @@ static int ll_statahead_thread(void *arg)
 
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
-			CDEBUG(D_READA, "error reading dir "DFID" at %llu/%llu: [rc %d] [parent %u]\n",
+			CDEBUG(D_READA, "error reading dir "DFID" at %llu/%llu: opendir_pid = %u: rc = %d\n",
 			       PFID(ll_inode2fid(dir)), pos, sai->sai_index,
-			       rc, plli->lli_opendir_pid);
+			       plli->lli_opendir_pid, rc);
 			goto out;
 		}
 
@@ -1362,9 +1362,10 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			struct ll_inode_info *lli = ll_i2info(dir);
 
 			rc = PTR_ERR(page);
-			CERROR("error reading dir "DFID" at %llu: [rc %d] [parent %u]\n",
+			CERROR("%s: error reading dir "DFID" at %llu: opendir_pid = %u : rc = %d\n",
+			       ll_get_fsname(dir->i_sb, NULL, 0),
 			       PFID(ll_inode2fid(dir)), pos,
-			       rc, lli->lli_opendir_pid);
+			       lli->lli_opendir_pid, rc);
 			break;
 		}
 
-- 
1.7.1
