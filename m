From: James Simmons <jsimmons@infradead.org>
Date: Tue, 23 Feb 2016 11:48:26 -0500
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move module info to end
	of libcfs module.c file
In-Reply-To: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
References: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456246111-26263-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Move the MODULE_* field in module.c that belongs to libcfs to the
end of the file like it is done for other kernel drivers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/module.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 05e2c56..de6688e 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -66,10 +66,6 @@
 #include "../../include/linux/lnet/lnet.h"
 #include "tracefile.h"
 
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Portals v3.1");
-MODULE_LICENSE("GPL");
-
 static struct dentry *lnet_debugfs_root;
 
 /* called when opening /dev/device */
@@ -668,7 +664,10 @@ static void exit_libcfs_module(void)
 		pr_err("LustreError: libcfs_debug_cleanup: %d\n", rc);
 }
 
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
+MODULE_DESCRIPTION("Portals v3.1");
 MODULE_VERSION("1.0.0");
+MODULE_LICENSE("GPL");
 
 module_init(init_libcfs_module);
 module_exit(exit_libcfs_module);
-- 
1.7.1
