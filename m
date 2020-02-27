From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:00 -0500
Subject: [lustre-devel] [PATCH 492/622] lustre: llite: error handling of
 ll_och_fill()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-493-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

The return error of ll_och_fill() should be handled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12690
Lustre-commit: 4d6d58575d3d ("LU-12690 llite: error handling of ll_och_fill()")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35913
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 856aa64..31d7dce 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1091,7 +1091,9 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 		goto out_release_it;
 
 	LASSERT(it_disposition(&it, DISP_ENQ_OPEN_REF));
-	ll_och_fill(sbi->ll_md_exp, &it, och);
+	rc = ll_och_fill(sbi->ll_md_exp, &it, och);
+	if (rc)
+		goto out_release_it;
 
 	if (!it_disposition(&it, DISP_OPEN_LEASE)) /* old server? */ {
 		rc = -EOPNOTSUPP;
@@ -2225,7 +2227,9 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 		goto out;
 	}
 
-	ll_och_fill(ll_i2sbi(inode)->ll_md_exp, it, och);
+	rc = ll_och_fill(ll_i2sbi(inode)->ll_md_exp, it, och);
+	if (rc)
+		goto out;
 
 	rc = ll_close_inode_openhandle(inode, och, 0, NULL);
 out:
-- 
1.8.3.1
