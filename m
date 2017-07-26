From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:33 -0400
Subject: [lustre-devel] [PATCH 17/20] staging: lustre: llite: allow cached
	acls
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Move the freeing of all cached acls from ll_get_acl() to the
function ll_clear_inode(). This way we free all cached acls
for the inode just before clearing it. This allow us to take
advantage of cached acls and correctly free them before free.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-on: https://review.whamcloud.com/25965
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c      | 3 ---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 1 +
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ab1c85c..215479a 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3035,9 +3035,6 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 	spin_lock(&lli->lli_lock);
 	/* VFS' acl_permission_check->check_acl will release the refcount */
 	acl = posix_acl_dup(lli->lli_posix_acl);
-#ifdef CONFIG_FS_POSIX_ACL
-	forget_cached_acl(inode, type);
-#endif
 	spin_unlock(&lli->lli_lock);
 
 	return acl;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ba7d3b9..5c8405c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1316,6 +1316,7 @@ void ll_clear_inode(struct inode *inode)
 	ll_xattr_cache_destroy(inode);
 
 #ifdef CONFIG_FS_POSIX_ACL
+	forget_all_cached_acls(inode);
 	if (lli->lli_posix_acl) {
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
-- 
1.8.3.1
