From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:39 -0500
Subject: [lustre-devel] [PATCH 531/622] lustre: modules: Use LIST_HEAD for
 declaring list_heads
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-532-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than
  struct list_head foo = LIST_HEAD_INIT(foo);
use
  LIST_HEAD(foo);

This is shorter and more in-keeping with upstream style.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 546993d587c5 ("LU-9679 modules: Use LIST_HEAD for declaring list_heads")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36669
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c   | 2 +-
 fs/lustre/mdc/mdc_reint.c   | 2 +-
 fs/lustre/osc/osc_request.c | 2 +-
 fs/lustre/ptlrpc/pinger.c   | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index b91c162..4d40087 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -581,7 +581,7 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 						     struct md_op_data *op_data)
 {
 	struct obd_device *obd = class_exp2obd(exp);
-	struct list_head cancels = LIST_HEAD_INIT(cancels);
+	LIST_HEAD(cancels);
 	struct ptlrpc_request *req;
 	struct ldlm_intent *lit;
 	struct layout_intent *layout;
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index d26e27d..0dc0de4 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -470,7 +470,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 int mdc_file_resync(struct obd_export *exp, struct md_op_data *op_data)
 {
-	struct list_head cancels = LIST_HEAD_INIT(cancels);
+	LIST_HEAD(cancels);
 	struct ptlrpc_request *req;
 	struct ldlm_lock *lock;
 	struct mdt_rec_resync *rec;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 39cac7d..d6761dd 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3382,7 +3382,7 @@ int osc_cleanup_common(struct obd_device *obd)
 	.quotactl	= osc_quotactl,
 };
 
-struct list_head osc_shrink_list = LIST_HEAD_INIT(osc_shrink_list);
+LIST_HEAD(osc_shrink_list);
 DEFINE_SPINLOCK(osc_shrink_lock);
 
 static struct shrinker osc_cache_shrinker = {
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index f584fc6..d8f57bb 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -43,7 +43,7 @@
 
 struct mutex pinger_mutex;
 static LIST_HEAD(pinger_imports);
-static struct list_head timeout_list = LIST_HEAD_INIT(timeout_list);
+static LIST_HEAD(timeout_list);
 
 struct ptlrpc_request *
 ptlrpc_prep_ping(struct obd_import *imp)
-- 
1.8.3.1
