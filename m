From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:08 -0500
Subject: [lustre-devel] [PATCH 320/622] lnet: fix cpt locking
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-321-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

In lnet_select_pathway() the call to lnet_handle_send_case_locked()
can result in sd_cpt being changed. If this function returns
REPEAT_SEND, we'll go back to the again label. It is possible at
this time to initiate discovery, which will unlock the cpt.
If the local cpt isn't updated we could potentially be manipulating
the wrong cpt resulting in some form of corruption or dead lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12163
Lustre-commit: f6d63067e1ec ("LU-12163 lnet: fix cpt locking")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34607
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8eeb5ec..0ee3a55 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2390,10 +2390,15 @@ struct lnet_ni *
 
 	rc = lnet_handle_send_case_locked(&send_data);
 
+	/* Update the local cpt since send_data.sd_cpt might've been
+	 * updated as a result of calling lnet_handle_send_case_locked().
+	 */
+	cpt = send_data.sd_cpt;
+
 	if (rc == REPEAT_SEND)
 		goto again;
 
-	lnet_net_unlock(send_data.sd_cpt);
+	lnet_net_unlock(cpt);
 
 	return rc;
 }
-- 
1.8.3.1
