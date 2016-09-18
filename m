From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:50 -0400
Subject: [lustre-devel] [PATCH 111/124] staging: lustre: llite: lock the
	inode to be migrated
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-112-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Because the inode and its connected dentries will be cleared
out of the cache after migration, the inode needs to be locked
during the migration.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4712
Reviewed-on: http://review.whamcloud.com/9689
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index d8761b8..5d4d17f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2802,11 +2802,15 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	qstr.name = name;
 	qstr.len = namelen;
 	dchild = d_lookup(file_dentry(file), &qstr);
-	if (dchild && dchild->d_inode) {
+	if (dchild) {
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 		if (dchild->d_inode) {
 			child_inode = igrab(dchild->d_inode);
-			ll_invalidate_aliases(child_inode);
+			if (child_inode) {
+				inode_lock(child_inode);
+				op_data->op_fid3 = *ll_inode2fid(child_inode);
+				ll_invalidate_aliases(child_inode);
+			}
 		}
 		dput(dchild);
 	} else {
@@ -2847,6 +2851,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 out_free:
 	if (child_inode) {
 		clear_nlink(child_inode);
+		inode_unlock(child_inode);
 		iput(child_inode);
 	}
 
-- 
1.7.1
