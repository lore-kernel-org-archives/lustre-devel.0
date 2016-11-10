From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:51 -0500
Subject: [lustre-devel] [PATCH 21/35] staging: lustre: statahead: lock leaks
	if statahead file recreated
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

During statahead file may be recreated, though this is rare case,
current code will leak the lock, this patch will release lock in
this case.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7232
Reviewed-on: http://review.whamcloud.com/16841
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 0677513..b43955f 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1475,6 +1475,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 
 				alias = ll_splice_alias(inode, *dentryp);
 				if (IS_ERR(alias)) {
+					ll_intent_release(&it);
 					rc = PTR_ERR(alias);
 					goto out_unplug;
 				}
@@ -1493,6 +1494,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 				       *dentryp,
 				       PFID(ll_inode2fid((*dentryp)->d_inode)),
 				       PFID(ll_inode2fid(inode)));
+				ll_intent_release(&it);
 				rc = -ESTALE;
 				goto out_unplug;
 			}
-- 
1.7.1
