From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:21 -0400
Subject: [lustre-devel] [PATCH v3 2/8] staging:lustre: fixup LNet resource
	container api
In-Reply-To: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433364207-14307-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Both lnet_res_container_setup and lnet_res_container_create
have additional parameters that are no longer used with the
removal of the FREELIST code. This patch removes the no
longer needed function arguments.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0740ab9..9fc3bf6 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -422,8 +422,7 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 }
 
 static int
-lnet_res_container_setup(struct lnet_res_container *rec,
-			 int cpt, int type, int objnum, int objsz)
+lnet_res_container_setup(struct lnet_res_container *rec, int cpt, int type)
 {
 	int rc = 0;
 	int i;
@@ -467,7 +466,7 @@ lnet_res_containers_destroy(struct lnet_res_container **recs)
 }
 
 static struct lnet_res_container **
-lnet_res_containers_create(int type, int objnum, int objsz)
+lnet_res_containers_create(int type)
 {
 	struct lnet_res_container **recs;
 	struct lnet_res_container *rec;
@@ -482,7 +481,7 @@ lnet_res_containers_create(int type, int objnum, int objsz)
 	}
 
 	cfs_percpt_for_each(rec, i, recs) {
-		rc = lnet_res_container_setup(rec, i, type, objnum, objsz);
+		rc = lnet_res_container_setup(rec, i, type);
 		if (rc != 0) {
 			lnet_res_containers_destroy(recs);
 			return NULL;
@@ -575,11 +574,11 @@ lnet_prepare(lnet_pid_t requested_pid)
 		goto failed;
 
 	rc = lnet_res_container_setup(&the_lnet.ln_eq_container, 0,
-				      LNET_COOKIE_TYPE_EQ, 0, 0);
+				      LNET_COOKIE_TYPE_EQ);
 	if (rc != 0)
 		goto failed;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, 0, 0);
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
@@ -587,7 +586,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	the_lnet.ln_me_containers = recs;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD, 0, 0);
+	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD);
 	if (recs == NULL) {
 		rc = -ENOMEM;
 		goto failed;
-- 
1.7.1
