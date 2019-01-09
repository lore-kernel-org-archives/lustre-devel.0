From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 24/29] lustre: osc_cache: change need_release
 to bool
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504259.26726.10938592737685333082.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This variable is used like a bool, so declare it as one.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b4bb36926046..1476f84e6156 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2316,7 +2316,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	unsigned int grants = 0, tmp;
 	int brw_flags = OBD_BRW_ASYNC;
 	int cmd = OBD_BRW_WRITE;
-	int need_release = 0;
+	bool need_release = false;
 	int rc = 0;
 
 	if (oap->oap_magic != OAP_MAGIC)
@@ -2393,7 +2393,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		spin_lock(&cli->cl_loi_list_lock);
 		if (!osc_enter_cache_try(cli, oap, grants)) {
 			grants = 0;
-			need_release = 1;
+			need_release = true;
 		}
 		spin_unlock(&cli->cl_loi_list_lock);
 		if (!need_release && ext->oe_end < index) {
@@ -2401,7 +2401,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			/* try to expand this extent */
 			rc = osc_extent_expand(ext, index, &tmp);
 			if (rc < 0) {
-				need_release = 1;
+				need_release = true;
 				/* don't free reserved grant */
 			} else {
 				OSC_EXTENT_DUMP(D_CACHE, ext,
@@ -2413,7 +2413,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		rc = 0;
 	} else if (ext) {
 		/* index is located outside of active extent */
-		need_release = 1;
+		need_release = true;
 	}
 	if (need_release) {
 		osc_extent_release(env, ext);
