From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:22 -0500
Subject: [lustre-devel] [PATCH 06/12] lustre: mdc: don't add to page cache
 upon failure
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Reading directory pages may fail on MDS, in this case client should
not cache a non-up-to-date directory page, because it will cause
a later read on the same page fail.

Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-5461
Reviewed-on: http://review.whamcloud.com/11450
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 1072b66..09b30ef 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1212,7 +1212,10 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 	}
 
 	rc = mdc_getpage(rp->rp_exp, fid, rp->rp_off, page_pool, npages, &req);
-	if (!rc) {
+	if (rc < 0) {
+		/* page0 is special, which was added into page cache early */
+		delete_from_page_cache(page0);
+	} else {
 		int lu_pgs = req->rq_bulk->bd_nob_transferred;
 
 		rd_pgs = (lu_pgs + PAGE_SIZE - 1) >> PAGE_SHIFT;
-- 
1.8.3.1
