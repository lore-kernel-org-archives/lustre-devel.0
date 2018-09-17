From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:26 -0400
Subject: [lustre-devel] [PATCH 16/30] lustre: lnet: Change sock_create() to
 sock_create_kern()
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <dougso@me.com>

Changing all calls from sock_create() to sock_create_kern().

Signed-off-by: Doug Oucharek <dougso@me.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9456
Reviewed-on: https://review.whamcloud.com/26958
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 6758090..d9c62d3 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -157,7 +157,7 @@
 	/* All errors are fatal except bind failure if the port is in use */
 	*fatal = 1;
 
-	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
+	rc = sock_create_kern(&init_net, PF_INET, SOCK_STREAM, 0, &sock);
 	*sockp = sock;
 	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
-- 
1.8.3.1
