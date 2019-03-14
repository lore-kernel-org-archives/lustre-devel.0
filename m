From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 18/32] lustre: socklnd: don't fall-back to
 tcp_sendpage.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231068.26912.10651319318558325240.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

sk_prot->sendpage is never NULL, so there is no
need for a fallback to tcp_sendpage.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index a4dc384c298e..2b5430452a73 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -123,12 +123,8 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
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
