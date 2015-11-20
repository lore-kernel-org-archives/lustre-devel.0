From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:10 -0500
Subject: [lustre-devel] [PATCH 34/40] staging: lustre: remove unnecessary
	EXPORT_SYMBOL from lnet layer
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13320
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c     |    1 -
 drivers/staging/lustre/lnet/lnet/lib-move.c   |    1 -
 drivers/staging/lustre/lnet/lnet/lib-socket.c |    3 ---
 drivers/staging/lustre/lnet/selftest/conctl.c |    2 --
 4 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 34f8c1b..7f5e0e8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -358,7 +358,6 @@ lnet_counters_reset(void)
 
 	lnet_net_unlock(LNET_LOCK_EX);
 }
-EXPORT_SYMBOL(lnet_counters_reset);
 
 static char *
 lnet_res_type2str(int type)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index c2cc8c8..430cb9a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1715,7 +1715,6 @@ lnet_msgtyp2str(int type)
 		return "<UNKNOWN>";
 	}
 }
-EXPORT_SYMBOL(lnet_msgtyp2str);
 
 void
 lnet_print_hdr(lnet_hdr_t *hdr)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 6f7ef4c..ccb425d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -513,7 +513,6 @@ lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
 	sock_release(*sockp);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_listen);
 
 int
 lnet_sock_accept(struct socket **newsockp, struct socket *sock)
@@ -555,7 +554,6 @@ failed:
 	sock_release(newsock);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_accept);
 
 int
 lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
@@ -591,4 +589,3 @@ lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
 	sock_release(*sockp);
 	return rc;
 }
-EXPORT_SYMBOL(lnet_sock_connect);
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 3dc8ea7..73e71cd 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -931,5 +931,3 @@ out:
 
 	return rc;
 }
-
-EXPORT_SYMBOL(lstcon_ioctl_entry);
-- 
1.7.1
