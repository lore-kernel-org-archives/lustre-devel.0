From: Elise Lennion <elise.lennion@gmail.com>
Date: Fri, 21 Oct 2016 22:14:39 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: Move assignments out of
	function calls.
Message-ID: <20161021221431.GA18524@lennorien.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Assignments inside of function calls confuse the reader and should be
avoided, so they were moved out before the call.

Found with Coccinelle, semantic patch:
@@
identifier f;
expression e1, e2;
assignment operator a;
@@

+ e1 a e2;
f(...,
- (e1 a e2)
+ e1
 ,...);

Signed-off-by: Elise Lennion <elise.lennion@gmail.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 5 ++---
 drivers/staging/lustre/lustre/llite/vvp_io.c    | 3 ++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 12647af..ec7f2a8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -764,9 +764,8 @@ static int ldlm_bl_thread_main(void *arg)
 
 		if (!blwi) {
 			atomic_dec(&blp->blp_busy_threads);
-			l_wait_event_exclusive(blp->blp_waitq,
-					       (blwi = ldlm_bl_get_work(blp)),
-					       &lwi);
+			blwi = ldlm_bl_get_work(blp);
+			l_wait_event_exclusive(blp->blp_waitq, blwi, &lwi);
 			busy = atomic_inc_return(&blp->blp_busy_threads);
 		} else {
 			busy = atomic_read(&blp->blp_busy_threads);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 1a4b897..87fdab2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -450,7 +450,8 @@ static void vvp_io_advance(const struct lu_env *env,
 	struct vvp_io	 *vio = cl2vvp_io(env, ios);
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
-	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count  -= nob);
+	vio->vui_tot_count -= nob;
+	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count);
 }
 
 static void vvp_io_update_iov(const struct lu_env *env,
-- 
2.7.4
