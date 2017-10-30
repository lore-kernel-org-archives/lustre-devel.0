From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: ldlm: minor
 list_entry improvements in ldlm_request.c
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956722.22133.16215765622967632452.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f5e791a92f62..1e7b8fc4dd00 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1642,7 +1642,7 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 	 */
 	while (count > 0) {
 		LASSERT(!list_empty(cancels));
-		lock = list_entry(cancels->next, struct ldlm_lock, l_bl_ast);
+		lock = list_first_entry(cancels, struct ldlm_lock, l_bl_ast);
 		LASSERT(lock->l_conn_export);
 
 		if (exp_connect_cancelset(lock->l_conn_export)) {
@@ -1766,7 +1766,7 @@ EXPORT_SYMBOL(ldlm_cli_cancel_unused);
 static int ldlm_resource_foreach(struct ldlm_resource *res,
 				 ldlm_iterator_t iter, void *closure)
 {
-	struct list_head *tmp, *next;
+	struct ldlm_lock *tmp;
 	struct ldlm_lock *lock;
 	int rc = LDLM_ITER_CONTINUE;
 
@@ -1774,18 +1774,14 @@ static int ldlm_resource_foreach(struct ldlm_resource *res,
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
