From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 17 Oct 2016 23:46:28 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: replace uses of
 class_devno_max by MAX_OBD_DEVICES
In-Reply-To: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <4ba436cdccbea6c6dbc631f8cf75cd80f4f9ddb4.1476739569.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

class_devno_max is an inline function that returns
MAX_OBD_DEVICES. Replace all calls to the function
by MAX_OBD_DEVICES.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  6 +++---
 drivers/staging/lustre/lustre/obdclass/genops.c    | 22 +++++++++++-----------
 .../lustre/lustre/obdclass/linux/linux-module.c    |  6 +++---
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2b21675..b775c74 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -345,7 +345,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			goto out;
 		}
 		obd = class_name2obd(data->ioc_inlbuf4);
-	} else if (data->ioc_dev < class_devno_max()) {
+	} else if (data->ioc_dev < MAX_OBD_DEVICES) {
 		obd = class_num2obd(data->ioc_dev);
 	} else {
 		CERROR("OBD ioctl: No device\n");
@@ -498,7 +498,7 @@ static int __init obdclass_init(void)
 	}
 
 	/* This struct is already zeroed for us (static global) */
-	for (i = 0; i < class_devno_max(); i++)
+	for (i = 0; i < MAX_OBD_DEVICES; i++)
 		obd_devs[i] = NULL;
 
 	/* Default the dirty page cache cap to 1/2 of system memory.
@@ -548,7 +548,7 @@ static void obdclass_exit(void)
 	lustre_unregister_fs();
 
 	misc_deregister(&obd_psdev);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (obd && obd->obd_set_up &&
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 99c2da6..af4fc58 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -290,7 +290,7 @@ struct obd_device *class_newdev(const char *type_name, const char *name)
 	LASSERT(newdev->obd_magic == OBD_DEVICE_MAGIC);
 
 	write_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (obd && (strcmp(name, obd->obd_name) == 0)) {
@@ -322,9 +322,9 @@ struct obd_device *class_newdev(const char *type_name, const char *name)
 	}
 	write_unlock(&obd_dev_lock);
 
-	if (!result && i >= class_devno_max()) {
+	if (!result && i >= MAX_OBD_DEVICES) {
 		CERROR("all %u OBD devices used, increase MAX_OBD_DEVICES\n",
-		       class_devno_max());
+		       MAX_OBD_DEVICES);
 		result = ERR_PTR(-EOVERFLOW);
 		goto out;
 	}
@@ -372,7 +372,7 @@ int class_name2dev(const char *name)
 		return -1;
 
 	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (obd && strcmp(name, obd->obd_name) == 0) {
@@ -397,7 +397,7 @@ struct obd_device *class_name2obd(const char *name)
 {
 	int dev = class_name2dev(name);
 
-	if (dev < 0 || dev > class_devno_max())
+	if (dev < 0 || dev > MAX_OBD_DEVICES)
 		return NULL;
 	return class_num2obd(dev);
 }
@@ -408,7 +408,7 @@ int class_uuid2dev(struct obd_uuid *uuid)
 	int i;
 
 	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (obd && obd_uuid_equals(uuid, &obd->obd_uuid)) {
@@ -435,7 +435,7 @@ struct obd_device *class_num2obd(int num)
 {
 	struct obd_device *obd = NULL;
 
-	if (num < class_devno_max()) {
+	if (num < MAX_OBD_DEVICES) {
 		obd = obd_devs[num];
 		if (!obd)
 			return NULL;
@@ -463,7 +463,7 @@ struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
 	int i;
 
 	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (!obd)
@@ -496,13 +496,13 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid, int *next)
 
 	if (!next)
 		i = 0;
-	else if (*next >= 0 && *next < class_devno_max())
+	else if (*next >= 0 && *next < MAX_OBD_DEVICES)
 		i = *next;
 	else
 		return NULL;
 
 	read_lock(&obd_dev_lock);
-	for (; i < class_devno_max(); i++) {
+	for (; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd = class_num2obd(i);
 
 		if (!obd)
@@ -533,7 +533,7 @@ int class_notify_sptlrpc_conf(const char *fsname, int namelen)
 	LASSERT(namelen > 0);
 
 	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		obd = class_num2obd(i);
 
 		if (!obd || obd->obd_set_up == 0 || obd->obd_stopping)
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 33342bf..ca5b466 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -228,7 +228,7 @@ static ssize_t health_show(struct kobject *kobj, struct attribute *attr,
 		return sprintf(buf, "LBUG\n");
 
 	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
+	for (i = 0; i < MAX_OBD_DEVICES; i++) {
 		struct obd_device *obd;
 
 		obd = class_num2obd(i);
@@ -326,7 +326,7 @@ static struct attribute *lustre_attrs[] = {
 
 static void *obd_device_list_seq_start(struct seq_file *p, loff_t *pos)
 {
-	if (*pos >= class_devno_max())
+	if (*pos >= MAX_OBD_DEVICES)
 		return NULL;
 
 	return pos;
@@ -339,7 +339,7 @@ static void obd_device_list_seq_stop(struct seq_file *p, void *v)
 static void *obd_device_list_seq_next(struct seq_file *p, void *v, loff_t *pos)
 {
 	++*pos;
-	if (*pos >= class_devno_max())
+	if (*pos >= MAX_OBD_DEVICES)
 		return NULL;
 
 	return pos;
-- 
2.5.0


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
