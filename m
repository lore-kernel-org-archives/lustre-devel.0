From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:12 -0400
Subject: [lustre-devel] [PATCH 15/15] staging/lustre: Remove unused cp_error
	from struct cl_page
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

cp_error member is not really set anywhere, so kill
it and the only printing user of it too.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 --
 drivers/staging/lustre/lustre/obdclass/cl_page.c  | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 78613a9..6d8f956 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -726,8 +726,6 @@ struct cl_page {
 	struct mutex		cp_mutex;
 	/** Linkage of pages within cl_req. */
 	struct list_head	       cp_flight;
-	/** Transfer error. */
-	int		      cp_error;
 
 	/**
 	 * Page type. Only CPT_TRANSIENT is used so far. Immutable after
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index db2dc6b..d903f71 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -989,9 +989,9 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
 {
 	(*printer)(env, cookie,
-		   "page@%p[%d %p %d %d %d %p %p %#x]\n",
+		   "page@%p[%d %p %d %d %p %p %#x]\n",
 		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
-		   pg->cp_state, pg->cp_error, pg->cp_type,
+		   pg->cp_state, pg->cp_type,
 		   pg->cp_owner, pg->cp_req, pg->cp_flags);
 }
 EXPORT_SYMBOL(cl_page_header_print);
-- 
2.7.4
