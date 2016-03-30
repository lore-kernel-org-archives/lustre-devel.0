From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:49:00 -0400
Subject: [lustre-devel] [PATCH v2 39/46] staging/lustre/llite: Move several
	declarations to llite_internal.h
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-40-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: John Hammond <john.hammond@intel.com>

Move several declarations between llite_internal.h and vvp_internal.h
with the goal of reserving the latter header for functions that
pertain to vvp_{device,object,page,...}.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13714
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/llite/llite_internal.h   | 32 +++++++++++++++++--
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 36 ++--------------------
 2 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 993cee8..ba24f09 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -663,6 +663,10 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 void ll_ras_enter(struct file *f);
 
 /* llite/lcommon_misc.c */
+int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp);
+int cl_ocd_update(struct obd_device *host,
+		  struct obd_device *watched,
+		  enum obd_notify_event ev, void *owner, void *data);
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		     struct ll_grouplock *cg);
 void cl_put_grouplock(struct ll_grouplock *cg);
@@ -881,9 +885,6 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env,
 	return via;
 }
 
-int vvp_global_init(void);
-void vvp_global_fini(void);
-
 void ll_queue_done_writing(struct inode *inode, unsigned long flags);
 void ll_close_thread_shutdown(struct ll_close_queue *lcq);
 int ll_close_thread_start(struct ll_close_queue **lcq_ret);
@@ -1089,6 +1090,22 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentry,
 		       int only_unplug);
 void ll_stop_statahead(struct inode *dir, void *key);
 
+blkcnt_t dirty_cnt(struct inode *inode);
+
+int cl_glimpse_size0(struct inode *inode, int agl);
+int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
+		    struct inode *inode, struct cl_object *clob, int agl);
+
+static inline int cl_glimpse_size(struct inode *inode)
+{
+	return cl_glimpse_size0(inode, 0);
+}
+
+static inline int cl_agl(struct inode *inode)
+{
+	return cl_glimpse_size0(inode, 1);
+}
+
 static inline int ll_glimpse_size(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1369,7 +1386,16 @@ int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page *page, enum cl_req_type crt);
 
 /* lcommon_cl.c */
+int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
+
 extern struct lu_env *cl_inode_fini_env;
 extern int cl_inode_fini_refcheck;
 
+int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
+void cl_inode_fini(struct inode *inode);
+int cl_local_size(struct inode *inode);
+
+__u64 cl_fid_build_ino(const struct lu_fid *fid, int api32);
+__u32 cl_fid_build_gen(const struct lu_fid *fid);
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 06e2726..ce4aeca 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -53,25 +53,6 @@ struct obd_device;
 struct obd_export;
 struct page;
 
-blkcnt_t dirty_cnt(struct inode *inode);
-
-int cl_glimpse_size0(struct inode *inode, int agl);
-int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
-		    struct inode *inode, struct cl_object *clob, int agl);
-
-static inline int cl_glimpse_size(struct inode *inode)
-{
-	return cl_glimpse_size0(inode, 0);
-}
-
-static inline int cl_agl(struct inode *inode)
-{
-	return cl_glimpse_size0(inode, 1);
-}
-
-/**
- * Locking policy for setattr.
- */
 enum ccc_setattr_lock_type {
 	/** Locking is done by server */
 	SETATTR_NOLOCK,
@@ -370,23 +351,9 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 	return container_of(slice, struct vvp_lock, vlk_cl);
 }
 
-int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
-
-int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
-void cl_inode_fini(struct inode *inode);
-int cl_local_size(struct inode *inode);
-
-__u64 cl_fid_build_ino(const struct lu_fid *fid, int api32);
-__u32 cl_fid_build_gen(const struct lu_fid *fid);
-
 # define CLOBINVRNT(env, clob, expr)					\
 	((void)sizeof(env), (void)sizeof(clob), (void)sizeof(!!(expr)))
 
-int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp);
-int cl_ocd_update(struct obd_device *host,
-		  struct obd_device *watched,
-		  enum obd_notify_event ev, void *owner, void *data);
-
 /**
  * New interfaces to get and put lov_stripe_md from lov layer. This violates
  * layering because lov_stripe_md is supposed to be a private data in lov.
@@ -415,6 +382,9 @@ struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
 
+int vvp_global_init(void);
+void vvp_global_fini(void);
+
 extern const struct file_operations vvp_dump_pgcache_file_ops;
 
 #endif /* VVP_INTERNAL_H */
-- 
2.1.0
