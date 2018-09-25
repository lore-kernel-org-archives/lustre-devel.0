From: James Simmons <jsimmons@infradead.org>
Date: Mon, 24 Sep 2018 23:37:30 -0400
Subject: [lustre-devel] [PATCH] lustre: lnet: copy the correct amountof cpts
 to lnet_cpts
Message-ID: <1537846650-8490-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The incorrect size was used in the memory copy of the requested
cpts to net->lnet_cpts. This lead to the following in testing
RIP: 0010:lnet_match2mt.isra.8+0x2b/0x40 [lnet]

lnet_mt_of_attach+0x72/0x1b0 [lnet]
LNetMEAttach+0x60/0x1f0 [lnet]
ptl_send_rpc+0x26f/0xbb0 [ptlrpc]
libcfs_debug_msg+0x57/0x80 [libcfs]
ptlrpc_send_new_req+0x4c9/0x860 [ptlrpc]
ptlrpc_check_set.part.21+0x855/0x18b0 [ptlrpc]
? try_to_del_timer_sync+0x4d/0x80
? del_timer_sync+0x35/0x40
ptlrpcd_check+0x3ae/0x3f0 [ptlrpc]
ptlrpcd+0x2be/0x320 [ptlrpc]
? wait_woken+0x80/0x80

Changing the size from ncpts to ncpts * sizeof(*net->net_cpts)

Signed-off-by: James Simmons <jsimmons@infradead.org>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11424
Reviewed-on: https://review.whamcloud.com/33229
---
 drivers/staging/lustre/lnet/lnet/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index c11821a..4c22416 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -174,7 +174,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 					      GFP_KERNEL);
 		if (!net->net_cpts)
 			return -ENOMEM;
-		memcpy(net->net_cpts, cpts, ncpts);
+		memcpy(net->net_cpts, cpts, ncpts * sizeof(*net->net_cpts));
 		net->net_ncpts = ncpts;
 		return 0;
 	}
-- 
1.8.3.1
