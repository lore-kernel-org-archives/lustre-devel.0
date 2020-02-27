From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:22 -0500
Subject: [lustre-devel] [PATCH 454/622] lustre: ptlrpc: fix reply buffers
 shrinking and growing
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-455-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The req_capsule_shrink() doesn't update capsule itself with
new buffer lenghts after the shrinking. Usually it is not
needed because reply is packed already. But if reply buffers
are re-allocated by req_capsule_server_grow() then non-updated
lenghts from capsule are used causing bigger reply message.
That may cause client buffer re-allocation with resend.

Patch does the following:
- update capsule length after the shrinking
  introduce lustre_grow_msg() to grow msg field in-place
- update req_capsule_server_grow() to use generic
  lustre_grow_msg() and make it able to grow reply without
  re-allocation if reply buffer is big enough already
- update sanity test 271f to use bigger file size to exceed
  current maximum reply buffer size allocated on client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12443
Lustre-commit: cedbb25e984c ("LU-12443 ptlrpc: fix reply buffers shrinking and growing")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35243
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/layout.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 67a7cd5..dd04eee 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -2309,11 +2309,16 @@ void req_capsule_shrink(struct req_capsule *pill,
 	LASSERTF(newlen <= len, "%s:%s, oldlen=%u, newlen=%u\n",
 		 fmt->rf_name, field->rmf_name, len, newlen);
 
-	if (loc == RCL_CLIENT)
+	if (loc == RCL_CLIENT) {
 		pill->rc_req->rq_reqlen = lustre_shrink_msg(msg, offset, newlen,
 							    1);
-	else
+	} else {
 		pill->rc_req->rq_replen = lustre_shrink_msg(msg, offset, newlen,
 							    1);
+		/* update also field size in reply lenghts arrays for possible
+		 * reply re-pack due to req_capsule_server_grow() call.
+		 */
+		req_capsule_set_size(pill, field, loc, newlen);
+	}
 }
 EXPORT_SYMBOL(req_capsule_shrink);
-- 
1.8.3.1
