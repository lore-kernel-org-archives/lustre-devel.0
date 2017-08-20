From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:17 -0400
Subject: [lustre-devel] [PATCH 23/64 v2] staging: lustre: uapi: move
	lustre_cfg_string() to obd_config.c
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

To perserve the truncate warning move lustre_cfg_string()
to obd_config.c. A identical function was created for
userland. This function was a bit big for a inline function.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_cfg.h | 29 ------------------
 drivers/staging/lustre/lustre/include/obd_class.h  |  1 +
 .../staging/lustre/lustre/obdclass/obd_config.c    | 34 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  1 +
 4 files changed, 36 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 9d6934b..21a48b1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -179,35 +179,6 @@ static inline void lustre_cfg_bufs_init(struct lustre_cfg_bufs *bufs,
 	}
 }
 
-static inline char *lustre_cfg_string(struct lustre_cfg *lcfg, __u32 index)
-{
-	char *s;
-
-	if (lcfg->lcfg_buflens[index] == 0)
-		return NULL;
-
-	s = lustre_cfg_buf(lcfg, index);
-	if (!s)
-		return NULL;
-
-	/*
-	 * make sure it's NULL terminated, even if this kills a char
-	 * of data.  Try to use the padding first though.
-	 */
-	if (s[lcfg->lcfg_buflens[index] - 1] != '\0') {
-		size_t last = min((size_t)lcfg->lcfg_buflens[index],
-				  cfs_size_round(lcfg->lcfg_buflens[index]) - 1);
-		char lost = s[last];
-
-		s[last] = '\0';
-		if (lost != '\0') {
-			CWARN("Truncated buf %d to '%s' (lost '%c'...)\n",
-			      index, s, lost);
-		}
-	}
-	return s;
-}
-
 static inline __u32 lustre_cfg_len(__u32 bufcount, __u32 *buflens)
 {
 	__u32 i;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 8cc13ea..7d98485 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -107,6 +107,7 @@ typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 			 struct llog_rec_hdr *, void *);
 
 /* obd_config.c */
+char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index);
 int class_process_config(struct lustre_cfg *lcfg);
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 4c7c4f3..dc7b27e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -170,6 +170,40 @@ int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh)
 }
 EXPORT_SYMBOL(class_parse_nid_quiet);
 
+char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index)
+{
+	char *s;
+
+	if (!lcfg->lcfg_buflens[index])
+		return NULL;
+
+	s = lustre_cfg_buf(lcfg, index);
+	if (!s)
+		return NULL;
+
+	/*
+	 * make sure it's NULL terminated, even if this kills a char
+	 * of data.  Try to use the padding first though.
+	 */
+	if (s[lcfg->lcfg_buflens[index] - 1] != '\0') {
+		size_t last = ALIGN(lcfg->lcfg_buflens[index], 8) - 1;
+		char lost;
+
+		/* Use the smaller value */
+		if (last > lcfg->lcfg_buflens[index])
+			last = lcfg->lcfg_buflens[index];
+
+		lost = s[last];
+		s[last] = '\0';
+		if (lost != '\0') {
+			CWARN("Truncated buf %d to '%s' (lost '%c'...)\n",
+			      index, s, lost);
+		}
+	}
+	return s;
+}
+EXPORT_SYMBOL(lustre_cfg_string);
+
 /********************** class fns **********************/
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index bb953d4..9143441 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -37,6 +37,7 @@
 #include <linux/key.h>
 
 #include "../include/obd.h"
+#include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_import.h"
 #include "../../include/uapi/linux/lustre/lustre_param.h"
-- 
1.8.3.1
