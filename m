From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 21/29] lustre: osc_cache: don't drop a lock
 we didn't take - two
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504241.26726.16825256312797481549.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_check_rpcs() drops a lock that it was called with, which can make
it harder to understand the code.

It is only called from one place, and that places takes the lock just
to all this function.
So instead, take the lock at the start of the function,
and drop it at the end.
This makes the code easier to follow.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 863884cac028..b2ad6a15014e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2187,11 +2187,11 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 
 /* called with the loi list lock held */
 static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
-	__must_hold(&cli->cl_loi_list_lock)
 {
 	struct osc_object *osc;
 	int rc = 0;
 
+	spin_lock(&cli->cl_loi_list_lock);
 	while ((osc = osc_next_obj(cli)) != NULL) {
 		struct cl_object *obj = osc2cl(osc);
 		struct lu_ref_link link;
@@ -2247,6 +2247,7 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 
 		spin_lock(&cli->cl_loi_list_lock);
 	}
+	spin_unlock(&cli->cl_loi_list_lock);
 }
 
 static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
@@ -2258,9 +2259,7 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 		return 0;
 
 	if (!async) {
-		spin_lock(&cli->cl_loi_list_lock);
 		osc_check_rpcs(env, cli);
-		spin_unlock(&cli->cl_loi_list_lock);
 	} else {
 		CDEBUG(D_CACHE, "Queue writeback work for client %p.\n", cli);
 		LASSERT(cli->cl_writeback_work);
