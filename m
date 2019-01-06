From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:46 -0500
Subject: [lustre-devel] [PATCH 13/14] lustre: sysfs: temporary work around
 for sysfs naming
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre uses the internal addressing of data structures to name
the sysfs objects. With newer kernels hashing is done on the
data structure addresses to make it harder to bypass address
space randomization. This breaks auto tuning with lustre. The
temporary work around is to use "%px" for the naming just to
make things work again. The long term solution is to move to
proper uuids for the name which is being worked on.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c     | 6 +++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c     | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 203a1f7..b258c80 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -959,7 +959,7 @@ int ll_fill_super(struct super_block *sb)
 		len -= 7;
 
 	/* Mount info */
-	snprintf(name, MAX_STRING_SIZE, "%.*s-%p", len,
+	snprintf(name, MAX_STRING_SIZE, "%.*s-%px", len,
 		 lsi->lsi_lmd->lmd_profile, sb);
 
 	/* Call ll_debugsfs_register_super() before lustre_process_log()
@@ -997,13 +997,13 @@ int ll_fill_super(struct super_block *sb)
 	CDEBUG(D_CONFIG, "Found profile %s: mdc=%s osc=%s\n", profilenm,
 	       lprof->lp_md, lprof->lp_dt);
 
-	dt = kasprintf(GFP_NOFS, "%s-%p", lprof->lp_dt, cfg->cfg_instance);
+	dt = kasprintf(GFP_NOFS, "%s-%px", lprof->lp_dt, cfg->cfg_instance);
 	if (!dt) {
 		err = -ENOMEM;
 		goto out_debugfs;
 	}
 
-	md = kasprintf(GFP_NOFS, "%s-%p", lprof->lp_md, cfg->cfg_instance);
+	md = kasprintf(GFP_NOFS, "%s-%px", lprof->lp_md, cfg->cfg_instance);
 	if (!md) {
 		err = -ENOMEM;
 		goto out_debugfs;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index a6be2ca..ca74c75 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1142,7 +1142,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	if (!inst)
 		return -ENOMEM;
 
-	pos = snprintf(inst, PAGE_SIZE, "%p", cfg->cfg_instance);
+	pos = snprintf(inst, PAGE_SIZE, "%px", cfg->cfg_instance);
 	if (pos >= PAGE_SIZE) {
 		kfree(inst);
 		return -E2BIG;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 8be8751..7d00ca4 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1323,7 +1323,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		    LUSTRE_CFG_BUFLEN(lcfg, 0) > 0) {
 			inst_len = LUSTRE_CFG_BUFLEN(lcfg, 0) +
 				   sizeof(clli->cfg_instance) * 2 + 4;
-			inst_name = kasprintf(GFP_NOFS, "%s-%p",
+			inst_name = kasprintf(GFP_NOFS, "%s-%px",
 					      lustre_cfg_string(lcfg, 0),
 					      clli->cfg_instance);
 			if (!inst_name) {
-- 
1.8.3.1
