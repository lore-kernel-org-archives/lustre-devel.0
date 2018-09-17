From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:13 -0400
Subject: [lustre-devel] [PATCH 03/30] lustre: osc: fix for cl_env_get in low
 memory
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

In low memory situation cl_env_get->cl_env_new->kmem_cache_alloc
could fail with ENOMEM error. Some parts doesn`t handle error
case, for example:
...(osc_lock_upcall()) ASSERTION( !IS_ERR(env) ) failed:
...(osc_lock.c:315:osc_lock_upcall()) LBUG

For osc_lock_upcall() the patch changes cl_env_get to
cl_env_percpu_peek, this prevents memory allocation and
couldn`t fail in low memory case.
For osc_extent_truncate() the patch adds error handle.

Signed-off-by: Alexander Boyko <c17825@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9065
Seagate-bug-id: MRP-4120
Reviewed-on: https://review.whamcloud.com/25171
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 3 +++
 drivers/staging/lustre/lustre/osc/osc_lock.c  | 5 ++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index e44822a..326f663 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1038,6 +1038,9 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	 * it's from lov_io_sub and not fully initialized.
 	 */
 	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
 	io  = &osc_env_info(env)->oti_io;
 	io->ci_obj = cl_object_top(osc2cl(obj));
 	io->ci_ignore_layout = 1;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index d93d33d..d6a275f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -297,9 +297,8 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	struct cl_lock_slice *slice = &oscl->ols_cl;
 	struct lu_env *env;
 	int rc;
-	u16 refcheck;
 
-	env = cl_env_get(&refcheck);
+	env = cl_env_percpu_get();
 	/* should never happen, similar to osc_ldlm_blocking_ast(). */
 	LASSERT(!IS_ERR(env));
 
@@ -338,7 +337,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 
 	if (oscl->ols_owner)
 		cl_sync_io_note(env, oscl->ols_owner, rc);
-	cl_env_put(env, &refcheck);
+	cl_env_percpu_put(env);
 
 	return rc;
 }
-- 
1.8.3.1
