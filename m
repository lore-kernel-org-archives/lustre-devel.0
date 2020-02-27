From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:30 -0500
Subject: [lustre-devel] [PATCH 162/622] lustre: mgc: restore mgc binding for
 sptlrpc
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-163-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The work for LU-9034 mapped config logs to separate mgc devices.
This change prevented the ability to configure sptlrpc. A later
work around was introduced in LU-9567. Recently it was reported
that the work around introduced can now cause a MGC failover
panic. This patch is the proper fix in that the sptlrpc is
properly bound to an mgc device.

The sptlrpc config record expects 2 pieces of data:

  *  [0]: fs_name/target_name,
  *  [1]: rule string

What was happening is that when you set cfg_instance it was used
to create a new instance name of the form fsname-%p. For sptlrpc
it expects it to only be fsname. The solution is to test if the
config record is for sptlrpc and in that can keep the first
record field as is. With this change we can drop cfg_obdname
which only sptlrpc used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10937
Lustre-commit: ca9300e53dc2 ("LU-10937 mgc: restore mgc binding for sptlrpc")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33311
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   | 1 -
 fs/lustre/mgc/mgc_request.c     | 7 +------
 fs/lustre/obdclass/obd_config.c | 5 ++++-
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 742e92a..434bb79 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -166,7 +166,6 @@ int class_config_llog_handler(const struct lu_env *env,
 
 /* Passed as data param to class_config_parse_llog */
 struct config_llog_instance {
-	char		       *cfg_obdname;
 	void		       *cfg_instance;
 	struct super_block     *cfg_sb;
 	struct obd_uuid		cfg_uuid;
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 785461b..5bfa1b7 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -224,10 +224,8 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	/* Keep the mgc around until we are done */
 	cld->cld_mgcexp = class_export_get(obd->obd_self_export);
 
-	if (cld_is_sptlrpc(cld)) {
+	if (cld_is_sptlrpc(cld))
 		sptlrpc_conf_log_start(logname);
-		cld->cld_cfg.cfg_obdname = obd->obd_name;
-	}
 
 	spin_lock(&config_list_lock);
 	list_add(&cld->cld_list_chain, &config_llog_list);
@@ -273,9 +271,6 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 
 	lcfg.cfg_instance = sb ? (void *)sb : (void *)obd;
 
-	if (type == CONFIG_T_SPTLRPC)
-		lcfg.cfg_instance = NULL;
-
 	cld = config_log_find(logname, &lcfg);
 	if (unlikely(cld))
 		return cld;
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 550cee0..398f888 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1357,6 +1357,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		lustre_cfg_bufs_init(&bufs, lcfg);
 
 		if (clli && clli->cfg_instance &&
+		    lcfg->lcfg_command != LCFG_SPTLRPC_CONF &&
 		    LUSTRE_CFG_BUFLEN(lcfg, 0) > 0) {
 			inst_len = LUSTRE_CFG_BUFLEN(lcfg, 0) +
 				   sizeof(clli->cfg_instance) * 2 + 4;
@@ -1389,12 +1390,14 @@ int class_config_llog_handler(const struct lu_env *env,
 		 */
 		if (clli && !clli->cfg_instance &&
 		    lcfg->lcfg_command == LCFG_SPTLRPC_CONF) {
+			struct obd_device *obd = clli->cfg_instance;
+
 			lustre_cfg_bufs_set(&bufs, 2, bufs.lcfg_buf[1],
 					    bufs.lcfg_buflen[1]);
 			lustre_cfg_bufs_set(&bufs, 1, bufs.lcfg_buf[0],
 					    bufs.lcfg_buflen[0]);
 			lustre_cfg_bufs_set_string(&bufs, 0,
-						   clli->cfg_obdname);
+						   obd->obd_name);
 		}
 
 		/* Add net info to setup command
-- 
1.8.3.1
