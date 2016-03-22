From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:10 -0400
Subject: [lustre-devel] [PATCH 23/29] staging: lustre: libcfs: migrate
	inline functions to source file
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move large inline functions out of libcfs_ioctl.h to
the source file linux-module.c belonging to libcfs.
This code is only used by the core of libcfs and such
inline functions don't belong in a uapi header file.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   65 --------------------
 .../lustre/lnet/libcfs/linux/linux-module.c        |   65 ++++++++++++++++++++
 2 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index e109a4b..3af13e4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -138,71 +138,6 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 91, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_MAX_NR		91
 
-static inline int libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
-{
-	int len = sizeof(*data);
-
-	len += cfs_size_round(data->ioc_inllen1);
-	len += cfs_size_round(data->ioc_inllen2);
-	return len;
-}
-
-static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
-{
-	if (data->ioc_hdr.ioc_len > (1 << 30)) {
-		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
-		return 1;
-	}
-	if (data->ioc_inllen1 > (1<<30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
-		return 1;
-	}
-	if (data->ioc_inllen2 > (1<<30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
-		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
-		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_pbuf1 && !data->ioc_plen1) {
-		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_pbuf2 && !data->ioc_plen2) {
-		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
-		return 1;
-	}
-	if (data->ioc_plen1 && !data->ioc_pbuf1) {
-		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
-		return 1;
-	}
-	if (data->ioc_plen2 && !data->ioc_pbuf2) {
-		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
-		return 1;
-	}
-	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
-		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
-		return 1;
-	}
-	if (data->ioc_inllen1 &&
-	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
-		return 1;
-	}
-	if (data->ioc_inllen2 &&
-	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
-			   data->ioc_inllen2 - 1] != '\0') {
-		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
-		return 1;
-	}
-	return 0;
-}
-
 int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uparam);
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 7634551..af19f3c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -40,6 +40,71 @@
 
 #define LNET_MINOR 240
 
+static inline int libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
+{
+	int len = sizeof(*data);
+
+	len += cfs_size_round(data->ioc_inllen1);
+	len += cfs_size_round(data->ioc_inllen2);
+	return len;
+}
+
+static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
+{
+	if (data->ioc_hdr.ioc_len > (1 << 30)) {
+		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
+		return 1;
+	}
+	if (data->ioc_inllen1 > (1<<30)) {
+		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
+		return 1;
+	}
+	if (data->ioc_inllen2 > (1<<30)) {
+		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
+		return 1;
+	}
+	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
+		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
+		return 1;
+	}
+	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
+		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
+		return 1;
+	}
+	if (data->ioc_pbuf1 && !data->ioc_plen1) {
+		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
+		return 1;
+	}
+	if (data->ioc_pbuf2 && !data->ioc_plen2) {
+		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
+		return 1;
+	}
+	if (data->ioc_plen1 && !data->ioc_pbuf1) {
+		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
+		return 1;
+	}
+	if (data->ioc_plen2 && !data->ioc_pbuf2) {
+		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
+		return 1;
+	}
+	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
+		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
+		return 1;
+	}
+	if (data->ioc_inllen1 &&
+	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
+		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
+		return 1;
+	}
+	if (data->ioc_inllen2 &&
+	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
+			   data->ioc_inllen2 - 1] != '\0') {
+		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
+		return 1;
+	}
+	return 0;
+}
+
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 {
 	if (libcfs_ioctl_is_invalid(data)) {
-- 
1.7.1
