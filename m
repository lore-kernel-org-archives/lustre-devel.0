From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Fri, 21 Jul 2017 11:29:53 +0530
Subject: [lustre-devel] [PATCH v3 3/3] staging: lustre: obdclass: linux:
	constify attribute_group structures.
In-Reply-To: <1500616793-21569-1-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500616793-21569-1-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <1500616793-21569-4-git-send-email-arvind.yadav.cs@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, di.wang@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              patch was sent to wrong group.
Changes in v3:
              typo error in cover-latter.

 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 9f5e829..eb88bd9 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -405,7 +405,7 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 struct kobject *lustre_kobj;
 EXPORT_SYMBOL_GPL(lustre_kobj);
 
-static struct attribute_group lustre_attr_group = {
+static const struct attribute_group lustre_attr_group = {
 	.attrs = lustre_attrs,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index e6c785a..814334b 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -151,7 +151,7 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
 	NULL,
 };
 
-static struct attribute_group lustre_attr_group = {
+static const struct attribute_group lustre_attr_group = {
 	.attrs = lustre_attrs,
 };
 
-- 
1.9.1
