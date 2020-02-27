From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:15 -0500
Subject: [lustre-devel] [PATCH 507/622] lustre: llite: clear flock when
 using localflock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-508-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

When mounting a client with "-o localflock" or equivalent option in
/etc/fstab, it does not clear out the "flock" mount option flag from
the superblock.  This results in "flock" still being the option used
and it displays both options in the /proc/mounts output:

  10.0.0.1 at o2ib:/lfs on /mnt/lfs type lustre (rw,flock,localflock)

Mount a client with both "flock,localflock" as mount options and
verify that the "flock" option is cleared by "localflock", and
vice versa.  Verify that "noflock" clears both options.

Remove the "remount_client()" helper in conf-sanity.sh, since this
shadows a helper function of the same name in test-framework.sh and
is confusing.  Instead, use "mount_client()" now that it can accept
mount options, and just pass "remount" explicitly in a few places.

Fixes: 083c51418b67 ("lustre: llite: enable flock mount option by default")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12859
Lustre-commit: 22ee4a1f64ec ("LU-12859 llite: clear flock when using localflock")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36452
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4580be3..49490ee 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -823,12 +823,12 @@ static int ll_options(char *options, struct ll_sb_info *sbi)
 		}
 		tmp = ll_set_opt("flock", s1, LL_SBI_FLOCK);
 		if (tmp) {
-			*flags |= tmp;
+			*flags = (*flags & ~LL_SBI_LOCALFLOCK) | tmp;
 			goto next;
 		}
 		tmp = ll_set_opt("localflock", s1, LL_SBI_LOCALFLOCK);
 		if (tmp) {
-			*flags |= tmp;
+			*flags = (*flags & ~LL_SBI_FLOCK) | tmp;
 			goto next;
 		}
 		tmp = ll_set_opt("noflock", s1,
@@ -2672,11 +2672,16 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 	if (sbi->ll_flags & LL_SBI_NOLCK)
 		seq_puts(seq, ",nolock");
 
+	/* "flock" is the default since 2.13, but it wasn't for many years,
+	 * so it is still useful to print this to show it is enabled.
+	 * Start to print "noflock" so it is now clear when flock is disabled.
+	 */
 	if (sbi->ll_flags & LL_SBI_FLOCK)
 		seq_puts(seq, ",flock");
-
-	if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
+	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
 		seq_puts(seq, ",localflock");
+	else
+		seq_puts(seq, ",noflock");
 
 	if (sbi->ll_flags & LL_SBI_USER_XATTR)
 		seq_puts(seq, ",user_xattr");
-- 
1.8.3.1
