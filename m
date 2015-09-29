From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:11 -0400
Subject: [lustre-devel] [PATCH 28/29] staging/lustre: Remove unused
	ccc_io_fini()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Does not appear to be used anywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lclient.h    | 1 -
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 7 -------
 2 files changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index d09d005..823be81 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -332,7 +332,6 @@ void ccc_lock_state(const struct lu_env *env,
 		    const struct cl_lock_slice *slice,
 		    enum cl_lock_state state);
 
-void ccc_io_fini(const struct lu_env *env, const struct cl_io_slice *ios);
 int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end);
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index 98a2e0e..eb43174 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -675,13 +675,6 @@ void ccc_lock_state(const struct lu_env *env,
  *
  */
 
-void ccc_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
-{
-	struct cl_io *io = ios->cis_io;
-
-	CLOBINVRNT(env, io->ci_obj, ccc_object_invariant(io->ci_obj));
-}
-
 int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end)
-- 
2.1.0
