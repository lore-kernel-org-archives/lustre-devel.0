From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:05 -0400
Subject: [lustre-devel] [PATCH 09/23] lustre: sec: check if page is empty
 with ZERO_PAGE
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

In osc_brw_fini_request(), page needs decryption only if it
is not empty. To check this, use ZERO_PAGE macro available
for all architectures, and compare with memcmp.
It will likely be faster/more efficient than comparing the
words by hand as may use optimized CPU instructions or ASM code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 45c26bc11b7b1e ("LU-12275 sec: check if page is empty with ZERO_PAGE")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38918
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1968d62..3bbe3d9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2075,16 +2075,11 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		}
 		for (idx = 0; idx < aa->aa_page_count; idx++) {
 			struct brw_page *pg = aa->aa_ppga[idx];
-			u64 *p, *q;
 
 			/* do not decrypt if page is all 0s */
-			p = q = page_address(pg->pg);
-			while (p - q < PAGE_SIZE / sizeof(*p)) {
-				if (*p != 0)
-					break;
-				p++;
-			}
-			if (p - q == PAGE_SIZE / sizeof(*p)) {
+			if (memcmp(page_address(pg->pg),
+				   page_address(ZERO_PAGE(0)),
+				   PAGE_SIZE) == 0) {
 				/* if page is empty forward info to upper layers
 				 * (ll_io_zero_page) by clearing PagePrivate2
 				 */
-- 
1.8.3.1
