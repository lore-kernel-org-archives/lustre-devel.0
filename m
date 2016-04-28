From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:36 -0400
Subject: [lustre-devel] [PATCH 6/8] staging: lustre: obd: add case
	LCFG_PARAM to osd_process_config
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Emoly Liu <emoly.liu@intel.com>

Some proc parameters were moved from ofd to osd module and only
their symlinks were kept in ofd for interoperability/compatibility.
To process this kind of config params passed by ofd, this patch is
to do the following fixes:

 - since these parameters are not included by the static lprocfs var
   list, a pre-check is added for them to avoid "unknown param" error
   message confuses the uses. If they are matched in this check, they
   will be passed to the osd directly.
 - improve the error messages in class_process_proc_param() and
   class_process_proc_seq_param() a little.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4221
Reviewed-on: http://review.whamcloud.com/8238
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_param.h |  1 +
 drivers/staging/lustre/lustre/obdclass/obd_config.c  | 20 +++++++++++---------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index 383fe6f..a42cf90 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -89,6 +89,7 @@ int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh);
 
 /* Prefixes for parameters handled by obd's proc methods (XXX_process_config) */
 #define PARAM_OST		  "ost."
+#define PARAM_OSD		"osd."
 #define PARAM_OSC		  "osc."
 #define PARAM_MDT		  "mdt."
 #define PARAM_MDD		  "mdd."
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index e60ef4a..72ee1cb 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1001,7 +1001,13 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 	for (i = 1; i < lcfg->lcfg_bufcount; i++) {
 		key = lustre_cfg_buf(lcfg, i);
 		/* Strip off prefix */
-		class_match_param(key, prefix, &key);
+		if (class_match_param(key, prefix, &key)) {
+			/*
+			 * If the prefix doesn't match, return error so we
+			 * can pass it down the stack
+			 */
+			return -ENOSYS;
+		}
 		sval = strchr(key, '=');
 		if (!sval || (*(sval + 1) == 0)) {
 			CERROR("Can't parse param %s (missing '=')\n", key);
@@ -1034,18 +1040,14 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			j++;
 		}
 		if (!matched) {
-			/* If the prefix doesn't match, return error so we
-			 * can pass it down the stack
-			 */
-			if (strnchr(key, keylen, '.'))
-				return -ENOSYS;
-			CERROR("%s: unknown param %s\n",
+			CERROR("%.*s: %s unknown param %s\n",
+			       (int)strlen(prefix) - 1, prefix,
 			       (char *)lustre_cfg_string(lcfg, 0), key);
 			/* rc = -EINVAL;	continue parsing other params */
 			skip++;
 		} else if (rc < 0) {
-			CERROR("writing proc entry %s err %d\n",
-			       var->name, rc);
+			CERROR("%s: error writing proc entry '%s': rc = %d\n",
+			       prefix, var->name, rc);
 			rc = 0;
 		} else {
 			CDEBUG(D_CONFIG, "%s.%.*s: Set parameter %.*s=%s\n",
-- 
2.7.4
