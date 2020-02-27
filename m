From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:38 -0500
Subject: [lustre-devel] [PATCH 170/622] lustre: mdt: fix read-on-open for
 big PAGE_SIZE
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-171-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Client PAGE_SIZE can be larger than server one so data returned
from server along with OPEN can be misaligned on client.

Patch replaces assertion on client with check and graceful exit,
changes MDC_DOM_DEF_INLINE_REPSIZE to be PAGE_SIZE at least and
updates mdt_dom_read_on_open() to return file tail for maximum
possible page size that can fit into reply.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11595
Lustre-commit: 4d7b022e373d ("LU-11595 mdt: fix read-on-open for big PAGE_SIZE")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c       | 22 ++++++++++++++++++++--
 fs/lustre/mdc/mdc_internal.h |  3 ++-
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 246d5de..44337a2 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -447,8 +447,26 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	if (!rnb || rnb->rnb_len == 0)
 		return;
 
-	CDEBUG(D_INFO, "Get data buffer along with open, len %i, i_size %llu\n",
-	       rnb->rnb_len, i_size_read(inode));
+	/* LU-11595: Server may return whole file and that is OK always or
+	 * it may return just file tail and its offset must be aligned with
+	 * client PAGE_SIZE to be used on that client, if server's PAGE_SIZE is
+	 * smaller then offset may be not aligned and that data is just ignored.
+	 */
+	if (rnb->rnb_offset % PAGE_SIZE)
+		return;
+
+	/* Server returns whole file or just file tail if it fills in
+	 * reply buffer, in both cases total size should be inode size.
+	 */
+	if (rnb->rnb_offset + rnb->rnb_len < i_size_read(inode)) {
+		CERROR("%s: server returns off/len %llu/%u < i_size %llu\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0), rnb->rnb_offset,
+		       rnb->rnb_len, i_size_read(inode));
+		return;
+	}
+
+	CDEBUG(D_INFO, "Get data along with open at %llu len %i, i_size %llu\n",
+	       rnb->rnb_offset, rnb->rnb_len, i_size_read(inode));
 
 	data = (char *)rnb + sizeof(*rnb);
 
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index b4af9778..7a6ec81 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -162,7 +162,8 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
 int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb);
 
-#define MDC_DOM_DEF_INLINE_REPSIZE 8192
+/* the minimum inline repsize should be PAGE_SIZE at least */
+#define MDC_DOM_DEF_INLINE_REPSIZE max(8192UL, PAGE_SIZE)
 #define MDC_DOM_MAX_INLINE_REPSIZE XATTR_SIZE_MAX
 
 #endif
-- 
1.8.3.1
