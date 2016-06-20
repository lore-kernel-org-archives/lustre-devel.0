From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:19 -0400
Subject: [lustre-devel] [PATCH 04/28] staging/lustre/llite: lock i_lock
	before __d_drop()
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bruno Faccini <bruno.faccini@intel.com>

There has been several Lustre Client crashes reported by sites
running with Lustre versions 2.1/2.5, all showing the same
dentry->d_hash->next corrupted pointer cause.

This patch fixes a regression that has been introduced since a
long time by commit :
(LU-506 kernel: FC15 - support dcache scalability changes.)

where i_lock protection usage has been removed and
that is likely to cause racy condition during dentry [un]hashing
and to be the root cause of these crashes.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: http://review.whamcloud.com/19287
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7973
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index b0c4548..5436a54 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2975,8 +2975,11 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		 * here to preserve get_cwd functionality on 2.6.
 		 * Bug 10503
 		 */
-		if (!d_inode(dentry)->i_nlink)
+		if (!d_inode(dentry)->i_nlink) {
+			spin_lock(&inode->i_lock);
 			d_lustre_invalidate(dentry, 0);
+			spin_unlock(&inode->i_lock);
+		}
 
 		ll_lookup_finish_locks(&oit, inode);
 	} else if (!ll_have_md_lock(d_inode(dentry), &ibits, LCK_MINMODE)) {
-- 
2.7.4
