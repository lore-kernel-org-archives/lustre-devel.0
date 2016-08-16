From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:31 -0400
Subject: [lustre-devel] [PATCH 78/80] staging: lustre: lnet: make connection
	more stable with packet loss
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-79-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander.boyko@seagate.com>, Alexey Lyashkov <alexey.lyashkov@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander.boyko@seagate.com>

IB network may lose last connection handshake packet.
This problem isn't Lustre specific and described at
https://oss.oracle.com/pipermail/rds-devel/2007-December/000271.html
for example. Solution is to make conection established if any packet
is received for it.

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Seagate-bug-id: MRP-2883
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8303
Reviewed-on: http://review.whamcloud.com/20874
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 19c90fc..6cd78ea 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3419,6 +3419,12 @@ kiblnd_qp_event(struct ib_event *event, void *arg)
 	case IB_EVENT_COMM_EST:
 		CDEBUG(D_NET, "%s established\n",
 		       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+		/*
+		 * We received a packet but connection isn't established
+		 * probably handshake packet was lost, so free to
+		 * force make connection established
+		 */
+		rdma_notify(conn->ibc_cmid, IB_EVENT_COMM_EST);
 		return;
 
 	default:
-- 
1.7.1
