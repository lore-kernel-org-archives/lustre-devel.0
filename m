From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:57 -0500
Subject: [lustre-devel] [PATCH 369/622] lnet: Change static defines to use
 macro for module.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-370-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch replaces mutex which are defined statically
in file net/lnet/lnet/module.c with kernel provided macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9010
Lustre-commit: bb967468875f ("LU-9010 lnet: Change static defines to use macro for module.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33932
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/module.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 95e1bae..5905f38 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -40,7 +40,7 @@
 module_param(config_on_load, int, 0444);
 MODULE_PARM_DESC(config_on_load, "configure network at module load");
 
-static struct mutex lnet_config_mutex;
+static DEFINE_MUTEX(lnet_config_mutex);
 
 static int
 lnet_configure(void *arg)
@@ -235,8 +235,6 @@ static int __init lnet_init(void)
 {
 	int rc;
 
-	mutex_init(&lnet_config_mutex);
-
 	rc = libcfs_setup();
 	if (rc)
 		return rc;
-- 
1.8.3.1
