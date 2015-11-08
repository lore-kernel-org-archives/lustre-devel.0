From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:17 -0500
Subject: [lustre-devel] [PATCH 12/13] staging: lustre: return proper error
	code for libcfs_kkuc_msg_put
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The functon libcfs_kkuc_msg_put() returns -ENOSYS which is not
correct. Return -ENXIO instead if the kuc header is corrupt.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 46cb81a..281cfd6 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -57,14 +57,14 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 	ssize_t count = kuch->kuc_msglen;
 	loff_t offset = 0;
 	mm_segment_t fs;
-	int rc = -ENOSYS;
+	int rc = -ENXIO;
 
 	if (!filp || IS_ERR(filp))
 		return -EBADF;
 
 	if (kuch->kuc_magic != KUC_MAGIC) {
 		CERROR("KernelComm: bad magic %x\n", kuch->kuc_magic);
-		return -ENOSYS;
+		return rc;
 	}
 
 	fs = get_fs();
-- 
1.7.1
