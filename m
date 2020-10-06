From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:47 -0400
Subject: [lustre-devel] [PATCH 08/42] lustre: llite: return -ENODATA if no
 default layout
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Don't return -ENOENT if fetching the default layout from the root
directory fails.  Otherwise, "lfs find" will print an error message
for every directory scanned in the filesystem:

     lfs find: /myth/tmp does not exist: No such file or directory

Fixes: 96377f5b2ad6 ("lustre: llite: fetch default layout for a directory")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13687
Lustre-commit: 7fb17eb7b7e60 ("LU-13687 llite: return -ENODATA if no default layout")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39200
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index c2a75ce..262aea0 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -710,10 +710,13 @@ int ll_dir_getstripe_default(struct inode *inode, void **plmm, int *plmm_size,
 	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
 				       &req, valid, 0);
 	if (rc == -ENODATA && !fid_is_root(ll_inode2fid(inode)) &&
-	    !(valid & (OBD_MD_MEA|OBD_MD_DEFAULT_MEA)) && root_request)
-		rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
-					       &root_req, valid,
-					       GET_DEFAULT_LAYOUT_ROOT);
+	    !(valid & (OBD_MD_MEA|OBD_MD_DEFAULT_MEA)) && root_request) {
+		int rc2 = ll_dir_get_default_layout(inode, (void **)&lmm,
+						    &lmm_size, &root_req, valid,
+						    GET_DEFAULT_LAYOUT_ROOT);
+		if (rc2 == 0)
+			rc = 0;
+	}
 
 	*plmm = lmm;
 	*plmm_size = lmm_size;
-- 
1.8.3.1
