From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:20 -0500
Subject: [lustre-devel] [PATCH 19/24] staging: lustre: remove unnecessary
	EXPORT_SYMBOL from lnet layer
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13320
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 53dd0bd..88905d5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -514,7 +514,6 @@ lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
 	sock_release(*sockp);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_listen);
 
 int
 lnet_sock_accept(struct socket **newsockp, struct socket *sock)
@@ -558,7 +557,6 @@ failed:
 	sock_release(newsock);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_accept);
 
 int
 lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
@@ -596,4 +594,3 @@ lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
 	sock_release(*sockp);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_connect);
-- 
1.7.1
