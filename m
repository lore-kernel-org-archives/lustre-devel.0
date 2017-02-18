From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:04 -0500
Subject: [lustre-devel] [PATCH 03/14] staging: lustre: osc: remove obsolete
	asserts
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Remove the no longer needed assert in the function
osc_cache_truncate_start(). The assertion in
osc_object_prune() will become faulty with upcoming
changes. The reason this will become a problem is
that there may exist freeing pages in object's
radix tree at the time of osc_object_prune(), which
causes failure at the assertion of (osc->oo_npages == 0).
This patch prevents that problem from happening.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6271
Reviewed-on: http://review.whamcloud.com/16456
Reviewed-on: http://review.whamcloud.com/16727
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c  | 1 -
 drivers/staging/lustre/lustre/osc/osc_object.c | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0490478..6445bbe 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2790,7 +2790,6 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 			 * We have to wait for this extent because we can't
 			 * truncate that page.
 			 */
-			LASSERT(!ext->oe_hp);
 			OSC_EXTENT_DUMP(D_CACHE, ext,
 					"waiting for busy extent\n");
 			waiting = osc_extent_get(ext);
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index d3e5ca7..4f8e78b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -200,10 +200,6 @@ static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
 	struct osc_object       *osc = cl2osc(obj);
 	struct ldlm_res_id      *resname = &osc_env_info(env)->oti_resname;
 
-	LASSERTF(osc->oo_npages == 0,
-		 DFID "still have %lu pages, obj: %p, osc: %p\n",
-		 PFID(lu_object_fid(&obj->co_lu)), osc->oo_npages, obj, osc);
-
 	/* DLM locks don't hold a reference of osc_object so we have to
 	 * clear it before the object is being destroyed.
 	 */
-- 
1.8.3.1
