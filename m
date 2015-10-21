From: Luis de Bethencourt <luisbg@osg.samsung.com>
Date: Wed, 21 Oct 2015 18:40:40 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: fix misleading
	indentation
Message-ID: <1445449240-30305-1-git-send-email-luisbg@osg.samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The code is correct, the indentation is misleading. Only the the return rc
is part of the conditional statement if rc != 0.

Fix a smatch warning:
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2157
kiblnd_hdev_setup_mrs() warn: curly braces intended?

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---

Hi,

This patch gives a warning in checkpatch.pl for the line:
if (hdev->ibh_mrs == NULL)

It would be cleaner if this was 'if (!hdev->ibh_mrs)' instead. I didn't fix
this as well because the file has 41 instances of comparisons with NULL. I
would be happy to do so in a patch in reply to this one if it would be good.

Thanks,
Luis

 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 28 +++++++++++-----------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index c2cc4e4..7c730e3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2154,23 +2154,23 @@ static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
 	if (rc != 0)
 		return rc;
 
-		LIBCFS_ALLOC(hdev->ibh_mrs, 1 * sizeof(*hdev->ibh_mrs));
-		if (hdev->ibh_mrs == NULL) {
-			CERROR("Failed to allocate MRs table\n");
-			return -ENOMEM;
-		}
+	LIBCFS_ALLOC(hdev->ibh_mrs, 1 * sizeof(*hdev->ibh_mrs));
+	if (hdev->ibh_mrs == NULL) {
+		CERROR("Failed to allocate MRs table\n");
+		return -ENOMEM;
+	}
 
-		hdev->ibh_mrs[0] = NULL;
-		hdev->ibh_nmrs   = 1;
+	hdev->ibh_mrs[0] = NULL;
+	hdev->ibh_nmrs   = 1;
 
-		mr = ib_get_dma_mr(hdev->ibh_pd, acflags);
-		if (IS_ERR(mr)) {
-			CERROR("Failed ib_get_dma_mr : %ld\n", PTR_ERR(mr));
-			kiblnd_hdev_cleanup_mrs(hdev);
-			return PTR_ERR(mr);
-		}
+	mr = ib_get_dma_mr(hdev->ibh_pd, acflags);
+	if (IS_ERR(mr)) {
+		CERROR("Failed ib_get_dma_mr : %ld\n", PTR_ERR(mr));
+		kiblnd_hdev_cleanup_mrs(hdev);
+		return PTR_ERR(mr);
+	}
 
-		hdev->ibh_mrs[0] = mr;
+	hdev->ibh_mrs[0] = mr;
 
 	return 0;
 }
-- 
2.5.1
