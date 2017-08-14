From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:38 -0400
Subject: [lustre-devel] [PATCH 10/64] staging: lustre: uapi: move
	obd_ioctl_getdata() declaration
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move obd_ioctl_getdata() from lustre_ioctl.h to obd_class.h
since this function is only used by kernel space.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h | 2 --
 drivers/staging/lustre/lustre/include/obd_class.h           | 3 +++
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index da9a071..914cea1 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -208,8 +208,6 @@ static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 	return 0;
 }
 
-int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
-
 /*
  * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
  * Linux Lustre user tools. New ioctls should NOT use this macro as
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a6a4b2f..d4a632a 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1559,4 +1559,7 @@ struct root_squash_info {
 	struct rw_semaphore	rsi_sem;
 };
 
+/* linux-module.c */
+int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
+
 #endif /* __LINUX_OBD_CLASS_H */
-- 
1.8.3.1
