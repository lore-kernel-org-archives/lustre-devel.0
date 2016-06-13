From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 13 Jun 2016 22:44:57 +0200
Subject: [lustre-devel] [PATCH] lustre: hide call to Posix ACL in ifdef
Message-ID: <1465850722-3534417-1-git-send-email-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Mike Rapoport <mike.rapoport@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

A call to forget_cached_acl() was recently added to the lustre file
system, but this is only available when CONFIG_FS_POSIX_ACL is
enabled, otherwise the build now fails with:

lustre/llite/file.c: In function 'll_get_acl':
lustre/llite/file.c:3134:2: error: implicit declaration of function 'forget_cached_acl' [-Werror=implicit-function-declaration]
  forget_cached_acl(inode, type);

This adds one more #ifdef for this call, corresponding to the
other 22 such checks for ACL in lustre.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b788dc51e425 ("staging: lustre: llite: drop acl from cache")
---
 drivers/staging/lustre/lustre/llite/file.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index bafa0b701e87..26c6cd60ae1d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3131,7 +3131,9 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 	spin_lock(&lli->lli_lock);
 	/* VFS' acl_permission_check->check_acl will release the refcount */
 	acl = posix_acl_dup(lli->lli_posix_acl);
+#ifdef CONFIG_FS_POSIX_ACL
 	forget_cached_acl(inode, type);
+#endif
 	spin_unlock(&lli->lli_lock);
 
 	return acl;
-- 
2.7.0
