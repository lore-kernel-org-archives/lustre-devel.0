From: Okash Khawaja <okash.khawaja@gmail.com>
Date: Tue, 15 Dec 2015 16:50:45 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: fix address space mismatches
Message-ID: <20151215165045.GA5213@bytefire-computer>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch fixes address space warnings from sparse. Function
lprocfs_write_helper() accepts user space buffer but was being 
passed kernel space buffer by these functions:

contention_seconds_store()
lockless_truncate_store()

Since these functions are used to implement show and store functions of
lustre_attr object and since lustre_attr object is used to implement object
inheritance through use of `container_of`, the address space warnings
show up at multiple places inside driver's code base.

This patch creates a user space version of lustre_attr object lustre_attr_u.
Keeping function names and signatures same - other than the __user attribute -
ensures that object inheritance continues to work as it was, but address
space discrepency is removed. That removes a whole bunch of address
space warnings.

Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h | 16 ++++++++++++++++
 drivers/staging/lustre/lustre/osc/lproc_osc.c          | 12 ++++++------
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index f18c0c7..df6d9d5 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -698,6 +698,22 @@ static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
 #define LUSTRE_RO_ATTR(name) LUSTRE_ATTR(name, 0444, name##_show, NULL)
 #define LUSTRE_RW_ATTR(name) LUSTRE_ATTR(name, 0644, name##_show, name##_store)
 
+struct lustre_attr_u {
+	struct attribute attr;
+	ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
+			char *buf);
+	ssize_t (*store)(struct kobject *kobj, struct attribute *attr,
+			 const char __user *buf, size_t len);
+};
+
+#define LUSTRE_ATTR_U(name, mode, show, store) \
+static struct lustre_attr_u lustre_attr_u_##name = __ATTR(name, mode, show, \
+		store)
+
+#define LUSTRE_RO_ATTR_U(name) LUSTRE_ATTR_U(name, 0444, name##_show, NULL)
+#define LUSTRE_RW_ATTR_U(name) LUSTRE_ATTR_U(name, 0644, name##_show, \
+		name##_store)
+
 extern const struct sysfs_ops lustre_sysfs_ops;
 
 /* all quota proc functions */
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index c4d44e7..dd80780 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -474,7 +474,7 @@ static ssize_t contention_seconds_show(struct kobject *kobj,
 
 static ssize_t contention_seconds_store(struct kobject *kobj,
 					struct attribute *attr,
-					const char *buffer,
+					const char __user *buffer,
 					size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
@@ -484,7 +484,7 @@ static ssize_t contention_seconds_store(struct kobject *kobj,
 	return lprocfs_write_helper(buffer, count, &od->od_contention_time) ?:
 		count;
 }
-LUSTRE_RW_ATTR(contention_seconds);
+LUSTRE_RW_ATTR_U(contention_seconds);
 
 static ssize_t lockless_truncate_show(struct kobject *kobj,
 				      struct attribute *attr,
@@ -499,7 +499,7 @@ static ssize_t lockless_truncate_show(struct kobject *kobj,
 
 static ssize_t lockless_truncate_store(struct kobject *kobj,
 				       struct attribute *attr,
-				       const char *buffer,
+				       const char __user *buffer,
 				       size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
@@ -509,7 +509,7 @@ static ssize_t lockless_truncate_store(struct kobject *kobj,
 	return lprocfs_write_helper(buffer, count, &od->od_lockless_truncate) ?:
 		count;
 }
-LUSTRE_RW_ATTR(lockless_truncate);
+LUSTRE_RW_ATTR_U(lockless_truncate);
 
 static ssize_t destroys_in_flight_show(struct kobject *kobj,
 				       struct attribute *attr,
@@ -766,13 +766,13 @@ int lproc_osc_attach_seqstat(struct obd_device *dev)
 static struct attribute *osc_attrs[] = {
 	&lustre_attr_active.attr,
 	&lustre_attr_checksums.attr,
-	&lustre_attr_contention_seconds.attr,
+	&lustre_attr_u_contention_seconds.attr,
 	&lustre_attr_cur_dirty_bytes.attr,
 	&lustre_attr_cur_grant_bytes.attr,
 	&lustre_attr_cur_lost_grant_bytes.attr,
 	&lustre_attr_destroys_in_flight.attr,
 	&lustre_attr_grant_shrink_interval.attr,
-	&lustre_attr_lockless_truncate.attr,
+	&lustre_attr_u_lockless_truncate.attr,
 	&lustre_attr_max_dirty_mb.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
-- 
2.5.2
