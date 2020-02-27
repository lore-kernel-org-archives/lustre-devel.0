From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:16 -0500
Subject: [lustre-devel] [PATCH 208/622] lustre: llite: enable flock mount
 option by default
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-209-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The "flock" mount option has been optional for many years, initially
because of potential stability issues, and also to provide a choice
for administrators to select between "flock" and "localflock" options.

However, from the large number of problems that users report when
trying to use applications that depend on this feature (typically
databases and other cloud stacks) that disabling flock by default
causes more problems than it solves.

Enable the "flock" (distributed coherent userspace locking) feature
by default.  If applications do not need this functionality, then it
will not affect them.  If applications *do* need this functionality,
they will get it.  If administrators really know what they are doing,
then they can use the "localflock" feature to enable client-local
flock functionality, possibly only on select nodes that need this.

Users wanting to disable this functionality should mount with the
existing "-o noflock" mount option.

If clients are already using "-o {flock|localflock|noflock}" then
their existing options will be handled appropriately.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10885
Lustre-commit: 3613af3e15cb ("LU-10885 llite: enable flock mount option by default")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32091
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4797ee9..84fc54d 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -104,7 +104,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 
 	sbi->ll_flags |= LL_SBI_VERBOSE;
 	sbi->ll_flags |= LL_SBI_CHECKSUM;
-
+	sbi->ll_flags |= LL_SBI_FLOCK;
 	sbi->ll_flags |= LL_SBI_LRU_RESIZE;
 	sbi->ll_flags |= LL_SBI_LAZYSTATFS;
 
-- 
1.8.3.1
