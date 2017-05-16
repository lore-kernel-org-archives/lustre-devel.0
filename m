From: Paolo Cretaro <melko@frugalware.org>
Date: Tue, 16 May 2017 22:56:10 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: specify address space
Message-ID: <20170516205610.21324-1-melko@frugalware.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix warning issued by sparse:
incorrect type in assignment (different address spaces).

Signed-off-by: Paolo Cretaro <melko@frugalware.org>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 9fca8d225ee0..e5e5213b4da0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -181,7 +181,7 @@ lnet_ipif_enumerate(char ***namesp)
 			goto out0;
 		}
 
-		ifc.ifc_buf = (char *)ifr;
+		ifc.ifc_buf = (char __user *)ifr;
 		ifc.ifc_len = nalloc * sizeof(*ifr);
 
 		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
-- 
2.13.0
