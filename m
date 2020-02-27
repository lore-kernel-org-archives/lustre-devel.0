From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:12 -0500
Subject: [lustre-devel] [PATCH 324/622] lnet: correct discovery LNetEQFree()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-325-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The EQ needs to be freed after all the queues are cleaned to avoid
having non-processed events on the event queue on free. This will
prevent the memory from being freed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12254
Lustre-commit: a0879b5985b4 ("LU-12254 lnet: correct discovery LNetEQFree()")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34796
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 7b11f28..8af9db2 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3142,8 +3142,6 @@ static int lnet_peer_discovery(void *arg)
 	 * size of the thundering herd if there are multiple threads
 	 * waiting on discovery of a single peer.
 	 */
-	LNetEQFree(the_lnet.ln_dc_eqh);
-	LNetInvalidateEQHandle(&the_lnet.ln_dc_eqh);
 
 	/* Queue cleanup 1: stop all pending pings and pushes. */
 	lnet_net_lock(LNET_LOCK_EX);
@@ -3171,6 +3169,9 @@ static int lnet_peer_discovery(void *arg)
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
+	LNetEQFree(the_lnet.ln_dc_eqh);
+	LNetInvalidateEQHandle(&the_lnet.ln_dc_eqh);
+
 	the_lnet.ln_dc_state = LNET_DC_STATE_SHUTDOWN;
 	wake_up(&the_lnet.ln_dc_waitq);
 
-- 
1.8.3.1
