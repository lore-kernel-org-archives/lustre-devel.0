From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:39:02 -0400
Subject: [lustre-devel] [PATCH 123/124] staging: lustre: o2iblnd: Put back
	work queue check previously removed
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-124-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

The previous patch, http://review.whamcloud.com/21304/, removed
a check needed until LU-5718 is properly addressed.  With
the check, LU-5718 results in an error message and a lost
RDMA operation.  Without it, we have memory corruption and
a crash (much harder to debug).

Putting the check back in case LU-5718 is not fixed soon.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7650
Reviewed-on: http://review.whamcloud.com/22281
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3a86879..b27de88 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1093,6 +1093,16 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			break;
 		}
 
+		if (tx->tx_nwrq >= IBLND_MAX_RDMA_FRAGS) {
+			CERROR("RDMA has too many fragments for peer %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
+			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
+			       IBLND_MAX_RDMA_FRAGS,
+			       srcidx, srcrd->rd_nfrags,
+			       dstidx, dstrd->rd_nfrags);
+			rc = -EMSGSIZE;
+			break;
+		}
+
 		wrknob = min(min(kiblnd_rd_frag_size(srcrd, srcidx),
 				 kiblnd_rd_frag_size(dstrd, dstidx)),
 			     (__u32)resid);
-- 
1.7.1
