From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 20:00:01 -0500
Subject: [lustre-devel] [PATCH 28/28] lustre: sec: fix O_DIRECT and
 encrypted files
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Sometimes, we can end up in a situation where
osc_release_bounce_pages() mistakenly consider pages as fscrypt
bounce pages, and tries to free them.
Fix the way we consider bounce pages by always setting the PageChecked
flag on them.

Fixes: feca6b62a6 ("lustre: sec: O_DIRECT for encrypted file")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14045
Lustre-commit: e07d0516dcde4b ("LU-14045 sec: fix O_DIRECT and encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/40295
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 746b695..f225ccd 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1369,8 +1369,11 @@ static inline void osc_release_bounce_pages(struct brw_page **pga,
 	int i;
 
 	for (i = 0; i < page_count; i++) {
-		if (!pga[i]->pg->mapping)
-			/* bounce pages are unmapped */
+		/* Bounce pages allocated by a call to
+		 * llcrypt_encrypt_pagecache_blocks() in osc_brw_prep_request()
+		 * are identified thanks to the PageChecked flag.
+		 */
+		if (PageChecked(pga[i]->pg))
 			llcrypt_finalize_bounce_page(&pga[i]->pg);
 		pga[i]->count -= pga[i]->bp_count_diff;
 		pga[i]->off += pga[i]->bp_off_diff;
@@ -1453,6 +1456,10 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				ptlrpc_request_free(req);
 				return rc;
 			}
+			/* Set PageChecked flag on bounce page for
+			 * disambiguation in osc_release_bounce_pages().
+			 */
+			SetPageChecked(data_page);
 			pg->pg = data_page;
 			/* there should be no gap in the middle of page array */
 			if (i == page_count - 1) {
-- 
1.8.3.1
