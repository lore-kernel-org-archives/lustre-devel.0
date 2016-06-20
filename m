From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:20 -0400
Subject: [lustre-devel] [PATCH 05/28] staging/lustre/osc: osc_lock_weight
	endless loop fix
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Alexander Zarochentsev <alexander.zarochentsev@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

With huge number of pages to scan by osc_lock_weight() it is likely
CLP_GANG_RESCHED is returned from osc_page_gang_lookup() and the scan
will be repeated again from the start. To be sure that the scan is
progressing across those restarts, next scan should be started from
the last scanned page index plus one.

Xyratex-bug-id: MRP-2145
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/12362
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5781
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_lock.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 42def38..d856775 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -634,11 +634,10 @@ static int weigh_cb(const struct lu_env *env, struct cl_io *io,
 
 	if (cl_page_is_vmlocked(env, page) ||
 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
-	   ) {
-		(*(unsigned long *)cbdata)++;
+	   )
 		return CLP_GANG_ABORT;
-	}
 
+	*(pgoff_t *)cbdata = osc_index(ops) + 1;
 	return CLP_GANG_OKAY;
 }
 
@@ -648,7 +647,7 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 {
 	struct cl_io *io = &osc_env_info(env)->oti_io;
 	struct cl_object *obj = cl_object_top(&oscobj->oo_cl);
-	unsigned long npages = 0;
+	pgoff_t page_index;
 	int result;
 
 	io->ci_obj = obj;
@@ -657,11 +656,12 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 	if (result != 0)
 		return result;
 
+	page_index = cl_index(obj, extent->start);
 	do {
 		result = osc_page_gang_lookup(env, io, oscobj,
-					      cl_index(obj, extent->start),
+					      page_index,
 					      cl_index(obj, extent->end),
-					      weigh_cb, (void *)&npages);
+					      weigh_cb, (void *)&page_index);
 		if (result == CLP_GANG_ABORT)
 			break;
 		if (result == CLP_GANG_RESCHED)
@@ -669,7 +669,7 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 	} while (result != CLP_GANG_OKAY);
 	cl_io_fini(env, io);
 
-	return npages;
+	return result == CLP_GANG_ABORT ? 1 : 0;
 }
 
 /**
-- 
2.7.4
