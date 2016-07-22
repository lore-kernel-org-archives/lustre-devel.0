From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:05 -0400
Subject: [lustre-devel] [PATCH 12/58] staging: lustre: llite: handle done
	flags differently in ll_dir_read
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Invert the done flag test to reduce the code indentation.
If done is true release the page and break out of the
while loop.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |   59 +++++++++++++++--------------
 1 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 48eacee..e4d3176 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -562,37 +562,38 @@ int ll_dir_read(struct inode *inode, struct md_op_data *op_data,
 					 namelen, ino, type);
 		}
 
-		if (!done) {
-			next = le64_to_cpu(dp->ldp_hash_end);
-			pos = next;
-			if (pos == MDS_DIR_END_OFF) {
-				/*
-				 * End of directory reached.
-				 */
-				done = 1;
-				ll_release_page(page, 0);
-			} else if (1 /* chain is exhausted*/) {
-				/*
-				 * Normal case: continue to the next
-				 * page.
-				 */
-				ll_release_page(page,
-						le32_to_cpu(dp->ldp_flags) &
-						LDF_COLLIDE);
-				next = pos;
-				page = ll_get_dir_page(inode, pos,
-						       &chain);
-			} else {
-				/*
-				 * go into overflow page.
-				 */
-				LASSERT(le32_to_cpu(dp->ldp_flags) &
-					LDF_COLLIDE);
-				ll_release_page(page, 1);
-			}
-		} else {
+		if (done) {
 			pos = hash;
 			ll_release_page(page, 0);
+			break;
+		}
+
+		next = le64_to_cpu(dp->ldp_hash_end);
+		pos = next;
+		if (pos == MDS_DIR_END_OFF) {
+			/*
+			 * End of directory reached.
+			 */
+			done = 1;
+			ll_release_page(page, 0);
+		} else if (1 /* chain is exhausted*/) {
+			/*
+			 * Normal case: continue to the next
+			 * page.
+			 */
+			ll_release_page(page,
+					le32_to_cpu(dp->ldp_flags) &
+					LDF_COLLIDE);
+			next = pos;
+			page = ll_get_dir_page(inode, pos,
+					       &chain);
+		} else {
+			/*
+			 * go into overflow page.
+			 */
+			LASSERT(le32_to_cpu(dp->ldp_flags) &
+				LDF_COLLIDE);
+			ll_release_page(page, 1);
 		}
 	}
 
-- 
1.7.1
