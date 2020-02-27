From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:59 -0500
Subject: [lustre-devel] [PATCH 431/622] lustre: mdc: dir page ldp_hash_end
 mistakenly adjusted
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-432-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

On system PAGE_SIZE > 4k, mdc_adjust_dirpages() adjusts dir page
end hash with le64_to_cpu() value, but it should be little endian.

Fixes: 4f76f0ec093 ("staging: lustre: llite: move dir cache to MDC layer")

WC-bug-id: https://jira.whamcloud.com/browse/LU-10094
Lustre-commit: d8b19ae66177 ("LU-10094 mdc: dir page ldp_hash_end mistakenly adjusted")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35517
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 693c455..162ace7 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1259,8 +1259,8 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 
 	for (i = 0; i < cfs_pgs; i++) {
 		struct lu_dirpage *dp = kmap(pages[i]);
-		u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
-		u32 flags = le32_to_cpu(dp->ldp_flags);
+		u64 hash_end = dp->ldp_hash_end;
+		u32 flags = dp->ldp_flags;
 		struct lu_dirpage *first = dp;
 
 		while (--lu_pgs > 0) {
@@ -1279,8 +1279,8 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 				break;
 
 			/* Save the hash and flags of this lu_dirpage. */
-			hash_end = le64_to_cpu(dp->ldp_hash_end);
-			flags = le32_to_cpu(dp->ldp_flags);
+			hash_end = dp->ldp_hash_end;
+			flags = dp->ldp_flags;
 
 			/* Check if lu_dirpage contains no entries. */
 			if (!end_dirent)
-- 
1.8.3.1
