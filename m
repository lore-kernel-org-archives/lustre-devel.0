From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:00 -0400
Subject: [lustre-devel] [PATCH 08/25] lustre: lnet: selftest MR fix
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

selftest always responded to the primary nid of the peer rather than
the source of the message, which it should be.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26723
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/rpc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 298de41..26132ab 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1482,7 +1482,7 @@ struct srpc_client_rpc *
 			sv->sv_shuttingdown);
 
 		buffer = container_of(ev->md.start, struct srpc_buffer, buf_msg);
-		buffer->buf_peer = ev->initiator;
+		buffer->buf_peer = ev->source;
 		buffer->buf_self = ev->target.nid;
 
 		LASSERT(scd->scd_buf_nposted > 0);
-- 
1.8.3.1
