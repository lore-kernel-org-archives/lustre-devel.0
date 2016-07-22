From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:03 -0400
Subject: [lustre-devel] [PATCH 10/58] staging: lustre: llite: reduce indent
	in ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Instead of making a large chunk of code conditional
based on if a page is valid we reverse the page
validity test and exit the loop if the page is invalid
instead. This allows a section of code to reduce its
indentation one level.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |  147 ++++++++++++++---------------
 1 files changed, 72 insertions(+), 75 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5b46dd8..77fadf1 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -508,93 +508,90 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 	while (rc == 0 && !done) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
+		__u64 hash;
+		__u64 next;
+
+		if (IS_ERR(page)) {
+			rc = PTR_ERR(page);
+			break;
+		}
+
+		hash = MDS_DIR_END_OFF;
+		dp = page_address(page);
+		for (ent = lu_dirent_start(dp); ent && !done;
+		     ent = lu_dirent_next(ent)) {
+			__u16	  type;
+			int	    namelen;
+			struct lu_fid  fid;
+			__u64	  lhash;
+			__u64	  ino;
 
-		if (!IS_ERR(page)) {
 			/*
-			 * If page is empty (end of directory is reached),
-			 * use this value.
+			 * XXX: implement correct swabbing here.
 			 */
-			__u64 hash = MDS_DIR_END_OFF;
-			__u64 next;
-
-			dp = page_address(page);
-			for (ent = lu_dirent_start(dp); ent && !done;
-			     ent = lu_dirent_next(ent)) {
-				__u16	  type;
-				int	    namelen;
-				struct lu_fid  fid;
-				__u64	  lhash;
-				__u64	  ino;
 
+			hash = le64_to_cpu(ent->lde_hash);
+			if (hash < pos)
 				/*
-				 * XXX: implement correct swabbing here.
+				 * Skip until we find target hash
+				 * value.
 				 */
+				continue;
 
-				hash = le64_to_cpu(ent->lde_hash);
-				if (hash < pos)
-					/*
-					 * Skip until we find target hash
-					 * value.
-					 */
-					continue;
-
-				namelen = le16_to_cpu(ent->lde_namelen);
-				if (namelen == 0)
-					/*
-					 * Skip dummy record.
-					 */
-					continue;
-
-				if (api32 && hash64)
-					lhash = hash >> 32;
-				else
-					lhash = hash;
-				fid_le_to_cpu(&fid, &ent->lde_fid);
-				ino = cl_fid_build_ino(&fid, api32);
-				type = ll_dirent_type_get(ent);
-				ctx->pos = lhash;
-				/* For 'll_nfs_get_name_filldir()', it will try
-				 * to access the 'ent' through its 'lde_name',
-				 * so the parameter 'name' for 'ctx->actor()'
-				 * must be part of the 'ent'.
+			namelen = le16_to_cpu(ent->lde_namelen);
+			if (namelen == 0)
+				/*
+				 * Skip dummy record.
 				 */
-				done = !dir_emit(ctx, ent->lde_name,
-						 namelen, ino, type);
-			}
-			next = le64_to_cpu(dp->ldp_hash_end);
-			if (!done) {
-				pos = next;
-				if (pos == MDS_DIR_END_OFF) {
-					/*
-					 * End of directory reached.
-					 */
-					done = 1;
-					ll_release_page(page, 0);
-				} else if (1 /* chain is exhausted*/) {
-					/*
-					 * Normal case: continue to the next
-					 * page.
-					 */
-					ll_release_page(page,
-					    le32_to_cpu(dp->ldp_flags) &
-							LDF_COLLIDE);
-					next = pos;
-					page = ll_get_dir_page(inode, pos,
-							       &chain);
-				} else {
-					/*
-					 * go into overflow page.
-					 */
-					LASSERT(le32_to_cpu(dp->ldp_flags) &
+				continue;
+
+			if (api32 && hash64)
+				lhash = hash >> 32;
+			else
+				lhash = hash;
+			fid_le_to_cpu(&fid, &ent->lde_fid);
+			ino = cl_fid_build_ino(&fid, api32);
+			type = ll_dirent_type_get(ent);
+			ctx->pos = lhash;
+			/* For 'll_nfs_get_name_filldir()', it will try
+			 * to access the 'ent' through its 'lde_name',
+			 * so the parameter 'name' for 'ctx->actor()'
+			 * must be part of the 'ent'.
+			 */
+			done = !dir_emit(ctx, ent->lde_name,
+					 namelen, ino, type);
+		}
+		next = le64_to_cpu(dp->ldp_hash_end);
+		if (!done) {
+			pos = next;
+			if (pos == MDS_DIR_END_OFF) {
+				/*
+				 * End of directory reached.
+				 */
+				done = 1;
+				ll_release_page(page, 0);
+			} else if (1 /* chain is exhausted*/) {
+				/*
+				 * Normal case: continue to the next
+				 * page.
+				 */
+				ll_release_page(page,
+						le32_to_cpu(dp->ldp_flags) &
 						LDF_COLLIDE);
-					ll_release_page(page, 1);
-				}
+				next = pos;
+				page = ll_get_dir_page(inode, pos,
+						       &chain);
 			} else {
-				pos = hash;
-				ll_release_page(page, 0);
+				/*
+				 * go into overflow page.
+				 */
+				LASSERT(le32_to_cpu(dp->ldp_flags) &
+					LDF_COLLIDE);
+				ll_release_page(page, 1);
 			}
 		} else {
-			rc = PTR_ERR(page);
+			pos = hash;
+			ll_release_page(page, 0);
 		}
 	}
 
-- 
1.7.1
