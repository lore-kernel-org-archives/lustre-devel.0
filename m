From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:50 -0500
Subject: [lustre-devel] [PATCH 482/622] lustre: obdclass: align to T10
 sector size when generating guard
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-483-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Otherwise the client and server would come up with
different checksum when the page size is different.

Improve test_810 to verify all available checksum types.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11729
Lustre-commit: 98ceaf854bb4 ("LU-11729 obdclass: align to T10 sector size when generating guard")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/34043
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/integrity.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index 5cb9a25..2d5760d 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -50,26 +50,26 @@ int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
 				 int *used_number, int sector_size,
 				 obd_dif_csum_fn *fn)
 {
-	unsigned int i;
+	unsigned int i = offset;
+	unsigned int end = offset + length;
 	char *data_buf;
 	u16 *guard_buf = guard_start;
 	unsigned int data_size;
 	int used = 0;
 
 	data_buf = kmap(page) + offset;
-	for (i = 0; i < length; i += sector_size) {
+	while (i < end) {
 		if (used >= guard_number) {
 			CERROR("%s: unexpected used guard number of DIF %u/%u, data length %u, sector size %u: rc = %d\n",
 			       obd_name, used, guard_number, length,
 			       sector_size, -E2BIG);
 			return -E2BIG;
 		}
-		data_size = length - i;
-		if (data_size > sector_size)
-			data_size = sector_size;
+		data_size = min(round_up(i + 1, sector_size), end) - i;
 		*guard_buf = fn(data_buf, data_size);
 		guard_buf++;
 		data_buf += data_size;
+		i += data_size;
 		used++;
 	}
 	kunmap(page);
-- 
1.8.3.1
