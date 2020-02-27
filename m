From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:52 -0500
Subject: [lustre-devel] [PATCH 184/622] lustre: llite: Fix style issues for
 symlink.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-185-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/llite/symlink.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: e486703b5278 ("LU-6142 llite: Fix style issues for symlink.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33811
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/symlink.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index 0690fdb..d2922d1 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -53,7 +53,8 @@ static int ll_readlink_internal(struct inode *inode,
 		int print_limit = min_t(int, PAGE_SIZE - 128, symlen);
 
 		*symname = lli->lli_symlink_name;
-		/* If the total CDEBUG() size is larger than a page, it
+		/*
+		 * If the total CDEBUG() size is larger than a page, it
 		 * will print a warning to the console, avoid this by
 		 * printing just the last part of the symlink.
 		 */
@@ -97,11 +98,11 @@ static int ll_readlink_internal(struct inode *inode,
 	}
 
 	*symname = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_MD);
-	if (!*symname ||
-	    strnlen(*symname, symlen) != symlen - 1) {
+	if (!*symname || strnlen(*symname, symlen) != symlen - 1) {
 		/* not full/NULL terminated */
-		CERROR("inode %lu: symlink not NULL terminated string of length %d\n",
-		       inode->i_ino, symlen - 1);
+		CERROR("%s: inode " DFID ": symlink not NULL terminated string of length %d\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), symlen - 1);
 		rc = -EPROTO;
 		goto failed;
 	}
@@ -143,7 +144,8 @@ static const char *ll_get_link(struct dentry *dentry,
 		return ERR_PTR(rc);
 	}
 
-	/* symname may contain a pointer to the request message buffer,
+	/*
+	 * symname may contain a pointer to the request message buffer,
 	 * we delay request releasing then.
 	 */
 	set_delayed_call(done, ll_put_link, request);
-- 
1.8.3.1
