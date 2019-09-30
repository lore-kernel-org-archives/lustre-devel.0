From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:06 -0400
Subject: [lustre-devel] [PATCH 107/151] lustre: recovery: support setstripe
 replay
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-108-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Regular file open will always reserve space for LOV ea, which is used
to store user specified lov_user_md, or lov_mds_md for replay, but if
this open is the first open in 'lfs setstripe', it doesn't have
lov_user_md specified, or lov_mds_md for replay because
O_LOV_DELAY_CREATE is set, but MDT will treat the EA field in the
request as valid one, so fails in magic check in this open replay.

This patch contains the fix for the client side.

1. client doesn't reserve space for LOV ea in
   open(O_LOV_DELAY_CREATE), this change is not necessary, but to
   make clean of the code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10155
Lustre-commit: 3a0a50f44f68 ("LU-10155 recovery: support setstripe replay")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30704
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 0b358b6..2eb6e8a 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -297,8 +297,14 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
 			     op_data->op_namelen + 1);
-	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
-			     max(lmmsize, obddev->u.cli.cl_default_mds_easize));
+	if (cl_is_lov_delay_create(it->it_flags)) {
+		/* open(O_LOV_DELAY_CREATE) won't pack lmm */
+		LASSERT(lmmsize == 0);
+		req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT, 0);
+	} else {
+		req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
+			max(lmmsize, obddev->u.cli.cl_default_mds_easize));
+	}
 
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
 			     RCL_CLIENT, op_data->op_file_secctx_name ?
-- 
1.8.3.1
