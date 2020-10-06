From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:42 -0400
Subject: [lustre-devel] [PATCH 03/42] lustre: sec: use memchr_inv() to check
 if page is zero.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

memchr_inv() is the preferred way to check if a memory region is all
zeros.  It is likely fast that memcmp() is it doesn't need to read the
ZERO_PAGE into cache, or into the CPU.  It was introduced in Linux
3.2.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: afee2380c105c ("LU-12275 sec: use memchr_inv() to check if page is zero.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39459
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1e56ca3..fbb8453 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2077,9 +2077,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			struct brw_page *pg = aa->aa_ppga[idx];
 
 			/* do not decrypt if page is all 0s */
-			if (memcmp(page_address(pg->pg),
-				   page_address(ZERO_PAGE(0)),
-				   PAGE_SIZE) == 0) {
+			if (memchr_inv(page_address(pg->pg), 0,
+				       PAGE_SIZE) == NULL) {
 				/* if page is empty forward info to upper layers
 				 * (ll_io_zero_page) by clearing PagePrivate2
 				 */
-- 
1.8.3.1
