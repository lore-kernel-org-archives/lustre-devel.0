From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:22 -0400
Subject: [lustre-devel] [PATCH 12/30] lustre: kuc: initialize kkuc_groups at
 module init time
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Some kkuc functions use kkuc_groups[group].next == NULL to test for an
empty group list. This is incorrect if the group was previously added
to but not empty. Remove all next == NULL tests and use module load
time initialization of the kkuc_groups array.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9306
Reviewed-on: https://review.whamcloud.com/26883
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_kernelcomm.h      |  1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  3 ++
 .../staging/lustre/lustre/obdclass/kernelcomm.c    | 38 +++++++++++++++-------
 3 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index 2b3fa84..8e3a990 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -45,6 +45,7 @@
 typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
 
 /* Kernel methods */
+void libcfs_kkuc_init(void);
 int libcfs_kkuc_msg_put(struct file *fp, void *payload);
 int libcfs_kkuc_group_put(unsigned int group, void *payload);
 int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index eabaafe..2d23608 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -42,6 +42,7 @@
 #include <obd_class.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <lustre_debug.h>
+#include <lustre_kernelcomm.h>
 #include <lprocfs_status.h>
 #include <linux/list.h>
 #include <cl_object.h>
@@ -664,6 +665,8 @@ static int __init obdclass_init(void)
 	if (err)
 		return err;
 
+	libcfs_kkuc_init();
+
 	err = obd_zombie_impexp_init();
 	if (err)
 		return err;
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 304288d..0fcfecf 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -96,10 +96,23 @@ struct kkuc_reg {
 	char		 kr_data[0];
 };
 
-static struct list_head kkuc_groups[KUC_GRP_MAX + 1] = {};
+static struct list_head kkuc_groups[KUC_GRP_MAX + 1];
 /* Protect message sending against remove and adds */
 static DECLARE_RWSEM(kg_sem);
 
+static inline bool libcfs_kkuc_group_is_valid(int group)
+{
+	return 0 <= group && group < ARRAY_SIZE(kkuc_groups);
+}
+
+void libcfs_kkuc_init(void)
+{
+	int group;
+
+	for (group = 0; group < ARRAY_SIZE(kkuc_groups); group++)
+		INIT_LIST_HEAD(&kkuc_groups[group]);
+}
+
 /** Add a receiver to a broadcast group
  * @param filp pipe to write into
  * @param uid identifier for this receiver
@@ -111,7 +124,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 {
 	struct kkuc_reg *reg;
 
-	if (group > KUC_GRP_MAX) {
+	if (!libcfs_kkuc_group_is_valid(group)) {
 		CDEBUG(D_WARNING, "Kernelcomm: bad group %d\n", group);
 		return -EINVAL;
 	}
@@ -130,8 +143,6 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 	memcpy(reg->kr_data, data, data_len);
 
 	down_write(&kg_sem);
-	if (!kkuc_groups[group].next)
-		INIT_LIST_HEAD(&kkuc_groups[group]);
 	list_add(&reg->kr_chain, &kkuc_groups[group]);
 	up_write(&kg_sem);
 
@@ -145,8 +156,10 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 {
 	struct kkuc_reg *reg, *next;
 
-	if (!kkuc_groups[group].next)
-		return 0;
+	if (!libcfs_kkuc_group_is_valid(group)) {
+		CDEBUG(D_WARNING, "Kernelcomm: bad group %d\n", group);
+		return -EINVAL;
+	}
 
 	if (!uid) {
 		/* Broadcast a shutdown message */
@@ -182,9 +195,14 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 	int rc = 0;
 	int one_success = 0;
 
+	if (!libcfs_kkuc_group_is_valid(group)) {
+		CDEBUG(D_WARNING, "Kernelcomm: bad group %d\n", group);
+		return -EINVAL;
+	}
+
 	down_write(&kg_sem);
 
-	if (unlikely(!kkuc_groups[group].next) ||
+	if (unlikely(list_empty(&kkuc_groups[group])) ||
 	    unlikely(OBD_FAIL_CHECK(OBD_FAIL_MDS_HSM_CT_REGISTER_NET))) {
 		/* no agent have fully registered, CDT will retry */
 		up_write(&kg_sem);
@@ -227,15 +245,11 @@ int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 	struct kkuc_reg *reg;
 	int rc = 0;
 
-	if (group > KUC_GRP_MAX) {
+	if (!libcfs_kkuc_group_is_valid(group)) {
 		CDEBUG(D_WARNING, "Kernelcomm: bad group %d\n", group);
 		return -EINVAL;
 	}
 
-	/* no link for this group */
-	if (!kkuc_groups[group].next)
-		return 0;
-
 	down_read(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
 		if (reg->kr_fp)
-- 
1.8.3.1
