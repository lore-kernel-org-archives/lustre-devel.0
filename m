From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:44 -0500
Subject: [lustre-devel] [PATCH 16/60] staging: lustre: llite: don't ignore
	layout for group lock request
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Henri Doreau <henri.doreau@cea.fr>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

ignore_layout can be set for operations that layout won't be changed,
typically page operations. Ignoring layout change in group lock
request will confuse layout change code at LOV layer and hit
assertion.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2766
Reviewed-on: http://review.whamcloud.com/6828
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  7 -------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  5 +++++
 drivers/staging/lustre/lustre/lov/lov_object.c     | 23 +++++++++++++++++++++-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  1 +
 5 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index f48660e..f0c132e 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -33,6 +33,7 @@
  * future).
  *
  */
+#define DEBUG_SUBSYSTEM S_LLITE
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
 #include "../include/obd.h"
@@ -132,7 +133,6 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 
 	io = vvp_env_thread_io(env);
 	io->ci_obj = obj;
-	io->ci_ignore_layout = 1;
 
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (rc != 0) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 19f85fc..3e9cf71 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1348,13 +1348,6 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 			io->ci_lockreq = CILR_MANDATORY;
 	}
 
-	/* ignore layout change for generic CIT_MISC but not for glimpse.
-	 * io context for glimpse must set ci_verify_layout to true,
-	 * see cl_glimpse_size0() for details.
-	 */
-	if (io->ci_type == CIT_MISC && !io->ci_verify_layout)
-		io->ci_ignore_layout = 1;
-
 	/* Enqueue layout lock and get layout version. We need to do this
 	 * even for operations requiring to open file, such as read and write,
 	 * because it might not grant layout lock in IT_OPEN.
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index f3a0583..8502128 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -134,6 +134,11 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	struct lov_layout_raid0 *r0     = lov_r0(loo);
 	struct lov_lock		*lovlck;
 
+	CDEBUG(D_INODE, "%p: lock/io FID " DFID "/" DFID ", lock/io clobj %p/%p\n",
+	       loo, PFID(lu_object_fid(lov2lu(loo))),
+	       PFID(lu_object_fid(&obj->co_lu)),
+	       lov2cl(loo), obj);
+
 	file_start = cl_offset(lov2cl(loo), lock->cll_descr.cld_start);
 	file_end   = cl_offset(lov2cl(loo), lock->cll_descr.cld_end + 1) - 1;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 46ec46e..9c4b5ab 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -650,12 +650,16 @@ static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 
 static inline void lov_conf_freeze(struct lov_object *lov)
 {
+	CDEBUG(D_INODE, "To take share lov(%p) owner %p/%p\n",
+	       lov, lov->lo_owner, current);
 	if (lov->lo_owner != current)
 		down_read(&lov->lo_type_guard);
 }
 
 static inline void lov_conf_thaw(struct lov_object *lov)
 {
+	CDEBUG(D_INODE, "To release share lov(%p) owner %p/%p\n",
+	       lov, lov->lo_owner, current);
 	if (lov->lo_owner != current)
 		up_read(&lov->lo_type_guard);
 }
@@ -698,10 +702,14 @@ static void lov_conf_lock(struct lov_object *lov)
 	down_write(&lov->lo_type_guard);
 	LASSERT(!lov->lo_owner);
 	lov->lo_owner = current;
+	CDEBUG(D_INODE, "Took exclusive lov(%p) owner %p\n",
+	       lov, lov->lo_owner);
 }
 
 static void lov_conf_unlock(struct lov_object *lov)
 {
+	CDEBUG(D_INODE, "To release exclusive lov(%p) owner %p\n",
+	       lov, lov->lo_owner);
 	lov->lo_owner = NULL;
 	up_write(&lov->lo_type_guard);
 }
@@ -725,6 +733,7 @@ static int lov_layout_change(const struct lu_env *unused,
 			     struct lov_object *lov, struct lov_stripe_md *lsm,
 			     const struct cl_object_conf *conf)
 {
+	struct lov_device *lov_dev = lov_object_dev(lov);
 	enum lov_layout_type llt = lov_type(lsm);
 	union lov_layout_state *state = &lov->u;
 	const struct lov_layout_operations *old_ops;
@@ -760,14 +769,21 @@ static int lov_layout_change(const struct lu_env *unused,
 
 	LASSERT(!atomic_read(&lov->lo_active_ios));
 
+	CDEBUG(D_INODE, DFID "Apply new layout lov %p, type %d\n",
+	       PFID(lu_object_fid(lov2lu(lov))), lov, llt);
+
 	lov->lo_type = LLT_EMPTY;
 
 	/* page bufsize fixup */
 	cl_object_header(&lov->lo_cl)->coh_page_bufsize -=
 			lov_page_slice_fixup(lov, NULL);
 
-	rc = new_ops->llo_init(env, lov_object_dev(lov), lov, lsm, conf, state);
+	rc = new_ops->llo_init(env, lov_dev, lov, lsm, conf, state);
 	if (rc) {
+		struct obd_device *obd = lov2obd(lov_dev->ld_lov);
+
+		CERROR("%s: cannot apply new layout on " DFID " : rc = %d\n",
+		       obd->obd_name, PFID(lu_object_fid(lov2lu(lov))), rc);
 		new_ops->llo_delete(env, lov, state);
 		new_ops->llo_fini(env, lov, state);
 		/* this file becomes an EMPTY file. */
@@ -923,6 +939,11 @@ int lov_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io)
 {
 	CL_IO_SLICE_CLEAN(lov_env_io(env), lis_cl);
+
+	CDEBUG(D_INODE, DFID "io %p type %d ignore/verify layout %d/%d\n",
+	       PFID(lu_object_fid(&obj->co_lu)), io, io->ci_type,
+	       io->ci_ignore_layout, io->ci_verify_layout);
+
 	return LOV_2DISPATCH_MAYLOCK(cl2lov(obj), llo_io_init,
 				     !io->ci_ignore_layout, env, obj, io);
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5ac0e14..72dd554 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1001,6 +1001,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	env = cl_env_get(&refcheck);
 	io  = &osc_env_info(env)->oti_io;
 	io->ci_obj = cl_object_top(osc2cl(obj));
+	io->ci_ignore_layout = 1;
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (rc < 0)
 		goto out;
-- 
1.8.3.1
