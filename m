From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:11 -0500
Subject: [lustre-devel] [PATCH 35/40] staging: lustre: avoid race during
	lnet acceptor thread termination
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

This patch will avoid potential race, around socket sleepers
wait list, during acceptor thread termination and using
sk_callback_lock RW-Lock protection.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6476
Reviewed-on: http://review.whamcloud.com/14503
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/acceptor.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index ffa2b19..61806ce 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -485,11 +485,17 @@ lnet_acceptor_start(void)
 void
 lnet_acceptor_stop(void)
 {
+	struct sock *sk;
+
 	if (lnet_acceptor_state.pta_shutdown) /* not running */
 		return;
 
 	lnet_acceptor_state.pta_shutdown = 1;
-	wake_up_all(sk_sleep(lnet_acceptor_state.pta_sock->sk));
+
+	sk = lnet_acceptor_state.pta_sock->sk;
+
+	/* awake any sleepers using safe method */
+	sk->sk_state_change(sk);
 
 	/* block until acceptor signals exit */
 	wait_for_completion(&lnet_acceptor_state.pta_signal);
-- 
1.7.1
