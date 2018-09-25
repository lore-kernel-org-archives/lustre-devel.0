From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:16 +1000
Subject: [lustre-devel] [PATCH 31/34] LU-7734 lnet: fix NULL access in
 lnet_peer_aliveness_enabled
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763604.32103.1694406227193499062.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

When a peer is not on a local network, lpni->lpni_net is NULL.
The lpni_net is access in lnet_peer_aliveness_enabled() without
checking if it's NULL. Fixed.

Test-Parameters: trivial
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: If328728e2bda2a19b273140a20c04b22bdda6bc4
Reviewed-on: http://review.whamcloud.com/22183
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 2d73aa1a121c..f811f125dfcb 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -534,6 +534,7 @@ struct lnet_peer_table {
  */
 #define lnet_peer_aliveness_enabled(lp)				\
 	(the_lnet.ln_routing &&					\
+	 (lp)->lpni_net &&					\
 	 (lp)->lpni_net->net_tunables.lct_peer_timeout > 0)
 
 struct lnet_route {
