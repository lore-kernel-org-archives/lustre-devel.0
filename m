From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 11/21] lustre: cl_object: remove vestigial
 debugging.
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781313.10620.6363156783936746853.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cl_env_inc() and cl_env_dec() don't do anything,
so discard them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index d71a680660da..1e704078664e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -565,14 +565,6 @@ struct cl_env {
 	void		       *ce_debug;
 };
 
-static void cl_env_inc(enum cache_stats_item item)
-{
-}
-
-static void cl_env_dec(enum cache_stats_item item)
-{
-}
-
 static void cl_env_init0(struct cl_env *cle, void *debug)
 {
 	LASSERT(cle->ce_ref == 0);
@@ -581,7 +573,6 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
 
 	cle->ce_ref = 1;
 	cle->ce_debug = debug;
-	cl_env_inc(CS_busy);
 }
 
 static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
@@ -611,9 +602,6 @@ static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
 		if (rc != 0) {
 			kmem_cache_free(cl_env_kmem, cle);
 			env = ERR_PTR(rc);
-		} else {
-			cl_env_inc(CS_create);
-			cl_env_inc(CS_total);
 		}
 	} else {
 		env = ERR_PTR(-ENOMEM);
@@ -623,7 +611,6 @@ static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
 
 static void cl_env_fini(struct cl_env *cle)
 {
-	cl_env_dec(CS_total);
 	lu_context_fini(&cle->ce_lu.le_ctx);
 	lu_context_fini(&cle->ce_ses);
 	kmem_cache_free(cl_env_kmem, cle);
@@ -782,7 +769,6 @@ void cl_env_put(struct lu_env *env, u16 *refcheck)
 	if (--cle->ce_ref == 0) {
 		int cpu = get_cpu();
 
-		cl_env_dec(CS_busy);
 		cle->ce_debug = NULL;
 		cl_env_exit(cle);
 		/*
@@ -903,7 +889,6 @@ void cl_env_percpu_put(struct lu_env *env)
 	cle->ce_ref--;
 	LASSERT(cle->ce_ref == 0);
 
-	cl_env_dec(CS_busy);
 	cle->ce_debug = NULL;
 
 	put_cpu();
