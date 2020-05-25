From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:59 -0400
Subject: [lustre-devel] [PATCH 22/45] lustre: llite: verify truncated xattr
 is handled
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Verify that a truncated trusted.lov xattr is handled properly,
for both plain and PFL layouts.

Add a test case that verifies this is fixed for both layout types.

Fixes: 814b53f76d ("lustre: llite: Don't access lov_md fields before size check")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13168
Lustre-commit: cb74546354201 ("LU-13168 tests: verify truncated xattr is handled")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38434
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/xattr.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 9e7ba21..119fb26 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -190,7 +190,8 @@ static int get_hsm_state(struct inode *inode, u32 *hus_states)
 	return rc;
 }
 
-static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
+static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump,
+			 size_t size)
 {
 	struct lov_comp_md_v1 *comp_v1 = (struct lov_comp_md_v1 *)lump;
 	struct lov_user_md *v1 = lump;
@@ -205,7 +206,12 @@ static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 		return 0;
 
 	if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
+		if (size < sizeof(*comp_v1))
+			return -ERANGE;
+
 		entry_count = comp_v1->lcm_entry_count;
+		if (size < offsetof(typeof(*comp_v1), lcm_entries[entry_count]))
+			return -ERANGE;
 		is_composite = true;
 	}
 
@@ -213,6 +219,10 @@ static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 		if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
 			void *ptr = comp_v1;
 
+			if (comp_v1->lcm_entries[i].lcme_offset + sizeof(*v1) >
+			    size)
+				return -ERANGE;
+
 			ptr += comp_v1->lcm_entries[i].lcme_offset;
 			v1 = (struct lov_user_md *)ptr;
 		}
@@ -265,7 +275,7 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 		return -ERANGE;
 	}
 
-	rc = ll_adjust_lum(inode, lump);
+	rc = ll_adjust_lum(inode, lump, size);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
