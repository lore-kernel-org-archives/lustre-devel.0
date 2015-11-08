From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:13 -0500
Subject: [lustre-devel] [PATCH 08/13] staging: lustre: remove unnecessary
	NULL checks in kernel_comm.c
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix checkpatch.pl reports of NULL comparison in kernel_comm.c.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 1081253..c9405e6 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -59,7 +59,7 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 	mm_segment_t fs;
 	int rc = -ENOSYS;
 
-	if (filp == NULL || IS_ERR(filp))
+	if (!filp || IS_ERR(filp))
 		return -EBADF;
 
 	if (kuch->kuc_magic != KUC_MAGIC) {
@@ -121,12 +121,12 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 	}
 
 	/* fput in group_rem */
-	if (filp == NULL)
+	if (!filp)
 		return -EBADF;
 
 	/* freed in group_rem */
 	reg = kmalloc(sizeof(*reg) + data_len, 0);
-	if (reg == NULL)
+	if (!reg)
 		return -ENOMEM;
 
 	reg->kr_fp = filp;
@@ -134,7 +134,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 	memcpy(reg->kr_data, data, data_len);
 
 	down_write(&kg_sem);
-	if (kkuc_groups[group].next == NULL)
+	if (!kkuc_groups[group].next)
 		INIT_LIST_HEAD(&kkuc_groups[group]);
 	list_add(&reg->kr_chain, &kkuc_groups[group]);
 	up_write(&kg_sem);
@@ -149,7 +149,7 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 {
 	struct kkuc_reg *reg, *next;
 
-	if (kkuc_groups[group].next == NULL)
+	if (!kkuc_groups[group].next)
 		return 0;
 
 	if (uid == 0) {
@@ -169,7 +169,7 @@ int libcfs_kkuc_group_rem(int uid, unsigned int group)
 			list_del(&reg->kr_chain);
 			CDEBUG(D_KUC, "Removed uid=%d fp=%p from group %d\n",
 			       reg->kr_uid, reg->kr_fp, group);
-			if (reg->kr_fp != NULL)
+			if (reg->kr_fp)
 				fput(reg->kr_fp);
 			kfree(reg);
 		}
@@ -188,7 +188,7 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 
 	down_write(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
-		if (reg->kr_fp != NULL) {
+		if (reg->kr_fp) {
 			rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
 			if (rc == 0)
 				one_success = 1;
@@ -227,12 +227,12 @@ int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 	}
 
 	/* no link for this group */
-	if (kkuc_groups[group].next == NULL)
+	if (!kkuc_groups[group].next)
 		return 0;
 
 	down_read(&kg_sem);
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
-		if (reg->kr_fp != NULL)
+		if (reg->kr_fp)
 			rc = cb_func(reg->kr_data, cb_arg);
 	}
 	up_read(&kg_sem);
-- 
1.7.1
