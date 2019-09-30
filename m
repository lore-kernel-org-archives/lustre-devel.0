From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:30 -0400
Subject: [lustre-devel] [PATCH 131/151] lustre: ldlm: fix export reference
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-132-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In ptlrpc_connect_interpert, the export reference could be
leaked if there is error before the following class_exp_put.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10656
Lustre-commit: e52f2ea40e55 ("LU-10656 ldlm: fix export reference")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31139
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 152a84c..6fc0c6b 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -935,7 +935,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	u64 old_connect_flags;
 	int msg_flags;
 	struct obd_connect_data *ocd;
-	struct obd_export *exp;
+	struct obd_export *exp = NULL;
 	int ret;
 
 	spin_lock(&imp->imp_lock);
@@ -1040,6 +1040,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	rc = ptlrpc_connect_set_flags(imp, ocd, old_connect_flags, exp,
 				      aa->pcaa_initial_connect);
 	class_export_put(exp);
+	exp = NULL;
+
 	if (rc)
 		goto out;
 
@@ -1205,6 +1207,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	imp->imp_connect_tried = 1;
 	spin_unlock(&imp->imp_lock);
 
+	if (exp)
+		class_export_put(exp);
+
 	if (rc != 0) {
 		IMPORT_SET_STATE(imp, LUSTRE_IMP_DISCON);
 		if (rc == -EACCES) {
-- 
1.8.3.1
