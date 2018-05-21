From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 14/30] staging: lustre: clean up __LIBCFS_H
 macro
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731286.24196.3320470277753492185.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

There is some confusion with names here - make it all uniform.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 63ea0e99ec58..ab77cf83af0f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -103,8 +103,6 @@ static inline int notifier_from_ioctl_errno(int err)
 
 int libcfs_setup(void);
 
-#define _LIBCFS_H
-
 /**
  * The path of debug log dump upcall script.
  */
@@ -124,4 +122,4 @@ int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 int (*handler)(void *data, int write, loff_t pos,
 					void __user *buffer, int len));
 
-#endif /* _LIBCFS_H */
+#endif /* __LIBCFS_LIBCFS_H__ */
