From: Jeff Layton <jlayton@kernel.org>
Date: Wed,  5 Jul 2017 12:37:44 -0400
Subject: [lustre-devel] [PATCH] lustre: don't set f_version in ll_readdir
Message-ID: <20170705163744.3228-1-jlayton@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: lustre-devel@lists.lustre.org, linux-fsdevel@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

f_version is only ever used by filesystem-specific code. Generic
VFS code never uses it.

Nothing in lustre ever looks at it, so just remove this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 drivers/staging/lustre/lustre/llite/dir.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 03a72c07f57c..ab53500007bf 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -367,8 +367,6 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	}
 	ctx->pos = pos;
 	ll_finish_md_op_data(op_data);
-	filp->f_version = inode->i_version;
-
 out:
 	if (!rc)
 		ll_stats_ops_tally(sbi, LPROC_LL_READDIR, 1);
@@ -1675,7 +1673,6 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 			else
 				fd->lfd_pos = offset;
 			file->f_pos = offset;
-			file->f_version = 0;
 		}
 		ret = offset;
 	}
-- 
2.13.0
