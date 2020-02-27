From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:41 -0500
Subject: [lustre-devel] [PATCH 173/622] lustre: osc: wrong page offset for
 T10PI checksum
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-174-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

The page offset might could be non-zero value. Thus, when
calculating T10PI checksum, the offset should be correct value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11697
Lustre-commit: c1f052055446 ("LU-11697 osc: wrong page offset for T10PI checksum")
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/33727
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 18b99a9..1fc7a57 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1153,7 +1153,8 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 		 * The left guard number should be able to hold checksums of a
 		 * whole page
 		 */
-		rc = obd_page_dif_generate_buffer(obd_name, pga[i]->pg, 0,
+		rc = obd_page_dif_generate_buffer(obd_name, pga[i]->pg,
+						  pga[i]->off & ~PAGE_MASK,
 						  count,
 						  guard_start + used_number,
 						  guard_number - used_number,
-- 
1.8.3.1
