From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:05 -0400
Subject: [lustre-devel] [PATCH 11/64 v2] staging: lustre: uapi: move
	obd_ioctl_is_invalid() to linux-module.c
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The inline function obd_ioctl_is_invalid() is no longer needed by
userland and also the function was pretty bug for a inline function.
Since this is the case we can move this kernel only code to the
linux-module.c which is the only place it is used.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_ioctl.h    | 76 ----------------------
 .../lustre/lustre/obdclass/linux/linux-module.c    | 76 ++++++++++++++++++++++
 2 files changed, 76 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index 914cea1..8585302 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -132,82 +132,6 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 	return len;
 }
 
-static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
-{
-	if (data->ioc_len > (1 << 30)) {
-		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen1 > (1 << 30)) {
-		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen2 > (1 << 30)) {
-		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen3 > (1 << 30)) {
-		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen4 > (1 << 30)) {
-		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
-		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
-		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf3 && !data->ioc_inllen3) {
-		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf4 && !data->ioc_inllen4) {
-		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_pbuf1 && !data->ioc_plen1) {
-		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_pbuf2 && !data->ioc_plen2) {
-		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (!data->ioc_pbuf1 && data->ioc_plen1) {
-		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
-		return 1;
-	}
-
-	if (!data->ioc_pbuf2 && data->ioc_plen2) {
-		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
-		return 1;
-	}
-
-	if (obd_ioctl_packlen(data) > data->ioc_len) {
-		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
-		       obd_ioctl_packlen(data), data->ioc_len);
-		return 1;
-	}
-
-	return 0;
-}
-
 /*
  * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
  * Linux Lustre user tools. New ioctls should NOT use this macro as
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 3a394d2..092e68a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -68,6 +68,82 @@
 #include "../../include/lustre/lustre_ioctl.h"
 #include "../../include/lustre_ver.h"
 
+static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
+{
+	if (data->ioc_len > BIT(30)) {
+		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen1 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen2 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen3 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen4 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf1 && data->ioc_inllen1 == 0) {
+		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf2 && data->ioc_inllen2 == 0) {
+		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf3 && data->ioc_inllen3 == 0) {
+		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf4 && data->ioc_inllen4 == 0) {
+		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf1 && data->ioc_plen1 == 0) {
+		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf2 && data->ioc_plen2 == 0) {
+		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf1 && data->ioc_plen1 != 0) {
+		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf2 && data->ioc_plen2 != 0) {
+		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (obd_ioctl_packlen(data) > data->ioc_len) {
+		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
+		obd_ioctl_packlen(data), data->ioc_len);
+		return 1;
+	}
+
+	return 0;
+}
+
 /* buffer MUST be at least the size of obd_ioctl_hdr */
 int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 {
-- 
1.8.3.1
