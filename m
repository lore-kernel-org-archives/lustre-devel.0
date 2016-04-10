From: Antoine BLIN <antoine.blin@lip6.fr>
Date: Sun, 10 Apr 2016 14:46:40 +0200
Subject: [lustre-devel] [PATCH] Mark a pointer as an userspace pointer using
	__user macro.
Message-ID: <1460292400-2732-1-git-send-email-antoine.blin@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This change fixes below sparse error: "error: incompatible types
in comparison expression (different address spaces)"

Signed-off-by: Antoine BLIN <antoine.blin@lip6.fr>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 2be9451..1fdabb3 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -490,10 +490,10 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 				   sizeof(struct list_head)))
 			return -EFAULT;
 
-		if (tmp.next == head_up)
-			return 0;
+		next = (struct list_head __user *)tmp.next;
 
-		next = tmp.next;
+		if (next == head_up)
+			return 0;
 
 		ent = list_entry(next, lstcon_rpc_ent_t, rpe_link);
 
-- 
2.7.4
