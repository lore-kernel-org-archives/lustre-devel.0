From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Fri,  6 Nov 2015 22:25:29 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: dir: Remove wrapper function
Message-ID: <1446828929-3742-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the function ll_check_page() and replace all its calls with the
function it wrapped.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/llite/dir.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5c9502b..842e6d6 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -239,12 +239,6 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	return rc;
 }
 
-static void ll_check_page(struct inode *dir, struct page *page)
-{
-	/* XXX: check page format later */
-	SetPageChecked(page);
-}
-
 void ll_release_page(struct page *page, int remove)
 {
 	kunmap(page);
@@ -432,7 +426,8 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		goto fail;
 	}
 	if (!PageChecked(page))
-		ll_check_page(dir, page);
+		/* XXX: check page format later */
+		SetPageChecked(page);
 	if (PageError(page)) {
 		CERROR("page error: "DFID" at %llu: rc %d\n",
 		       PFID(ll_inode2fid(dir)), hash, -5);
-- 
2.1.0
