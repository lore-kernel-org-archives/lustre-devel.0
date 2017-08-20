From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:01 -0400
Subject: [lustre-devel] [PATCH 07/64 v2] staging: lustre: uapi: remove
	userland version of obd_ioctl_*()
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The header lustre_ioctl.h has both kernel and user space versions
of obd_ioctl_*() functions. Lets remove the user land version
which have been integrated into the lustre tools.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_ioctl.h    | 87 ----------------------
 1 file changed, 87 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index eb08df3..84654af 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -208,8 +208,6 @@ static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 	return 0;
 }
 
-#ifdef __KERNEL__
-
 int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
 int obd_ioctl_popdata(void __user *arg, void *data, int len);
 
@@ -218,91 +216,6 @@ static inline void obd_ioctl_freedata(char *buf, size_t len)
 	kvfree(buf);
 }
 
-#else /* __KERNEL__ */
-
-static inline int obd_ioctl_pack(struct obd_ioctl_data *data, char **pbuf,
-				 int max_len)
-{
-	char *ptr;
-	struct obd_ioctl_data *overlay;
-
-	data->ioc_len = obd_ioctl_packlen(data);
-	data->ioc_version = OBD_IOCTL_VERSION;
-
-	if (*pbuf && data->ioc_len > max_len) {
-		fprintf(stderr, "pbuf = %p, ioc_len = %u, max_len = %d\n",
-			*pbuf, data->ioc_len, max_len);
-		return -EINVAL;
-	}
-
-	if (!*pbuf)
-		*pbuf = malloc(data->ioc_len);
-
-	if (!*pbuf)
-		return -ENOMEM;
-
-	overlay = (struct obd_ioctl_data *)*pbuf;
-	memcpy(*pbuf, data, sizeof(*data));
-
-	ptr = overlay->ioc_bulk;
-	if (data->ioc_inlbuf1)
-		LOGL(data->ioc_inlbuf1, data->ioc_inllen1, ptr);
-
-	if (data->ioc_inlbuf2)
-		LOGL(data->ioc_inlbuf2, data->ioc_inllen2, ptr);
-
-	if (data->ioc_inlbuf3)
-		LOGL(data->ioc_inlbuf3, data->ioc_inllen3, ptr);
-
-	if (data->ioc_inlbuf4)
-		LOGL(data->ioc_inlbuf4, data->ioc_inllen4, ptr);
-
-	if (obd_ioctl_is_invalid(overlay)) {
-		fprintf(stderr, "invalid ioctl data: ioc_len = %u, max_len = %d\n",
-			data->ioc_len, max_len);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static inline int
-obd_ioctl_unpack(struct obd_ioctl_data *data, char *pbuf, int max_len)
-{
-	char *ptr;
-	struct obd_ioctl_data *overlay;
-
-	if (!pbuf)
-		return 1;
-
-	overlay = (struct obd_ioctl_data *)pbuf;
-
-	/* Preserve the caller's buffer pointers */
-	overlay->ioc_inlbuf1 = data->ioc_inlbuf1;
-	overlay->ioc_inlbuf2 = data->ioc_inlbuf2;
-	overlay->ioc_inlbuf3 = data->ioc_inlbuf3;
-	overlay->ioc_inlbuf4 = data->ioc_inlbuf4;
-
-	memcpy(data, pbuf, sizeof(*data));
-
-	ptr = overlay->ioc_bulk;
-	if (data->ioc_inlbuf1)
-		LOGU(data->ioc_inlbuf1, data->ioc_inllen1, ptr);
-
-	if (data->ioc_inlbuf2)
-		LOGU(data->ioc_inlbuf2, data->ioc_inllen2, ptr);
-
-	if (data->ioc_inlbuf3)
-		LOGU(data->ioc_inlbuf3, data->ioc_inllen3, ptr);
-
-	if (data->ioc_inlbuf4)
-		LOGU(data->ioc_inlbuf4, data->ioc_inllen4, ptr);
-
-	return 0;
-}
-
-#endif /* !__KERNEL__ */
-
 /*
  * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
  * Linux Lustre user tools. New ioctls should NOT use this macro as
-- 
1.8.3.1
