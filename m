From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:45 -0500
Subject: [lustre-devel] [PATCH 597/622] lustre: dom: check read-on-open
 buffer presents in reply
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-598-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The ll_dom_finish_open() uses req_capsule_has_field() wronly,
it check only format but not buffer presence in reply, that
causes unneeded console errors about missing buffer later in
req_capsule_server_get()

Patch replaces that with req_capsule_field_present() to check
if server pack that field in reply or not and properly skip
responses from an old server.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13136
Lustre-commit: 58bea527100b ("LU-13136 dom: check read-on-open buffer presents in reply")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37249
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Stephane Thiell <sthiell@stanford.edu>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h | 3 +++
 fs/lustre/llite/file.c                | 4 ++--
 fs/lustre/ptlrpc/layout.c             | 7 ++++---
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index feb5e77..ea6baef 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -112,6 +112,9 @@ u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 int req_capsule_has_field(const struct req_capsule *pill,
 			  const struct req_msg_field *field,
 			  enum req_location loc);
+int req_capsule_field_present(const struct req_capsule *pill,
+			      const struct req_msg_field *field,
+			      enum req_location loc);
 void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
 			u32 newlen, enum req_location loc);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a3c36a7..c7233bf 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -459,8 +459,8 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	if (!obj)
 		return;
 
-	if (!req_capsule_has_field(&req->rq_pill, &RMF_NIOBUF_INLINE,
-				   RCL_SERVER))
+	if (!req_capsule_field_present(&req->rq_pill, &RMF_NIOBUF_INLINE,
+				       RCL_SERVER))
 		return;
 
 	rnb = req_capsule_server_get(&req->rq_pill, &RMF_NIOBUF_INLINE);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 06db86d..4213fb2 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -2268,9 +2268,9 @@ int req_capsule_has_field(const struct req_capsule *pill,
  * Returns a non-zero value if the given @field is present in the given
  * @pill's PTLRPC request or reply (@loc), else it returns 0.
  */
-static int req_capsule_field_present(const struct req_capsule *pill,
-				     const struct req_msg_field *field,
-				     enum req_location loc)
+int req_capsule_field_present(const struct req_capsule *pill,
+			      const struct req_msg_field *field,
+			      enum req_location loc)
 {
 	u32 offset;
 
@@ -2280,6 +2280,7 @@ static int req_capsule_field_present(const struct req_capsule *pill,
 	offset = __req_capsule_offset(pill, field, loc);
 	return lustre_msg_bufcount(__req_msg(pill, loc)) > offset;
 }
+EXPORT_SYMBOL(req_capsule_field_present);
 
 /**
  * This function shrinks the size of the _buffer_ of the @pill's PTLRPC
-- 
1.8.3.1
