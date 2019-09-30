From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:32 -0400
Subject: [lustre-devel] [PATCH 013/151] lustre: fld: fld client lookup
 should retry
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Di <di.wang@intel.com>

If FLD client lookup fails because of the remote target
is shutdown (or deactive), it should retry another target,
otherwise it will cause the application failure.

And FLD client should stop retry if the import has
been deactive.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6419
Lustre-commit: 3ededde903c ("LU-6419 fld: fld client lookup should retry")
Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/14313
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 062f19f..75cba18 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -367,7 +367,7 @@ int fld_client_rpc(struct obd_export *exp,
 	rc = ptlrpc_queue_wait(req);
 	obd_put_request_slot(&exp->exp_obd->u.cli);
 	if (rc != 0) {
-		if (imp->imp_state != LUSTRE_IMP_CLOSED) {
+		if (imp->imp_state != LUSTRE_IMP_CLOSED && !imp->imp_deactive) {
 			/* Since LWP is not replayable, so it will keep
 			 * trying unless umount happens, otherwise it would
 			 * cause unnecessary failure of the application.
@@ -404,6 +404,7 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 {
 	struct lu_seq_range res = { 0 };
 	struct lu_fld_target *target;
+	struct lu_fld_target *origin;
 	int rc;
 
 	rc = fld_cache_lookup(fld->lcf_cache, seq, &res);
@@ -415,7 +416,8 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 	/* Can not find it in the cache */
 	target = fld_client_get_target(fld, seq);
 	LASSERT(target);
-
+	origin = target;
+again:
 	CDEBUG(D_INFO,
 	       "%s: Lookup fld entry (seq: %#llx) on target %s (idx %llu)\n",
 	       fld->lcf_name, seq, fld_target_name(target), target->ft_idx);
@@ -424,6 +426,23 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 	fld_range_set_type(&res, flags);
 	rc = fld_client_rpc(target->ft_exp, &res, FLD_QUERY, NULL);
 
+	if (rc == -ESHUTDOWN) {
+		/* If fld lookup failed because the target has been shutdown,
+		 * then try next target in the list, until trying all targets
+		 * or fld lookup succeeds
+		 */
+		spin_lock(&fld->lcf_lock);
+		if (target->ft_chain.next == fld->lcf_targets.prev)
+			target = list_entry(fld->lcf_targets.next,
+					    struct lu_fld_target, ft_chain);
+		else
+			target = list_entry(target->ft_chain.next,
+						 struct lu_fld_target,
+						 ft_chain);
+		spin_unlock(&fld->lcf_lock);
+		if (target != origin)
+			goto again;
+	}
 	if (rc == 0) {
 		*mds = res.lsr_index;
 
-- 
1.8.3.1
