From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:15 -0400
Subject: [lustre-devel] [PATCH 21/64 v2] staging: lustre: uapi: remove
	lustre_cfg_free wrapper
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Replace all lustre_cfg_free() calls with direct kfree()
call.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_cfg.h  | 6 ------
 drivers/staging/lustre/lustre/mgc/mgc_request.c     | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 4 ++--
 drivers/staging/lustre/lustre/obdclass/obd_mount.c  | 6 +++---
 4 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 8eb394e..3f280b5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -246,12 +246,6 @@ static inline struct lustre_cfg *lustre_cfg_new(int cmd,
 	return lcfg;
 }
 
-static inline void lustre_cfg_free(struct lustre_cfg *lcfg)
-{
-	kfree(lcfg);
-	return;
-}
-
 static inline int lustre_cfg_sanity_check(void *buf, size_t len)
 {
 	struct lustre_cfg *lcfg = (struct lustre_cfg *)buf;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 36c3049..192b24d 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1293,7 +1293,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		       prev_version, max_version, obdname, params);
 
 		rc = class_process_config(lcfg);
-		lustre_cfg_free(lcfg);
+		kfree(lcfg);
 		if (rc)
 			CDEBUG(D_INFO, "process config for %s error %d\n",
 			       obdname, rc);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 783f9e0..4b5cd7d 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1262,7 +1262,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		lcfg_new->lcfg_nal = 0; /* illegal value for obsolete field */
 
 		rc = class_process_config(lcfg_new);
-		lustre_cfg_free(lcfg_new);
+		kfree(lcfg_new);
 
 		if (inst)
 			kfree(inst_name);
@@ -1442,7 +1442,7 @@ int class_manual_cleanup(struct obd_device *obd)
 	if (rc)
 		CERROR("detach failed %d: %s\n", rc, obd->obd_name);
 out:
-	lustre_cfg_free(lcfg);
+	kfree(lcfg);
 	return rc;
 }
 EXPORT_SYMBOL(class_manual_cleanup);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 555e67e..74de1fa 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -90,7 +90,7 @@ int lustre_process_log(struct super_block *sb, char *logname,
 	lustre_cfg_bufs_set(bufs, 3, &sb, sizeof(sb));
 	lcfg = lustre_cfg_new(LCFG_LOG_START, bufs);
 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
-	lustre_cfg_free(lcfg);
+	kfree(lcfg);
 
 	kfree(bufs);
 
@@ -128,7 +128,7 @@ int lustre_end_log(struct super_block *sb, char *logname,
 		lustre_cfg_bufs_set(&bufs, 2, cfg, sizeof(*cfg));
 	lcfg = lustre_cfg_new(LCFG_LOG_END, &bufs);
 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
-	lustre_cfg_free(lcfg);
+	kfree(lcfg);
 	return rc;
 }
 EXPORT_SYMBOL(lustre_end_log);
@@ -161,7 +161,7 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 	lcfg = lustre_cfg_new(cmd, &bufs);
 	lcfg->lcfg_nid = nid;
 	rc = class_process_config(lcfg);
-	lustre_cfg_free(lcfg);
+	kfree(lcfg);
 	return rc;
 }
 
-- 
1.8.3.1
