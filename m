From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 12 Apr 2017 11:31:53 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: checking for NULL instead
	if IS_ERR
Message-ID: <20170412083153.GA3250@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lustre_cfg_new() returns error pointers and never NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 8fce88f69039..6a7e7a7d2af1 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1427,8 +1427,8 @@ int class_manual_cleanup(struct obd_device *obd)
 	lustre_cfg_bufs_reset(&bufs, obd->obd_name);
 	lustre_cfg_bufs_set_string(&bufs, 1, flags);
 	lcfg = lustre_cfg_new(LCFG_CLEANUP, &bufs);
-	if (!lcfg)
-		return -ENOMEM;
+	if (IS_ERR(lcfg))
+		return PTR_ERR(lcfg);
 
 	rc = class_process_config(lcfg);
 	if (rc) {
