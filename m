From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:11 -0400
Subject: [lustre-devel] [PATCH 19/25] lustre: lnd: Don't Assert On Reconnect
 with MultiQP
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <dougso@me.com>

The work from LU-8943 activated the ability to have multiple
connections between peers. If any of those connections need to be
reconnected (i.e. parameter renegotiation), we were getting
an assert from kiblnd_reconnect_peer() which was not changed
to allow for having multiple connections ongoing at the
same time.

This patch gets rid of the assert from kiblnd_reconnect_peer()
which is no longer valid after LU-8943.

Signed-off-by: Doug Oucharek <dougso@me.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9507
Reviewed-on: https://review.whamcloud.com/27139
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 80398c1..db563c0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1303,8 +1303,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		goto no_reconnect;
 	}
 
-	LASSERT(!peer_ni->ibp_accepting && !peer_ni->ibp_connecting &&
-		list_empty(&peer_ni->ibp_conns));
+	if (peer_ni->ibp_accepting)
+		CNETERR("Detecting race between accepting and reconnecting\n");
 	peer_ni->ibp_reconnecting--;
 
 	if (!kiblnd_peer_active(peer_ni)) {
-- 
1.8.3.1
