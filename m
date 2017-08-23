From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 23 Aug 2017 09:51:31 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: obd: check for allocation
	failure
Message-ID: <20170823064917.afedqlponb5qu6og@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lustre_cfg_new() can fail with ERR_PTR(-ENOMEM) so we should check for
that.

Fixes: d7e09d0397e8 ("staging: add Lustre file system client support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 8e0d4b1d86dc..7cb99f11caa0 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -159,6 +159,8 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 		lustre_cfg_bufs_set_string(&bufs, 4, s4);
 
 	lcfg = lustre_cfg_new(cmd, &bufs);
+	if (IS_ERR(lcfg))
+		return PTR_ERR(lcfg);
 	lcfg->lcfg_nid = nid;
 	rc = class_process_config(lcfg);
 	lustre_cfg_free(lcfg);
