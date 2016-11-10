From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:52 -0500
Subject: [lustre-devel] [PATCH 22/35] staging: lustre: llite: clear dir
	stripe md in ll_iget
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If ll_iget fails during inode initialization, especially
during striped directory lookup after creation failed,
then it should clear stripe MD before make_bad_inode(),
because make_bad_inode() will reset the i_mode, which
can cause ll_clear_inode() skip freeing those stripe MD.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7230
Reviewed-on: http://review.whamcloud.com/16677
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   10 ++++++++++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f635efa..c0513bf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -785,6 +785,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 void ll_put_super(struct super_block *sb);
 void ll_kill_super(struct super_block *sb);
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock);
+void ll_dir_clear_lsm_md(struct inode *inode);
 void ll_clear_inode(struct inode *inode);
 int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import);
 int ll_setattr(struct dentry *de, struct iattr *attr);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 609db9b..dcd9240 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1058,7 +1058,7 @@ struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock)
 	return inode;
 }
 
-static void ll_dir_clear_lsm_md(struct inode *inode)
+void ll_dir_clear_lsm_md(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9ea43e1..b07079c 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -117,6 +117,14 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			rc = cl_file_inode_init(inode, md);
 
 		if (rc) {
+			/*
+			 * Let's clear directory lsm here, otherwise
+			 * make_bad_inode() will reset the inode mode
+			 * to regular, then ll_clear_inode will not
+			 * be able to clear lsm_md
+			 */
+			if (S_ISDIR(inode->i_mode))
+				ll_dir_clear_lsm_md(inode);
 			make_bad_inode(inode);
 			unlock_new_inode(inode);
 			iput(inode);
@@ -129,6 +137,8 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p): rc = %d\n",
 		       PFID(&md->body->mbo_fid1), inode, rc);
 		if (rc) {
+			if (S_ISDIR(inode->i_mode))
+				ll_dir_clear_lsm_md(inode);
 			iput(inode);
 			inode = ERR_PTR(rc);
 		}
-- 
1.7.1
