From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:32 -0500
Subject: [lustre-devel] [PATCH 584/622] lustre: uapi: LU-12521 llapi: add
 separate fsname and instance API
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-585-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

For Lustre the kernel internal cfg instance is represented by a
16 numeric value very similar but not an UUID. This value is
exposed to user land since this value is used to generate the
sysfs directory tree to represent virtual devices. Expose this
fixed value for kernel and user land use.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12521
Lustre-commit: 00d14521ca1c ("LU-12521 llapi: add separate fsname and instance API")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35451
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_config.c         | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 97cb8c1..0ccdf5f 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1374,7 +1374,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		    lcfg->lcfg_command != LCFG_SPTLRPC_CONF &&
 		    LUSTRE_CFG_BUFLEN(lcfg, 0) > 0) {
 			inst_len = LUSTRE_CFG_BUFLEN(lcfg, 0) +
-				   sizeof(clli->cfg_instance) * 2 + 4;
+				   LUSTRE_MAXINSTANCE + 4;
 			inst_name = kasprintf(GFP_NOFS, "%s-%px",
 					      lustre_cfg_string(lcfg, 0),
 					      clli->cfg_instance);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 1c36114..08589e6 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -829,6 +829,7 @@ static inline char *obd_uuid2str(const struct obd_uuid *uuid)
 }
 
 #define LUSTRE_MAXFSNAME 8
+#define LUSTRE_MAXINSTANCE 16
 
 /* Extract fsname from uuid (or target name) of a target
  * e.g. (myfs-OST0007_UUID -> myfs)
-- 
1.8.3.1
