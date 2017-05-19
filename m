From: Nikola Jelic <nikola.jelic83@gmail.com>
Date: Fri, 19 May 2017 20:48:07 +0200
Subject: [lustre-devel] [PATCH] lustre: ko2iblnd: removed forced u32 casts
	after htonl
Message-ID: <20170519184807.9783-1-nikola.jelic83@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

sockaddr_in.sin_addr.s_addr is __be32 integral type, so the (__force u32)
cast after the htonl call is unnecessary, and also detected by sparse:
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2309:33: warning: incorrect type in assignment (different base types)
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2381:30: warning: incorrect type in assignment (different base types)

Signed-off-by: Nikola Jelic <nikola.jelic83@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 79321e4aaf30..0520f02f670d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2306,7 +2306,7 @@ static int kiblnd_dev_need_failover(struct kib_dev *dev)
 
 	memset(&srcaddr, 0, sizeof(srcaddr));
 	srcaddr.sin_family = AF_INET;
-	srcaddr.sin_addr.s_addr = (__force u32)htonl(dev->ibd_ifip);
+	srcaddr.sin_addr.s_addr = htonl(dev->ibd_ifip);
 
 	memset(&dstaddr, 0, sizeof(dstaddr));
 	dstaddr.sin_family = AF_INET;
@@ -2378,7 +2378,7 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 
 	memset(&addr, 0, sizeof(addr));
 	addr.sin_family      = AF_INET;
-	addr.sin_addr.s_addr = (__force u32)htonl(dev->ibd_ifip);
+	addr.sin_addr.s_addr = htonl(dev->ibd_ifip);
 	addr.sin_port	= htons(*kiblnd_tunables.kib_service);
 
 	/* Bind to failover device or port */
-- 
2.11.0
