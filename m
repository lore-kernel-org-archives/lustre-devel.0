From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:41 -0500
Subject: [lustre-devel] [PATCH 13/60] staging: lustre: obdclass:
	health_check to report unhealthy upon LBUG
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

When a LBUG has occurred, without panic_on_lbug being set,
health_check sysfs file must return an unhealthy state.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7486
Reviewed-on: http://review.whamcloud.com/17981
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 22e6d1f..ef25db6 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -224,8 +224,10 @@ static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
 	int i;
 	size_t len = 0;
 
-	if (libcfs_catastrophe)
-		return sprintf(buf, "LBUG\n");
+	if (libcfs_catastrophe) {
+		len = sprintf(buf, "LBUG\n");
+		healthy = false;
+	}
 
 	read_lock(&obd_dev_lock);
 	for (i = 0; i < class_devno_max(); i++) {
-- 
1.8.3.1
