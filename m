From: Nikola Jelic <nikola.jelic83@gmail.com>
Date: Sat, 27 May 2017 23:37:28 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: changed __u32 to __be32
Message-ID: <20170527213728.19297-1-nikola.jelic83@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Temporary variable is used only as __be32, for both assignments and reads,
but the type is inconsistent (__u32).

Signed-off-by: Nikola Jelic <nikola.jelic83@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 9fca8d225ee0..776f3c2fa486 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -89,7 +89,7 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 	struct ifreq ifr;
 	int nob;
 	int rc;
-	__u32 val;
+	__be32 val;
 
 	nob = strnlen(name, IFNAMSIZ);
 	if (nob == IFNAMSIZ) {
-- 
2.11.0
