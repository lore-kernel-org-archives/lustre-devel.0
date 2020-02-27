From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:43 -0500
Subject: [lustre-devel] [PATCH 475/622] lustre: llite: extend readahead
 locks for striped file
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-476-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Currently cl_io_read_ahead() can not return locks
that cross stripe boundary at one time, thus readahead
will stop because of this reason.

This is really bad, as we will stop readahead every
time we hit stripe boundary, for example default stripe
size is 1M, this could hurt performances very much
especially with async readahead introduced.

So try to use existed locks aggressivly if there is no
lock contention, otherwise lock should be not
less than requested extent.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: cfbeae97d736 ("LU-12043 llite: extend readahead locks for striped file")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35438
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  2 ++
 fs/lustre/llite/rw.c          | 14 ++++++++++++--
 fs/lustre/osc/osc_io.c        |  2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 71ca283..65fdab9 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1474,6 +1474,8 @@ struct cl_read_ahead {
 	void (*cra_release)(const struct lu_env *env, void *cbdata);
 	/* Callback data for cra_release routine */
 	void				*cra_cbdata;
+	/* whether lock is in contention */
+	bool				cra_contention;
 };
 
 static inline void cl_read_ahead_release(const struct lu_env *env,
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 4fec9a6..7c2dbdc 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -369,6 +369,18 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 				if (rc < 0)
 					break;
 
+				/* Do not shrink the ria_end@any case until
+				 * the minimum end of current read is covered.
+				 * And only shrink the ria_end if the matched
+				 * LDLM lock doesn't cover more.
+				 */
+				if (page_idx > ra.cra_end ||
+				    (ra.cra_contention &&
+				     page_idx > ria->ria_end_min)) {
+					ria->ria_end = ra.cra_end;
+					break;
+				}
+
 				CDEBUG(D_READA, "idx: %lu, ra: %lu, rpc: %lu\n",
 				       page_idx, ra.cra_end, ra.cra_rpc_size);
 				LASSERTF(ra.cra_end >= page_idx,
@@ -387,8 +399,6 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 					ria->ria_end = end - 1;
 				if (ria->ria_end < ria->ria_end_min)
 					ria->ria_end = ria->ria_end_min;
-				if (ria->ria_end > ra.cra_end)
-					ria->ria_end = ra.cra_end;
 			}
 
 			/* If the page is inside the read-ahead window */
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 4f46b95..8e299d4 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -92,6 +92,8 @@ static int osc_io_read_ahead(const struct lu_env *env,
 				       dlmlock->l_policy_data.l_extent.end);
 		ra->cra_release = osc_read_ahead_release;
 		ra->cra_cbdata = dlmlock;
+		if (ra->cra_end != CL_PAGE_EOF)
+			ra->cra_contention = true;
 		result = 0;
 	}
 
-- 
1.8.3.1
