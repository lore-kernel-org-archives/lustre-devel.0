From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:36 -0400
Subject: [lustre-devel] [PATCH 42/64 v2] staging: lustre: uapi: remove
	CONFIG_LUSTRE_OBD_MAX_IOCTL
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Now that lustre_ioctl.h is a UAPI header the kernel configuration
option CONFIG_LUSTRE_OBD_MAX_IOCTL needs to be remove. The user
land utilites will no longer be able to see this option and
actually they never used this option before. Since this is the
case setting the kernel configuration to something other than
8K could actually break things. The best option is just hard
code it to 8K.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/25246
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h    |  1 -
 drivers/staging/lustre/lustre/Kconfig                          | 10 ----------
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c    |  2 ++
 3 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index 3060e4d..1f52477 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -56,7 +56,6 @@ enum md_echo_cmd {
 
 #define OBD_IOCTL_VERSION	0x00010004
 #define OBD_DEV_BY_DEVNAME	0xffffd0de
-#define OBD_MAX_IOCTL_BUFFER	CONFIG_LUSTRE_OBD_MAX_IOCTL_BUFFER
 
 struct obd_ioctl_data {
 	__u32		ioc_len;
diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index 9f5d75f..90d8269 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -31,16 +31,6 @@ config LUSTRE_FS
 
 	  See also http://wiki.lustre.org/
 
-config LUSTRE_OBD_MAX_IOCTL_BUFFER
-	int "Lustre obd max ioctl buffer bytes (default 8KB)"
-	depends on LUSTRE_FS
-	default 8192
-	help
-	  This option defines the maximum size of buffer in bytes that user space
-	  applications can pass to Lustre kernel module through ioctl interface.
-
-	  If unsure, use default.
-
 config LUSTRE_DEBUG_EXPENSIVE_CHECK
 	bool "Enable Lustre DEBUG checks"
 	depends on LUSTRE_FS
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index b2f5597..94af257 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -68,6 +68,8 @@
 #include "../../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../../../include/uapi/linux/lustre/lustre_ver.h"
 
+#define OBD_MAX_IOCTL_BUFFER	8192
+
 static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 {
 	if (data->ioc_len > BIT(30)) {
-- 
1.8.3.1
