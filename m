From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:12 -0400
Subject: [lustre-devel] [PATCH 40/43] staging/lustre/llite: Remove unused
	vui_local_lock field
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-41-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

vvp_io_setattr_lock is the only user that sets it, but it's
never checked anywhere, so could go away.
Also get rid of enum ccc_setattr_lock_type that becomes unused.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 12 ------------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  3 ---
 2 files changed, 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index ce4aeca..27b9b0a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -53,15 +53,6 @@ struct obd_device;
 struct obd_export;
 struct page;
 
-enum ccc_setattr_lock_type {
-	/** Locking is done by server */
-	SETATTR_NOLOCK,
-	/** Extent lock is enqueued */
-	SETATTR_EXTENT_LOCK,
-	/** Existing local extent lock is used */
-	SETATTR_MATCH_LOCK
-};
-
 /* specific architecture can implement only part of this list */
 enum vvp_io_subtype {
 	/** normal IO */
@@ -112,9 +103,6 @@ struct vvp_io {
 			bool		ft_flags_valid;
 		} fault;
 		struct {
-			enum ccc_setattr_lock_type vui_local_lock;
-		} setattr;
-		struct {
 			struct pipe_inode_info	*vui_pipe;
 			unsigned int		 vui_flags;
 		} splice;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 366ac1c..aed7b8e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -567,7 +567,6 @@ static int vvp_io_setattr_iter_init(const struct lu_env *env,
 static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct vvp_io *vio = vvp_env_io(env);
 	struct cl_io  *io  = ios->cis_io;
 	__u64 new_size;
 	__u32 enqflags = 0;
@@ -585,8 +584,6 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 		new_size = 0;
 	}
 
-	vio->u.setattr.vui_local_lock = SETATTR_EXTENT_LOCK;
-
 	return vvp_io_one_lock(env, io, enqflags, CLM_WRITE,
 			       new_size, OBD_OBJECT_EOF);
 }
-- 
2.1.0
