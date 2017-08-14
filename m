From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:52 -0400
Subject: [lustre-devel] [PATCH 24/64] staging: lustre: obdclass: no need to
	check for kfree
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

In class_config_llog_handler() a flag, inst, was used to
determine if it was safe to call kfree. Its not needed so
remove the flag.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index dc7b27e..32ffa25 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1142,7 +1142,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		char *inst_name = NULL;
 		int inst_len = 0;
 		size_t lcfg_len;
-		int inst = 0, swab = 0;
+		int swab = 0;
 
 		lcfg = (struct lustre_cfg *)cfg_buf;
 		if (lcfg->lcfg_version == __swab32(LUSTRE_CFG_VERSION)) {
@@ -1233,7 +1233,6 @@ int class_config_llog_handler(const struct lu_env *env,
 
 		if (clli && clli->cfg_instance &&
 		    LUSTRE_CFG_BUFLEN(lcfg, 0) > 0) {
-			inst = 1;
 			inst_len = LUSTRE_CFG_BUFLEN(lcfg, 0) +
 				   sizeof(clli->cfg_instance) * 2 + 4;
 			inst_name = kasprintf(GFP_NOFS, "%s-%p",
@@ -1304,9 +1303,7 @@ int class_config_llog_handler(const struct lu_env *env,
 
 		rc = class_process_config(lcfg_new);
 		kfree(lcfg_new);
-
-		if (inst)
-			kfree(inst_name);
+		kfree(inst_name);
 		break;
 	}
 	default:
-- 
1.8.3.1
