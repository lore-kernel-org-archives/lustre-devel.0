From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 21 Aug 2016 18:04:36 -0400
Subject: [lustre-devel] [PATCH 3/3] staging/lustre: Remove unused cp_error
	from struct cl_page
In-Reply-To: <1471817076-563589-1-git-send-email-green@linuxhacker.ru>
References: <1471817076-563589-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471817076-563589-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

cp_error member is not really set anywhere, so kill
it and the only printing user of it too.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 --
 drivers/staging/lustre/lustre/obdclass/cl_page.c  | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 4c00be2..5e63a27 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -701,8 +701,6 @@ enum cl_page_type {
 struct cl_page {
 	/** Reference counter. */
 	atomic_t	     cp_ref;
-	/** Transfer error. */
-	int			 cp_error;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object	*cp_obj;
 	/** vmpage */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index bd71859..80c6e0e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -981,9 +981,9 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
 {
 	(*printer)(env, cookie,
-		   "page@%p[%d %p %d %d %d %p %p]\n",
+		   "page@%p[%d %p %d %d %p %p]\n",
 		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
-		   pg->cp_state, pg->cp_error, pg->cp_type,
+		   pg->cp_state, pg->cp_type,
 		   pg->cp_owner, pg->cp_req);
 }
 EXPORT_SYMBOL(cl_page_header_print);
-- 
2.7.4
