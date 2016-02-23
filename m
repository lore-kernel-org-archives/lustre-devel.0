From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:02 -0500
Subject: [lustre-devel] [PATCH 24/56] staging/lustre: Remove
	lustre_build_version.h
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

of the two macroses is contained the LUSTRE_RELEASE was unused and
BUILD_VERSION is too generically named and was replaced with
LUSTRE_VERSION_STRING with all the users (provided by lustre_ver.h)

With in-kernel client the build version should be combined with
kernel build information anyway.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_build_version.h       |  2 --
 drivers/staging/lustre/lustre/obdclass/class_obd.c            | 11 +++++------
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c   |  1 -
 3 files changed, 5 insertions(+), 9 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_build_version.h

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_build_version.h b/drivers/staging/lustre/lustre/include/lustre/lustre_build_version.h
deleted file mode 100644
index 93a3d7d..0000000
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_build_version.h
+++ /dev/null
@@ -1,2 +0,0 @@
-#define BUILD_VERSION "v2_3_64_0-g6e62c21-CHANGED-3.9.0"
-#define LUSTRE_RELEASE 3.9.0_g6e62c21
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 4b7e21f..f805693 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -42,7 +42,6 @@
 #include "../../include/linux/lnet/lnetctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre/lustre_build_version.h"
 #include <linux/list.h>
 #include "../include/cl_object.h"
 #include "llog_internal.h"
@@ -218,14 +217,14 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			goto out;
 		}
 
-		if (strlen(BUILD_VERSION) + 1 > data->ioc_inllen1) {
+		if (strlen(LUSTRE_VERSION_STRING) + 1 > data->ioc_inllen1) {
 			CERROR("ioctl buffer too small to hold version\n");
 			err = -EINVAL;
 			goto out;
 		}
 
-		memcpy(data->ioc_bulk, BUILD_VERSION,
-		       strlen(BUILD_VERSION) + 1);
+		memcpy(data->ioc_bulk, LUSTRE_VERSION_STRING,
+		       strlen(LUSTRE_VERSION_STRING) + 1);
 
 		err = obd_ioctl_popdata((void __user *)arg, data, len);
 		if (err)
@@ -481,7 +480,7 @@ static int __init init_obdclass(void)
 
 	int lustre_register_fs(void);
 
-	LCONSOLE_INFO("Lustre: Build Version: "BUILD_VERSION"\n");
+	LCONSOLE_INFO("Lustre: Build Version: " LUSTRE_VERSION_STRING "\n");
 
 	spin_lock_init(&obd_types_lock);
 	obd_zombie_impexp_init();
@@ -579,7 +578,7 @@ static void cleanup_obdclass(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Class Driver Build Version: " BUILD_VERSION);
+MODULE_DESCRIPTION("Lustre Class Driver Build Version: " LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 689f33a..f3c4a17 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -70,7 +70,6 @@
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
 #include "../../include/lustre_ver.h"
-#include "../../include/lustre/lustre_build_version.h"
 
 /* buffer MUST be at least the size of obd_ioctl_hdr */
 int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
-- 
2.1.0
