From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 14:09:56 +0300
Subject: [lustre-devel] [patch] staging: lustre: cl_page: fix a typo in
	comments
Message-ID: <20161205110955.GA19260@elgon.mountain>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We want to "sever" all the ways to get a new pointer to "pg".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index bdc0aa5846ef..cd9a40ca4448 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -667,7 +667,7 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
 	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
 
 	/*
-	 * Severe all ways to obtain new pointers to @pg.
+	 * Sever all ways to obtain new pointers to @pg.
 	 */
 	cl_page_owner_clear(pg);
 
