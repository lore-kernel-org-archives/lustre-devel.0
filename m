From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:01 -0400
Subject: [lustre-devel] [PATCH 05/20] lnet: socklnd: remove comments about
 "darwin".
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

As lustre only runs on Linux now, comments about
Darwin are not relevant.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/lnet/klnds/socklnd/socklnd_cb.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 2759455..623478c 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -701,10 +701,6 @@ struct ksock_conn *
 					      KSOCK_MSG_NOOP,
 	       tx->tx_nob, tx->tx_niov, tx->tx_nkiov);
 
-	/*
-	 * FIXME: SOCK_WMEM_QUEUED and SOCK_ERROR could block in __DARWIN8__
-	 * but they're used inside spinlocks a lot.
-	 */
 	bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
 	spin_lock_bh(&sched->kss_lock);
 
@@ -2203,10 +2199,6 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
 		LASSERT(!conn->ksnc_closing);
 
-		/*
-		 * SOCK_ERROR will reset error code of socket in
-		 * some platform (like Darwin8.x)
-		 */
 		error = conn->ksnc_sock->sk->sk_err;
 		if (error) {
 			ksocknal_conn_addref(conn);
-- 
1.8.3.1
