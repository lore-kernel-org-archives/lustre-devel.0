From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:20 -0500
Subject: [lustre-devel] [PATCH 452/622] lustre: ptlrpc: check buffer length
 in lustre_msg_string()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-453-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

Check buffer length in lustre_msg_string() in case of any invalid
access.

Reported-by: Alibaba Cloud <yunye.ry@alibaba-inc.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-12613
Lustre-commit: 728c58d60fae ("LU-12613 ptlrpc: check buffer length in lustre_msg_string()")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35932
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Yunye Ry <yunye.ry@alibaba-inc.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pack_generic.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 4a0856a..9b28624 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -712,6 +712,11 @@ char *lustre_msg_string(struct lustre_msg *m, u32 index, u32 max_len)
 		       m, index, blen);
 		return NULL;
 	}
+	if (blen > PTLRPC_MAX_BUFLEN) {
+		CERROR("buffer length of msg %p buffer[%d] is invalid(%d)\n",
+		       m, index, blen);
+		return NULL;
+	}
 
 	if (max_len == 0) {
 		if (slen != blen - 1) {
-- 
1.8.3.1
