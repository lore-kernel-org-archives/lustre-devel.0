From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: ldlm: use
 list_first_entry in ldlm_lock
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956711.22133.6246810949146823613.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This make the code (slightly) more readable.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index b5d84f3f6071..ed061cc46986 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1685,7 +1685,7 @@ ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	if (list_empty(arg->list))
 		return -ENOENT;
 
-	lock = list_entry(arg->list->next, struct ldlm_lock, l_bl_ast);
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_bl_ast);
 
 	/* nobody should touch l_bl_ast */
 	lock_res_and_lock(lock);
@@ -1721,7 +1721,7 @@ ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	if (list_empty(arg->list))
 		return -ENOENT;
 
-	lock = list_entry(arg->list->next, struct ldlm_lock, l_cp_ast);
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_cp_ast);
 
 	/* It's possible to receive a completion AST before we've set
 	 * the l_completion_ast pointer: either because the AST arrived
@@ -1767,7 +1767,7 @@ ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	if (list_empty(arg->list))
 		return -ENOENT;
 
-	lock = list_entry(arg->list->next, struct ldlm_lock, l_rk_ast);
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_rk_ast);
 	list_del_init(&lock->l_rk_ast);
 
 	/* the desc just pretend to exclusive */
@@ -1794,7 +1794,7 @@ static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	if (list_empty(arg->list))
 		return -ENOENT;
 
-	gl_work = list_entry(arg->list->next, struct ldlm_glimpse_work,
+	gl_work = list_first_entry(arg->list, struct ldlm_glimpse_work,
 			     gl_list);
 	list_del_init(&gl_work->gl_list);
 
