From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:28 -0400
Subject: [lustre-devel] [PATCH 25/38] lustre: obd: enhance print_lustre_cfg()
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Make the function print_lustre_cfg() exportables so we can provide
details when debugging other parts of the stack that handle
lustre_cfg processing. We currently report the index of the buffer
in struct lustre_cfg as well as the buffers length. We don't report
the actually string so lets add that info as well.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-id: https://jira.whamcloud.com/browse/LU-7004
Reviewed-on: https://review.whamcloud.com/28590
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |  1 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c | 12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index e994c968..e250bc3 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -106,6 +106,7 @@ typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 
 /* obd_config.c */
 char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index);
+void print_lustre_cfg(struct lustre_cfg *lcfg);
 int class_process_config(struct lustre_cfg *lcfg);
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data);
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index b431c34..3803056 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -308,12 +308,13 @@ void lustre_swab_llog_hdr(struct llog_log_hdr *h)
 }
 EXPORT_SYMBOL(lustre_swab_llog_hdr);
 
-static void print_lustre_cfg(struct lustre_cfg *lcfg)
+void print_lustre_cfg(struct lustre_cfg *lcfg)
 {
 	int i;
 
 	if (!(libcfs_debug & D_OTHER)) /* don't loop on nothing */
 		return;
+
 	CDEBUG(D_OTHER, "lustre_cfg: %p\n", lcfg);
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_version: %#x\n", lcfg->lcfg_version);
 
@@ -324,10 +325,13 @@ static void print_lustre_cfg(struct lustre_cfg *lcfg)
 
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_bufcount: %d\n", lcfg->lcfg_bufcount);
 	if (lcfg->lcfg_bufcount < LUSTRE_CFG_MAX_BUFCOUNT)
-		for (i = 0; i < lcfg->lcfg_bufcount; i++)
-			CDEBUG(D_OTHER, "\tlcfg->lcfg_buflens[%d]: %d\n",
-			       i, lcfg->lcfg_buflens[i]);
+		for (i = 0; i < lcfg->lcfg_bufcount; i++) {
+			CDEBUG(D_OTHER, "\tlcfg->lcfg_buflens[%d]: %d %s\n",
+			       i, lcfg->lcfg_buflens[i],
+			       lustre_cfg_string(lcfg, i));
+		}
 }
+EXPORT_SYMBOL(print_lustre_cfg);
 
 void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg)
 {
-- 
1.8.3.1
