From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:48 -0500
Subject: [lustre-devel] [PATCH 240/622] lnet: lnd: increase CQ entries
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-241-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Several sites have reported RDMA timeouts. Most of the timeouts
are occurring for transmits on the active_tx queue. Transmits are
placed on the active_tx queue until a completion is received. If
there isn't enough CQ entries available, it's possible for a
completions events to be delayed, causing these timeouts.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12065
Lustre-commit: bf3fc7f1a7bf ("LU-12065 lnd: increase CQ entries")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34473
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 999b58d..44f1d84 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -136,8 +136,7 @@ struct kib_tunables {
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 
-#define IBLND_CQ_ENTRIES(c)	\
-	(IBLND_RECV_WRS(c) + 2 * c->ibc_queue_depth)
+#define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + kiblnd_send_wrs(c))
 
 struct kib_hca_dev;
 
-- 
1.8.3.1
