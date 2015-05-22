From: James Simmons <jsimmons@infradead.org>
Date: Fri, 22 May 2015 14:32:30 -0400
Subject: [lustre-devel] [PATCH 4/6] staging:lustre: use available kernel
	wrappers in lib-socket.c
In-Reply-To: <uja.ornl@gmail.com>
References: <uja.ornl@gmail.com>
Message-ID: <1432319552-10479-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of handling calls to struct proto ourselves we can use
equivalent kernel wrappers. No wrapper exist for unlocked ioctl
handling so we create one here for our use. I expect some day
that function will be integrated into sock.c.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |   47 ++++++++++++++++---------
 1 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 2e87168..2d46a69 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -35,22 +35,37 @@
  */
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-
 #include <linux/if.h>
 #include <linux/in.h>
+#include <linux/net.h>
 #include <linux/file.h>
+#include <linux/pagemap.h>
 /* For sys_open & sys_close */
 #include <linux/syscalls.h>
+#include <net/sock.h>
+
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/lnet/lib-lnet.h"
+
+static int
+kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
+{
+	mm_segment_t oldfs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = filp->f_op->unlocked_ioctl(filp, cmd, arg);
+	set_fs(oldfs);
+
+	return err;
+}
 
 static int
 lnet_sock_ioctl(int cmd, unsigned long arg)
 {
-	mm_segment_t	oldmm = get_fs();
+	struct file    *sock_filp;
 	struct socket  *sock;
 	int		rc;
-	struct file    *sock_filp;
 
 	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
 	if (rc != 0) {
@@ -65,10 +80,7 @@ lnet_sock_ioctl(int cmd, unsigned long arg)
 		goto out;
 	}
 
-	set_fs(KERNEL_DS);
-	if (sock_filp->f_op->unlocked_ioctl)
-		rc = sock_filp->f_op->unlocked_ioctl(sock_filp, cmd, arg);
-	set_fs(oldmm);
+	rc = kernel_sock_unlocked_ioctl(sock_filp, cmd, arg);
 
 	fput(sock_filp);
 out:
@@ -398,8 +410,8 @@ lnet_sock_create (struct socket **sockp, int *fatal,
 		locaddr.sin_addr.s_addr = (local_ip == 0) ?
 					  INADDR_ANY : htonl(local_ip);
 
-		rc = sock->ops->bind(sock, (struct sockaddr *)&locaddr,
-				     sizeof(locaddr));
+		rc = kernel_bind(sock, (struct sockaddr *)&locaddr,
+				 sizeof(locaddr));
 		if (rc == -EADDRINUSE) {
 			CDEBUG(D_NET, "Port %d already in use\n", local_port);
 			*fatal = 0;
@@ -459,8 +471,10 @@ lnet_sock_getaddr (struct socket *sock, bool remote, __u32 *ip, int *port)
 	int		len = sizeof (sin);
 	int		rc;
 
-	rc = sock->ops->getname (sock, (struct sockaddr *)&sin, &len,
-				 remote ? 2 : 0);
+	if (remote)
+		rc = kernel_getpeername(sock, (struct sockaddr *)&sin, &len);
+	else
+		rc = kernel_getsockname(sock, (struct sockaddr *)&sin, &len);
 	if (rc != 0) {
 		CERROR ("Error %d getting sock %s IP/port\n",
 			rc, remote ? "peer" : "local");
@@ -510,7 +524,7 @@ lnet_sock_listen (struct socket **sockp,
 		return rc;
 	}
 
-	rc = (*sockp)->ops->listen(*sockp, backlog);
+	rc = kernel_listen(*sockp, backlog);
 	if (rc == 0)
 		return 0;
 
@@ -581,9 +595,8 @@ lnet_sock_connect (struct socket **sockp, int *fatal,
 	srvaddr.sin_port = htons(peer_port);
 	srvaddr.sin_addr.s_addr = htonl(peer_ip);
 
-	rc = (*sockp)->ops->connect(*sockp,
-				    (struct sockaddr *)&srvaddr, sizeof(srvaddr),
-				    0);
+	rc = kernel_connect(*sockp, (struct sockaddr *)&srvaddr,
+			    sizeof(srvaddr), 0);
 	if (rc == 0)
 		return 0;
 
-- 
1.7.1
