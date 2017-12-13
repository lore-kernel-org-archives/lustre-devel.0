From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 04/12] staging: lustre: ldlm: minor
 list_entry improvements in ldlm_request.c
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495488.27582.6910804861419753279.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Small clarify improvements, and one local variable avoided.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a9a1551cc9bc..a1b909004de8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1653,7 +1653,7 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 	 */
 	while (count > 0) {
 		LASSERT(!list_empty(cancels));
-		lock = list_entry(cancels->next, struct ldlm_lock, l_bl_ast);
+		lock = list_first_entry(cancels, struct ldlm_lock, l_bl_ast);
 		LASSERT(lock->l_conn_export);
 
 		if (exp_connect_cancelset(lock->l_conn_export)) {
@@ -1777,7 +1777,7 @@ EXPORT_SYMBOL(ldlm_cli_cancel_unused);
 static int ldlm_resource_foreach(struct ldlm_resource *res,
 				 ldlm_iterator_t iter, void *closure)
 {
-	struct list_head *tmp, *next;
+	struct ldlm_lock *tmp;
 	struct ldlm_lock *lock;
 	int rc = LDLM_ITER_CONTINUE;
 
@@ -1785,18 +1785,14 @@ static int ldlm_resource_foreach(struct ldlm_resource *res,
 		return LDLM_ITER_CONTINUE;
 
 	lock_res(res);
-	list_for_each_safe(tmp, next, &res->lr_granted) {
-		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
-
+	list_for_each_entry_safe(lock, tmp, &res->lr_granted, l_res_link) {
 		if (iter(lock, closure) == LDLM_ITER_STOP) {
 			rc = LDLM_ITER_STOP;
 			goto out;
 		}
 	}
 
-	list_for_each_safe(tmp, next, &res->lr_waiting) {
-		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
-
+	list_for_each_entry_safe(lock, tmp, &res->lr_waiting, l_res_link) {
 		if (iter(lock, closure) == LDLM_ITER_STOP) {
 			rc = LDLM_ITER_STOP;
 			goto out;
