From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Jul 2017 17:42:27 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: Off by two in
	lmv_fid2path()
Message-ID: <20170728144227.uml3x27mqug3ciox@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We want to concatonate join string one, a '/' character, string two and
then a NUL terminator.  The destination buffer holds ori_gf->gf_pathlen
characters.  The strlen() function returns the number of characters not
counting the NUL terminator.  So we should be adding two extra spaces,
one for the foward slash and one for the NUL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Not tested.  Please review this one carefully.

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 64fcaef0bacd..70c58291814d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -657,8 +657,8 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 		char *ptr;
 
 		ori_gf = karg;
-		if (strlen(ori_gf->gf_path) +
-		    strlen(gf->gf_path) > ori_gf->gf_pathlen) {
+		if (strlen(ori_gf->gf_path) + 1 +
+		    strlen(gf->gf_path) + 1 > ori_gf->gf_pathlen) {
 			rc = -EOVERFLOW;
 			goto out_fid2path;
 		}
