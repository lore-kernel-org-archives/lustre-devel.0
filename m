From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:52 -0400
Subject: [lustre-devel] [PATCH 11/37] lnet: socklnd: don't fall-back to
 tcp_sendpage.
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

sk_prot->sendpage is never NULL, so there is no
need for a fallback to tcp_sendpage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 011d760069142 ("LU-12678 socklnd: don't fall-back to tcp_sendpage.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39134
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_lib.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 2adc99c..1d6cd0e 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -123,12 +123,8 @@
 		    fragsize < tx->tx_resid)
 			msgflg |= MSG_MORE;
 
-		if (sk->sk_prot->sendpage) {
-			rc = sk->sk_prot->sendpage(sk, page,
-						   offset, fragsize, msgflg);
-		} else {
-			rc = tcp_sendpage(sk, page, offset, fragsize, msgflg);
-		}
+		rc = sk->sk_prot->sendpage(sk, page,
+					   offset, fragsize, msgflg);
 	} else {
 		struct msghdr msg = { .msg_flags = MSG_DONTWAIT };
 		int i;
-- 
1.8.3.1
