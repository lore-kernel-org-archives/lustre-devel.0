From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:33 -0400
Subject: [lustre-devel] [PATCH 80/80] staging: lustre: lnet: Stop Infinite
	CON RACE Condition
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-81-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

In current code, when a CON RACE occurs, the passive side will
let the node with the higher NID value win the race.

We have a field case where a node can have a "stuck"
connection which never goes away and is the trigger of a
never-ending loop of re-connections.

This patch introduces a counter to how many times a
connection in a connecting state has been the cause of a CON RACE
rejection. After 20 times (constant MAX_CONN_RACES_BEFORE_ABORT),
we assume the connection is stuck and let the other side (with
lower NID) win.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7646
Reviewed-on: http://review.whamcloud.com/19430
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   24 ++++++++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 078a0c3..fbc4f68 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -582,6 +582,8 @@ struct kib_peer {
 	unsigned short		ibp_connecting;
 	/* reconnect this peer later */
 	unsigned short		ibp_reconnecting:1;
+	/* counter of how many times we triggered a conn race */
+	unsigned char		ibp_races;
 	/* # consecutive reconnection attempts to this peer */
 	unsigned int		ibp_reconnected;
 	/* errno on closing this peer */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6d1b14a..430ff85 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -36,6 +36,8 @@
 
 #include "o2iblnd.h"
 
+#define MAX_CONN_RACES_BEFORE_ABORT 20
+
 static void kiblnd_peer_alive(struct kib_peer *peer);
 static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
 static void kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx,
@@ -2405,23 +2407,37 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			goto failed;
 		}
 
-		/* tie-break connection race in favour of the higher NID */
+		/*
+		 * Tie-break connection race in favour of the higher NID.
+		 * If we keep running into a race condition multiple times,
+		 * we have to assume that the connection attempt with the
+		 * higher NID is stuck in a connecting state and will never
+		 * recover.  As such, we pass through this if-block and let
+		 * the lower NID connection win so we can move forward.
+		 */
 		if (peer2->ibp_connecting &&
-		    nid < ni->ni_nid) {
+		    nid < ni->ni_nid && peer2->ibp_races <
+		    MAX_CONN_RACES_BEFORE_ABORT) {
+			peer2->ibp_races++;
 			write_unlock_irqrestore(g_lock, flags);
 
-			CWARN("Conn race %s\n", libcfs_nid2str(peer2->ibp_nid));
+			CDEBUG(D_NET, "Conn race %s\n",
+			       libcfs_nid2str(peer2->ibp_nid));
 
 			kiblnd_peer_decref(peer);
 			rej.ibr_why = IBLND_REJECT_CONN_RACE;
 			goto failed;
 		}
-
+		if (peer2->ibp_races >= MAX_CONN_RACES_BEFORE_ABORT)
+			CNETERR("Conn race %s: unresolved after %d attempts, letting lower NID win\n",
+				libcfs_nid2str(peer2->ibp_nid),
+				MAX_CONN_RACES_BEFORE_ABORT);
 		/**
 		 * passive connection is allowed even this peer is waiting for
 		 * reconnection.
 		 */
 		peer2->ibp_reconnecting = 0;
+		peer2->ibp_races = 0;
 		peer2->ibp_accepting++;
 		kiblnd_peer_addref(peer2);
 
-- 
1.7.1
