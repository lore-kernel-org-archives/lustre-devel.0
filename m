From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:26 -0400
Subject: [lustre-devel] [PATCH 04/10] lustre: lnd: use less CQ entries for
 each connection
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

Currently we have a 2 work requests chains per transfer.
It mean OFED stack will generate only 2 events if transfer will
faild. Reduce number CQ entries to avoid extra resource consumption.

Signed-off-by: Alexey Lyashkov <c17817@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9810
Seagate-bug-id: MRP-4508
Reviewed-on: https://review.whamcloud.com/28279
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index a6008ea..cd64cfb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -142,7 +142,9 @@ struct kib_tunables {
 #define IBLND_SEND_WRS(c)	\
 	((c->ibc_max_frags + 1) * kiblnd_concurrent_sends(c->ibc_version, \
 							  c->ibc_peer->ibp_ni))
-#define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + IBLND_SEND_WRS(c))
+#define IBLND_CQ_ENTRIES(c)	\
+	(IBLND_RECV_WRS(c) + 2 * kiblnd_concurrent_sends(c->ibc_version, \
+							 c->ibc_peer->ibp_ni))
 
 struct kib_hca_dev;
 
-- 
1.8.3.1
