From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:51 -0400
Subject: [lustre-devel] [PATCH 10/37] lnet: Fix some out-of-date comments.
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The structures these comments describe have changed or been removed,
but the comments weren't updated at the time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 617ad3af720a3 ("LU-12678 lnet: Fix some out-of-date comments.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39127
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 7d49fff..0ac3637 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -255,15 +255,13 @@ struct ksock_nal_data {
 #define SOCKNAL_INIT_DATA	1
 #define SOCKNAL_INIT_ALL	2
 
-/*
- * A packet just assembled for transmission is represented by 1 or more
- * struct iovec fragments (the first frag contains the portals header),
- * followed by 0 or more struct bio_vec fragments.
+/* A packet just assembled for transmission is represented by 1
+ * struct iovec fragment - the portals header -  followed by 0
+ * or more struct bio_vec fragments.
  *
  * On the receive side, initially 1 struct iovec fragment is posted for
  * receive (the header).  Once the header has been received, the payload is
- * received into either struct iovec or struct bio_vec fragments, depending on
- * what the header matched or whether the message needs forwarding.
+ * received into struct bio_vec fragments.
  */
 struct ksock_conn;				/* forward ref */
 struct ksock_route;				/* forward ref */
@@ -296,8 +294,6 @@ struct ksock_tx {				/* transmit packet */
 
 #define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_payload[0]))
 
-/* network zero copy callback descriptor embedded in struct ksock_tx */
-
 #define SOCKNAL_RX_KSM_HEADER	1 /* reading ksock message header */
 #define SOCKNAL_RX_LNET_HEADER	2 /* reading lnet message header */
 #define SOCKNAL_RX_PARSE	3 /* Calling lnet_parse() */
-- 
1.8.3.1
