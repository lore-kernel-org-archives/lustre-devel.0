From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:54 -0500
Subject: [lustre-devel] [PATCH 11/27] staging: lustre: bind socklnd peers to
	a specific CPT
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Currently the socklnd driver doesn't support
CPT affinity for its peers. Binding peers to
a specific CPT and memory allocated to the
NUMA node belonging to the CPT should give a
performance boost.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7245
Reviewed-on: http://review.whamcloud.com/16710
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index d843082..2c83b95 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -102,6 +102,7 @@ ksocknal_destroy_route(ksock_route_t *route)
 static int
 ksocknal_create_peer(ksock_peer_t **peerp, lnet_ni_t *ni, lnet_process_id_t id)
 {
+	int cpt = lnet_cpt_of_nid(id.nid);
 	ksock_net_t *net = ni->ni_data;
 	ksock_peer_t *peer;
 
@@ -109,7 +110,7 @@ ksocknal_create_peer(ksock_peer_t **peerp, lnet_ni_t *ni, lnet_process_id_t id)
 	LASSERT(id.pid != LNET_PID_ANY);
 	LASSERT(!in_interrupt());
 
-	LIBCFS_ALLOC(peer, sizeof(*peer));
+	LIBCFS_CPT_ALLOC(peer, lnet_cpt_table(), cpt, sizeof(*peer));
 	if (!peer)
 		return -ENOMEM;
 
-- 
1.7.1
