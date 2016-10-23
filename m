From: Elise Lennion <elise.lennion@gmail.com>
Date: Sun, 23 Oct 2016 00:30:52 -0000
Subject: [lustre-devel] [PATCH v2] staging: lustre: Move assignments out of
	function calls.
Message-ID: <20161023003044.GA23170@lennorien.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Assignments inside of function calls confuse the reader and should be
avoided, so it was moved out before the call.

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
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---

 v2: Removed the proposed change on use of l_wait_event_exclusive().

 drivers/staging/lustre/lustre/llite/vvp_io.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

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
