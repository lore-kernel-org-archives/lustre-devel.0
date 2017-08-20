From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:10 -0400
Subject: [lustre-devel] [PATCH 16/64 v2] staging: lustre: uapi: move kernel
	only prototypes out of lustre_param.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move all the kernel specific function prototypes from
lustre_param.h into obd_config.h which is a kernel only
header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24325
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_param.h | 11 -----------
 drivers/staging/lustre/lustre/include/obd_class.h    | 18 ++++++++++++++++++
 2 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index 8061a04..2620e02 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -47,17 +47,6 @@
  * @{
  */
 
-/* For interoperability */
-struct cfg_interop_param {
-	char *old_param;
-	char *new_param;
-};
-
-/* obd_config.c */
-int class_find_param(char *buf, char *key, char **valp);
-int class_parse_nid(char *buf, lnet_nid_t *nid, char **endh);
-int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh);
-
 /****************** User-settable parameter keys *********************/
 /* e.g.
 	tunefs.lustre --param="failover.node=192.168.0.13 at tcp0" /dev/sda
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index d4a632a..8cc13ea 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -105,10 +105,28 @@ void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc,
 struct llog_rec_hdr;
 typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 			 struct llog_rec_hdr *, void *);
+
 /* obd_config.c */
 int class_process_config(struct lustre_cfg *lcfg);
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data);
+
+/* For interoperability */
+struct cfg_interop_param {
+	char *old_param;
+	char *new_param;
+};
+
+int class_find_param(char *buf, char *key, char **valp);
+struct cfg_interop_param *class_find_old_param(const char *param,
+					       struct cfg_interop_param *ptr);
+int class_get_next_param(char **params, char *copy);
+int class_parse_nid(char *buf, lnet_nid_t *nid, char **endh);
+int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh);
+int class_parse_net(char *buf, u32 *net, char **endh);
+int class_match_nid(char *buf, char *key, lnet_nid_t nid);
+int class_match_net(char *buf, char *key, u32 net);
+
 struct obd_device *class_incref(struct obd_device *obd,
 				const char *scope, const void *source);
 void class_decref(struct obd_device *obd,
-- 
1.8.3.1
