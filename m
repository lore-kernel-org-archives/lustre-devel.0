From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 6 Nov 2015 22:06:03 +0000
Subject: [lustre-devel] [PATCH] Staging: lustre: dir: Remove wrapper
	function
In-Reply-To: <1446828929-3742-1-git-send-email-shivanib134@gmail.com>
References: <1446828929-3742-1-git-send-email-shivanib134@gmail.com>
Message-ID: <b675c62f3eff4762ac6f4d8f918a3dee@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>From: devel [mailto:driverdev-devel-bounces at linuxdriverproject.org] On Behalf Of Shivani Bhardwaj
>Sent: Friday, November 06, 2015 11:55 AM
>To: gregkh at linuxfoundation.org
>Cc: oleg.drokin at intel.com; devel at driverdev.osuosl.org; andreas.dilger at intel.com; linux-kernel at vger.kernel.org; lustre-devel at lists.lustre.org
>Subject: [PATCH] Staging: lustre: dir: Remove wrapper function
>
>Remove the function ll_check_page() and replace all its calls with the
>function it wrapped.
>
>Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
>---
> drivers/staging/lustre/lustre/llite/dir.c | 9 ++-------
> 1 file changed, 2 insertions(+), 7 deletions(-)

Acked-by: James Simmons <jsimmons@infradead.org>

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

_______________________________________________
devel mailing list
devel at linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
