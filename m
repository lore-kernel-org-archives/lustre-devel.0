From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Nov 2016 17:52:32 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: obd: rename health sysfs
	file to health_check
Message-ID: <1478559152-3624-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Testing revealed that the sysfs file health is actually the
wrong name. Rename to the proper name health_check.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/obdclass/linux/linux-module.c    |    8 ++++----
 drivers/staging/lustre/sysfs-fs-lustre             |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index be09e04..9f5e829 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -217,8 +217,8 @@ static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
 	return sprintf(buf, "%s\n", "on");
 }
 
-static ssize_t health_show(struct kobject *kobj, struct attribute *attr,
-			   char *buf)
+static ssize_t
+health_check_show(struct kobject *kobj, struct attribute *attr, char *buf)
 {
 	bool healthy = true;
 	int i;
@@ -311,14 +311,14 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 
 LUSTRE_RO_ATTR(version);
 LUSTRE_RO_ATTR(pinger);
-LUSTRE_RO_ATTR(health);
+LUSTRE_RO_ATTR(health_check);
 LUSTRE_RW_ATTR(jobid_var);
 LUSTRE_RW_ATTR(jobid_name);
 
 static struct attribute *lustre_attrs[] = {
 	&lustre_attr_version.attr,
 	&lustre_attr_pinger.attr,
-	&lustre_attr_health.attr,
+	&lustre_attr_health_check.attr,
 	&lustre_attr_jobid_name.attr,
 	&lustre_attr_jobid_var.attr,
 	NULL,
diff --git a/drivers/staging/lustre/sysfs-fs-lustre b/drivers/staging/lustre/sysfs-fs-lustre
index 20206ba..8691c65 100644
--- a/drivers/staging/lustre/sysfs-fs-lustre
+++ b/drivers/staging/lustre/sysfs-fs-lustre
@@ -11,7 +11,7 @@ Description:
 		Shows if the lustre module has pinger support.
 		"on" means yes and "off" means no.
 
-What:		/sys/fs/lustre/health
+What:		/sys/fs/lustre/health_check
 Date:		May 2015
 Contact:	"Oleg Drokin" <oleg.drokin@intel.com>
 Description:
-- 
1.7.1
