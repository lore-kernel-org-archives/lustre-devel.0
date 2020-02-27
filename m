From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:36 -0500
Subject: [lustre-devel] [PATCH 288/622] lnet: use number of wrs to calculate
 CQEs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-289-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Using concurrent sends to calculate the number of CQEs results
in a small number of CQEs which exposes an issue where under
failure scenarios, example when a node reboots, there wouldn't
be enough CQEs available leading to IB_EVENT_QP_FATAL

Fixes: b61010ddf672 ("lnet: lnd: bring back concurrent_sends")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12279
Lustre-commit: 24294b843f79 ("LU-12279 lnet: use number of wrs to calculate CQEs")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34945
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index eb80d5e..2f7ca52 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -136,9 +136,7 @@ struct kib_tunables {
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 
-#define IBLND_CQ_ENTRIES(c)	\
-	(IBLND_RECV_WRS(c) + 2 * kiblnd_concurrent_sends(c->ibc_version, \
-							 c->ibc_peer->ibp_ni))
+#define IBLND_CQ_ENTRIES(c) (IBLND_RECV_WRS(c) + kiblnd_send_wrs(c))
 
 struct kib_hca_dev;
 
-- 
1.8.3.1
