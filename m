From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:29 -0400
Subject: [lustre-devel] [PATCH 090/124] staging: lustre: obdclass: change
	cl_fault_io->ft_nob to size_t
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-91-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the type accordant usage.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12380
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    4 ++--
 drivers/staging/lustre/lustre/llite/rw26.c         |    4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    4 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    4 ++--
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 5af1153..f360ec9 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1766,7 +1766,7 @@ struct cl_io {
 			/** page index within file. */
 			pgoff_t	 ft_index;
 			/** bytes valid byte on a faulted page. */
-			int	     ft_nob;
+			size_t	     ft_nob;
 			/** writable page? for nopage() only */
 			int	     ft_writable;
 			/** page of an executable? */
@@ -2297,7 +2297,7 @@ int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
 			  struct cl_page *page, pgoff_t *max_index);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
-int cl_page_size(const struct cl_object *obj);
+size_t cl_page_size(const struct cl_object *obj);
 int cl_pages_prune(const struct lu_env *env, struct cl_object *obj);
 
 void cl_lock_print(const struct lu_env *env, void *cookie,
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index f35eb2e..df0318e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -213,10 +213,10 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 	int i;
 	ssize_t rc = 0;
 	loff_t file_offset  = pv->ldp_start_offset;
-	long size	   = pv->ldp_size;
+	size_t size = pv->ldp_size;
 	int page_count      = pv->ldp_nr;
 	struct page **pages = pv->ldp_pages;
-	long page_size      = cl_page_size(obj);
+	size_t page_size = cl_page_size(obj);
 	bool do_io;
 	int  io_pages       = 0;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 5c89dbd..18784a8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1032,9 +1032,9 @@ pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
 }
 EXPORT_SYMBOL(cl_index);
 
-int cl_page_size(const struct cl_object *obj)
+size_t cl_page_size(const struct cl_object *obj)
 {
-	return 1 << PAGE_SHIFT;
+	return 1UL << PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_page_size);
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 91d28b5..9df117b 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1010,7 +1010,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	struct cl_io	    *io;
 	struct cl_page	  *clp;
 	struct lustre_handle    lh = { 0 };
-	int page_size = cl_page_size(obj);
+	size_t page_size = cl_page_size(obj);
 	int refcheck;
 	int rc;
 	int i;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 7698054..96beba4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -200,7 +200,7 @@ static int osc_io_submit(const struct lu_env *env,
  * Expand stripe KMS if necessary.
  */
 static void osc_page_touch_at(const struct lu_env *env,
-			      struct cl_object *obj, pgoff_t idx, unsigned to)
+			      struct cl_object *obj, pgoff_t idx, size_t to)
 {
 	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
@@ -369,7 +369,7 @@ static int osc_io_fault_start(const struct lu_env *env,
 
 	io = ios->cis_io;
 	fio = &io->u.ci_fault;
-	CDEBUG(D_INFO, "%lu %d %d\n",
+	CDEBUG(D_INFO, "%lu %d %zu\n",
 	       fio->ft_index, fio->ft_writable, fio->ft_nob);
 	/*
 	 * If mapping is writeable, adjust kms to cover this page,
-- 
1.7.1
