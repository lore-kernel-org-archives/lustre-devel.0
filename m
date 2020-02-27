From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:30 -0500
Subject: [lustre-devel] [PATCH 522/622] lustre: llite: statfs to use NODELAY
 with MDS
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-523-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

otherwise client umount can get stuck if MDS is down
for a reason. recovery-small/110k simulates this.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12809
Lustre-commit: a7ae8da24229 ("LU-12809 llite: statfs to use NODELAY with MDS")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36297
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 84472fb..1245336 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1869,6 +1869,9 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 
 	max_age = ktime_get_seconds() - sbi->ll_statfs_max_age;
 
+	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
+		flags |= OBD_STATFS_NODELAY;
+
 	rc = obd_statfs(NULL, sbi->ll_md_exp, osfs, max_age, flags);
 	if (rc)
 		return rc;
@@ -1882,9 +1885,6 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	if (osfs->os_state & OS_STATE_SUM)
 		goto out;
 
-	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
-		flags |= OBD_STATFS_NODELAY;
-
 	rc = obd_statfs(NULL, sbi->ll_dt_exp, &obd_osfs, max_age, flags);
 	if (rc) {
 		/* Possibly a filesystem with no OSTs.  Report MDT totals. */
-- 
1.8.3.1
