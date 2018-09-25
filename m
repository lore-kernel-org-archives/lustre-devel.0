From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 28/34] LU-7734 lnet: Fix crash in
 router_proc.c
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763594.32103.9029692452686853485.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Fixed NULL access in the case when a peer is a remote
peer. In that case lpni_net is NULL.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ida234ff016b2bdc305acf74df0f99600d2555e27
Reviewed-on: http://review.whamcloud.com/21327
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/router_proc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 977a937f261c..a887ca446d42 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -492,7 +492,8 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			int nrefs = atomic_read(&peer->lpni_refcount);
 			time64_t lastalive = -1;
 			char *aliveness = "NA";
-			int maxcr = peer->lpni_net->net_tunables.lct_peer_tx_credits;
+			int maxcr = peer->lpni_net ?
+				peer->lpni_net->net_tunables.lct_peer_tx_credits : 0;
 			int txcr = peer->lpni_txcredits;
 			int mintxcr = peer->lpni_mintxcredits;
 			int rtrcr = peer->lpni_rtrcredits;
