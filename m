From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:37 -0500
Subject: [lustre-devel] [PATCH 469/622] lustre: llite: remove ft_mtime field
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-470-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is set but never accessed, so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: b674c418fa04 ("LU-6142 llite: remove ft_mtime field")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35887
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_internal.h | 5 -----
 fs/lustre/llite/vvp_io.c       | 1 -
 2 files changed, 6 deletions(-)

diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 7a463cb..1cc152f 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -66,11 +66,6 @@ struct vvp_io {
 
 	union {
 		struct vvp_fault_io {
-			/**
-			 * Inode modification time that is checked across DLM
-			 * lock request.
-			 */
-			time64_t		ft_mtime;
 			struct vm_area_struct	*ft_vma;
 			/**
 			 *  locked page returned from vvp_io
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index e676e62..d0d8b1f 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -271,7 +271,6 @@ static int vvp_io_fault_iter_init(const struct lu_env *env,
 	struct inode *inode = vvp_object_inode(ios->cis_obj);
 
 	LASSERT(inode == file_inode(vio->vui_fd->fd_file));
-	vio->u.fault.ft_mtime = inode->i_mtime.tv_sec;
 	return 0;
 }
 
-- 
1.8.3.1
