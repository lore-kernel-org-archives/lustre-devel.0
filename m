From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:49:05 -0400
Subject: [lustre-devel] [PATCH v2 44/46] staging/lustre: Fix spacing style
	before open parenthesis
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-45-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This fixes the remaining occurences of checkpatch warnings
of the form of
WARNING: space prohibited between function name and open parenthesis '('

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h  | 64 +++++++++++-----------
 .../lustre/lustre/include/lustre/lustre_idl.h      |  2 +-
 .../lustre/lustre/include/lustre/lustre_user.h     | 36 ++++++------
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  2 +-
 .../staging/lustre/lustre/include/lustre_import.h  |  2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h | 36 ++++++------
 drivers/staging/lustre/lustre/obdclass/debug.c     |  4 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    | 22 ++++----
 drivers/staging/lustre/lustre/osc/osc_request.c    |  2 +-
 9 files changed, 85 insertions(+), 85 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index b5088b1..fcb9db6 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -656,21 +656,21 @@ static inline struct seq_server_site *lu_site2seq(const struct lu_site *s)
  * @{
  */
 
-int  lu_site_init	 (struct lu_site *s, struct lu_device *d);
-void lu_site_fini	 (struct lu_site *s);
-int  lu_site_init_finish  (struct lu_site *s);
-void lu_stack_fini	(const struct lu_env *env, struct lu_device *top);
-void lu_device_get	(struct lu_device *d);
-void lu_device_put	(struct lu_device *d);
-int  lu_device_init       (struct lu_device *d, struct lu_device_type *t);
-void lu_device_fini       (struct lu_device *d);
-int  lu_object_header_init(struct lu_object_header *h);
+int lu_site_init(struct lu_site *s, struct lu_device *d);
+void lu_site_fini(struct lu_site *s);
+int lu_site_init_finish(struct lu_site *s);
+void lu_stack_fini(const struct lu_env *env, struct lu_device *top);
+void lu_device_get(struct lu_device *d);
+void lu_device_put(struct lu_device *d);
+int lu_device_init(struct lu_device *d, struct lu_device_type *t);
+void lu_device_fini(struct lu_device *d);
+int lu_object_header_init(struct lu_object_header *h);
 void lu_object_header_fini(struct lu_object_header *h);
-int  lu_object_init       (struct lu_object *o,
-			   struct lu_object_header *h, struct lu_device *d);
-void lu_object_fini       (struct lu_object *o);
-void lu_object_add_top    (struct lu_object_header *h, struct lu_object *o);
-void lu_object_add	(struct lu_object *before, struct lu_object *o);
+int lu_object_init(struct lu_object *o,
+		   struct lu_object_header *h, struct lu_device *d);
+void lu_object_fini(struct lu_object *o);
+void lu_object_add_top(struct lu_object_header *h, struct lu_object *o);
+void lu_object_add(struct lu_object *before, struct lu_object *o);
 
 /**
  * Helpers to initialize and finalize device types.
@@ -1118,7 +1118,7 @@ struct lu_context_key {
 	{							 \
 		type *value;				      \
 								  \
-		CLASSERT(PAGE_CACHE_SIZE >= sizeof (*value));       \
+		CLASSERT(PAGE_CACHE_SIZE >= sizeof(*value));       \
 								  \
 		value = kzalloc(sizeof(*value), GFP_NOFS);	\
 		if (!value)				\
@@ -1154,12 +1154,12 @@ do {						    \
 	(key)->lct_owner = THIS_MODULE;		 \
 } while (0)
 
-int   lu_context_key_register(struct lu_context_key *key);
-void  lu_context_key_degister(struct lu_context_key *key);
-void *lu_context_key_get     (const struct lu_context *ctx,
-			       const struct lu_context_key *key);
-void  lu_context_key_quiesce (struct lu_context_key *key);
-void  lu_context_key_revive  (struct lu_context_key *key);
+int lu_context_key_register(struct lu_context_key *key);
+void lu_context_key_degister(struct lu_context_key *key);
+void *lu_context_key_get(const struct lu_context *ctx,
+			 const struct lu_context_key *key);
+void lu_context_key_quiesce(struct lu_context_key *key);
+void lu_context_key_revive(struct lu_context_key *key);
 
 /*
  * LU_KEY_INIT_GENERIC() has to be a macro to correctly determine an
@@ -1216,21 +1216,21 @@ void  lu_context_key_revive  (struct lu_context_key *key);
 	LU_TYPE_START(mod, __VA_ARGS__);	\
 	LU_TYPE_STOP(mod, __VA_ARGS__)
 
-int   lu_context_init  (struct lu_context *ctx, __u32 tags);
-void  lu_context_fini  (struct lu_context *ctx);
-void  lu_context_enter (struct lu_context *ctx);
-void  lu_context_exit  (struct lu_context *ctx);
-int   lu_context_refill(struct lu_context *ctx);
+int lu_context_init(struct lu_context *ctx, __u32 tags);
+void lu_context_fini(struct lu_context *ctx);
+void lu_context_enter(struct lu_context *ctx);
+void lu_context_exit(struct lu_context *ctx);
+int lu_context_refill(struct lu_context *ctx);
 
 /*
  * Helper functions to operate on multiple keys. These are used by the default
  * device type operations, defined by LU_TYPE_INIT_FINI().
  */
 
-int  lu_context_key_register_many(struct lu_context_key *k, ...);
+int lu_context_key_register_many(struct lu_context_key *k, ...);
 void lu_context_key_degister_many(struct lu_context_key *k, ...);
-void lu_context_key_revive_many  (struct lu_context_key *k, ...);
-void lu_context_key_quiesce_many (struct lu_context_key *k, ...);
+void lu_context_key_revive_many(struct lu_context_key *k, ...);
+void lu_context_key_quiesce_many(struct lu_context_key *k, ...);
 
 /**
  * Environment.
@@ -1246,9 +1246,9 @@ struct lu_env {
 	struct lu_context *le_ses;
 };
 
-int  lu_env_init  (struct lu_env *env, __u32 tags);
-void lu_env_fini  (struct lu_env *env);
-int  lu_env_refill(struct lu_env *env);
+int lu_env_init(struct lu_env *env, __u32 tags);
+void lu_env_fini(struct lu_env *env);
+int lu_env_refill(struct lu_env *env);
 
 /** @} lu_context */
 
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4318511..12e6718 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3306,7 +3306,7 @@ struct getinfo_fid2path {
 	char	    gf_path[0];
 } __packed;
 
-void lustre_swab_fid2path (struct getinfo_fid2path *gf);
+void lustre_swab_fid2path(struct getinfo_fid2path *gf);
 
 enum {
 	LAYOUT_INTENT_ACCESS    = 0,
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 276906e..19f2271 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -193,37 +193,37 @@ struct ost_id {
  * *INFO    - set/get lov_user_mds_data
  */
 /* see <lustre_lib.h> for ioctl numberss 101-150 */
-#define LL_IOC_GETFLAGS		 _IOR ('f', 151, long)
-#define LL_IOC_SETFLAGS		 _IOW ('f', 152, long)
-#define LL_IOC_CLRFLAGS		 _IOW ('f', 153, long)
+#define LL_IOC_GETFLAGS		 _IOR('f', 151, long)
+#define LL_IOC_SETFLAGS		 _IOW('f', 152, long)
+#define LL_IOC_CLRFLAGS		 _IOW('f', 153, long)
 /* LL_IOC_LOV_SETSTRIPE: See also OBD_IOC_LOV_SETSTRIPE */
-#define LL_IOC_LOV_SETSTRIPE	    _IOW ('f', 154, long)
+#define LL_IOC_LOV_SETSTRIPE	    _IOW('f', 154, long)
 /* LL_IOC_LOV_GETSTRIPE: See also OBD_IOC_LOV_GETSTRIPE */
-#define LL_IOC_LOV_GETSTRIPE	    _IOW ('f', 155, long)
+#define LL_IOC_LOV_GETSTRIPE	    _IOW('f', 155, long)
 /* LL_IOC_LOV_SETEA: See also OBD_IOC_LOV_SETEA */
-#define LL_IOC_LOV_SETEA		_IOW ('f', 156, long)
-#define LL_IOC_RECREATE_OBJ	     _IOW ('f', 157, long)
-#define LL_IOC_RECREATE_FID	     _IOW ('f', 157, struct lu_fid)
-#define LL_IOC_GROUP_LOCK	       _IOW ('f', 158, long)
-#define LL_IOC_GROUP_UNLOCK	     _IOW ('f', 159, long)
+#define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
+#define LL_IOC_RECREATE_OBJ	     _IOW('f', 157, long)
+#define LL_IOC_RECREATE_FID	     _IOW('f', 157, struct lu_fid)
+#define LL_IOC_GROUP_LOCK	       _IOW('f', 158, long)
+#define LL_IOC_GROUP_UNLOCK	     _IOW('f', 159, long)
 /* LL_IOC_QUOTACHECK: See also OBD_IOC_QUOTACHECK */
-#define LL_IOC_QUOTACHECK	       _IOW ('f', 160, int)
+#define LL_IOC_QUOTACHECK	       _IOW('f', 160, int)
 /* LL_IOC_POLL_QUOTACHECK: See also OBD_IOC_POLL_QUOTACHECK */
-#define LL_IOC_POLL_QUOTACHECK	  _IOR ('f', 161, struct if_quotacheck *)
+#define LL_IOC_POLL_QUOTACHECK	  _IOR('f', 161, struct if_quotacheck *)
 /* LL_IOC_QUOTACTL: See also OBD_IOC_QUOTACTL */
 #define LL_IOC_QUOTACTL		 _IOWR('f', 162, struct if_quotactl)
 #define IOC_OBD_STATFS		  _IOWR('f', 164, struct obd_statfs *)
 #define IOC_LOV_GETINFO		 _IOWR('f', 165, struct lov_user_mds_data *)
-#define LL_IOC_FLUSHCTX		 _IOW ('f', 166, long)
-#define LL_IOC_RMTACL		   _IOW ('f', 167, long)
-#define LL_IOC_GETOBDCOUNT	      _IOR ('f', 168, long)
+#define LL_IOC_FLUSHCTX		 _IOW('f', 166, long)
+#define LL_IOC_RMTACL		   _IOW('f', 167, long)
+#define LL_IOC_GETOBDCOUNT	      _IOR('f', 168, long)
 #define LL_IOC_LLOOP_ATTACH	     _IOWR('f', 169, long)
 #define LL_IOC_LLOOP_DETACH	     _IOWR('f', 170, long)
 #define LL_IOC_LLOOP_INFO	       _IOWR('f', 171, struct lu_fid)
 #define LL_IOC_LLOOP_DETACH_BYDEV       _IOWR('f', 172, long)
-#define LL_IOC_PATH2FID		 _IOR ('f', 173, long)
+#define LL_IOC_PATH2FID		 _IOR('f', 173, long)
 #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
-#define LL_IOC_GET_MDTIDX	       _IOR ('f', 175, int)
+#define LL_IOC_GET_MDTIDX	       _IOR('f', 175, int)
 
 /* see <lustre_lib.h> for ioctl numbers 177-210 */
 
@@ -1100,7 +1100,7 @@ struct hsm_action_list {
 } __packed;
 
 #ifndef HAVE_CFS_SIZE_ROUND
-static inline int cfs_size_round (int val)
+static inline int cfs_size_round(int val)
 {
 	return (val + 7) & (~0x7);
 }
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index bb16ae9..e229e91 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -161,7 +161,7 @@ static inline void *lustre_cfg_buf(struct lustre_cfg *lcfg, int index)
 	int offset;
 	int bufcount;
 
-	LASSERT (index >= 0);
+	LASSERT(index >= 0);
 
 	bufcount = lcfg->lcfg_bufcount;
 	if (index >= bufcount)
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index dac2d84..8325c82 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -109,7 +109,7 @@ static inline char *ptlrpc_import_state_name(enum lustre_imp_state state)
 		"RECOVER", "FULL", "EVICTED",
 	};
 
-	LASSERT (state <= LUSTRE_IMP_EVICTED);
+	LASSERT(state <= LUSTRE_IMP_EVICTED);
 	return import_state_names[state];
 }
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index c5713d7..2e66b27 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -280,16 +280,16 @@ static inline void obd_ioctl_freedata(char *buf, int len)
 #define OBD_IOC_DATA_TYPE long
 
 #define OBD_IOC_CREATE		 _IOWR('f', 101, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_DESTROY		_IOW ('f', 104, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_DESTROY		_IOW('f', 104, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_PREALLOCATE	    _IOWR('f', 105, OBD_IOC_DATA_TYPE)
 
-#define OBD_IOC_SETATTR		_IOW ('f', 107, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_SETATTR		_IOW('f', 107, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETATTR		_IOWR ('f', 108, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_READ		   _IOWR('f', 109, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_WRITE		  _IOWR('f', 110, OBD_IOC_DATA_TYPE)
 
 #define OBD_IOC_STATFS		 _IOWR('f', 113, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_SYNC		   _IOW ('f', 114, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_SYNC		   _IOW('f', 114, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_READ2		  _IOWR('f', 115, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_FORMAT		 _IOWR('f', 116, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_PARTITION	      _IOWR('f', 117, OBD_IOC_DATA_TYPE)
@@ -308,13 +308,13 @@ static inline void obd_ioctl_freedata(char *buf, int len)
 #define OBD_IOC_GETDTNAME	       OBD_IOC_GETNAME
 
 #define OBD_IOC_LOV_GET_CONFIG	 _IOWR('f', 132, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_CLIENT_RECOVER	 _IOW ('f', 133, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PING_TARGET	    _IOW ('f', 136, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_CLIENT_RECOVER	 _IOW('f', 133, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_PING_TARGET	    _IOW('f', 136, OBD_IOC_DATA_TYPE)
 
 #define OBD_IOC_DEC_FS_USE_COUNT       _IO  ('f', 139)
-#define OBD_IOC_NO_TRANSNO	     _IOW ('f', 140, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_SET_READONLY	   _IOW ('f', 141, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_ABORT_RECOVERY	 _IOR ('f', 142, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_NO_TRANSNO	     _IOW('f', 140, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_SET_READONLY	   _IOW('f', 141, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_ABORT_RECOVERY	 _IOR('f', 142, OBD_IOC_DATA_TYPE)
 
 #define OBD_IOC_ROOT_SQUASH	    _IOWR('f', 143, OBD_IOC_DATA_TYPE)
 
@@ -324,27 +324,27 @@ static inline void obd_ioctl_freedata(char *buf, int len)
 
 #define OBD_IOC_CLOSE_UUID	     _IOWR ('f', 147, OBD_IOC_DATA_TYPE)
 
-#define OBD_IOC_CHANGELOG_SEND	 _IOW ('f', 148, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_CHANGELOG_SEND	 _IOW('f', 148, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETDEVICE	      _IOWR ('f', 149, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_FID2PATH	       _IOWR ('f', 150, OBD_IOC_DATA_TYPE)
 /* see also <lustre/lustre_user.h> for ioctls 151-153 */
 /* OBD_IOC_LOV_SETSTRIPE: See also LL_IOC_LOV_SETSTRIPE */
-#define OBD_IOC_LOV_SETSTRIPE	  _IOW ('f', 154, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LOV_SETSTRIPE	  _IOW('f', 154, OBD_IOC_DATA_TYPE)
 /* OBD_IOC_LOV_GETSTRIPE: See also LL_IOC_LOV_GETSTRIPE */
-#define OBD_IOC_LOV_GETSTRIPE	  _IOW ('f', 155, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LOV_GETSTRIPE	  _IOW('f', 155, OBD_IOC_DATA_TYPE)
 /* OBD_IOC_LOV_SETEA: See also LL_IOC_LOV_SETEA */
-#define OBD_IOC_LOV_SETEA	      _IOW ('f', 156, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_LOV_SETEA	      _IOW('f', 156, OBD_IOC_DATA_TYPE)
 /* see <lustre/lustre_user.h> for ioctls 157-159 */
 /* OBD_IOC_QUOTACHECK: See also LL_IOC_QUOTACHECK */
-#define OBD_IOC_QUOTACHECK	     _IOW ('f', 160, int)
+#define OBD_IOC_QUOTACHECK	     _IOW('f', 160, int)
 /* OBD_IOC_POLL_QUOTACHECK: See also LL_IOC_POLL_QUOTACHECK */
-#define OBD_IOC_POLL_QUOTACHECK	_IOR ('f', 161, struct if_quotacheck *)
+#define OBD_IOC_POLL_QUOTACHECK	_IOR('f', 161, struct if_quotacheck *)
 /* OBD_IOC_QUOTACTL: See also LL_IOC_QUOTACTL */
 #define OBD_IOC_QUOTACTL	       _IOWR('f', 162, struct if_quotactl)
 /* see  also <lustre/lustre_user.h> for ioctls 163-176 */
-#define OBD_IOC_CHANGELOG_REG	  _IOW ('f', 177, struct obd_ioctl_data)
-#define OBD_IOC_CHANGELOG_DEREG	_IOW ('f', 178, struct obd_ioctl_data)
-#define OBD_IOC_CHANGELOG_CLEAR	_IOW ('f', 179, struct obd_ioctl_data)
+#define OBD_IOC_CHANGELOG_REG	  _IOW('f', 177, struct obd_ioctl_data)
+#define OBD_IOC_CHANGELOG_DEREG	_IOW('f', 178, struct obd_ioctl_data)
+#define OBD_IOC_CHANGELOG_CLEAR	_IOW('f', 179, struct obd_ioctl_data)
 #define OBD_IOC_RECORD		 _IOWR('f', 180, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_ENDRECORD	      _IOWR('f', 181, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_PARSE		  _IOWR('f', 182, OBD_IOC_DATA_TYPE)
@@ -352,7 +352,7 @@ static inline void obd_ioctl_freedata(char *buf, int len)
 #define OBD_IOC_PROCESS_CFG	    _IOWR('f', 184, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_DUMP_LOG	       _IOWR('f', 185, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_CLEAR_LOG	      _IOWR('f', 186, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PARAM		  _IOW ('f', 187, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_PARAM		  _IOW('f', 187, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_POOL		   _IOWR('f', 188, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_REPLACE_NIDS	   _IOWR('f', 189, OBD_IOC_DATA_TYPE)
 
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index 43a7f7a..e4edfb2 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -68,8 +68,8 @@ int block_debug_check(char *who, void *addr, int end, __u64 off, __u64 id)
 
 	LASSERT(addr);
 
-	ne_off = le64_to_cpu (off);
-	id = le64_to_cpu (id);
+	ne_off = le64_to_cpu(off);
+	id = le64_to_cpu(id);
 	if (memcmp(addr, (char *)&ne_off, LPDS)) {
 		CDEBUG(D_ERROR, "%s: id %#llx offset %llu off: %#llx != %#llx\n",
 		       who, id, off, *(__u64 *)addr, ne_off);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index aba6469..ae19d39 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -403,20 +403,20 @@ extern struct lu_context_key osc_session_key;
 int osc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
 		  const struct cl_io *io);
-int osc_io_init  (const struct lu_env *env,
-		  struct cl_object *obj, struct cl_io *io);
-int osc_req_init (const struct lu_env *env, struct cl_device *dev,
-		  struct cl_req *req);
+int osc_io_init(const struct lu_env *env,
+		struct cl_object *obj, struct cl_io *io);
+int osc_req_init(const struct lu_env *env, struct cl_device *dev,
+		 struct cl_req *req);
 struct lu_object *osc_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t ind);
 
-void osc_index2policy  (ldlm_policy_data_t *policy, const struct cl_object *obj,
-			pgoff_t start, pgoff_t end);
-int  osc_lvb_print     (const struct lu_env *env, void *cookie,
-			lu_printer_t p, const struct ost_lvb *lvb);
+void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
+		      pgoff_t start, pgoff_t end);
+int osc_lvb_print(const struct lu_env *env, void *cookie,
+		  lu_printer_t p, const struct ost_lvb *lvb);
 
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
@@ -448,11 +448,11 @@ void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 		   struct osc_object *osc);
 int lru_queue_work(const struct lu_env *env, void *data);
 
-void osc_object_set_contended  (struct osc_object *obj);
+void osc_object_set_contended(struct osc_object *obj);
 void osc_object_clear_contended(struct osc_object *obj);
-int  osc_object_is_contended   (struct osc_object *obj);
+int  osc_object_is_contended(struct osc_object *obj);
 
-int  osc_lock_is_lockless      (const struct osc_lock *olck);
+int  osc_lock_is_lockless(const struct osc_lock *olck);
 
 /*****************************************************************************
  *
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 5b9f72c..4d3eed6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2485,7 +2485,7 @@ static int osc_statfs_async(struct obd_export *exp,
 	}
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_statfs_interpret;
-	CLASSERT (sizeof(*aa) <= sizeof(req->rq_async_args));
+	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	aa->aa_oi = oinfo;
 
-- 
2.1.0
