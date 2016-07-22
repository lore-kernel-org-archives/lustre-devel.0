From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:00 -0400
Subject: [lustre-devel] [PATCH 07/58] staging: lustre: llite: label the
	debug info
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

We report the inode size but never print in the debug
message that the number reported is the size.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5b38177..4d81a64 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -615,7 +615,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	int			api32	= ll_need_32bit_api(sbi);
 	int			rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) pos %lu/%llu 32bit_api %d\n",
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) pos/size %lu/%llu 32bit_api %d\n",
 	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
 	       i_size_read(inode), api32);
 
-- 
1.7.1
