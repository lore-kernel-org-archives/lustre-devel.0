From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:15 -0500
Subject: [lustre-devel] [PATCH 10/13] staging: lustre: add space around '+'
	in kernel_comm code
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add in missing space arouund '+' in the kernel_comm code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/uapi_kernelcomm.h        |    2 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
index a8feab6..5ace9f8 100644
--- a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
@@ -54,7 +54,7 @@ struct kuc_hdr {
 	__u16 kuc_msglen;
 } __aligned(sizeof(__u64));
 
-#define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr)+CR_MAXSIZE)
+#define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr) + CR_MAXSIZE)
 
 #define KUC_MAGIC  0x191C /*Lustre9etLinC */
 
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index eb5b0be..709b1ab 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -102,7 +102,7 @@ struct kkuc_reg {
 	char		 kr_data[0];
 };
 
-static struct list_head kkuc_groups[KUC_GRP_MAX+1] = {};
+static struct list_head kkuc_groups[KUC_GRP_MAX + 1] = {};
 /* Protect message sending against remove and adds */
 static DECLARE_RWSEM(kg_sem);
 
-- 
1.7.1
