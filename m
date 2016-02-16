From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:39 -0500
Subject: [lustre-devel] [PATCH 07/45] staging/lustre: Remove unused
	osc_on_mdt function
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This only makes sense on metadata server, so get rid of it.

Also remove now unused MDS_OSC_MAX_RIF_DEFAULT define

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h   |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c | 28 +--------------------------
 2 files changed, 1 insertion(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 991d2c6..c64a499 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -216,7 +216,6 @@ struct timeout_item {
 };
 
 #define OSC_MAX_RIF_DEFAULT       8
-#define MDS_OSC_MAX_RIF_DEFAULT   50
 #define OSC_MAX_RIF_MAX	 256
 #define OSC_MAX_DIRTY_DEFAULT  (OSC_MAX_RIF_DEFAULT * 4)
 #define OSC_MAX_DIRTY_MB_MAX   2048     /* arbitrary, but < MAX_LONG bytes */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 3c8d441..b52ffc0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -227,29 +227,6 @@ void client_destroy_import(struct obd_import *imp)
 }
 EXPORT_SYMBOL(client_destroy_import);
 
-/**
- * Check whether or not the OSC is on MDT.
- * In the config log,
- * osc on MDT
- *	setup 0:{fsname}-OSTxxxx-osc[-MDTxxxx] 1:lustre-OST0000_UUID 2:NID
- * osc on client
- *	setup 0:{fsname}-OSTxxxx-osc 1:lustre-OST0000_UUID 2:NID
- *
- **/
-static int osc_on_mdt(char *obdname)
-{
-	char *ptr;
-
-	ptr = strrchr(obdname, '-');
-	if (ptr == NULL)
-		return 0;
-
-	if (strncmp(ptr + 1, "MDT", 3) == 0)
-		return 1;
-
-	return 0;
-}
-
 /* Configure an RPC client OBD device.
  *
  * lcfg parameters:
@@ -400,10 +377,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 512 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 4;
 	} else {
-		if (osc_on_mdt(obddev->obd_name))
-			cli->cl_max_rpcs_in_flight = MDS_OSC_MAX_RIF_DEFAULT;
-		else
-			cli->cl_max_rpcs_in_flight = OSC_MAX_RIF_DEFAULT;
+		cli->cl_max_rpcs_in_flight = OSC_MAX_RIF_DEFAULT;
 	}
 	rc = ldlm_get_ref();
 	if (rc) {
-- 
2.1.0
