From: Guillermo O. Freschi <kedrot@gmail.com>
Date: Fri,  5 May 2017 10:51:29 -0300
Subject: [lustre-devel] [PATCH] drivers: staging/lustre: conrpc.c - fix
	sparse error: incompatible types in comparison expression
	(different address spaces)
Message-ID: <20170505135129.14757-1-kedrot@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org
Cc: "Guillermo O. Freschi" <kedrot@gmail.com>

Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index da36c55b86d3..f4578200994f 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -487,7 +487,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 				   sizeof(struct list_head)))
 			return -EFAULT;
 
-		if (tmp.next == head_up)
+		if ((struct list_head __user *)tmp.next == head_up)
 			return 0;
 
 		next = tmp.next;
-- 
2.11.0
