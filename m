From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:15 -0500
Subject: [lustre-devel] [PATCH 207/622] lustre: ptlrpc: improve memory
 allocation for service RPCs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-208-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

The memory for service RPCs are not always page aligned
for its size i.e 17KiB for example. Round up to the nearest
power of 2 so we can effectively use the whole allocated buffer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11897
Cray-bug-id: LUS-6657
Lustre-commit: 3a90458bd84d ("LU-11897 ost: improve memory allocation for ost")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/34127
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index b94ed6a..7bc578c 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -641,6 +641,13 @@ struct ptlrpc_service *
 	service->srv_rep_portal	= conf->psc_buf.bc_rep_portal;
 	service->srv_req_portal	= conf->psc_buf.bc_req_portal;
 
+	/* With slab/alloc_pages buffer size will be rounded up to 2^n */
+	if (service->srv_buf_size & (service->srv_buf_size - 1)) {
+		int round = size_roundup_power2(service->srv_buf_size);
+
+		service->srv_buf_size = round;
+	}
+
 	/* Increase max reply size to next power of two */
 	service->srv_max_reply_size = 1;
 	while (service->srv_max_reply_size <
-- 
1.8.3.1
