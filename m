From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:24 -0500
Subject: [lustre-devel] [PATCH 576/622] lnet: discard struct ksock_peer
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-577-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

struct ksock_peer is declared in a forward-ref, but
never defined or used.  Let's remove it, and change
some spaces to TABs while we are there.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 179d50565e0b ("LU-12678 lnet: discard struct ksock_peer")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36835
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 832bc08..2d4e8d59 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -264,10 +264,9 @@ struct ksock_nal_data {
  * received into either struct iovec or struct bio_vec fragments, depending on
  * what the header matched or whether the message needs forwarding.
  */
-struct ksock_conn;  /* forward ref */
-struct ksock_peer_ni;  /* forward ref */
-struct ksock_route; /* forward ref */
-struct ksock_proto; /* forward ref */
+struct ksock_conn;				/* forward ref */
+struct ksock_route;				/* forward ref */
+struct ksock_proto;				/* forward ref */
 
 struct ksock_tx {				/* transmit packet */
 	struct list_head	tx_list;	/* queue on conn for transmission etc
-- 
1.8.3.1
