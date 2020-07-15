From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:43 -0400
Subject: [lustre-devel] [PATCH 02/37] lustre: ldlm: check slv and limit
 before updating
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

slv and limit do not change for most of time,
ldlm_cli_update_pool() could be called for each RPC reply,
try hold read lock to check firstly could avoid heavy write
lock in hot path.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13365
Lustre-commit: 3116b9e19dc09 ("LU-13365 ldlm: check slv and limit before updating")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/37969
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index e1ba596..6318137 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1163,6 +1163,14 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 	new_slv = lustre_msg_get_slv(req->rq_repmsg);
 	obd = req->rq_import->imp_obd;
 
+	read_lock(&obd->obd_pool_lock);
+	if (obd->obd_pool_slv == new_slv &&
+	    obd->obd_pool_limit == new_limit) {
+		read_unlock(&obd->obd_pool_lock);
+		return 0;
+	}
+	read_unlock(&obd->obd_pool_lock);
+
 	/*
 	 * Set new SLV and limit in OBD fields to make them accessible
 	 * to the pool thread. We do not access obd_namespace and pool
-- 
1.8.3.1
