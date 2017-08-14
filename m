From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:50 -0400
Subject: [lustre-devel] [PATCH 22/64] staging: lustre: uapi: don't memory
	allocate in UAPI header
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The inline function lustre_cfg_new() calls kzalloc() but
this is a UAPI header. Remove kzalloc() and rename the
function to lustre_cfg_init(). The lustre kernel code
that was calling lustre_cfg_new() can doing the memory
allocation and pass the new buffer to lustre_cfg_init()
to fill in.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_cfg.h | 11 ++--------
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  9 +++++---
 .../staging/lustre/lustre/obdclass/obd_config.c    | 17 +++++++++++----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 24 ++++++++++++++++++----
 4 files changed, 41 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 3f280b5..9d6934b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -222,18 +222,12 @@ static inline __u32 lustre_cfg_len(__u32 bufcount, __u32 *buflens)
 
 #include "obd_support.h"
 
-static inline struct lustre_cfg *lustre_cfg_new(int cmd,
-						struct lustre_cfg_bufs *bufs)
+static inline void lustre_cfg_init(struct lustre_cfg *lcfg, int cmd,
+				   struct lustre_cfg_bufs *bufs)
 {
-	struct lustre_cfg *lcfg;
 	char *ptr;
 	int i;
 
-	lcfg = kzalloc(lustre_cfg_len(bufs->lcfg_bufcount, bufs->lcfg_buflen),
-		       GFP_NOFS);
-	if (!lcfg)
-		return ERR_PTR(-ENOMEM);
-
 	lcfg->lcfg_version = LUSTRE_CFG_VERSION;
 	lcfg->lcfg_command = cmd;
 	lcfg->lcfg_bufcount = bufs->lcfg_bufcount;
@@ -243,7 +237,6 @@ static inline struct lustre_cfg *lustre_cfg_new(int cmd,
 		lcfg->lcfg_buflens[i] = bufs->lcfg_buflen[i];
 		LOGL((char *)bufs->lcfg_buf[i], bufs->lcfg_buflen[i], ptr);
 	}
-	return lcfg;
 }
 
 static inline int lustre_cfg_sanity_check(void *buf, size_t len)
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 3674788..3bead6a 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1165,6 +1165,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		char *cname;
 		char *params;
 		char *uuid;
+		size_t len;
 
 		rc = -EINVAL;
 		if (datalen < sizeof(*entry))
@@ -1293,11 +1294,13 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		lustre_cfg_bufs_set_string(&bufs, 1, params);
 
 		rc = -ENOMEM;
-		lcfg = lustre_cfg_new(LCFG_PARAM, &bufs);
-		if (IS_ERR(lcfg)) {
-			CERROR("mgc: cannot allocate memory\n");
+		len = lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen);
+		lcfg = kzalloc(len, GFP_NOFS);
+		if (!lcfg) {
+			rc = -ENOMEM;
 			break;
 		}
+		lustre_cfg_init(lcfg, LCFG_PARAM, &bufs);
 
 		CDEBUG(D_INFO, "ir apply logs %lld/%lld for %s -> %s\n",
 		       prev_version, max_version, obdname, params);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 4b5cd7d..4c7c4f3 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1107,6 +1107,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		struct lustre_cfg_bufs bufs;
 		char *inst_name = NULL;
 		int inst_len = 0;
+		size_t lcfg_len;
 		int inst = 0, swab = 0;
 
 		lcfg = (struct lustre_cfg *)cfg_buf;
@@ -1238,8 +1239,14 @@ int class_config_llog_handler(const struct lu_env *env,
 						   clli->cfg_obdname);
 		}
 
-		lcfg_new = lustre_cfg_new(lcfg->lcfg_command, &bufs);
+		lcfg_len = lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen);
+		lcfg_new = kzalloc(lcfg_len, GFP_NOFS);
+		if (!lcfg_new) {
+			rc = -ENOMEM;
+			goto out;
+		}
 
+		lustre_cfg_init(lcfg_new, lcfg->lcfg_command, &bufs);
 		lcfg_new->lcfg_num   = lcfg->lcfg_num;
 		lcfg_new->lcfg_flags = lcfg->lcfg_flags;
 
@@ -1426,9 +1433,11 @@ int class_manual_cleanup(struct obd_device *obd)
 
 	lustre_cfg_bufs_reset(&bufs, obd->obd_name);
 	lustre_cfg_bufs_set_string(&bufs, 1, flags);
-	lcfg = lustre_cfg_new(LCFG_CLEANUP, &bufs);
-	if (IS_ERR(lcfg))
-		return PTR_ERR(lcfg);
+	lcfg = kzalloc(lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen),
+			GFP_NOFS);
+	if (!lcfg)
+		return -ENOMEM;
+	lustre_cfg_init(lcfg, LCFG_CLEANUP, &bufs);
 
 	rc = class_process_config(lcfg);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 74de1fa..5094829 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -88,10 +88,17 @@ int lustre_process_log(struct super_block *sb, char *logname,
 	lustre_cfg_bufs_set_string(bufs, 1, logname);
 	lustre_cfg_bufs_set(bufs, 2, cfg, sizeof(*cfg));
 	lustre_cfg_bufs_set(bufs, 3, &sb, sizeof(sb));
-	lcfg = lustre_cfg_new(LCFG_LOG_START, bufs);
+	lcfg = kzalloc(lustre_cfg_len(bufs->lcfg_bufcount, bufs->lcfg_buflen),
+		       GFP_NOFS);
+	if (!lcfg) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	lustre_cfg_init(lcfg, LCFG_LOG_START, bufs);
+
 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
 	kfree(lcfg);
-
+out:
 	kfree(bufs);
 
 	if (rc == -EINVAL)
@@ -126,7 +133,12 @@ int lustre_end_log(struct super_block *sb, char *logname,
 	lustre_cfg_bufs_set_string(&bufs, 1, logname);
 	if (cfg)
 		lustre_cfg_bufs_set(&bufs, 2, cfg, sizeof(*cfg));
-	lcfg = lustre_cfg_new(LCFG_LOG_END, &bufs);
+	lcfg = kzalloc(lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen),
+		       GFP_NOFS);
+	if (!lcfg)
+		return -ENOMEM;
+	lustre_cfg_init(lcfg, LCFG_LOG_END, &bufs);
+
 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
 	kfree(lcfg);
 	return rc;
@@ -158,7 +170,11 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 	if (s4)
 		lustre_cfg_bufs_set_string(&bufs, 4, s4);
 
-	lcfg = lustre_cfg_new(cmd, &bufs);
+	lcfg = kzalloc(lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen),
+		       GFP_NOFS);
+	if (!lcfg)
+		return -ENOMEM;
+	lustre_cfg_init(lcfg, cmd, &bufs);
 	lcfg->lcfg_nid = nid;
 	rc = class_process_config(lcfg);
 	kfree(lcfg);
-- 
1.8.3.1
