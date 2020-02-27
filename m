From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:03 -0500
Subject: [lustre-devel] [PATCH 315/622] lustre: llite: check correct size in
 ll_dom_finish_open()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-316-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The check in ll_dom_finish_open() for data end shouldn't
use i_size for comparision because it may be not updated
yet with just returned data from server. Use size value in
mdt_body from reply for that check.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12014
Lustre-commit: 7b9fd576f7de ("LU-12014 llite: check correct size in ll_dom_finish_open()")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33895
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 50220eb..88d5c2d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -418,6 +418,7 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	struct address_space *mapping = inode->i_mapping;
 	struct page *vmpage;
 	struct niobuf_remote *rnb;
+	struct mdt_body *body;
 	char *data;
 	unsigned long index, start;
 	struct niobuf_local lnb;
@@ -441,18 +442,19 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	if (rnb->rnb_offset % PAGE_SIZE)
 		return;
 
-	/* Server returns whole file or just file tail if it fills in
-	 * reply buffer, in both cases total size should be inode size.
+	/* Server returns whole file or just file tail if it fills in reply
+	 * buffer, in both cases total size should be equal to the file size.
 	 */
-	if (rnb->rnb_offset + rnb->rnb_len < i_size_read(inode)) {
-		CERROR("%s: server returns off/len %llu/%u < i_size %llu\n",
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	if (rnb->rnb_offset + rnb->rnb_len != body->mbo_dom_size) {
+		CERROR("%s: server returns off/len %llu/%u but size %llu\n",
 		       ll_i2sbi(inode)->ll_fsname, rnb->rnb_offset,
-		       rnb->rnb_len, i_size_read(inode));
+		       rnb->rnb_len, body->mbo_dom_size);
 		return;
 	}
 
-	CDEBUG(D_INFO, "Get data along with open at %llu len %i, i_size %llu\n",
-	       rnb->rnb_offset, rnb->rnb_len, i_size_read(inode));
+	CDEBUG(D_INFO, "Get data along with open at %llu len %i, size %llu\n",
+	       rnb->rnb_offset, rnb->rnb_len, body->mbo_dom_size);
 
 	data = (char *)rnb + sizeof(*rnb);
 
-- 
1.8.3.1
