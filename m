From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:44 -0500
Subject: [lustre-devel] [PATCH 176/622] lustre: uapi: fix warnings when
 lustre_user.h included
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-177-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Checking for lustre/lustre_user.h in a configure script
generates a warning because of the included <sys/quota.h>

  checking lustre/lustre_user.h usability... no
  checking lustre/lustre_user.h presence... yes
  WARNING: present but cannot be compiled
  WARNING: check for missing prerequisite headers?
  WARNING: see the Autoconf documentation
  WARNING: section "Present But Cannot Be Compiled"
  WARNING: proceeding with the preprocessor's result
  WARNING: in the future, the compiler will take precedence

Looking into config.log it shows:

  In file included from /usr/include/lustre/lustre_user.h:59,
                   from conftest.c:91:
  /usr/include/sys/quota.h:221: error: expected declaration
    specifiers or '...' before 'caddr_t'

Since we don't really need much from the <sys/quota.h> header,
just use the default linux UAPI quota header.

Fix an unused variable warning in ll_dir_ioctl().

Lustre-commit: db0592145574 ("LU-11783 utils: fix warnings when lustre_user.h included")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33876
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f54987a..ef4fa36 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1356,7 +1356,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lov_user_md_v1 *lumv1_ptr = &lumv1;
 		struct lov_user_md_v1 __user *lumv1p = (void __user *)arg;
 		struct lov_user_md_v3 __user *lumv3p = (void __user *)arg;
-		int lum_size;
+		int lum_size = 0;
 
 		int set_default = 0;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3bd6fc7..649aeeb 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -44,10 +44,10 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/quota.h>
 
 #ifdef __KERNEL__
 # include <linux/fs.h>
-# include <linux/quota.h>
 # include <linux/sched/signal.h>
 # include <linux/string.h> /* snprintf() */
 # include <linux/version.h>
@@ -57,7 +57,6 @@
 # include <stdbool.h>
 # include <stdio.h> /* snprintf() */
 # include <string.h>
-# include <sys/quota.h>
 # include <sys/stat.h>
 #endif /* __KERNEL__ */
 #include <uapi/linux/lustre/lustre_fiemap.h>
-- 
1.8.3.1
