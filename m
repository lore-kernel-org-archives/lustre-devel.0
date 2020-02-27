From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:20 -0500
Subject: [lustre-devel] [PATCH 272/622] lustre: llite: fill copied dentry
 name's ending char properly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-273-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Dentry name expect an extra '\0'. and dentry_len won't calcualte
extra '\0' for it, but we should allocate memory and fill it
when copying dentry name by ourselves.

Otherwise, lu_name_is_valid_2() will try to access @name[len]
and check whether it is '\0'. this is invalid memory access.
We will possibly hit a crash if the first access that bit is '\0'.
and the bit overwritten by someone else, and finally we failed
sanity check in mdc_name_pack().

LustreError: 157839:0:(mdc_lib.c:137:mdc_pack_name()) LBUG

Fixes: 2eae6a4 ("lustre: llite: make sure name pack atomic")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12169
Lustre-commit: bc9cc327983c ("LU-12169 llite: fill copied dentry name's ending char properly")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34611
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/file.c          | 10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 9ebdcb6..4e956da 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -456,6 +456,7 @@
 #define OBD_FAIL_LLITE_CREATE_NODE_PAUSE		0x140c
 #define OBD_FAIL_LLITE_IMUTEX_SEC			0x140e
 #define OBD_FAIL_LLITE_IMUTEX_NOSEC			0x140f
+#define OBD_FAIL_LLITE_OPEN_BY_NAME			0x1410
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0f15ea8..61d53c4 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -513,12 +513,14 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	 * if server supports open-by-fid, or file name is invalid, don't pack
 	 * name in open request
 	 */
-	if (!(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID)) {
+	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_OPEN_BY_NAME) ||
+	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID)) {
 retry:
 		len = de->d_name.len;
-		name = kmalloc(len, GFP_NOFS);
+		name = kmalloc(len + 1, GFP_NOFS);
 		if (!name)
 			return -ENOMEM;
+
 		/* race here */
 		spin_lock(&de->d_lock);
 		if (len != de->d_name.len) {
@@ -527,12 +529,12 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 			goto retry;
 		}
 		memcpy(name, de->d_name.name, len);
+		name[len] = '\0';
 		spin_unlock(&de->d_lock);
 
 		if (!lu_name_is_valid_2(name, len)) {
 			kfree(name);
-			name = NULL;
-			len = 0;
+			return -ESTALE;
 		}
 	}
 
-- 
1.8.3.1
