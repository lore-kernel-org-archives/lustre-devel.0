From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:40 -0400
Subject: [lustre-devel] [PATCH 041/124] staging: lustre: llite: don't call
	make_bad_inode() on an old inode
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In ll_iget() if ll_update_inode() fails then do not call
make_bad_inode() on the inode since it may still be in use.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5468
Reviewed-on: http://review.whamcloud.com/11609
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index e2dc920..85f8ce7 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -132,7 +132,6 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p): rc = %d\n",
 		       PFID(&md->body->mbo_fid1), inode, rc);
 		if (rc) {
-			make_bad_inode(inode);
 			iput(inode);
 			inode = ERR_PTR(rc);
 		}
-- 
1.7.1
