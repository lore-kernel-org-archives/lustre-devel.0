From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 12/29] lustre: osc_cache: avoid confusing
 variable reuse.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504179.26726.1340537377320556999.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In osc_extent_wait(), the 'rc' variable use used for
three very different purposes.  This makes the code
a bit harder to read.
For one of the purposes, introduce a boolean 'need_release'.
For another, use a conditional expression instead.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0c78b95e45a3..5a295799f177 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -929,7 +929,8 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 			   enum osc_extent_state state)
 {
 	struct osc_object *obj = ext->oe_obj;
-	int rc = 0;
+	bool need_release = false;
+	int rc;
 
 	osc_object_lock(obj);
 	LASSERT(sanity_check_nolock(ext) == 0);
@@ -943,11 +944,11 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 		} else if (ext->oe_state == OES_CACHE) {
 			ext->oe_urgent = 1;
 			osc_extent_hold(ext);
-			rc = 1;
+			need_release = true;
 		}
 	}
 	osc_object_unlock(obj);
-	if (rc == 1)
+	if (need_release)
 		osc_extent_release(env, ext);
 
 	/* wait for the extent until its state becomes @state */
@@ -963,11 +964,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 				smp_load_acquire(&ext->oe_state) == state);
 
 	}
-	if (ext->oe_rc < 0)
-		rc = ext->oe_rc;
-	else
-		rc = 0;
-	return rc;
+	return ext->oe_rc < 0 ? ext->oe_rc : 0;
 }
 
 /**
