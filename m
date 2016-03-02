From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:52 -0500
Subject: [lustre-devel] [PATCH 09/27] staging: lustre: set task state before
	scheduling in lnet_sock_accept
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>

From: John L. Hammond <john.hammond@intel.com>

In the original code change when libcfs_sock_accept() was made
into lnet_sock_accept() a call to set_current_state(TASK_INTERRUPTIBLE)
got dropped which was restored. For upstream this is an
optimization of calling init_waitqueue_entry() only if
accept() return -EAGAIN. Also we can remove setting the
task to TASK_RUNNING that is not needed.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6407
Reviewed-on: http://review.whamcloud.com/14265
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 5d77049..269a6d8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -531,8 +531,6 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 	struct socket *newsock;
 	int rc;
 
-	init_waitqueue_entry(&wait, current);
-
 	/*
 	 * XXX this should add a ref to sock->ops->owner, if
 	 * TCP could be a module
@@ -548,11 +546,11 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 	rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
 	if (rc == -EAGAIN) {
 		/* Nothing ready, so wait for activity */
-		set_current_state(TASK_INTERRUPTIBLE);
+		init_waitqueue_entry(&wait, current);
 		add_wait_queue(sk_sleep(sock->sk), &wait);
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule();
 		remove_wait_queue(sk_sleep(sock->sk), &wait);
-		set_current_state(TASK_RUNNING);
 		rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
 	}
 
-- 
1.7.1
