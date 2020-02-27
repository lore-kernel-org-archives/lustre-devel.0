From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:59 -0500
Subject: [lustre-devel] [PATCH 131/622] lustre: ldlm: update l_blocking_lock
 under lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-132-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Update l_blocking_lock under with locking to prevent race
between lock_handle_convert0() and ldlm_work_bl_ast() code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11287
Lustre-commit: 2a520282888d ("LU-11287 ldlm: update l_blocking_lock under lock")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33124
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lock.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index bdbbfec..869d664 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1639,16 +1639,7 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 
 	lock = list_first_entry(arg->list, struct ldlm_lock, l_bl_ast);
 
-	/* nobody should touch l_bl_ast */
-	lock_res_and_lock(lock);
-	list_del_init(&lock->l_bl_ast);
-
-	LASSERT(ldlm_is_ast_sent(lock));
-	LASSERT(lock->l_bl_ast_run == 0);
 	LASSERT(lock->l_blocking_lock);
-	lock->l_bl_ast_run++;
-	unlock_res_and_lock(lock);
-
 	ldlm_lock2desc(lock->l_blocking_lock, &d);
 	/* copy blocking lock ibits in cancel_bits as well,
 	 * new client may use them for lock convert and it is
@@ -1658,9 +1649,16 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 	d.l_policy_data.l_inodebits.cancel_bits =
 		lock->l_blocking_lock->l_policy_data.l_inodebits.bits;
 
+	/* nobody should touch l_bl_ast */
+	lock_res_and_lock(lock);
+	list_del_init(&lock->l_bl_ast);
+
+	LASSERT(ldlm_is_ast_sent(lock));
+	LASSERT(lock->l_bl_ast_run == 0);
+	lock->l_bl_ast_run++;
+	unlock_res_and_lock(lock);
+
 	rc = lock->l_blocking_ast(lock, &d, (void *)arg, LDLM_CB_BLOCKING);
-	LDLM_LOCK_RELEASE(lock->l_blocking_lock);
-	lock->l_blocking_lock = NULL;
 	LDLM_LOCK_RELEASE(lock);
 
 	return rc;
-- 
1.8.3.1
