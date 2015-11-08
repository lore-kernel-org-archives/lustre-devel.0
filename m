From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:14 -0500
Subject: [lustre-devel] [PATCH 09/13] staging: lustre: cleanup block comment
	style in kernel_comm code
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fixup the comments to the linux kernel style for the source and
headers related to the kernel_comm work.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/uapi_kernelcomm.h        |   10 ++++++----
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   12 ++++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
index 5e0b8de..a8feab6 100644
--- a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
@@ -45,11 +45,13 @@
  */
 struct kuc_hdr {
 	__u16 kuc_magic;
-	__u8  kuc_transport;  /* Each new Lustre feature should use a different
-				 transport */
+	/* Each new Lustre feature should use a different transport */
+	__u8  kuc_transport;
 	__u8  kuc_flags;
-	__u16 kuc_msgtype;    /* Message type or opcode, transport-specific */
-	__u16 kuc_msglen;     /* Including header */
+	/* Message type or opcode, transport-specific */
+	__u16 kuc_msgtype;
+	/* Including header */
+	__u16 kuc_msglen;
 } __aligned(sizeof(__u64));
 
 #define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr)+CR_MAXSIZE)
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index c9405e6..eb5b0be 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -89,9 +89,11 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 }
 EXPORT_SYMBOL(libcfs_kkuc_msg_put);
 
-/* Broadcast groups are global across all mounted filesystems;
+/*
+ * Broadcast groups are global across all mounted filesystems;
  * i.e. registering for a group on 1 fs will get messages for that
- * group from any fs */
+ * group from any fs
+ */
 /** A single group registration has a uid and a file pointer */
 struct kkuc_reg {
 	struct list_head kr_chain;
@@ -200,8 +202,10 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 	}
 	up_write(&kg_sem);
 
-	/* don't return an error if the message has been delivered
-	 * at least to one agent */
+	/*
+	 * don't return an error if the message has been delivered
+	 * at least to one agent
+	 */
 	if (one_success)
 		rc = 0;
 
-- 
1.7.1
