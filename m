From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:38 -0500
Subject: [lustre-devel] [PATCH 10/60] staging: lustre: obdclass: add more
	info to sysfs version string
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Update the sysfs "version" file to print "lustre: " with
the version number.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5969
Reviewed-on: http://review.whamcloud.com/16721
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 9f5e829..22e6d1f 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -208,7 +208,7 @@ struct miscdevice obd_psdev = {
 static ssize_t version_show(struct kobject *kobj, struct attribute *attr,
 			    char *buf)
 {
-	return sprintf(buf, "%s\n", LUSTRE_VERSION_STRING);
+	return sprintf(buf, "lustre: %s\n", LUSTRE_VERSION_STRING);
 }
 
 static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
-- 
1.8.3.1
