From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:37 -0400
Subject: [lustre-devel] [PATCH 41/41] staging: lustre: echo: request pages
	in batches
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, James Simmons <jsimmons@infradead.org>

From: Alex Zhuravlev <alexey.zhuravlev@intel.com>

rather than fetch them one by one.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5278
Reviewed-on: http://review.whamcloud.com/13612
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    |   38 ++++++++-----------
 1 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index d8e3e96..c69588c 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1335,7 +1335,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 {
 	struct obd_ioobj ioo;
 	struct niobuf_local *lnb;
-	struct niobuf_remote *rnb;
+	struct niobuf_remote rnb;
 	u64 off;
 	u64 npages, tot_pages;
 	int i, ret = 0, brw_flags = 0;
@@ -1347,9 +1347,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	tot_pages = count >> PAGE_SHIFT;
 
 	lnb = kcalloc(npages, sizeof(struct niobuf_local), GFP_NOFS);
-	rnb = kcalloc(npages, sizeof(struct niobuf_remote), GFP_NOFS);
-
-	if (!lnb || !rnb) {
+	if (!lnb) {
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1361,25 +1359,22 @@ static int echo_client_prep_commit(const struct lu_env *env,
 
 	off = offset;
 
-	for (; tot_pages; tot_pages -= npages) {
+	for (; tot_pages > 0; tot_pages -= npages) {
 		int lpages;
 
 		if (tot_pages < npages)
 			npages = tot_pages;
 
-		for (i = 0; i < npages; i++, off += PAGE_SIZE) {
-			rnb[i].rnb_offset = off;
-			rnb[i].rnb_len = PAGE_SIZE;
-			rnb[i].rnb_flags = brw_flags;
-		}
-
-		ioo.ioo_bufcnt = npages;
+		rnb.rnb_offset = off;
+		rnb.rnb_len = npages * PAGE_SIZE;
+		rnb.rnb_flags = brw_flags;
+		ioo.ioo_bufcnt = 1;
+		off += npages * PAGE_SIZE;
 
 		lpages = npages;
-		ret = obd_preprw(env, rw, exp, oa, 1, &ioo, rnb, &lpages, lnb);
+		ret = obd_preprw(env, rw, exp, oa, 1, &ioo, &rnb, &lpages, lnb);
 		if (ret != 0)
 			goto out;
-		LASSERT(lpages == npages);
 
 		for (i = 0; i < lpages; i++) {
 			struct page *page = lnb[i].lnb_page;
@@ -1398,17 +1393,17 @@ static int echo_client_prep_commit(const struct lu_env *env,
 
 			if (rw == OBD_BRW_WRITE)
 				echo_client_page_debug_setup(page, rw,
-							    ostid_id(&oa->o_oi),
-							     rnb[i].rnb_offset,
-							     rnb[i].rnb_len);
+							     ostid_id(&oa->o_oi),
+							     lnb[i].lnb_file_offset,
+							     lnb[i].lnb_len);
 			else
 				echo_client_page_debug_check(page,
-							    ostid_id(&oa->o_oi),
-							     rnb[i].rnb_offset,
-							     rnb[i].rnb_len);
+							     ostid_id(&oa->o_oi),
+							     lnb[i].lnb_file_offset,
+							     lnb[i].lnb_len);
 		}
 
-		ret = obd_commitrw(env, rw, exp, oa, 1, &ioo, rnb, npages, lnb,
+		ret = obd_commitrw(env, rw, exp, oa, 1, &ioo, &rnb, npages, lnb,
 				   ret);
 		if (ret != 0)
 			goto out;
@@ -1420,7 +1415,6 @@ static int echo_client_prep_commit(const struct lu_env *env,
 
 out:
 	kfree(lnb);
-	kfree(rnb);
 	return ret;
 }
 
-- 
1.7.1
