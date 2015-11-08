From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:12 -0500
Subject: [lustre-devel] [PATCH 07/13] staging: lustre: convert kernelcomm
	group to unsigned int
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The group variable was converted to an unsigned int in
libcfs_kkuc_group_add() to avoid a potential overflow.
The variable group is used in other kernelcomm functions
so it makes sense to convert the rest of the group
variables to unsigned int.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_kernelcomm.h      |    6 +++---
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index 235b980..14bad00 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -45,11 +45,11 @@ typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
 
 /* Kernel methods */
 int libcfs_kkuc_msg_put(struct file *fp, void *payload);
-int libcfs_kkuc_group_put(int group, void *payload);
+int libcfs_kkuc_group_put(unsigned int group, void *payload);
 int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
 			  void *data, size_t data_len);
-int libcfs_kkuc_group_rem(int uid, int group);
-int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
+int libcfs_kkuc_group_rem(int uid, unsigned int group);
+int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 			      void *cb_arg);
 
 #endif /* __LUSTRE_KERNELCOMM_H__ */
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index e290246..1081253 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -145,7 +145,7 @@ int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_add);
 
-int libcfs_kkuc_group_rem(int uid, int group)
+int libcfs_kkuc_group_rem(int uid, unsigned int group)
 {
 	struct kkuc_reg *reg, *next;
 
@@ -180,7 +180,7 @@ int libcfs_kkuc_group_rem(int uid, int group)
 }
 EXPORT_SYMBOL(libcfs_kkuc_group_rem);
 
-int libcfs_kkuc_group_put(int group, void *payload)
+int libcfs_kkuc_group_put(unsigned int group, void *payload)
 {
 	struct kkuc_reg	*reg;
 	int		 rc = 0;
@@ -215,7 +215,7 @@ EXPORT_SYMBOL(libcfs_kkuc_group_put);
  * @param cb_func the function to be called.
  * @param cb_arg extra argument to be passed to the callback function.
  */
-int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
+int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 			      void *cb_arg)
 {
 	struct kkuc_reg *reg;
-- 
1.7.1
