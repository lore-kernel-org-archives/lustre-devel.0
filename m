From: Guillermo O. Freschi <kedrot@gmail.com>
Date: Wed,  7 Jun 2017 06:15:19 -0300
Subject: [lustre-devel] [PATCH 2/2] drivers: staging/lustre: conrpc.c - fix
	sparse warning: warning: incorrect type in argument *
	(different address spaces)
In-Reply-To: <20170607091519.5248-1-kedrot@gmail.com>
References: <8FAAC9A9-A33E-40FA-B073-C4E0EAA7725A@intel.com>
	<20170607091519.5248-1-kedrot@gmail.com>
Message-ID: <20170607091519.5248-2-kedrot@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org
Cc: "Guillermo O. Freschi" <kedrot@gmail.com>

The calls to `copy_to_user` suggest that `ent` is pointing to userspace
memory, but `ent` is missing the `__user` qualifier.

Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index f4578200994f..04a5d7e80151 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -469,7 +469,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 {
 	struct list_head tmp;
 	struct list_head __user *next;
-	struct lstcon_rpc_ent *ent;
+	struct lstcon_rpc_ent __user *ent;
 	struct srpc_generic_reply *rep;
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *msg;
-- 
2.11.0
