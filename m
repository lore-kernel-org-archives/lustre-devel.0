From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:46 -0400
Subject: [lustre-devel] [PATCH 07/22] lustre: llite: prevent MAX_DIO_SIZE
 32-bit truncation
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

On 4kB PAGE_SIZE systems, kmalloc can allocate up to 4MB, which makes
MAX_DIO_SIZE up to 682MB. This number can fit into 32 bits.
But on 64kB PAGE_SIZE systems, kmalloc can allocate up to 512MB, which
then makes MAX_DIO_SIZE up to 1365GB. This needs 64 bits to fit.
Make sure that for every platform MAX_DIO_SIZE is not abusively
truncated, by casting it to size_t.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13528
Lustre-commit: 8cfd5be8b04bd ("LU-13528 llite: prevent MAX_DIO_SIZE 32-bit truncation")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38526
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 7abf3fc..5e7aa6e 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -276,7 +276,7 @@ struct ll_dio_pages {
  * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc.
  */
 #define MAX_DIO_SIZE ((KMALLOC_MAX_SIZE / sizeof(struct brw_page) * PAGE_SIZE) & \
-		      ~(DT_MAX_BRW_SIZE - 1))
+		      ~((size_t)DT_MAX_BRW_SIZE - 1))
 
 static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 {
-- 
1.8.3.1
