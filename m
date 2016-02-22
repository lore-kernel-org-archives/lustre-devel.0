From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:21 -0500
Subject: [lustre-devel] [PATCH 20/24] staging: lustre: avoid race during
	lnet acceptor thread termination
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>

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
index 8f9876b..3468433 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -488,11 +488,17 @@ lnet_acceptor_start(void)
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
