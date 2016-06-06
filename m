From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sun,  5 Jun 2016 23:28:52 -0400
Subject: [lustre-devel] [PATCH 3/4] staging/lustre/osc: Remove ops_temp from
	osc_page
In-Reply-To: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
References: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465183733-3147667-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

It's no longer used and never set anywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h | 5 -----
 drivers/staging/lustre/lustre/osc/osc_page.c        | 2 +-
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index ae19d39..7359fcb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -356,11 +356,6 @@ struct osc_page {
 	 */
 	unsigned	      ops_transfer_pinned:1,
 	/**
-	 * True for a `temporary page' created by read-ahead code, probably
-	 * outside of any DLM lock.
-	 */
-			      ops_temp:1,
-	/**
 	 * in LRU?
 	 */
 			      ops_in_lru:1,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index c29c2ea..fc36743 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -214,7 +214,7 @@ static void osc_page_delete(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	int rc;
 
-	LINVRNT(opg->ops_temp || osc_page_protected(env, opg, CLM_READ, 1));
+	LINVRNT(osc_page_protected(env, opg, CLM_READ, 1));
 
 	CDEBUG(D_TRACE, "%p\n", opg);
 	osc_page_transfer_put(env, opg);
-- 
2.7.4
