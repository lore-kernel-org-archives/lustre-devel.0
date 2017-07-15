From: James Simmons <jsimmons@infradead.org>
Date: Sat, 15 Jul 2017 11:32:08 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: ko2iblnd: check
	copy_from_iter/copy_to_iter return code
Message-ID: <1500132728-28511-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Amir Shehata <amir.shehata@intel.com>, Olaf Weber <olaf.weber@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, stable@vger.kernel.org, James Simmons <jsimmons@infradead.org>

From: Arnd Bergmann <arnd@arndb.de>

We now get a helpful warning for code that calls copy_{from,to}_iter
without checking the return value, introduced by commit aa28de275a24
("iov_iter/hardening: move object size checks to inlined part").

drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_send':
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1643:2: error: ignoring return value of 'copy_from_iter', declared with attribute warn_unused_result [-Werror=unused-result]
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_recv':
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1744:3: error: ignoring return value of 'copy_to_iter', declared with attribute warn_unused_result [-Werror=unused-result]

In case we get short copies here, we may get incorrect behavior.
I've added failure handling for both rx and tx now, returning
-EFAULT as expected.

Cc: stable at vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c    | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 85b242e..8fc191d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1640,8 +1640,13 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	ibmsg = tx->tx_msg;
 	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
 
-	copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
-		       &from);
+	rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, payload_nob,
+			    &from);
+	if (rc != payload_nob) {
+		kiblnd_pool_free_node(&tx->tx_pool->tpo_pool, &tx->tx_list);
+		return -EFAULT;
+	}
+
 	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
 	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
 
@@ -1741,8 +1746,14 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			break;
 		}
 
-		copy_to_iter(&rxmsg->ibm_u.immediate.ibim_payload,
-			     IBLND_MSG_SIZE, to);
+		rc = copy_to_iter(&rxmsg->ibm_u.immediate.ibim_payload, rlen,
+				  to);
+		if (rc != rlen) {
+			rc = -EFAULT;
+			break;
+		}
+
+		rc = 0;
 		lnet_finalize(ni, lntmsg, 0);
 		break;
 
-- 
1.8.3.1
