From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:55 -0500
Subject: [lustre-devel] [PATCH 12/27] staging: lustre: fix socklnd issues
	found by Klocwork Insight tool
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Null pointer 'best_iface' that comes from line 802 may be
dereferenced at line 832.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9386
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 2c83b95..a710541 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -804,6 +804,8 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 			ip = peer->ksnp_passive_ips[i];
 			best_iface = ksocknal_ip2iface(peer->ksnp_ni, ip);
 
+			/* peer passive ips are kept up to date */
+			LASSERT(best_iface);
 		} else {
 			/* choose a new interface */
 			LASSERT(i == peer->ksnp_n_passive_ips);
@@ -838,6 +840,8 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 				best_npeers = iface->ksni_npeers;
 			}
 
+			LASSERT(best_iface);
+
 			best_iface->ksni_npeers++;
 			ip = best_iface->ksni_ipaddr;
 			peer->ksnp_passive_ips[i] = ip;
-- 
1.7.1
