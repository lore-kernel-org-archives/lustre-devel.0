From: NeilBrown <neilb@suse.com>
Date: Mon, 10 Dec 2018 11:46:16 +1100
Subject: [lustre-devel] [PATCH 1/4] lustre: lnet_startup_lndnet: avoid
 use-after-free
In-Reply-To: <154440246926.29887.1667505755325904791.stgit@noble>
References: <154440246926.29887.1667505755325904791.stgit@noble>
Message-ID: <154440277611.29887.14421165959542572417.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If lnet_startup_lndni() fails it will free 'ni'.
So we mustn't de-reference it in the LASSERT() in that case.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fadd5d7f187a..6d528242acd9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1848,12 +1848,12 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 
 		rc = lnet_startup_lndni(ni, tun);
 
-		LASSERT(ni->ni_net->net_tunables.lct_peer_timeout <= 0 ||
-			ni->ni_net->net_lnd->lnd_query);
-
 		if (rc < 0)
 			goto failed1;
 
+		LASSERT(ni->ni_net->net_tunables.lct_peer_timeout <= 0 ||
+			ni->ni_net->net_lnd->lnd_query);
+
 		lnet_ni_addref(ni);
 		list_add_tail(&ni->ni_netlist, &local_ni_list);
 
