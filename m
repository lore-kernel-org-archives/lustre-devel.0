From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sun,  5 Jun 2016 23:28:53 -0400
Subject: [lustre-devel] [PATCH 4/4] staging/lustre/osc: Get rid of
	osc_page_protected()
In-Reply-To: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
References: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465183733-3147667-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

There was a proper debugging function by that name that's long
gone.
The currently remaining shadow that always returns true is not
really useful so it could be dropped along with all the
asserts it is part of.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index fc36743..5a3e694 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -52,13 +52,6 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
  *  @{
  */
 
-static int osc_page_protected(const struct lu_env *env,
-			      const struct osc_page *opg,
-			      enum cl_lock_mode mode, int unref)
-{
-	return 1;
-}
-
 /*****************************************************************************
  *
  * Page operations.
@@ -110,8 +103,6 @@ int osc_page_cache_add(const struct lu_env *env,
 	struct osc_page *opg = cl2osc_page(slice);
 	int result;
 
-	LINVRNT(osc_page_protected(env, opg, CLM_WRITE, 0));
-
 	osc_page_transfer_get(opg, "transfer\0cache");
 	result = osc_queue_async_io(env, io, opg);
 	if (result != 0)
@@ -214,8 +205,6 @@ static void osc_page_delete(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	int rc;
 
-	LINVRNT(osc_page_protected(env, opg, CLM_READ, 1));
-
 	CDEBUG(D_TRACE, "%p\n", opg);
 	osc_page_transfer_put(env, opg);
 	rc = osc_teardown_async_page(env, obj, opg);
@@ -254,8 +243,6 @@ static void osc_page_clip(const struct lu_env *env,
 	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_async_page *oap = &opg->ops_oap;
 
-	LINVRNT(osc_page_protected(env, opg, CLM_READ, 0));
-
 	opg->ops_from = from;
 	opg->ops_to = to;
 	spin_lock(&oap->oap_lock);
@@ -269,8 +256,6 @@ static int osc_page_cancel(const struct lu_env *env,
 	struct osc_page *opg = cl2osc_page(slice);
 	int rc = 0;
 
-	LINVRNT(osc_page_protected(env, opg, CLM_READ, 0));
-
 	/* Check if the transferring against this page
 	 * is completed, or not even queued.
 	 */
@@ -320,10 +305,6 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		cl_page_slice_add(page, &opg->ops_cl, obj, index,
 				  &osc_page_ops);
 	}
-	/*
-	 * Cannot assert osc_page_protected() here as read-ahead
-	 * creates temporary pages outside of a lock.
-	 */
 	/* ops_inflight and ops_lru are the same field, but it doesn't
 	 * hurt to initialize it twice :-)
 	 */
@@ -382,9 +363,6 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	struct osc_async_page *oap = &opg->ops_oap;
 	struct osc_object *obj = oap->oap_obj;
 
-	LINVRNT(osc_page_protected(env, opg,
-				   crt == CRT_WRITE ? CLM_WRITE : CLM_READ, 1));
-
 	LASSERTF(oap->oap_magic == OAP_MAGIC, "Bad oap magic: oap %p, magic 0x%x\n",
 		 oap, oap->oap_magic);
 	LASSERT(oap->oap_async_flags & ASYNC_READY);
-- 
2.7.4
