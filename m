From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:48 -0500
Subject: [lustre-devel] [PATCH 060/622] lnet: ko2iblnd: determine gaps
 correctly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

We're allowed to start at a non-aligned page offset in the first
fragment and end at a non-aligned page offset in the last fragment.

When checking the iovec exclude both of the first and last fragments
from the tx_gaps check.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11064
Lustre-commit: e40ea6fd4494 ("LU-11064 lnd: determine gaps correctly")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32586
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c2ce3b9..60706b4 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -737,6 +737,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_net *net = ni->ni_data;
 	struct scatterlist *sg;
 	int fragnob;
+	int max_nkiov;
 
 	CDEBUG(D_NET, "niov %d offset %d nob %d\n", nkiov, offset, nob);
 
@@ -751,16 +752,24 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		LASSERT(nkiov > 0);
 	}
 
+	max_nkiov = nkiov;
+
 	sg = tx->tx_frags;
 	do {
 		LASSERT(nkiov > 0);
 
 		fragnob = min((int)(kiov->bv_len - offset), nob);
 
-		if ((fragnob < (int)(kiov->bv_len - offset)) && nkiov > 1) {
+		/* We're allowed to start at a non-aligned page offset in
+		 * the first fragment and end at a non-aligned page offset
+		 * in the last fragment.
+		 */
+		if ((fragnob < (int)(kiov->bv_len - offset)) &&
+		    nkiov < max_nkiov && nob > fragnob) {
 			CDEBUG(D_NET,
-			       "fragnob %d < available page %d: with remaining %d kiovs\n",
-			       fragnob, (int)(kiov->bv_len - offset), nkiov);
+			       "fragnob %d < available page %d: with remaining %d kiovs with %d nob left\n",
+			       fragnob, (int)(kiov->bv_len - offset),
+			       nkiov, nob);
 			tx->tx_gaps = true;
 		}
 
-- 
1.8.3.1
