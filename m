From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:32 -0500
Subject: [lustre-devel] [PATCH 404/622] lustre: llite: MS_* flags and SB_*
 flags split
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-405-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

In kernel 4.20 the MS_* flags should only be used for mount
time flags and SB_* flags for checking super_block.s_flags
The MS_* flags have moved to a uapi header. Change the one
that was missed, MS_NOSEC to SB_NOSEC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12355
Lustre-commit:72a84970e6d2a ("LU-12355 llite: MS_* flags and SB_* flags split")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35019
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e0395e5..3e058d2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -270,7 +270,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	/* Setting this indicates we correctly support S_NOSEC (See kernel
 	 * commit 9e1f1de02c2275d7172e18dc4e7c2065777611bf)
 	 */
-	sb->s_flags |= MS_NOSEC;
+	sb->s_flags |= SB_NOSEC;
 
 	if (sbi->ll_flags & LL_SBI_FLOCK)
 		sbi->ll_fop = &ll_file_operations_flock;
-- 
1.8.3.1
