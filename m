From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:45 -0400
Subject: [lustre-devel] [PATCH 05/18] lustre: sec: deal with encrypted
 object size
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Problem with size of encrypted file comes from the fact that
an encrypted page will always contain PAGE_SIZE bytes of data,
even if clear text page is only a few bytes. And server infers
object size from content of encrypted page.

The way to address this is the following. Upon writing, when the
client encrypts the page representing the end of the file, it puts
into o_size info of the request's body, the size of the clear text
version of the file. On server side, this information is used to
adjust isize of the object, but still storing the complete pages
on disk.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 83d660436a164 ("LU-12275 sec: deal with encrypted object size")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36146
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 65d17a8..b27a259 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1446,10 +1446,18 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				ptlrpc_request_free(req);
 				return rc;
 			}
+			pg->pg = data_page;
+			/* there should be no gap in the middle of page array */
+			if (i == page_count - 1) {
+				struct osc_async_page *oap = brw_page2oap(pg);
+
+				oa->o_size = oap->oap_count +
+					     oap->oap_obj_off +
+					     oap->oap_page_off;
+			}
 			/* len is forced to PAGE_SIZE, and poff to 0
 			 * so store the old, clear text info
 			 */
-			pg->pg = data_page;
 			pg->bp_count_diff = PAGE_SIZE - pg->count;
 			pg->count = PAGE_SIZE;
 			pg->bp_off_diff = pg->off & ~PAGE_MASK;
-- 
1.8.3.1
