From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:18 -0500
Subject: [lustre-devel] [PATCH 13/13] staging: lustre: cleanup white space
	in kernel comm code
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Cleanup the last white space issues in the kernel comm code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/uapi_kernelcomm.h        |   10 +++++-----
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
index 5ace9f8..5e99836 100644
--- a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
@@ -56,17 +56,17 @@ struct kuc_hdr {
 
 #define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr) + CR_MAXSIZE)
 
-#define KUC_MAGIC  0x191C /*Lustre9etLinC */
+#define KUC_MAGIC		0x191C /*Lustre9etLinC */
 
 /* kuc_msgtype values are defined in each transport */
 enum kuc_transport_type {
-	KUC_TRANSPORT_GENERIC   = 1,
-	KUC_TRANSPORT_HSM       = 2,
-	KUC_TRANSPORT_CHANGELOG = 3,
+	KUC_TRANSPORT_GENERIC	= 1,
+	KUC_TRANSPORT_HSM	= 2,
+	KUC_TRANSPORT_CHANGELOG	= 3,
 };
 
 enum kuc_generic_message_type {
-	KUC_MSG_SHUTDOWN = 1,
+	KUC_MSG_SHUTDOWN	= 1,
 };
 
 /* KUC Broadcast Groups. This determines which userspace process hears which
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 281cfd6..a2efb08 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -185,7 +185,7 @@ EXPORT_SYMBOL(libcfs_kkuc_group_rem);
 int libcfs_kkuc_group_put(unsigned int group, void *payload)
 {
 	struct kkuc_reg	*reg;
-	int		 rc = 0;
+	int rc = 0;
 	int one_success = 0;
 
 	down_write(&kg_sem);
-- 
1.7.1
