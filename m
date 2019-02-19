From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 23/37] lustre: prefer to use tabs for
 alignment.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494604.24125.7873412904407447511.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch changes a lot of places that use spaces for
alignment to instead use tabs - though in one case in a
comment, spaces are used in place of tabs to be more consistent.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    2 
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   10 -
 .../lustre/include/linux/libcfs/libcfs_debug.h     |   30 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   12 -
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   24 +
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 
 .../staging/lustre/include/linux/lnet/socklnd.h    |    2 
 .../lustre/include/uapi/linux/lnet/libcfs_debug.h  |  124 +++----
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |   56 +--
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   10 -
 .../lustre/include/uapi/linux/lnet/lnetst.h        |   14 -
 .../lustre/include/uapi/linux/lnet/nidstr.h        |    6 
 .../include/uapi/linux/lustre/lustre_fiemap.h      |    2 
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  350 +++++++++----------
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  378 ++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   60 ++-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   32 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    4 
 drivers/staging/lustre/lnet/selftest/timer.c       |    8 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    2 
 .../staging/lustre/lustre/include/lustre_import.h  |    6 
 drivers/staging/lustre/lustre/include/obd.h        |   10 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    6 
 drivers/staging/lustre/lustre/llite/file.c         |    2 
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    2 
 drivers/staging/lustre/lustre/llite/xattr.c        |    2 
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   26 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   24 +
 drivers/staging/lustre/lustre/obdclass/genops.c    |    6 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    8 
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    2 
 drivers/staging/lustre/lustre/osc/osc_request.c    |   40 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 
 35 files changed, 635 insertions(+), 635 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 3e51752491d0..56905317fab0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -372,7 +372,7 @@ enum {
 
 struct cfs_percpt_lock {
 	/* cpu-partition-table for this lock */
-	struct cfs_cpt_table     *pcl_cptab;
+	struct cfs_cpt_table	 *pcl_cptab;
 	/* exclusively locked */
 	unsigned int		  pcl_locked;
 	/* private lock table */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index ca8620b93de7..03da963b8d33 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -33,17 +33,17 @@
 struct page;
 
 struct cfs_crypto_hash_type {
-	char		*cht_name;      /*< hash algorithm name, equal to
+	char		*cht_name;	/*< hash algorithm name, equal to
 					 * format name for crypto api
 					 */
-	unsigned int    cht_key;	/*< init key by default (valid for
+	unsigned int	cht_key;	/*< init key by default (valid for
 					 * 4 bytes context like crc32, adler
 					 */
-	unsigned int    cht_size;       /**< hash digest size */
+	unsigned int	cht_size;	/**< hash digest size */
 };
 
 enum cfs_crypto_hash_alg {
-	CFS_HASH_ALG_NULL       = 0,
+	CFS_HASH_ALG_NULL	= 0,
 	CFS_HASH_ALG_ADLER32,
 	CFS_HASH_ALG_CRC32,
 	CFS_HASH_ALG_CRC32C,
@@ -54,7 +54,7 @@ enum cfs_crypto_hash_alg {
 	CFS_HASH_ALG_SHA384,
 	CFS_HASH_ALG_SHA512,
 	CFS_HASH_ALG_MAX,
-	CFS_HASH_ALG_SPEED_MAX = CFS_HASH_ALG_MD5,
+	CFS_HASH_ALG_SPEED_MAX	= CFS_HASH_ALG_MD5,
 	CFS_HASH_ALG_UNKNOWN	= 0xff
 };
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 3fd6ad7a3b56..ba5d5ba2dac2 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -68,11 +68,11 @@ extern unsigned int libcfs_panic_on_lbug;
 #if !defined(__x86_64__)
 # ifdef __ia64__
 #  define CDEBUG_STACK() (THREAD_SIZE -					\
-			  ((unsigned long)__builtin_dwarf_cfa() &       \
+			  ((unsigned long)__builtin_dwarf_cfa() &	\
 			   (THREAD_SIZE - 1)))
 # else
 #  define CDEBUG_STACK() (THREAD_SIZE -					\
-			  ((unsigned long)__builtin_frame_address(0) &  \
+			  ((unsigned long)__builtin_frame_address(0) &	\
 			   (THREAD_SIZE - 1)))
 # endif /* __ia64__ */
 
@@ -87,7 +87,7 @@ do {									\
 		(msgdata)->msg_mask = mask;				\
 		(msgdata)->msg_cdls = cdls;				\
 		dump_stack();						\
-	      /*panic("LBUG");*/					\
+		/*panic("LBUG");*/					\
 	}								\
 } while (0)
 #define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
@@ -120,22 +120,22 @@ struct libcfs_debug_msg_data {
 
 #define LIBCFS_DEBUG_MSG_DATA_INIT(data, mask, cdls)			\
 do {									\
-	(data)->msg_subsys = DEBUG_SUBSYSTEM;				\
-	(data)->msg_file   = __FILE__;					\
-	(data)->msg_fn     = __func__;					\
-	(data)->msg_line   = __LINE__;					\
-	(data)->msg_cdls   = (cdls);					\
-	(data)->msg_mask   = (mask);					\
+	(data)->msg_subsys	= DEBUG_SUBSYSTEM;			\
+	(data)->msg_file	= __FILE__;				\
+	(data)->msg_fn		= __func__;				\
+	(data)->msg_line	= __LINE__;				\
+	(data)->msg_cdls	= (cdls);				\
+	(data)->msg_mask	= (mask);				\
 } while (0)
 
 #define LIBCFS_DEBUG_MSG_DATA_DECL(dataname, mask, cdls)		\
 	static struct libcfs_debug_msg_data dataname = {		\
-	       .msg_subsys = DEBUG_SUBSYSTEM,				\
-	       .msg_file   = __FILE__,					\
-	       .msg_fn     = __func__,					\
-	       .msg_line   = __LINE__,					\
-	       .msg_cdls   = (cdls)	 };				\
-	dataname.msg_mask   = (mask)
+		.msg_subsys	= DEBUG_SUBSYSTEM,			\
+		.msg_file	= __FILE__,				\
+		.msg_fn		= __func__,				\
+		.msg_line	= __LINE__,				\
+		.msg_cdls	= (cdls)	 };			\
+	dataname.msg_mask	= (mask)
 
 /**
  * Filters out logging messages based on mask and subsystem.
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 4a4197874f80..0e73eef6a992 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -47,10 +47,10 @@ int __cfs_fail_check_set(u32 id, u32 value, int set);
 int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set);
 
 enum {
-	CFS_FAIL_LOC_NOSET      = 0,
-	CFS_FAIL_LOC_ORSET      = 1,
-	CFS_FAIL_LOC_RESET      = 2,
-	CFS_FAIL_LOC_VALUE      = 3
+	CFS_FAIL_LOC_NOSET	= 0,
+	CFS_FAIL_LOC_ORSET	= 1,
+	CFS_FAIL_LOC_RESET	= 2,
+	CFS_FAIL_LOC_VALUE	= 3
 };
 
 /* Failure injection control */
@@ -76,8 +76,8 @@ enum {
 static inline bool CFS_FAIL_PRECHECK(u32 id)
 {
 	return cfs_fail_loc &&
-	       ((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
-		(cfs_fail_loc & id & CFS_FAULT));
+		((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
+		 (cfs_fail_loc & id & CFS_FAULT));
 }
 
 static inline int cfs_fail_check_set(u32 id, u32 value,
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index be315958a4b3..89d25ca57c18 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -304,25 +304,25 @@ struct cfs_hash_ops {
 	unsigned int (*hs_hash)(struct cfs_hash *hs, const void *key,
 				unsigned int mask);
 	/** return key address of @hnode */
-	void *   (*hs_key)(struct hlist_node *hnode);
+	void *	(*hs_key)(struct hlist_node *hnode);
 	/** copy key from @hnode to @key */
-	void     (*hs_keycpy)(struct hlist_node *hnode, void *key);
+	void	(*hs_keycpy)(struct hlist_node *hnode, void *key);
 	/**
 	 *  compare @key with key of @hnode
 	 *  returns 1 on a match
 	 */
-	int      (*hs_keycmp)(const void *key, struct hlist_node *hnode);
+	int	(*hs_keycmp)(const void *key, struct hlist_node *hnode);
 	/** return object address of @hnode, i.e: container_of(...hnode) */
-	void *   (*hs_object)(struct hlist_node *hnode);
+	void *	(*hs_object)(struct hlist_node *hnode);
 	/** get refcount of item, always called with holding bucket-lock */
-	void     (*hs_get)(struct cfs_hash *hs, struct hlist_node *hnode);
+	void	(*hs_get)(struct cfs_hash *hs, struct hlist_node *hnode);
 	/** release refcount of item */
-	void     (*hs_put)(struct cfs_hash *hs, struct hlist_node *hnode);
+	void	(*hs_put)(struct cfs_hash *hs, struct hlist_node *hnode);
 	/** release refcount of item, always called with holding bucket-lock */
-	void     (*hs_put_locked)(struct cfs_hash *hs,
-				  struct hlist_node *hnode);
+	void	(*hs_put_locked)(struct cfs_hash *hs,
+				 struct hlist_node *hnode);
 	/** it's called before removing of @hnode */
-	void     (*hs_exit)(struct cfs_hash *hs, struct hlist_node *hnode);
+	void	(*hs_exit)(struct cfs_hash *hs, struct hlist_node *hnode);
 };
 
 /** total number of buckets in @hs */
@@ -460,8 +460,8 @@ static inline int
 cfs_hash_bkt_size(struct cfs_hash *hs)
 {
 	return offsetof(struct cfs_hash_bucket, hsb_head[0]) +
-	       hs->hs_hops->hop_hhead_size(hs) * CFS_HASH_BKT_NHLIST(hs) +
-	       hs->hs_extra_bytes;
+		hs->hs_hops->hop_hhead_size(hs) * CFS_HASH_BKT_NHLIST(hs) +
+		hs->hs_extra_bytes;
 }
 
 static inline unsigned
@@ -703,7 +703,7 @@ void *cfs_hash_del(struct cfs_hash *hs, const void *key,
 void *cfs_hash_del_key(struct cfs_hash *hs, const void *key);
 
 /* Hash lookup/for_each functions */
-#define CFS_HASH_LOOP_HOG       1024
+#define CFS_HASH_LOOP_HOG	1024
 
 typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
 				      struct cfs_hash_bd *bd,
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d525e4f928fe..515fd63708c0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -141,7 +141,7 @@ void  cfs_array_free(void *vars);
 #define LASSERT_ATOMIC_GT_LT(a, v1, v2)				\
 do {								\
 	int __v = atomic_read(a);				\
-	LASSERTF(__v > v1 && __v < v2, "value: %d\n", __v);     \
+	LASSERTF(__v > v1 && __v < v2, "value: %d\n", __v);	\
 } while (0)
 
 /** assert value of @a is great than @v1 and little/equal to @v2 */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index fb5d07460243..e60c446fbb27 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -611,7 +611,7 @@ void lnet_counters_reset(void);
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
 int lnet_extract_iov(int dst_niov, struct kvec *dst,
 		     int src_niov, const struct kvec *src,
-		      unsigned int offset, unsigned int len);
+		     unsigned int offset, unsigned int len);
 
 unsigned int lnet_kiov_nob(unsigned int niov, struct bio_vec *iov);
 int lnet_extract_kiov(int dst_niov, struct bio_vec *dst,
@@ -827,7 +827,7 @@ void lnet_incr_stats(struct lnet_element_stats *stats,
 		     enum lnet_stats_type stats_type);
 
 u32 lnet_sum_stats(struct lnet_element_stats *stats,
-		     enum lnet_stats_type stats_type);
+		   enum lnet_stats_type stats_type);
 
 void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			      struct lnet_element_stats *stats);
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index ca814afd34ef..9f318b73cd34 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -41,7 +41,7 @@
 struct ksock_hello_msg {
 	u32		kshm_magic;	/* magic number of socklnd message */
 	u32		kshm_version;	/* version of socklnd message */
-	lnet_nid_t      kshm_src_nid;	/* sender's nid */
+	lnet_nid_t	kshm_src_nid;	/* sender's nid */
 	lnet_nid_t	kshm_dst_nid;	/* destination nid */
 	lnet_pid_t	kshm_src_pid;	/* sender's pid */
 	lnet_pid_t	kshm_dst_pid;	/* destination pid */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
index 2672fe7ae103..91d80ab064ad 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
@@ -62,38 +62,38 @@ struct ptldebug_header {
 #define PH_FLAG_FIRST_RECORD	1
 
 /* Debugging subsystems (32 bits, non-overlapping) */
-#define S_UNDEFINED     0x00000001
-#define S_MDC           0x00000002
-#define S_MDS           0x00000004
-#define S_OSC           0x00000008
-#define S_OST           0x00000010
-#define S_CLASS         0x00000020
-#define S_LOG           0x00000040
-#define S_LLITE         0x00000080
-#define S_RPC           0x00000100
-#define S_MGMT          0x00000200
-#define S_LNET          0x00000400
-#define S_LND           0x00000800 /* ALL LNDs */
-#define S_PINGER        0x00001000
-#define S_FILTER        0x00002000
-#define S_LIBCFS        0x00004000
-#define S_ECHO          0x00008000
-#define S_LDLM          0x00010000
-#define S_LOV           0x00020000
-#define S_LQUOTA        0x00040000
-#define S_OSD           0x00080000
-#define S_LFSCK         0x00100000
-#define S_SNAPSHOT      0x00200000
+#define S_UNDEFINED	0x00000001
+#define S_MDC		0x00000002
+#define S_MDS		0x00000004
+#define S_OSC		0x00000008
+#define S_OST		0x00000010
+#define S_CLASS		0x00000020
+#define S_LOG		0x00000040
+#define S_LLITE		0x00000080
+#define S_RPC		0x00000100
+#define S_MGMT		0x00000200
+#define S_LNET		0x00000400
+#define S_LND		0x00000800 /* ALL LNDs */
+#define S_PINGER	0x00001000
+#define S_FILTER	0x00002000
+#define S_LIBCFS	0x00004000
+#define S_ECHO		0x00008000
+#define S_LDLM		0x00010000
+#define S_LOV		0x00020000
+#define S_LQUOTA	0x00040000
+#define S_OSD		0x00080000
+#define S_LFSCK		0x00100000
+#define S_SNAPSHOT	0x00200000
 /* unused */
-#define S_LMV           0x00800000 /* b_new_cmd */
+#define S_LMV		0x00800000 /* b_new_cmd */
 /* unused */
-#define S_SEC           0x02000000 /* upcall cache */
-#define S_GSS           0x04000000 /* b_new_cmd */
+#define S_SEC		0x02000000 /* upcall cache */
+#define S_GSS		0x04000000 /* b_new_cmd */
 /* unused */
-#define S_MGC           0x10000000
-#define S_MGS           0x20000000
-#define S_FID           0x40000000 /* b_new_cmd */
-#define S_FLD           0x80000000 /* b_new_cmd */
+#define S_MGC		0x10000000
+#define S_MGS		0x20000000
+#define S_FID		0x40000000 /* b_new_cmd */
+#define S_FLD		0x80000000 /* b_new_cmd */
 
 #define LIBCFS_DEBUG_SUBSYS_NAMES {					\
 	"undefined", "mdc", "mds", "osc", "ost", "class", "log",	\
@@ -103,38 +103,38 @@ struct ptldebug_header {
 	"fid", "fld", NULL }
 
 /* Debugging masks (32 bits, non-overlapping) */
-#define D_TRACE         0x00000001 /* ENTRY/EXIT markers */
-#define D_INODE         0x00000002
-#define D_SUPER         0x00000004
-#define D_EXT2          0x00000008 /* anything from ext2_debug */
-#define D_MALLOC        0x00000010 /* print malloc, free information */
-#define D_CACHE         0x00000020 /* cache-related items */
-#define D_INFO          0x00000040 /* general information */
-#define D_IOCTL         0x00000080 /* ioctl related information */
-#define D_NETERROR      0x00000100 /* network errors */
-#define D_NET           0x00000200 /* network communications */
-#define D_WARNING       0x00000400 /* CWARN(...) == CDEBUG (D_WARNING, ...) */
-#define D_BUFFS         0x00000800
-#define D_OTHER         0x00001000
-#define D_DENTRY        0x00002000
-#define D_NETTRACE      0x00004000
-#define D_PAGE          0x00008000 /* bulk page handling */
-#define D_DLMTRACE      0x00010000
-#define D_ERROR         0x00020000 /* CERROR(...) == CDEBUG (D_ERROR, ...) */
-#define D_EMERG         0x00040000 /* CEMERG(...) == CDEBUG (D_EMERG, ...) */
-#define D_HA            0x00080000 /* recovery and failover */
-#define D_RPCTRACE      0x00100000 /* for distributed debugging */
-#define D_VFSTRACE      0x00200000
-#define D_READA         0x00400000 /* read-ahead */
-#define D_MMAP          0x00800000
-#define D_CONFIG        0x01000000
-#define D_CONSOLE       0x02000000
-#define D_QUOTA         0x04000000
-#define D_SEC           0x08000000
-#define D_LFSCK         0x10000000 /* For both OI scrub and LFSCK */
-#define D_HSM           0x20000000
-#define D_SNAPSHOT      0x40000000 /* snapshot */
-#define D_LAYOUT        0x80000000
+#define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
+#define D_INODE		0x00000002
+#define D_SUPER		0x00000004
+#define D_EXT2		0x00000008 /* anything from ext2_debug */
+#define D_MALLOC	0x00000010 /* print malloc, free information */
+#define D_CACHE		0x00000020 /* cache-related items */
+#define D_INFO		0x00000040 /* general information */
+#define D_IOCTL		0x00000080 /* ioctl related information */
+#define D_NETERROR	0x00000100 /* network errors */
+#define D_NET		0x00000200 /* network communications */
+#define D_WARNING	0x00000400 /* CWARN(...) == CDEBUG (D_WARNING, ...) */
+#define D_BUFFS		0x00000800
+#define D_OTHER		0x00001000
+#define D_DENTRY	0x00002000
+#define D_NETTRACE	0x00004000
+#define D_PAGE		0x00008000 /* bulk page handling */
+#define D_DLMTRACE	0x00010000
+#define D_ERROR		0x00020000 /* CERROR(...) == CDEBUG (D_ERROR, ...) */
+#define D_EMERG		0x00040000 /* CEMERG(...) == CDEBUG (D_EMERG, ...) */
+#define D_HA		0x00080000 /* recovery and failover */
+#define D_RPCTRACE	0x00100000 /* for distributed debugging */
+#define D_VFSTRACE	0x00200000
+#define D_READA		0x00400000 /* read-ahead */
+#define D_MMAP		0x00800000
+#define D_CONFIG	0x01000000
+#define D_CONSOLE	0x02000000
+#define D_QUOTA		0x04000000
+#define D_SEC		0x08000000
+#define D_LFSCK		0x10000000 /* For both OI scrub and LFSCK */
+#define D_HSM		0x20000000
+#define D_SNAPSHOT	0x40000000 /* snapshot */
+#define D_LAYOUT	0x80000000
 
 #define LIBCFS_DEBUG_MASKS_NAMES {					\
 	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
@@ -144,7 +144,7 @@ struct ptldebug_header {
 	"console", "quota", "sec", "lfsck", "hsm", "snapshot", "layout",\
 	NULL }
 
-#define D_CANTMASK   (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
+#define D_CANTMASK	(D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
 
 #define LIBCFS_DEBUG_FILE_PATH_DEFAULT "/tmp/lustre-log"
 
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index 4590f65c333f..765466f41d61 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -82,41 +82,41 @@ struct libcfs_debug_ioctl_data {
 };
 
 /* 'f' ioctls are defined in lustre_ioctl.h and lustre_user.h except for: */
-#define LIBCFS_IOC_DEBUG_MASK		   _IOWR('f', 250, long)
-#define IOCTL_LIBCFS_TYPE		   long
+#define LIBCFS_IOC_DEBUG_MASK		_IOWR('f', 250, long)
+#define IOCTL_LIBCFS_TYPE		long
 
-#define IOC_LIBCFS_TYPE			   ('e')
-#define IOC_LIBCFS_MIN_NR		   30
+#define IOC_LIBCFS_TYPE			('e')
+#define IOC_LIBCFS_MIN_NR		30
 /* libcfs ioctls */
 /* IOC_LIBCFS_PANIC obsolete in 2.8.0, was _IOWR('e', 30, IOCTL_LIBCFS_TYPE) */
-#define IOC_LIBCFS_CLEAR_DEBUG		   _IOWR('e', 31, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_MARK_DEBUG		   _IOWR('e', 32, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_CLEAR_DEBUG		_IOWR('e', 31, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_MARK_DEBUG		_IOWR('e', 32, IOCTL_LIBCFS_TYPE)
 /* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
-#define IOC_LIBCFS_GET_NI		   _IOWR('e', 50, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_FAIL_NID		   _IOWR('e', 51, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_NOTIFY_ROUTER	   _IOWR('e', 55, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_UNCONFIGURE		   _IOWR('e', 56, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_NI		_IOWR('e', 50, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_NOTIFY_ROUTER	_IOWR('e', 55, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_UNCONFIGURE		_IOWR('e', 56, IOCTL_LIBCFS_TYPE)
 /*	 IOC_LIBCFS_PORTALS_COMPATIBILITY  _IOWR('e', 57, IOCTL_LIBCFS_TYPE) */
-#define IOC_LIBCFS_LNET_DIST		   _IOWR('e', 58, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_CONFIGURE		   _IOWR('e', 59, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_TESTPROTOCOMPAT	   _IOWR('e', 60, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_PING			   _IOWR('e', 61, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_PING_PEER               _IOWR('e', 62, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_LNETST		   _IOWR('e', 63, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_LNET_FAULT		   _IOWR('e', 64, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_LNET_DIST		_IOWR('e', 58, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_CONFIGURE		_IOWR('e', 59, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_TESTPROTOCOMPAT	_IOWR('e', 60, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_PING			_IOWR('e', 61, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_PING_PEER		_IOWR('e', 62, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_LNETST		_IOWR('e', 63, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_LNET_FAULT		_IOWR('e', 64, IOCTL_LIBCFS_TYPE)
 /* lnd ioctls */
-#define IOC_LIBCFS_REGISTER_MYNID	   _IOWR('e', 70, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_CLOSE_CONNECTION	   _IOWR('e', 71, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_PUSH_CONNECTION	   _IOWR('e', 72, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_GET_CONN		   _IOWR('e', 73, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_DEL_PEER		   _IOWR('e', 74, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_ADD_PEER		   _IOWR('e', 75, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_GET_PEER		   _IOWR('e', 76, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_DISCOVER                _IOWR('e', 77, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_ADD_INTERFACE	   _IOWR('e', 78, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, IOCTL_LIBCFS_TYPE)
-#define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_REGISTER_MYNID	_IOWR('e', 70, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_CLOSE_CONNECTION	_IOWR('e', 71, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_PUSH_CONNECTION	_IOWR('e', 72, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_CONN		_IOWR('e', 73, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_DEL_PEER		_IOWR('e', 74, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_ADD_PEER		_IOWR('e', 75, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_PEER		_IOWR('e', 76, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_DISCOVER		_IOWR('e', 77, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_ADD_INTERFACE	_IOWR('e', 78, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_DEL_INTERFACE	_IOWR('e', 79, IOCTL_LIBCFS_TYPE)
+#define IOC_LIBCFS_GET_INTERFACE	_IOWR('e', 80, IOCTL_LIBCFS_TYPE)
 
 /*
  * DLC Specific IOCTL numbers.
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 4fcc5336d927..956af3c53cfc 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -289,9 +289,9 @@ struct lnet_counters {
 	__u64	drop_length;
 } __packed;
 
-#define LNET_NI_STATUS_UP      0x15aac0de
-#define LNET_NI_STATUS_DOWN    0xdeadface
-#define LNET_NI_STATUS_INVALID 0x00000000
+#define LNET_NI_STATUS_UP	0x15aac0de
+#define LNET_NI_STATUS_DOWN	0xdeadface
+#define LNET_NI_STATUS_INVALID	0x00000000
 
 #define LNET_INTERFACES_NUM		16
 
@@ -596,7 +596,7 @@ enum lnet_event_kind {
 	LNET_EVENT_UNLINK,
 };
 
-#define LNET_SEQ_GT(a, b)      (((signed long)((a) - (b))) > 0)
+#define LNET_SEQ_GT(a, b)	(((signed long)((a) - (b))) > 0)
 
 /**
  * Information about an event on a MD.
@@ -650,7 +650,7 @@ struct lnet_event {
 	 * The message type, to ensure a handler for LNET_EVENT_SEND can
 	 * distinguish between LNET_MSG_GET and LNET_MSG_PUT.
 	 */
-	__u32               msg_type;
+	__u32			msg_type;
 	/**
 	 * Indicates the completion status of the operation. It's 0 for
 	 * successful operations, otherwise it's an error code.
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
index a6eebee1a69c..27fcd91931a6 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
@@ -58,7 +58,7 @@
 					 */
 #define LSTIO_GROUP_DEL		0xC13	/* delete group */
 #define LSTIO_NODES_ADD		0xC14	/* add nodes to specified group */
-#define LSTIO_GROUP_UPDATE      0xC15	/* update group */
+#define LSTIO_GROUP_UPDATE	0xC15	/* update group */
 #define LSTIO_BATCH_ADD		0xC20	/* add batch */
 #define LSTIO_BATCH_START	0xC21	/* start batch */
 #define LSTIO_BATCH_STOP	0xC22	/* stop batch */
@@ -100,9 +100,9 @@ struct lstcon_ndlist_ent {
 };				/*** node_list entry, for list_batch command */
 
 struct lstcon_test_ent {
-	int	tse_type;       /* test type */
-	int	tse_loop;       /* loop count */
-	int	tse_concur;     /* concurrency of test */
+	int	tse_type;	/* test type */
+	int	tse_loop;	/* loop count */
+	int	tse_concur;	/* concurrency of test */
 };				/* test summary entry, for
 				 * list_batch command
 				 */
@@ -520,9 +520,9 @@ enum lst_brw_flags {
 
 struct lst_test_bulk_param {
 	int	blk_opc;	/* bulk operation code */
-	int	blk_size;       /* size (bytes) */
-	int	blk_time;       /* time of running the test*/
-	int	blk_flags;      /* reserved flags */
+	int	blk_size;	/* size (bytes) */
+	int	blk_time;	/* time of running the test*/
+	int	blk_flags;	/* reserved flags */
 	int	blk_cli_off;	/* bulk offset on client */
 	int	blk_srv_off;	/* reserved: bulk offset on server */
 };
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
index 3c5901d81d52..6c49d59f4f85 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
@@ -44,7 +44,7 @@ enum {
 	/*GMLND		= 3, removed v2_0_0-rc1a-16-gc660aac	*/
 	/*PTLLND	= 4, removed v2_7_50			*/
 	O2IBLND		= 5,
-	/*CIBLND        = 6, removed v2_0_0-rc1a-175-gd2b8a0e	*/
+	/*CIBLND	= 6, removed v2_0_0-rc1a-175-gd2b8a0e	*/
 	/*OPENIBLND	= 7, removed v2_0_0-rc1a-175-gd2b8a0e	*/
 	/*IIBLND	= 8, removed v2_0_0-rc1a-175-gd2b8a0e	*/
 	LOLND		= 9,
@@ -57,8 +57,8 @@ enum {
 
 struct list_head;
 
-#define LNET_NIDSTR_COUNT  1024    /* # of nidstrings */
-#define LNET_NIDSTR_SIZE   32      /* size of each one (see below for usage) */
+#define LNET_NIDSTR_COUNT	1024	/* # of nidstrings */
+#define LNET_NIDSTR_SIZE	32	/* size of each one (see below for usage) */
 
 /* support decl needed by both kernel and user space */
 char *libcfs_next_nidstring(void);
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
index d24a93e57ed7..7ecb6f6354cc 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
@@ -49,7 +49,7 @@
 static inline size_t fiemap_count_to_size(size_t extent_count)
 {
 	return sizeof(struct fiemap) + extent_count *
-				       sizeof(struct fiemap_extent);
+		sizeof(struct fiemap_extent);
 }
 
 static inline unsigned int fiemap_size_to_count(size_t array_size)
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index bffe62e87e00..62b9a3301c4d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -443,14 +443,14 @@ struct luda_type {
 };
 
 #ifndef IFSHIFT
-#define IFSHIFT                 12
+#define IFSHIFT		12
 #endif
 
 #ifndef IFTODT
-#define IFTODT(type)		(((type) & S_IFMT) >> IFSHIFT)
+#define IFTODT(type)	(((type) & S_IFMT) >> IFSHIFT)
 #endif
 #ifndef DTTOIF
-#define DTTOIF(dirtype)		((dirtype) << IFSHIFT)
+#define DTTOIF(dirtype)	((dirtype) << IFSHIFT)
 #endif
 
 struct lu_dirpage {
@@ -551,8 +551,8 @@ static inline void lustre_handle_copy(struct lustre_handle *tgt,
 }
 
 /* flags for lm_flags */
-#define MSGHDR_AT_SUPPORT	       0x1
-#define MSGHDR_CKSUM_INCOMPAT18	 0x2
+#define MSGHDR_AT_SUPPORT	0x1
+#define MSGHDR_CKSUM_INCOMPAT18	0x2
 
 #define lustre_msg lustre_msg_v2
 /* we depend on this structure to be 8-byte aligned */
@@ -570,7 +570,7 @@ struct lustre_msg_v2 {
 };
 
 /* without gss, ptlrpc_body is put@the first buffer. */
-#define PTLRPC_NUM_VERSIONS     4
+#define PTLRPC_NUM_VERSIONS	4
 
 struct ptlrpc_body_v3 {
 	struct lustre_handle pb_handle;
@@ -578,8 +578,8 @@ struct ptlrpc_body_v3 {
 	__u32 pb_version;
 	__u32 pb_opc;
 	__u32 pb_status;
-	__u64 pb_last_xid; /* highest replied XID without lower unreplied XID */
-	__u16 pb_tag;      /* virtual slot idx for multiple modifying RPCs */
+	__u64 pb_last_xid;	/* highest replied XID without lower unreplied XID */
+	__u16 pb_tag;		/* virtual slot idx for multiple modifying RPCs */
 	__u16 pb_padding0;
 	__u32 pb_padding1;
 	__u64 pb_last_committed;
@@ -587,13 +587,13 @@ struct ptlrpc_body_v3 {
 	__u32 pb_flags;
 	__u32 pb_op_flags;
 	__u32 pb_conn_cnt;
-	__u32 pb_timeout;  /* for req, the deadline, for rep, the service est */
-	__u32 pb_service_time; /* for rep, actual service time */
+	__u32 pb_timeout;	/* for req, the deadline, for rep, the service est */
+	__u32 pb_service_time;	/* for rep, actual service time */
 	__u32 pb_limit;
 	__u64 pb_slv;
 	/* VBR: pre-versions */
 	__u64 pb_pre_versions[PTLRPC_NUM_VERSIONS];
-	__u64 pb_mbits; /**< match bits for bulk request */
+	__u64 pb_mbits;		/**< match bits for bulk request */
 	/* padding for future needs */
 	__u64 pb_padding64_0;
 	__u64 pb_padding64_1;
@@ -601,7 +601,7 @@ struct ptlrpc_body_v3 {
 	char  pb_jobid[LUSTRE_JOBID_SIZE];
 };
 
-#define ptlrpc_body     ptlrpc_body_v3
+#define ptlrpc_body	ptlrpc_body_v3
 
 struct ptlrpc_body_v2 {
 	struct lustre_handle pb_handle;
@@ -609,8 +609,8 @@ struct ptlrpc_body_v2 {
 	__u32 pb_version;
 	__u32 pb_opc;
 	__u32 pb_status;
-	__u64 pb_last_xid; /* highest replied XID without lower unreplied XID */
-	__u16 pb_tag;      /* virtual slot idx for multiple modifying RPCs */
+	__u64 pb_last_xid;	/* highest replied XID without lower unreplied XID */
+	__u16 pb_tag;		/* virtual slot idx for multiple modifying RPCs */
 	__u16 pb_padding0;
 	__u32 pb_padding1;
 	__u64 pb_last_committed;
@@ -618,10 +618,10 @@ struct ptlrpc_body_v2 {
 	__u32 pb_flags;
 	__u32 pb_op_flags;
 	__u32 pb_conn_cnt;
-	__u32 pb_timeout;  /* for req, the deadline, for rep, the service est */
-	__u32 pb_service_time; /* for rep, actual service time, also used for
-				* net_latency of req
-				*/
+	__u32 pb_timeout;	/* for req, the deadline, for rep, the service est */
+	__u32 pb_service_time;	/* for rep, actual service time, also used for
+				 * net_latency of req
+				 */
 	__u32 pb_limit;
 	__u64 pb_slv;
 	/* VBR: pre-versions */
@@ -881,66 +881,66 @@ enum cksum_type {
 
 /* opcodes */
 enum ost_cmd {
-	OST_REPLY      =  0,       /* reply ? */
-	OST_GETATTR    =  1,
-	OST_SETATTR    =  2,
-	OST_READ       =  3,
-	OST_WRITE      =  4,
-	OST_CREATE     =  5,
-	OST_DESTROY    =  6,
-	OST_GET_INFO   =  7,
-	OST_CONNECT    =  8,
-	OST_DISCONNECT =  9,
-	OST_PUNCH      = 10,
-	OST_OPEN       = 11,
-	OST_CLOSE      = 12,
-	OST_STATFS     = 13,
-	OST_SYNC       = 16,
-	OST_SET_INFO   = 17,
-	OST_QUOTACHECK = 18, /* not used since 2.4 */
-	OST_QUOTACTL   = 19,
+	OST_REPLY	=  0,	/* reply ? */
+	OST_GETATTR	=  1,
+	OST_SETATTR	=  2,
+	OST_READ	=  3,
+	OST_WRITE	=  4,
+	OST_CREATE	=  5,
+	OST_DESTROY	=  6,
+	OST_GET_INFO	=  7,
+	OST_CONNECT	=  8,
+	OST_DISCONNECT	=  9,
+	OST_PUNCH	= 10,
+	OST_OPEN	= 11,
+	OST_CLOSE	= 12,
+	OST_STATFS	= 13,
+	OST_SYNC	= 16,
+	OST_SET_INFO	= 17,
+	OST_QUOTACHECK	= 18,	/* not used since 2.4 */
+	OST_QUOTACTL	= 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
-	OST_LADVISE    = 21,
+	OST_LADVISE	= 21,
 	OST_LAST_OPC /* must be < 33 to avoid MDS_GETATTR */
 };
 #define OST_FIRST_OPC  OST_REPLY
 
 enum obdo_flags {
-	OBD_FL_INLINEDATA   = 0x00000001,
-	OBD_FL_OBDMDEXISTS  = 0x00000002,
-	OBD_FL_DELORPHAN    = 0x00000004, /* if set in o_flags delete orphans */
-	OBD_FL_NORPC        = 0x00000008, /* set in o_flags do in OSC not OST */
-	OBD_FL_IDONLY       = 0x00000010, /* set in o_flags only adjust obj id*/
-	OBD_FL_RECREATE_OBJS = 0x00000020, /* recreate missing obj */
-	OBD_FL_DEBUG_CHECK  = 0x00000040, /* echo client/server debug check */
-	OBD_FL_NO_PRJQUOTA  = 0x00000080, /* the object's project is over
-					   * quota
-					   */
-	OBD_FL_NO_USRQUOTA  = 0x00000100, /* the object's owner is over quota */
-	OBD_FL_NO_GRPQUOTA  = 0x00000200, /* the object's group is over quota */
-	OBD_FL_CREATE_CROW  = 0x00000400, /* object should be create on write */
-	OBD_FL_SRVLOCK      = 0x00000800, /* delegate DLM locking to server */
-	OBD_FL_CKSUM_CRC32  = 0x00001000, /* CRC32 checksum type */
-	OBD_FL_CKSUM_ADLER  = 0x00002000, /* ADLER checksum type */
-	OBD_FL_CKSUM_CRC32C = 0x00004000, /* CRC32C checksum type */
-	OBD_FL_CKSUM_RSVD2  = 0x00008000, /* for future cksum types */
-	OBD_FL_CKSUM_RSVD3  = 0x00010000, /* for future cksum types */
-	OBD_FL_SHRINK_GRANT = 0x00020000, /* object shrink the grant */
-	OBD_FL_MMAP         = 0x00040000, /* object is mmapped on the client.
-					   * XXX: obsoleted - reserved for old
-					   * clients prior than 2.2
-					   */
-	OBD_FL_RECOV_RESEND = 0x00080000, /* recoverable resent */
-	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
-	OBD_FL_FLUSH        = 0x00200000, /* flush pages on the OST */
-	OBD_FL_SHORT_IO     = 0x00400000, /* short io request */
+	OBD_FL_INLINEDATA	= 0x00000001,
+	OBD_FL_OBDMDEXISTS	= 0x00000002,
+	OBD_FL_DELORPHAN	= 0x00000004, /* if set in o_flags delete orphans */
+	OBD_FL_NORPC		= 0x00000008, /* set in o_flags do in OSC not OST */
+	OBD_FL_IDONLY		= 0x00000010, /* set in o_flags only adjust obj id*/
+	OBD_FL_RECREATE_OBJS	= 0x00000020, /* recreate missing obj */
+	OBD_FL_DEBUG_CHECK	= 0x00000040, /* echo client/server debug check */
+	OBD_FL_NO_PRJQUOTA	= 0x00000080, /* the object's project is over
+					       * quota
+					       */
+	OBD_FL_NO_USRQUOTA	= 0x00000100, /* the object's owner is over quota */
+	OBD_FL_NO_GRPQUOTA	= 0x00000200, /* the object's group is over quota */
+	OBD_FL_CREATE_CROW	= 0x00000400, /* object should be create on write */
+	OBD_FL_SRVLOCK		= 0x00000800, /* delegate DLM locking to server */
+	OBD_FL_CKSUM_CRC32	= 0x00001000, /* CRC32 checksum type */
+	OBD_FL_CKSUM_ADLER	= 0x00002000, /* ADLER checksum type */
+	OBD_FL_CKSUM_CRC32C	= 0x00004000, /* CRC32C checksum type */
+	OBD_FL_CKSUM_RSVD2	= 0x00008000, /* for future cksum types */
+	OBD_FL_CKSUM_RSVD3	= 0x00010000, /* for future cksum types */
+	OBD_FL_SHRINK_GRANT	= 0x00020000, /* object shrink the grant */
+	OBD_FL_MMAP		= 0x00040000, /* object is mmapped on the client.
+					       * XXX: obsoleted - reserved for old
+					       * clients prior than 2.2
+					       */
+	OBD_FL_RECOV_RESEND	= 0x00080000, /* recoverable resent */
+	OBD_FL_NOSPC_BLK	= 0x00100000, /* no more block space on OST */
+	OBD_FL_FLUSH		= 0x00200000, /* flush pages on the OST */
+	OBD_FL_SHORT_IO		= 0x00400000, /* short io request */
 	/* OBD_FL_LOCAL_MASK = 0xF0000000, was local-only flags until 2.10 */
 
 	/* Note that while these checksum values are currently separate bits,
 	 * in 2.x we can actually allow all values from 1-31 if we wanted.
 	 */
-	OBD_FL_CKSUM_ALL    = OBD_FL_CKSUM_CRC32 | OBD_FL_CKSUM_ADLER |
-			      OBD_FL_CKSUM_CRC32C,
+	OBD_FL_CKSUM_ALL	= (OBD_FL_CKSUM_CRC32 | OBD_FL_CKSUM_ADLER |
+				   OBD_FL_CKSUM_CRC32C),
 };
 
 /*
@@ -1233,9 +1233,9 @@ struct niobuf_remote {
  */
 #define OST_LVB_ERR_INIT 0xffbadbad80000000ULL
 #define OST_LVB_ERR_MASK 0xffbadbad00000000ULL
-#define OST_LVB_IS_ERR(blocks)					  \
+#define OST_LVB_IS_ERR(blocks)					\
 	((blocks & OST_LVB_ERR_MASK) == OST_LVB_ERR_MASK)
-#define OST_LVB_SET_ERR(blocks, rc)				     \
+#define OST_LVB_SET_ERR(blocks, rc)				\
 	do { blocks = OST_LVB_ERR_INIT + rc; } while (0)
 #define OST_LVB_GET_ERR(blocks)    (int)(blocks - OST_LVB_ERR_INIT)
 
@@ -1316,9 +1316,9 @@ struct ldlm_gl_lquota_desc {
 /* LVB used with quota (global and per-ID) locks */
 struct lquota_lvb {
 	__u64	lvb_flags;	/* see LQUOTA_FL* above */
-	__u64	lvb_id_may_rel; /* space that might be released later */
-	__u64	lvb_id_rel;     /* space released by the slave for this ID */
-	__u64	lvb_id_qunit;   /* current qunit value */
+	__u64	lvb_id_may_rel;	/* space that might be released later */
+	__u64	lvb_id_rel;	/* space released by the slave for this ID */
+	__u64	lvb_id_qunit;	/* current qunit value */
 	__u64	lvb_pad1;
 };
 
@@ -1488,17 +1488,17 @@ static inline int ll_inode_to_ext_flags(int iflags)
 
 static inline int ll_xflags_to_inode_flags(int xflags)
 {
-	return ((xflags & FS_XFLAG_SYNC) ? S_SYNC : 0) |
-	       ((xflags & FS_XFLAG_NOATIME) ? S_NOATIME : 0) |
-	       ((xflags & FS_XFLAG_APPEND) ? S_APPEND : 0) |
+	return ((xflags & FS_XFLAG_SYNC)      ? S_SYNC      : 0) |
+	       ((xflags & FS_XFLAG_NOATIME)   ? S_NOATIME   : 0) |
+	       ((xflags & FS_XFLAG_APPEND)    ? S_APPEND    : 0) |
 	       ((xflags & FS_XFLAG_IMMUTABLE) ? S_IMMUTABLE : 0);
 }
 
 static inline int ll_inode_flags_to_xflags(int flags)
 {
-	return ((flags & S_SYNC) ? FS_XFLAG_SYNC : 0) |
-	       ((flags & S_NOATIME) ? FS_XFLAG_NOATIME : 0) |
-	       ((flags & S_APPEND) ? FS_XFLAG_APPEND : 0) |
+	return ((flags & S_SYNC)      ? FS_XFLAG_SYNC      : 0) |
+	       ((flags & S_NOATIME)   ? FS_XFLAG_NOATIME   : 0) |
+	       ((flags & S_APPEND)    ? FS_XFLAG_APPEND    : 0) |
 	       ((flags & S_IMMUTABLE) ? FS_XFLAG_IMMUTABLE : 0);
 }
 
@@ -1583,7 +1583,7 @@ struct mdt_rec_setattr {
 	__s64		sa_ctime;
 	__u32		sa_attr_flags;
 	__u32		sa_mode;
-	__u32		sa_bias;      /* some operation flags */
+	__u32		sa_bias;	/* some operation flags */
 	__u32		sa_projid;
 	__u32		sa_padding_4;
 	__u32		sa_padding_5;
@@ -1698,17 +1698,17 @@ struct mdt_rec_create {
 	__s64		cr_time;
 	__u64		cr_rdev;
 	__u64		cr_ioepoch;
-	__u64		cr_padding_1;   /* rr_blocks */
+	__u64		cr_padding_1;	/* rr_blocks */
 	__u32		cr_mode;
 	__u32		cr_bias;
 	/* use of helpers set/get_mrc_cr_flags() is needed to access
 	 * 64 bits cr_flags [cr_flags_l, cr_flags_h], this is done to
 	 * extend cr_flags size without breaking 1.8 compat
 	 */
-	__u32		cr_flags_l;     /* for use with open, low  32 bits  */
-	__u32		cr_flags_h;     /* for use with open, high 32 bits */
-	__u32		cr_umask;       /* umask for create */
-	__u32		cr_padding_4;   /* rr_padding_4 */
+	__u32		cr_flags_l;	/* for use with open, low  32 bits  */
+	__u32		cr_flags_h;	/* for use with open, high 32 bits */
+	__u32		cr_umask;	/* umask for create */
+	__u32		cr_padding_4;	/* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
@@ -1726,16 +1726,16 @@ struct mdt_rec_link {
 	struct lu_fid   lk_fid1;
 	struct lu_fid   lk_fid2;
 	__s64		lk_time;
-	__u64		lk_padding_1;   /* rr_atime */
-	__u64		lk_padding_2;   /* rr_ctime */
-	__u64		lk_padding_3;   /* rr_size */
-	__u64		lk_padding_4;   /* rr_blocks */
+	__u64		lk_padding_1;	/* rr_atime */
+	__u64		lk_padding_2;	/* rr_ctime */
+	__u64		lk_padding_3;	/* rr_size */
+	__u64		lk_padding_4;	/* rr_blocks */
 	__u32		lk_bias;
-	__u32		lk_padding_5;   /* rr_mode */
-	__u32		lk_padding_6;   /* rr_flags */
-	__u32		lk_padding_7;   /* rr_padding_2 */
-	__u32		lk_padding_8;   /* rr_padding_3 */
-	__u32		lk_padding_9;   /* rr_padding_4 */
+	__u32		lk_padding_5;	/* rr_mode */
+	__u32		lk_padding_6;	/* rr_flags */
+	__u32		lk_padding_7;	/* rr_padding_2 */
+	__u32		lk_padding_8;	/* rr_padding_3 */
+	__u32		lk_padding_9;	/* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
@@ -1753,16 +1753,16 @@ struct mdt_rec_unlink {
 	struct lu_fid   ul_fid1;
 	struct lu_fid   ul_fid2;
 	__s64		ul_time;
-	__u64		ul_padding_2;   /* rr_atime */
-	__u64		ul_padding_3;   /* rr_ctime */
-	__u64		ul_padding_4;   /* rr_size */
-	__u64		ul_padding_5;   /* rr_blocks */
+	__u64		ul_padding_2;	/* rr_atime */
+	__u64		ul_padding_3;	/* rr_ctime */
+	__u64		ul_padding_4;	/* rr_size */
+	__u64		ul_padding_5;	/* rr_blocks */
 	__u32		ul_bias;
 	__u32		ul_mode;
-	__u32		ul_padding_6;   /* rr_flags */
-	__u32		ul_padding_7;   /* rr_padding_2 */
-	__u32		ul_padding_8;   /* rr_padding_3 */
-	__u32		ul_padding_9;   /* rr_padding_4 */
+	__u32		ul_padding_6;	/* rr_flags */
+	__u32		ul_padding_7;	/* rr_padding_2 */
+	__u32		ul_padding_8;	/* rr_padding_3 */
+	__u32		ul_padding_9;	/* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
@@ -1777,19 +1777,19 @@ struct mdt_rec_rename {
 	__u32		rn_suppgid1_h;
 	__u32		rn_suppgid2;
 	__u32		rn_suppgid2_h;
-	struct lu_fid   rn_fid1;
-	struct lu_fid   rn_fid2;
+	struct lu_fid	rn_fid1;
+	struct lu_fid	rn_fid2;
 	__s64		rn_time;
-	__u64		rn_padding_1;   /* rr_atime */
-	__u64		rn_padding_2;   /* rr_ctime */
-	__u64		rn_padding_3;   /* rr_size */
-	__u64		rn_padding_4;   /* rr_blocks */
+	__u64		rn_padding_1;	/* rr_atime */
+	__u64		rn_padding_2;	/* rr_ctime */
+	__u64		rn_padding_3;	/* rr_size */
+	__u64		rn_padding_4;	/* rr_blocks */
 	__u32		rn_bias;	/* some operation flags */
 	__u32		rn_mode;	/* cross-ref rename has mode */
-	__u32		rn_padding_5;   /* rr_flags */
-	__u32		rn_padding_6;   /* rr_padding_2 */
-	__u32		rn_padding_7;   /* rr_padding_3 */
-	__u32		rn_padding_8;   /* rr_padding_4 */
+	__u32		rn_padding_5;	/* rr_flags */
+	__u32		rn_padding_6;	/* rr_padding_2 */
+	__u32		rn_padding_7;	/* rr_padding_3 */
+	__u32		rn_padding_8;	/* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
@@ -1804,21 +1804,21 @@ struct mdt_rec_setxattr {
 	__u32		sx_suppgid1_h;
 	__u32		sx_suppgid2;
 	__u32		sx_suppgid2_h;
-	struct lu_fid   sx_fid;
-	__u64		sx_padding_1;   /* These three are rr_fid2 */
+	struct lu_fid	sx_fid;
+	__u64		sx_padding_1;	/* These three are rr_fid2 */
 	__u32		sx_padding_2;
 	__u32		sx_padding_3;
 	__u64		sx_valid;
 	__s64		sx_time;
-	__u64		sx_padding_5;   /* rr_ctime */
-	__u64		sx_padding_6;   /* rr_size */
-	__u64		sx_padding_7;   /* rr_blocks */
+	__u64		sx_padding_5;	/* rr_ctime */
+	__u64		sx_padding_6;	/* rr_size */
+	__u64		sx_padding_7;	/* rr_blocks */
 	__u32		sx_size;
 	__u32		sx_flags;
-	__u32		sx_padding_8;   /* rr_flags */
-	__u32		sx_padding_9;   /* rr_padding_2 */
-	__u32		sx_padding_10;  /* rr_padding_3 */
-	__u32		sx_padding_11;  /* rr_padding_4 */
+	__u32		sx_padding_8;	/* rr_flags */
+	__u32		sx_padding_9;	/* rr_padding_2 */
+	__u32		sx_padding_10;	/* rr_padding_3 */
+	__u32		sx_padding_11;	/* rr_padding_4 */
 };
 
 /*
@@ -1858,13 +1858,13 @@ struct mdt_rec_reint {
 /* lmv structures */
 struct lmv_desc {
 	__u32 ld_tgt_count;		/* how many MDS's */
-	__u32 ld_active_tgt_count;	 /* how many active */
-	__u32 ld_default_stripe_count;     /* how many objects are used */
-	__u32 ld_pattern;		  /* default hash pattern */
+	__u32 ld_active_tgt_count;	/* how many active */
+	__u32 ld_default_stripe_count;	/* how many objects are used */
+	__u32 ld_pattern;		/* default hash pattern */
 	__u64 ld_default_hash_size;
 	__u64 ld_padding_1;		/* also fix lustre_swab_lmv_desc */
 	__u32 ld_padding_2;		/* also fix lustre_swab_lmv_desc */
-	__u32 ld_qos_maxage;		    /* in second */
+	__u32 ld_qos_maxage;		/* in second */
 	__u32 ld_padding_3;		/* also fix lustre_swab_lmv_desc */
 	__u32 ld_padding_4;		/* also fix lustre_swab_lmv_desc */
 	struct obd_uuid ld_uuid;
@@ -2038,20 +2038,20 @@ struct lov_desc {
 	struct obd_uuid ld_uuid;
 };
 
-#define ld_magic ld_active_tgt_count       /* for swabbing from llogs */
+#define ld_magic ld_active_tgt_count	/* for swabbing from llogs */
 
 /*
  *   LDLM requests:
  */
 /* opcodes -- MUST be distinct from OST/MDS opcodes */
 enum ldlm_cmd {
-	LDLM_ENQUEUE     = 101,
-	LDLM_CONVERT     = 102,
-	LDLM_CANCEL      = 103,
+	LDLM_ENQUEUE	 = 101,
+	LDLM_CONVERT	 = 102,
+	LDLM_CANCEL	 = 103,
 	LDLM_BL_CALLBACK = 104,
 	LDLM_CP_CALLBACK = 105,
 	LDLM_GL_CALLBACK = 106,
-	LDLM_SET_INFO    = 107,
+	LDLM_SET_INFO	 = 107,
 	LDLM_LAST_OPC
 };
 #define LDLM_FIRST_OPC LDLM_ENQUEUE
@@ -2067,25 +2067,25 @@ struct ldlm_res_id {
 
 /* lock types */
 enum ldlm_mode {
-	LCK_MINMODE = 0,
-	LCK_EX      = 1,
-	LCK_PW      = 2,
-	LCK_PR      = 4,
-	LCK_CW      = 8,
-	LCK_CR      = 16,
-	LCK_NL      = 32,
-	LCK_GROUP   = 64,
-	LCK_COS     = 128,
+	LCK_MINMODE	= 0,
+	LCK_EX		= 1,
+	LCK_PW		= 2,
+	LCK_PR		= 4,
+	LCK_CW		= 8,
+	LCK_CR		= 16,
+	LCK_NL		= 32,
+	LCK_GROUP	= 64,
+	LCK_COS		= 128,
 	LCK_MAXMODE
 };
 
-#define LCK_MODE_NUM    8
+#define LCK_MODE_NUM	8
 
 enum ldlm_type {
-	LDLM_PLAIN     = 10,
-	LDLM_EXTENT    = 11,
-	LDLM_FLOCK     = 12,
-	LDLM_IBITS     = 13,
+	LDLM_PLAIN	= 10,
+	LDLM_EXTENT	= 11,
+	LDLM_FLOCK	= 12,
+	LDLM_IBITS	= 13,
 	LDLM_MAX_TYPE
 };
 
@@ -2150,7 +2150,7 @@ struct ldlm_intent {
 
 struct ldlm_resource_desc {
 	enum ldlm_type lr_type;
-	__u32 lr_padding;       /* also fix lustre_swab_ldlm_resource_desc */
+	__u32 lr_padding;	/* also fix lustre_swab_ldlm_resource_desc */
 	struct ldlm_res_id lr_name;
 };
 
@@ -2173,7 +2173,7 @@ struct ldlm_request {
 
 struct ldlm_reply {
 	__u32 lock_flags;
-	__u32 lock_padding;     /* also fix lustre_swab_ldlm_reply */
+	__u32 lock_padding;	/* also fix lustre_swab_ldlm_reply */
 	struct ldlm_lock_desc lock_desc;
 	struct lustre_handle lock_handle;
 	__u64  lock_policy_res1;
@@ -2206,9 +2206,9 @@ struct mgs_send_param {
 };
 
 /* We pass this info to the MGS so it can write config logs */
-#define MTI_NAME_MAXLEN  64
+#define MTI_NAME_MAXLEN	 64
 #define MTI_PARAM_MAXLEN 4096
-#define MTI_NIDS_MAX     32
+#define MTI_NIDS_MAX	 32
 struct mgs_target_info {
 	__u32		mti_lustre_ver;
 	__u32		mti_stripe_index;
@@ -2695,8 +2695,8 @@ enum sec_cmd {
 /*
  * capa related definitions
  */
-#define CAPA_HMAC_MAX_LEN       64
-#define CAPA_HMAC_KEY_MAX_LEN   56
+#define CAPA_HMAC_MAX_LEN	64
+#define CAPA_HMAC_KEY_MAX_LEN	56
 
 /* NB take care when changing the sequence of elements this struct,
  * because the offset info is used in find_capa()
@@ -2716,34 +2716,34 @@ struct lustre_capa {
 
 /** lustre_capa::lc_opc */
 enum {
-	CAPA_OPC_BODY_WRITE   = 1 << 0,  /**< write object data */
-	CAPA_OPC_BODY_READ    = 1 << 1,  /**< read object data */
-	CAPA_OPC_INDEX_LOOKUP = 1 << 2,  /**< lookup object fid */
-	CAPA_OPC_INDEX_INSERT = 1 << 3,  /**< insert object fid */
-	CAPA_OPC_INDEX_DELETE = 1 << 4,  /**< delete object fid */
-	CAPA_OPC_OSS_WRITE    = 1 << 5,  /**< write oss object data */
-	CAPA_OPC_OSS_READ     = 1 << 6,  /**< read oss object data */
-	CAPA_OPC_OSS_TRUNC    = 1 << 7,  /**< truncate oss object */
-	CAPA_OPC_OSS_DESTROY  = 1 << 8,  /**< destroy oss object */
-	CAPA_OPC_META_WRITE   = 1 << 9,  /**< write object meta data */
-	CAPA_OPC_META_READ    = 1 << 10, /**< read object meta data */
+	CAPA_OPC_BODY_WRITE	= 1 << 0,  /**< write object data */
+	CAPA_OPC_BODY_READ	= 1 << 1,  /**< read object data */
+	CAPA_OPC_INDEX_LOOKUP	= 1 << 2,  /**< lookup object fid */
+	CAPA_OPC_INDEX_INSERT	= 1 << 3,  /**< insert object fid */
+	CAPA_OPC_INDEX_DELETE	= 1 << 4,  /**< delete object fid */
+	CAPA_OPC_OSS_WRITE	= 1 << 5,  /**< write oss object data */
+	CAPA_OPC_OSS_READ	= 1 << 6,  /**< read oss object data */
+	CAPA_OPC_OSS_TRUNC	= 1 << 7,  /**< truncate oss object */
+	CAPA_OPC_OSS_DESTROY	= 1 << 8,  /**< destroy oss object */
+	CAPA_OPC_META_WRITE	= 1 << 9,  /**< write object meta data */
+	CAPA_OPC_META_READ	= 1 << 10, /**< read object meta data */
 };
 
 #define CAPA_OPC_OSS_RW (CAPA_OPC_OSS_READ | CAPA_OPC_OSS_WRITE)
-#define CAPA_OPC_MDS_ONLY						   \
+#define CAPA_OPC_MDS_ONLY						\
 	(CAPA_OPC_BODY_WRITE | CAPA_OPC_BODY_READ | CAPA_OPC_INDEX_LOOKUP | \
 	 CAPA_OPC_INDEX_INSERT | CAPA_OPC_INDEX_DELETE)
-#define CAPA_OPC_OSS_ONLY						   \
-	(CAPA_OPC_OSS_WRITE | CAPA_OPC_OSS_READ | CAPA_OPC_OSS_TRUNC |      \
+#define CAPA_OPC_OSS_ONLY						\
+	(CAPA_OPC_OSS_WRITE | CAPA_OPC_OSS_READ | CAPA_OPC_OSS_TRUNC |	\
 	 CAPA_OPC_OSS_DESTROY)
 #define CAPA_OPC_MDS_DEFAULT ~CAPA_OPC_OSS_ONLY
 #define CAPA_OPC_OSS_DEFAULT ~(CAPA_OPC_MDS_ONLY | CAPA_OPC_OSS_ONLY)
 
 struct lustre_capa_key {
-	__u64   lk_seq;       /**< mds# */
-	__u32   lk_keyid;     /**< key# */
-	__u32   lk_padding;
-	__u8    lk_key[CAPA_HMAC_KEY_MAX_LEN];    /**< key */
+	__u64	lk_seq;				/**< mds# */
+	__u32	lk_keyid;			/**< key# */
+	__u32	lk_padding;
+	__u8	lk_key[CAPA_HMAC_KEY_MAX_LEN];	/**< key */
 } __packed;
 
 /** The link ea holds 1 \a link_ea_entry for each hardlink */
@@ -2751,7 +2751,7 @@ struct lustre_capa_key {
 struct link_ea_header {
 	__u32 leh_magic;
 	__u32 leh_reccount;
-	__u64 leh_len;      /* total size */
+	__u64 leh_len;		/* total size */
 	__u32 leh_overflow_time;
 	__u32 leh_padding;
 };
@@ -2787,13 +2787,13 @@ struct getparent {
 } __packed;
 
 enum {
-	LAYOUT_INTENT_ACCESS    = 0,	/** generic access */
-	LAYOUT_INTENT_READ      = 1,	/** not used */
-	LAYOUT_INTENT_WRITE     = 2,	/** write file, for comp layout */
-	LAYOUT_INTENT_GLIMPSE   = 3,	/** not used */
-	LAYOUT_INTENT_TRUNC     = 4,	/** truncate file, for comp layout */
-	LAYOUT_INTENT_RELEASE   = 5,	/** reserved for HSM release */
-	LAYOUT_INTENT_RESTORE   = 6	/** reserved for HSM restore */
+	LAYOUT_INTENT_ACCESS	= 0,	/** generic access */
+	LAYOUT_INTENT_READ	= 1,	/** not used */
+	LAYOUT_INTENT_WRITE	= 2,	/** write file, for comp layout */
+	LAYOUT_INTENT_GLIMPSE	= 3,	/** not used */
+	LAYOUT_INTENT_TRUNC	= 4,	/** truncate file, for comp layout */
+	LAYOUT_INTENT_RELEASE	= 5,	/** reserved for HSM release */
+	LAYOUT_INTENT_RESTORE	= 6	/** reserved for HSM restore */
 };
 
 /* enqueue layout lock with intent */
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 178837cedd07..3b80b50543d8 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -68,13 +68,13 @@
  * are co-existing.
  */
 #if __BITS_PER_LONG != 64 || defined(__ARCH_WANT_STAT64)
-typedef struct stat64   lstat_t;
-#define lstat_f  lstat64
+typedef struct stat64	lstat_t;
+#define lstat_f		lstat64
 #define fstat_f		fstat64
 #define fstatat_f	fstatat64
 #else
-typedef struct stat     lstat_t;
-#define lstat_f  lstat
+typedef struct stat	lstat_t;
+#define lstat_f		lstat
 #define fstat_f		fstat
 #define fstatat_f	fstatat
 #endif
@@ -87,47 +87,47 @@ typedef struct stat     lstat_t;
 #define LL_SUPER_MAGIC 0x0BD00BD0
 
 #ifndef FSFILT_IOC_GETFLAGS
-#define FSFILT_IOC_GETFLAGS	       _IOR('f', 1, long)
-#define FSFILT_IOC_SETFLAGS	       _IOW('f', 2, long)
-#define FSFILT_IOC_GETVERSION	     _IOR('f', 3, long)
-#define FSFILT_IOC_SETVERSION	     _IOW('f', 4, long)
-#define FSFILT_IOC_GETVERSION_OLD	 _IOR('v', 1, long)
-#define FSFILT_IOC_SETVERSION_OLD	 _IOW('v', 2, long)
+#define FSFILT_IOC_GETFLAGS		_IOR('f', 1, long)
+#define FSFILT_IOC_SETFLAGS		_IOW('f', 2, long)
+#define FSFILT_IOC_GETVERSION		_IOR('f', 3, long)
+#define FSFILT_IOC_SETVERSION		_IOW('f', 4, long)
+#define FSFILT_IOC_GETVERSION_OLD	_IOR('v', 1, long)
+#define FSFILT_IOC_SETVERSION_OLD	_IOW('v', 2, long)
 #endif
 
 /* FIEMAP flags supported by Lustre */
 #define LUSTRE_FIEMAP_FLAGS_COMPAT (FIEMAP_FLAG_SYNC | FIEMAP_FLAG_DEVICE_ORDER)
 
 enum obd_statfs_state {
-	OS_STATE_DEGRADED       = 0x00000001, /**< RAID degraded/rebuilding */
-	OS_STATE_READONLY       = 0x00000002, /**< filesystem is read-only */
-	OS_STATE_RDONLY_1       = 0x00000004, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_RDONLY_2       = 0x00000008, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_RDONLY_3       = 0x00000010, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATE_DEGRADED	= 0x00000001, /**< RAID degraded/rebuilding */
+	OS_STATE_READONLY	= 0x00000002, /**< filesystem is read-only */
+	OS_STATE_RDONLY_1	= 0x00000004, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATE_RDONLY_2	= 0x00000008, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATE_RDONLY_3	= 0x00000010, /**< obsolete 1.6, was EROFS=30 */
 };
 
 struct obd_statfs {
-	__u64	   os_type;
-	__u64	   os_blocks;
-	__u64	   os_bfree;
-	__u64	   os_bavail;
-	__u64	   os_files;
-	__u64	   os_ffree;
-	__u8	    os_fsid[40];
-	__u32	   os_bsize;
-	__u32	   os_namelen;
-	__u64	   os_maxbytes;
-	__u32	   os_state;       /**< obd_statfs_state OS_STATE_* flag */
-	__u32	   os_fprecreated; /* objs available now to the caller */
-				   /* used in QoS code to find preferred OSTs */
-	__u32	   os_spare2;
-	__u32	   os_spare3;
-	__u32	   os_spare4;
-	__u32	   os_spare5;
-	__u32	   os_spare6;
-	__u32	   os_spare7;
-	__u32	   os_spare8;
-	__u32	   os_spare9;
+	__u64	os_type;
+	__u64	os_blocks;
+	__u64	os_bfree;
+	__u64	os_bavail;
+	__u64	os_files;
+	__u64	os_ffree;
+	__u8	os_fsid[40];
+	__u32	os_bsize;
+	__u32	os_namelen;
+	__u64	os_maxbytes;
+	__u32	os_state;	/**< obd_statfs_state OS_STATE_* flag */
+	__u32	os_fprecreated;	/* objs available now to the caller
+				 * used in QoS code to find preferred OSTs */
+	__u32	os_spare2;
+	__u32	os_spare3;
+	__u32	os_spare4;
+	__u32	os_spare5;
+	__u32	os_spare6;
+	__u32	os_spare7;
+	__u32	os_spare8;
+	__u32	os_spare9;
 };
 
 /**
@@ -137,12 +137,12 @@ struct obd_statfs {
  * FIDs are never reused.
  **/
 struct lu_fid {
-       /**
-	* FID sequence. Sequence is a unit of migration: all files (objects)
-	* with FIDs from a given sequence are stored on the same server.
-	* Lustre should support 2^64 objects, so even if each sequence
-	* has only a single object we can still enumerate 2^64 objects.
-	**/
+	/**
+	 * FID sequence. Sequence is a unit of migration: all files (objects)
+	 * with FIDs from a given sequence are stored on the same server.
+	 * Lustre should support 2^64 objects, so even if each sequence
+	 * has only a single object we can still enumerate 2^64 objects.
+	 **/
 	__u64 f_seq;
 	/* FID number within sequence. */
 	__u32 f_oid;
@@ -237,33 +237,33 @@ struct ll_futimes_3 {
  * *INFO    - set/get lov_user_mds_data
  */
 /*	lustre_ioctl.h			101-150 */
-#define LL_IOC_GETFLAGS		 _IOR('f', 151, long)
-#define LL_IOC_SETFLAGS		 _IOW('f', 152, long)
-#define LL_IOC_CLRFLAGS		 _IOW('f', 153, long)
-#define LL_IOC_LOV_SETSTRIPE	    _IOW('f', 154, long)
+#define LL_IOC_GETFLAGS			_IOR('f', 151, long)
+#define LL_IOC_SETFLAGS			_IOW('f', 152, long)
+#define LL_IOC_CLRFLAGS			_IOW('f', 153, long)
+#define LL_IOC_LOV_SETSTRIPE		_IOW('f', 154, long)
 #define LL_IOC_LOV_SETSTRIPE_NEW	_IOWR('f', 154, struct lov_user_md)
-#define LL_IOC_LOV_GETSTRIPE	    _IOW('f', 155, long)
+#define LL_IOC_LOV_GETSTRIPE		_IOW('f', 155, long)
 #define LL_IOC_LOV_GETSTRIPE_NEW	_IOR('f', 155, struct lov_user_md)
 #define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
 /*	LL_IOC_RECREATE_OBJ		157 obsolete */
 /*	LL_IOC_RECREATE_FID		158 obsolete */
-#define LL_IOC_GROUP_LOCK	       _IOW('f', 158, long)
-#define LL_IOC_GROUP_UNLOCK	     _IOW('f', 159, long)
+#define LL_IOC_GROUP_LOCK		_IOW('f', 158, long)
+#define LL_IOC_GROUP_UNLOCK		_IOW('f', 159, long)
 /* #define LL_IOC_QUOTACHECK		160 OBD_IOC_QUOTACHECK */
 /* #define LL_IOC_POLL_QUOTACHECK	161 OBD_IOC_POLL_QUOTACHECK */
 /* #define LL_IOC_QUOTACTL		162 OBD_IOC_QUOTACTL */
-#define IOC_OBD_STATFS		  _IOWR('f', 164, struct obd_statfs *)
+#define IOC_OBD_STATFS			_IOWR('f', 164, struct obd_statfs *)
 /*	IOC_LOV_GETINFO			165 obsolete */
-#define LL_IOC_FLUSHCTX		 _IOW('f', 166, long)
+#define LL_IOC_FLUSHCTX			_IOW('f', 166, long)
 /* LL_IOC_RMTACL			167 obsolete */
-#define LL_IOC_GETOBDCOUNT	      _IOR('f', 168, long)
-#define LL_IOC_LLOOP_ATTACH	     _IOWR('f', 169, long)
-#define LL_IOC_LLOOP_DETACH	     _IOWR('f', 170, long)
-#define LL_IOC_LLOOP_INFO	       _IOWR('f', 171, struct lu_fid)
-#define LL_IOC_LLOOP_DETACH_BYDEV       _IOWR('f', 172, long)
-#define LL_IOC_PATH2FID		 _IOR('f', 173, long)
+#define LL_IOC_GETOBDCOUNT		_IOR('f', 168, long)
+#define LL_IOC_LLOOP_ATTACH		_IOWR('f', 169, long)
+#define LL_IOC_LLOOP_DETACH		_IOWR('f', 170, long)
+#define LL_IOC_LLOOP_INFO		_IOWR('f', 171, struct lu_fid)
+#define LL_IOC_LLOOP_DETACH_BYDEV	_IOWR('f', 172, long)
+#define LL_IOC_PATH2FID			_IOR('f', 173, long)
 #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
-#define LL_IOC_GET_MDTIDX	       _IOR('f', 175, int)
+#define LL_IOC_GET_MDTIDX		_IOR('f', 175, int)
 #define LL_IOC_FUTIMES_3		_IOWR('f', 176, struct ll_futimes_3)
 
 /*	lustre_ioctl.h			177-210 */
@@ -281,8 +281,8 @@ struct ll_futimes_3 {
 						struct hsm_current_action)
 /* see <lustre_lib.h> for ioctl numbers 221-232 */
 
-#define LL_IOC_LMV_SETSTRIPE	    _IOWR('f', 240, struct lmv_user_md)
-#define LL_IOC_LMV_GETSTRIPE	    _IOWR('f', 241, struct lmv_user_md)
+#define LL_IOC_LMV_SETSTRIPE		_IOWR('f', 240, struct lmv_user_md)
+#define LL_IOC_LMV_GETSTRIPE		_IOWR('f', 241, struct lmv_user_md)
 #define LL_IOC_SET_LEASE		_IOWR('f', 243, long)
 #define LL_IOC_GET_LEASE		_IO('f', 244)
 #define LL_IOC_HSM_IMPORT		_IOWR('f', 245, struct hsm_user_import)
@@ -299,15 +299,15 @@ enum ll_lease_type {
 	LL_LEASE_UNLCK	= 0x4,
 };
 
-#define LL_STATFS_LMV	   1
-#define LL_STATFS_LOV	   2
+#define LL_STATFS_LMV		1
+#define LL_STATFS_LOV		2
 #define LL_STATFS_NODELAY	4
 
-#define IOC_MDC_TYPE	    'i'
-#define IOC_MDC_LOOKUP	  _IOWR(IOC_MDC_TYPE, 20, struct obd_device *)
-#define IOC_MDC_GETFILESTRIPE   _IOWR(IOC_MDC_TYPE, 21, struct lov_user_md *)
-#define IOC_MDC_GETFILEINFO     _IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data *)
-#define LL_IOC_MDC_GETINFO      _IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data *)
+#define IOC_MDC_TYPE		'i'
+#define IOC_MDC_LOOKUP		_IOWR(IOC_MDC_TYPE, 20, struct obd_device *)
+#define IOC_MDC_GETFILESTRIPE	_IOWR(IOC_MDC_TYPE, 21, struct lov_user_md *)
+#define IOC_MDC_GETFILEINFO	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data *)
+#define LL_IOC_MDC_GETINFO	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data *)
 
 #define MAX_OBD_NAME 128 /* If this changes, a NEW ioctl must be added */
 
@@ -318,12 +318,12 @@ enum ll_lease_type {
  */
 #define O_LOV_DELAY_CREATE	(O_NOCTTY | FASYNC)
 
-#define LL_FILE_IGNORE_LOCK     0x00000001
-#define LL_FILE_GROUP_LOCKED    0x00000002
+#define LL_FILE_IGNORE_LOCK	0x00000001
+#define LL_FILE_GROUP_LOCKED	0x00000002
 #define LL_FILE_READAHEA	0x00000004
 #define LL_FILE_LOCKED_DIRECTIO 0x00000008 /* client-side locks with dio */
-#define LL_FILE_LOCKLESS_IO     0x00000010 /* server-side locks with cio */
-#define LL_FILE_RMTACL	  0x00000020
+#define LL_FILE_LOCKLESS_IO	0x00000010 /* server-side locks with cio */
+#define LL_FILE_RMTACL		0x00000020
 
 #define LOV_USER_MAGIC_V1	0x0BD10BD0
 #define LOV_USER_MAGIC		LOV_USER_MAGIC_V1
@@ -333,7 +333,7 @@ enum ll_lease_type {
 #define LOV_USER_MAGIC_SPECIFIC	0x0BD50BD0	/* for specific OSTs */
 #define LOV_USER_MAGIC_COMP_V1	0x0BD60BD0
 
-#define LMV_USER_MAGIC    0x0CD30CD0    /*default lmv magic*/
+#define LMV_USER_MAGIC		0x0CD30CD0	/*default lmv magic*/
 
 #define LOV_PATTERN_RAID0	0x001
 #define LOV_PATTERN_RAID1	0x002
@@ -347,8 +347,8 @@ enum ll_lease_type {
 #define LOV_MAXPOOLNAME 15
 #define LOV_POOLNAMEF "%.15s"
 
-#define LOV_MIN_STRIPE_BITS 16   /* maximum PAGE_SIZE (ia64), power of 2 */
-#define LOV_MIN_STRIPE_SIZE (1 << LOV_MIN_STRIPE_BITS)
+#define LOV_MIN_STRIPE_BITS	16	/* maximum PAGE_SIZE (ia64), power of 2 */
+#define LOV_MIN_STRIPE_SIZE	(1 << LOV_MIN_STRIPE_BITS)
 #define LOV_MAX_STRIPE_COUNT_OLD 160
 /* This calculation is crafted so that input of 4096 will result in 160
  * which in turn is equal to old maximal stripe count.
@@ -360,49 +360,49 @@ enum ll_lease_type {
  *
  * (max buffer size - lov+rpc header) / sizeof(struct lov_ost_data_v1)
  */
-#define LOV_MAX_STRIPE_COUNT 2000  /* ((12 * 4096 - 256) / 24) */
-#define LOV_ALL_STRIPES       0xffff /* only valid for directories */
+#define LOV_MAX_STRIPE_COUNT	2000  /* ((12 * 4096 - 256) / 24) */
+#define LOV_ALL_STRIPES		0xffff /* only valid for directories */
 #define LOV_V1_INSANE_STRIPE_COUNT 65532 /* maximum stripe count bz13933 */
 
 #define XATTR_LUSTRE_PREFIX	"lustre."
 #define XATTR_LUSTRE_LOV	"lustre.lov"
 
 #define lov_user_ost_data lov_user_ost_data_v1
-struct lov_user_ost_data_v1 {     /* per-stripe data structure */
-	struct ost_id l_ost_oi;	  /* OST object ID */
-	__u32 l_ost_gen;	  /* generation of this OST index */
-	__u32 l_ost_idx;	  /* OST index in LOV */
+struct lov_user_ost_data_v1 {	/* per-stripe data structure */
+	struct ost_id l_ost_oi;	/* OST object ID */
+	__u32 l_ost_gen;	/* generation of this OST index */
+	__u32 l_ost_idx;	/* OST index in LOV */
 } __packed;
 
 #define lov_user_md lov_user_md_v1
-struct lov_user_md_v1 {	   /* LOV EA user data (host-endian) */
-	__u32 lmm_magic;	  /* magic number = LOV_USER_MAGIC_V1 */
+struct lov_user_md_v1 {		/* LOV EA user data (host-endian) */
+	__u32 lmm_magic;	/* magic number = LOV_USER_MAGIC_V1 */
 	__u32 lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
-	struct ost_id lmm_oi;	  /* LOV object ID */
-	__u32 lmm_stripe_size;    /* size of stripe in bytes */
-	__u16 lmm_stripe_count;   /* num stripes in use for this object */
+	struct ost_id lmm_oi;	/* LOV object ID */
+	__u32 lmm_stripe_size;	/* size of stripe in bytes */
+	__u16 lmm_stripe_count;	/* num stripes in use for this object */
 	union {
 		__u16 lmm_stripe_offset;  /* starting stripe offset in
 					   * lmm_objects, use when writing
 					   */
-		__u16 lmm_layout_gen;     /* layout generation number
+		__u16 lmm_layout_gen;	  /* layout generation number
 					   * used when reading
 					   */
 	};
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __attribute__((packed,  __may_alias__));
 
-struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
-	__u32 lmm_magic;	  /* magic number = LOV_USER_MAGIC_V3 */
+struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
+	__u32 lmm_magic;	/* magic number = LOV_USER_MAGIC_V3 */
 	__u32 lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
-	struct ost_id lmm_oi;	  /* LOV object ID */
-	__u32 lmm_stripe_size;    /* size of stripe in bytes */
-	__u16 lmm_stripe_count;   /* num stripes in use for this object */
+	struct ost_id lmm_oi;	/* LOV object ID */
+	__u32 lmm_stripe_size;	/* size of stripe in bytes */
+	__u16 lmm_stripe_count;	/* num stripes in use for this object */
 	union {
 		__u16 lmm_stripe_offset;  /* starting stripe offset in
 					   * lmm_objects, use when writing
 					   */
-		__u16 lmm_layout_gen;     /* layout generation number
+		__u16 lmm_layout_gen;	  /* layout generation number
 					   * used when reading
 					   */
 	};
@@ -425,9 +425,9 @@ static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
 }
 
 enum lov_comp_md_entry_flags {
-	LCME_FL_PRIMARY		= 0x00000001,   /* Not used */
-	LCME_FL_STALE		= 0x00000002,   /* Not used */
-	LCME_FL_OFFLINE		= 0x00000004,   /* Not used */
+	LCME_FL_PRIMARY		= 0x00000001,	/* Not used */
+	LCME_FL_STALE		= 0x00000002,	/* Not used */
+	LCME_FL_OFFLINE		= 0x00000004,	/* Not used */
 	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
 	LCME_FL_INIT		= 0x00000010,	/* instantiated */
 	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
@@ -480,7 +480,7 @@ static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 		return sizeof(struct lov_user_md_v1) +
 				stripes * sizeof(struct lov_user_ost_data_v1);
 	return sizeof(struct lov_user_md_v3) +
-	       stripes * sizeof(struct lov_user_ost_data_v1);
+		stripes * sizeof(struct lov_user_ost_data_v1);
 }
 
 /* Compile with -D_LARGEFILE64_SOURCE or -D_GNU_SOURCE (or #define) to
@@ -524,16 +524,16 @@ enum lmv_hash_type {
 #define LMV_MAX_STRIPE_COUNT 2000  /* ((12 * 4096 - 256) / 24) */
 #define lmv_user_md lmv_user_md_v1
 struct lmv_user_md_v1 {
-	__u32	lum_magic;	 /* must be the first field */
-	__u32	lum_stripe_count;  /* dirstripe count */
-	__u32	lum_stripe_offset; /* MDT idx for default dirstripe */
-	__u32	lum_hash_type;     /* Dir stripe policy */
-	__u32	lum_type;	  /* LMV type: default or normal */
+	__u32	lum_magic;		/* must be the first field */
+	__u32	lum_stripe_count;	/* dirstripe count */
+	__u32	lum_stripe_offset;	/* MDT idx for default dirstripe */
+	__u32	lum_hash_type;		/* Dir stripe policy */
+	__u32	lum_type;		/* LMV type: default or normal */
 	__u32	lum_padding1;
 	__u32	lum_padding2;
 	__u32	lum_padding3;
 	char	lum_pool_name[LOV_MAXPOOLNAME + 1];
-	struct	lmv_user_mds_data  lum_objects[0];
+	struct lmv_user_mds_data  lum_objects[0];
 } __packed;
 
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
@@ -548,11 +548,11 @@ struct ll_recreate_obj {
 };
 
 struct ll_fid {
-	__u64 id;	 /* holds object id */
-	__u32 generation; /* holds object generation */
-	__u32 f_type;     /* holds object type or stripe idx when passing it to
-			   * OST for saving into EA.
-			   */
+	__u64 id;		/* holds object id */
+	__u32 generation;	/* holds object generation */
+	__u32 f_type;		/* holds object type or stripe idx when
+				 * passing it to OST for saving into EA.
+				 */
 };
 
 #define UUID_MAX	40
@@ -631,22 +631,22 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 
 /********* Quotas **********/
 
-#define Q_QUOTACHECK   0x800100 /* deprecated as of 2.4 */
-#define Q_INITQUOTA    0x800101 /* deprecated as of 2.4  */
-#define Q_GETOINFO     0x800102 /* get obd quota info */
-#define Q_GETOQUOTA    0x800103 /* get obd quotas */
-#define Q_FINVALIDATE  0x800104 /* deprecated as of 2.4 */
+#define Q_QUOTACHECK	0x800100 /* deprecated as of 2.4 */
+#define Q_INITQUOTA	0x800101 /* deprecated as of 2.4  */
+#define Q_GETOINFO	0x800102 /* get obd quota info */
+#define Q_GETOQUOTA	0x800103 /* get obd quotas */
+#define Q_FINVALIDATE	0x800104 /* deprecated as of 2.4 */
 
 /* these must be explicitly translated into linux Q_* in ll_dir_ioctl */
-#define LUSTRE_Q_QUOTAON    0x800002	/* deprecated as of 2.4 */
-#define LUSTRE_Q_QUOTAOFF   0x800003	/* deprecated as of 2.4 */
-#define LUSTRE_Q_GETINFO    0x800005     /* get information about quota files */
-#define LUSTRE_Q_SETINFO    0x800006     /* set information about quota files */
-#define LUSTRE_Q_GETQUOTA   0x800007     /* get user quota structure */
-#define LUSTRE_Q_SETQUOTA   0x800008     /* set user quota structure */
+#define LUSTRE_Q_QUOTAON	0x800002	/* deprecated as of 2.4 */
+#define LUSTRE_Q_QUOTAOFF	0x800003	/* deprecated as of 2.4 */
+#define LUSTRE_Q_GETINFO	0x800005	/* get information about quota files */
+#define LUSTRE_Q_SETINFO	0x800006	/* set information about quota files */
+#define LUSTRE_Q_GETQUOTA	0x800007	/* get user quota structure */
+#define LUSTRE_Q_SETQUOTA	0x800008	/* set user quota structure */
 /* lustre-specific control commands */
-#define LUSTRE_Q_INVALIDATE  0x80000b	/* deprecated as of 2.4 */
-#define LUSTRE_Q_FINVALIDATE 0x80000c	/* deprecated as of 2.4 */
+#define LUSTRE_Q_INVALIDATE	0x80000b	/* deprecated as of 2.4 */
+#define LUSTRE_Q_FINVALIDATE	0x80000c	/* deprecated as of 2.4 */
 
 #define ALLQUOTA 255	/* set all quota */
 
@@ -666,7 +666,7 @@ static inline char *qtype_name(int qtype)
 #define IDENTITY_DOWNCALL_MAGIC 0x6d6dd629
 
 /* permission */
-#define N_PERMS_MAX      64
+#define N_PERMS_MAX	64
 
 struct perm_downcall_data {
 	__u64 pdd_nid;
@@ -720,23 +720,23 @@ struct obd_dqblk {
 };
 
 enum {
-	QC_GENERAL      = 0,
-	QC_MDTIDX       = 1,
-	QC_OSTIDX       = 2,
-	QC_UUID	 = 3
+	QC_GENERAL	= 0,
+	QC_MDTIDX	= 1,
+	QC_OSTIDX	= 2,
+	QC_UUID		= 3
 };
 
 struct if_quotactl {
-	__u32		   qc_cmd;
-	__u32		   qc_type;
-	__u32		   qc_id;
-	__u32		   qc_stat;
-	__u32		   qc_valid;
-	__u32		   qc_idx;
-	struct obd_dqinfo       qc_dqinfo;
-	struct obd_dqblk	qc_dqblk;
-	char		    obd_type[16];
-	struct obd_uuid	 obd_uuid;
+	__u32		  qc_cmd;
+	__u32		  qc_type;
+	__u32		  qc_id;
+	__u32		  qc_stat;
+	__u32		  qc_valid;
+	__u32		  qc_idx;
+	struct obd_dqinfo qc_dqinfo;
+	struct obd_dqblk  qc_dqblk;
+	char		  obd_type[16];
+	struct obd_uuid	  obd_uuid;
 };
 
 /* swap layout flags */
@@ -759,26 +759,26 @@ struct lustre_swap_layouts {
 /********* Changelogs **********/
 /** Changelog record types */
 enum changelog_rec_type {
-	CL_MARK     = 0,
-	CL_CREATE   = 1,  /* namespace */
-	CL_MKDIR    = 2,  /* namespace */
-	CL_HARDLINK = 3,  /* namespace */
-	CL_SOFTLINK = 4,  /* namespace */
-	CL_MKNOD    = 5,  /* namespace */
-	CL_UNLINK   = 6,  /* namespace */
-	CL_RMDIR    = 7,  /* namespace */
-	CL_RENAME   = 8,  /* namespace */
-	CL_EXT      = 9,  /* namespace extended record (2nd half of rename) */
-	CL_OPEN     = 10, /* not currently used */
-	CL_CLOSE    = 11, /* may be written to log only with mtime change */
-	CL_LAYOUT   = 12, /* file layout/striping modified */
-	CL_TRUNC    = 13,
-	CL_SETATTR  = 14,
-	CL_XATTR    = 15,
-	CL_HSM      = 16, /* HSM specific events, see flags */
-	CL_MTIME    = 17, /* Precedence: setattr > mtime > ctime > atime */
-	CL_CTIME    = 18,
-	CL_ATIME    = 19,
+	CL_MARK		= 0,
+	CL_CREATE	= 1,  /* namespace */
+	CL_MKDIR	= 2,  /* namespace */
+	CL_HARDLINK	= 3,  /* namespace */
+	CL_SOFTLINK	= 4,  /* namespace */
+	CL_MKNOD	= 5,  /* namespace */
+	CL_UNLINK	= 6,  /* namespace */
+	CL_RMDIR	= 7,  /* namespace */
+	CL_RENAME	= 8,  /* namespace */
+	CL_EXT		= 9,  /* namespace extended record (2nd half of rename) */
+	CL_OPEN		= 10, /* not currently used */
+	CL_CLOSE	= 11, /* may be written to log only with mtime change */
+	CL_LAYOUT	= 12, /* file layout/striping modified */
+	CL_TRUNC	= 13,
+	CL_SETATTR	= 14,
+	CL_XATTR	= 15,
+	CL_HSM		= 16, /* HSM specific events, see flags */
+	CL_MTIME	= 17, /* Precedence: setattr > mtime > ctime > atime */
+	CL_CTIME	= 18,
+	CL_ATIME	= 19,
 	CL_LAST
 };
 
@@ -808,9 +808,9 @@ enum changelog_rec_flags {
 
 /* Anything under the flagmask may be per-type (if desired) */
 /* Flags for unlink */
-#define CLF_UNLINK_LAST       0x0001 /* Unlink of last hardlink */
-#define CLF_UNLINK_HSM_EXISTS 0x0002 /* File has something in HSM */
-				     /* HSM cleaning needed */
+#define CLF_UNLINK_LAST		0x0001 /* Unlink of last hardlink */
+#define CLF_UNLINK_HSM_EXISTS	0x0002 /* File has something in HSM
+					* HSM cleaning needed */
 /* Flags for rename */
 #define CLF_RENAME_LAST		0x0001	/* rename unlink last hardlink of
 					 * target
@@ -827,12 +827,12 @@ enum changelog_rec_flags {
  */
 #define CLF_HSM_ERR_L	0 /* HSM return code, 7 bits */
 #define CLF_HSM_ERR_H	6
-#define CLF_HSM_EVENT_L      7 /* HSM event, 3 bits, see enum hsm_event */
-#define CLF_HSM_EVENT_H      9
-#define CLF_HSM_FLAG_L      10 /* HSM flags, 2 bits, 1 used, 1 spare */
-#define CLF_HSM_FLAG_H      11
-#define CLF_HSM_SPARE_L     12 /* 4 spare bits */
-#define CLF_HSM_SPARE_H     15
+#define CLF_HSM_EVENT_L	7 /* HSM event, 3 bits, see enum hsm_event */
+#define CLF_HSM_EVENT_H	9
+#define CLF_HSM_FLAG_L	10 /* HSM flags, 2 bits, 1 used, 1 spare */
+#define CLF_HSM_FLAG_H	11
+#define CLF_HSM_SPARE_L	12 /* 4 spare bits */
+#define CLF_HSM_SPARE_H	15
 #define CLF_HSM_LAST	15
 
 /* Remove bits higher than _h, then extract the value
@@ -841,22 +841,22 @@ enum changelog_rec_flags {
 #define CLF_GET_BITS(_b, _h, _l) (((_b << (CLF_HSM_LAST - _h)) & 0xFFFF) \
 				   >> (CLF_HSM_LAST - _h + _l))
 
-#define CLF_HSM_SUCCESS      0x00
-#define CLF_HSM_MAXERROR     0x7E
-#define CLF_HSM_ERROVERFLOW  0x7F
+#define CLF_HSM_SUCCESS		0x00
+#define CLF_HSM_MAXERROR	0x7E
+#define CLF_HSM_ERROVERFLOW	0x7F
 
 #define CLF_HSM_DIRTY	1 /* file is dirty after HSM request end */
 
 /* 3 bits field => 8 values allowed */
 enum hsm_event {
-	HE_ARCHIVE      = 0,
-	HE_RESTORE      = 1,
-	HE_CANCEL       = 2,
-	HE_RELEASE      = 3,
-	HE_REMOVE       = 4,
+	HE_ARCHIVE	= 0,
+	HE_RESTORE	= 1,
+	HE_CANCEL	= 2,
+	HE_RELEASE	= 3,
+	HE_REMOVE	= 4,
 	HE_STATE	= 5,
-	HE_SPARE1       = 6,
-	HE_SPARE2       = 7,
+	HE_SPARE1	= 6,
+	HE_SPARE2	= 7,
 };
 
 static inline enum hsm_event hsm_get_cl_event(__u16 flags)
@@ -1070,14 +1070,14 @@ enum changelog_message_type {
 
 struct ioc_data_version {
 	__u64 idv_version;
-	__u64 idv_flags;     /* See LL_DV_xxx */
+	__u64 idv_flags;	/* See LL_DV_xxx */
 };
 
 #define LL_DV_RD_FLUSH	(1 << 0) /* Flush dirty pages from clients */
 #define LL_DV_WR_FLUSH	(1 << 1) /* Flush all caching pages from clients */
 
 #ifndef offsetof
-# define offsetof(typ, memb)     ((unsigned long)((char *)&(((typ *)0)->memb)))
+# define offsetof(typ, memb)	((unsigned long)((char *)&(((typ *)0)->memb)))
 #endif
 
 #define dot_lustre_name ".lustre"
@@ -1284,14 +1284,14 @@ static inline const char *hsm_copytool_action2name(enum hsm_copytool_action  a)
 
 /* Copytool item action description */
 struct hsm_action_item {
-	__u32      hai_len;     /* valid size of this struct */
-	__u32      hai_action;  /* hsm_copytool_action, but use known size */
-	struct lu_fid hai_fid;     /* Lustre FID to operated on */
-	struct lu_fid hai_dfid;    /* fid used for data access */
+	__u32		hai_len;     /* valid size of this struct */
+	__u32		hai_action;  /* hsm_copytool_action, but use known size */
+	struct lu_fid	hai_fid;     /* Lustre FID to operated on */
+	struct lu_fid	hai_dfid;    /* fid used for data access */
 	struct hsm_extent hai_extent;  /* byte range to operate on */
-	__u64      hai_cookie;  /* action cookie from coordinator */
-	__u64      hai_gid;     /* grouplock id */
-	char       hai_data[0]; /* variable length */
+	__u64		hai_cookie;  /* action cookie from coordinator */
+	__u64		hai_gid;     /* grouplock id */
+	char		hai_data[0]; /* variable length */
 } __packed;
 
 /*
@@ -1326,12 +1326,12 @@ static inline char *hai_dump_data_field(struct hsm_action_item *hai,
 #define HAL_MAXSIZE LNET_MTU /* bytes, used in userspace only */
 struct hsm_action_list {
 	__u32 hal_version;
-	__u32 hal_count;       /* number of hai's to follow */
-	__u64 hal_compound_id; /* returned by coordinator */
+	__u32 hal_count;	/* number of hai's to follow */
+	__u64 hal_compound_id;	/* returned by coordinator */
 	__u64 hal_flags;
-	__u32 hal_archive_id; /* which archive backend */
+	__u32 hal_archive_id;	/* which archive backend */
 	__u32 padding1;
-	char  hal_fsname[0];   /* null-terminated */
+	char  hal_fsname[0];	/* null-terminated */
 	/* struct hsm_action_item[hal_count] follows, aligned on 8-byte
 	 * boundaries. See hai_first
 	 */
@@ -1384,8 +1384,8 @@ struct hsm_user_import {
 };
 
 /* Copytool progress reporting */
-#define HP_FLAG_COMPLETED 0x01
-#define HP_FLAG_RETRY     0x02
+#define HP_FLAG_COMPLETED	0x01
+#define HP_FLAG_RETRY		0x02
 
 struct hsm_progress {
 	struct lu_fid		hp_fid;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 2bf12284bf43..92427254d74c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -74,25 +74,25 @@
 #define IBLND_N_SCHED_HIGH		4
 
 struct kib_tunables {
-	int *kib_dev_failover;           /* HCA failover */
-	unsigned int *kib_service;       /* IB service number */
+	int *kib_dev_failover;		/* HCA failover */
+	unsigned int *kib_service;	/* IB service number */
 	int *kib_min_reconnect_interval; /* first failed connection retry... */
 	int *kib_max_reconnect_interval; /* exponentially increasing to this */
-	int *kib_cksum;                  /* checksum struct kib_msg? */
-	int *kib_timeout;                /* comms timeout (seconds) */
-	int *kib_keepalive;              /* keepalive timeout (seconds) */
-	int *kib_ntx;                    /* # tx descs */
-	char **kib_default_ipif;         /* default IPoIB interface */
+	int *kib_cksum;			/* checksum struct kib_msg? */
+	int *kib_timeout;		/* comms timeout (seconds) */
+	int *kib_keepalive;		/* keepalive timeout (seconds) */
+	int *kib_ntx;			/* # tx descs */
+	char **kib_default_ipif;	/* default IPoIB interface */
 	int *kib_retry_count;
 	int *kib_rnr_retry_count;
-	int *kib_ib_mtu;                 /* IB MTU */
-	int *kib_require_priv_port;      /* accept only privileged ports */
-	int *kib_use_priv_port; /* use privileged port for active connect */
-	int *kib_nscheds;                /* # threads on each CPT */
-	int *kib_wrq_sge;		 /* # sg elements per wrq */
-	bool *kib_use_fastreg_gaps;	 /* enable discontiguous fastreg
-					  * fragment support
-					  */
+	int *kib_ib_mtu;		/* IB MTU */
+	int *kib_require_priv_port;	/* accept only privileged ports */
+	int *kib_use_priv_port;		/* use privileged port for active connect */
+	int *kib_nscheds;		/* # threads on each CPT */
+	int *kib_wrq_sge;		/* # sg elements per wrq */
+	bool *kib_use_fastreg_gaps;	/* enable discontiguous fastreg
+					 * fragment support
+					 */
 };
 
 extern struct kib_tunables  kiblnd_tunables;
@@ -164,11 +164,11 @@ struct kib_dev {
 	int			ibd_nnets;	/* # nets extant */
 
 	time64_t		ibd_next_failover;
-	int			ibd_failed_failover; /* # failover failures */
-	unsigned int		ibd_failover;        /* failover in progress */
-	unsigned int		ibd_can_failover;    /* IPoIB interface is a
-						      * bonding master
-						      */
+	int			ibd_failed_failover;	/* # failover failures */
+	unsigned int		ibd_failover;		/* failover in progress */
+	unsigned int		ibd_can_failover;	/* IPoIB interface is a
+							 * bonding master
+							 */
 	struct list_head	ibd_nets;
 	struct kib_hca_dev	*ibd_hdev;
 	enum kib_dev_caps	ibd_dev_caps;
@@ -330,8 +330,8 @@ struct kib_sched_info {
 
 struct kib_data {
 	int			kib_init;	    /* initialisation state */
-	int			kib_shutdown;       /* shut down? */
-	struct list_head	kib_devs;           /* IB devices extant */
+	int			kib_shutdown;	    /* shut down? */
+	struct list_head	kib_devs;	    /* IB devices extant */
 	struct list_head	kib_failed_devs;    /* list head of failed devices */
 	wait_queue_head_t	kib_failover_waitq; /* schedulers sleep here */
 	atomic_t		kib_nthreads;	    /* # live threads */
@@ -540,7 +540,7 @@ struct kib_conn {
 	int			ibc_state;	/* what's happening */
 	int			ibc_nsends_posted;	/* # uncompleted sends */
 	int			ibc_noops_posted;	/* # uncompleted NOOPs */
-	int			ibc_credits;     /* # credits I have */
+	int			ibc_credits;		/* # credits I have */
 	int			ibc_outstanding_credits; /* # credits to return */
 	int			ibc_reserved_credits; /* # ACK/DONE msg credits */
 	int			ibc_comms_error; /* set on comms error */
@@ -581,13 +581,13 @@ struct kib_conn {
 #define IBLND_CONN_DISCONNECTED		5	 /* disconnected */
 
 struct kib_peer_ni {
-	struct list_head	ibp_list;        /* stash on global peer_ni list */
-	lnet_nid_t		ibp_nid;         /* who's on the other end(s) */
-	struct lnet_ni		*ibp_ni;         /* LNet interface */
-	struct list_head	ibp_conns;       /* all active connections */
-	struct kib_conn		*ibp_next_conn;  /* next connection to send on for
-						  * round robin */
-	struct list_head	ibp_tx_queue;	 /* msgs waiting for a conn */
+	struct list_head	ibp_list;	/* stash on global peer_ni list */
+	lnet_nid_t		ibp_nid;	/* who's on the other end(s) */
+	struct lnet_ni		*ibp_ni;	/* LNet interface */
+	struct list_head	ibp_conns;	/* all active connections */
+	struct kib_conn		*ibp_next_conn; /* next connection to send on for
+						 * round robin */
+	struct list_head	ibp_tx_queue;	/* msgs waiting for a conn */
 	u64			ibp_incarnation; /* incarnation of peer_ni */
 	/* when (in seconds) I was last alive */
 	time64_t		ibp_last_alive;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index ce1f9e78b4d9..add2744c9d8d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -54,15 +54,15 @@
 #define SOCKNAL_NSCHEDS		3
 #define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
 
-#define SOCKNAL_PEER_HASH_SIZE  101   /* # peer_ni lists */
-#define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
-#define SOCKNAL_INSANITY_RECONN 5000  /* connd is trying on reconn infinitely */
-#define SOCKNAL_ENOMEM_RETRY    1     /* seconds between retries */
+#define SOCKNAL_PEER_HASH_SIZE	101   /* # peer_ni lists */
+#define SOCKNAL_RESCHED		100   /* # scheduler loops before reschedule */
+#define SOCKNAL_INSANITY_RECONN	5000  /* connd is trying on reconn infinitely */
+#define SOCKNAL_ENOMEM_RETRY	1     /* seconds between retries */
 
-#define SOCKNAL_SINGLE_FRAG_TX  0     /* disable multi-fragment sends */
-#define SOCKNAL_SINGLE_FRAG_RX  0     /* disable multi-fragment receives */
+#define SOCKNAL_SINGLE_FRAG_TX	0     /* disable multi-fragment sends */
+#define SOCKNAL_SINGLE_FRAG_RX	0     /* disable multi-fragment receives */
 
-#define SOCKNAL_VERSION_DEBUG   0     /* enable protocol version debugging */
+#define SOCKNAL_VERSION_DEBUG	0     /* enable protocol version debugging */
 
 /*
  * risk kmap deadlock on multi-frag I/O (backs off to single-frag if disabled).
@@ -461,31 +461,31 @@ extern struct ksock_tunables ksocknal_tunables;
 
 struct ksock_proto {
 	/* version number of protocol */
-	int        pro_version;
+	int	pro_version;
 
 	/* handshake function */
-	int        (*pro_send_hello)(struct ksock_conn *, struct ksock_hello_msg *);
+	int	(*pro_send_hello)(struct ksock_conn *, struct ksock_hello_msg *);
 
 	/* handshake function */
-	int        (*pro_recv_hello)(struct ksock_conn *, struct ksock_hello_msg *, int);
+	int	(*pro_recv_hello)(struct ksock_conn *, struct ksock_hello_msg *, int);
 
 	/* message pack */
-	void       (*pro_pack)(struct ksock_tx *);
+	void	(*pro_pack)(struct ksock_tx *);
 
 	/* message unpack */
-	void       (*pro_unpack)(struct ksock_msg *);
+	void	(*pro_unpack)(struct ksock_msg *);
 
 	/* queue tx on the connection */
 	struct ksock_tx *(*pro_queue_tx_msg)(struct ksock_conn *, struct ksock_tx *);
 
 	/* queue ZC ack on the connection */
-	int        (*pro_queue_tx_zcack)(struct ksock_conn *, struct ksock_tx *, u64);
+	int	(*pro_queue_tx_zcack)(struct ksock_conn *, struct ksock_tx *, u64);
 
 	/* handle ZC request */
-	int        (*pro_handle_zcreq)(struct ksock_conn *, u64, int);
+	int	(*pro_handle_zcreq)(struct ksock_conn *, u64, int);
 
 	/* handle ZC ACK */
-	int        (*pro_handle_zcack)(struct ksock_conn *, u64, u64);
+	int	(*pro_handle_zcack)(struct ksock_conn *, u64, u64);
 
 	/*
 	 * msg type matches the connection type:
@@ -494,7 +494,7 @@ struct ksock_proto {
 	 *   return MATCH_YES : matching type
 	 *   return MATCH_MAY : can be backup
 	 */
-	int        (*pro_match_tx)(struct ksock_conn *, struct ksock_tx *, int);
+	int	(*pro_match_tx)(struct ksock_conn *, struct ksock_tx *, int);
 };
 
 extern struct ksock_proto ksocknal_protocol_v1x;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 2df9ce4995f3..18f5c6b3b587 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -92,9 +92,9 @@ EXPORT_SYMBOL(libcfs_next_nidstring);
  * <nidrange>        :== <addrrange> '@' <net>
  * <addrrange>       :== '*' |
  *                       <ipaddr_range> |
- *			 <cfs_expr_list>
+ *                       <cfs_expr_list>
  * <ipaddr_range>    :== <cfs_expr_list>.<cfs_expr_list>.<cfs_expr_list>.
- *			 <cfs_expr_list>
+ *                       <cfs_expr_list>
  * <cfs_expr_list>   :== <number> |
  *                       <expr_list>
  * <expr_list>       :== '[' <range_expr> [ ',' <range_expr>] ']'
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index bb61e3aa11e9..51ff979ca4ad 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -46,12 +46,12 @@
  * sorted by increasing expiry time. The number of slots is 2**7 (128),
  * to cover a time period of 1024 seconds into the future before wrapping.
  */
-#define STTIMER_MINPOLL        3	/* log2 min poll interval (8 s) */
+#define STTIMER_MINPOLL		3	/* log2 min poll interval (8 s) */
 #define STTIMER_SLOTTIME	BIT(STTIMER_MINPOLL)
-#define STTIMER_SLOTTIMEMASK   (~(STTIMER_SLOTTIME - 1))
+#define STTIMER_SLOTTIMEMASK	(~(STTIMER_SLOTTIME - 1))
 #define STTIMER_NSLOTS		BIT(7)
-#define STTIMER_SLOT(t)	       (&stt_data.stt_hash[(((t) >> STTIMER_MINPOLL) & \
-						    (STTIMER_NSLOTS - 1))])
+#define STTIMER_SLOT(t)		(&stt_data.stt_hash[(((t) >> STTIMER_MINPOLL) & \
+						     (STTIMER_NSLOTS - 1))])
 
 static struct st_timer_data {
 	spinlock_t	  stt_lock;
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index c85ef9ec639f..67b002bb1d1d 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -139,7 +139,7 @@ fld_debugfs_cache_flush_release(struct inode *inode, struct file *file)
 
 static const struct file_operations fld_debugfs_cache_flush_fops = {
 	.owner		= THIS_MODULE,
-	.open           = simple_open,
+	.open		= simple_open,
 	.write		= fld_debugfs_cache_flush_write,
 	.release	= fld_debugfs_cache_flush_release,
 };
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 7d52665a3c33..31b3881fb6c9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -69,9 +69,9 @@ struct adaptive_timeout {
 
 struct ptlrpc_at_array {
 	struct list_head	*paa_reqs_array; /** array to hold requests */
-	u32			paa_size;        /** the size of array */
-	u32			paa_count;       /** the total count of reqs */
-	time64_t		paa_deadline;    /** the earliest deadline of reqs */
+	u32			paa_size;	 /** the size of array */
+	u32			paa_count;	 /** the total count of reqs */
+	time64_t		paa_deadline;	 /** the earliest deadline of reqs */
 	u32			*paa_reqs_count; /** the count of reqs in each entry */
 };
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 9cffda3741ce..e09268f08e5c 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -690,10 +690,10 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 
 enum md_op_flags {
 	MF_MDC_CANCEL_FID1	= BIT(0),
-	MF_MDC_CANCEL_FID2      = BIT(1),
-	MF_MDC_CANCEL_FID3      = BIT(2),
-	MF_MDC_CANCEL_FID4      = BIT(3),
-	MF_GET_MDT_IDX          = BIT(4),
+	MF_MDC_CANCEL_FID2	= BIT(1),
+	MF_MDC_CANCEL_FID3	= BIT(2),
+	MF_MDC_CANCEL_FID4	= BIT(3),
+	MF_GET_MDT_IDX		= BIT(4),
 };
 
 enum md_cli_flags {
@@ -744,7 +744,7 @@ struct md_op_data {
 	u32			op_flags;
 
 	/* Various operation flags. */
-	enum mds_op_bias        op_bias;
+	enum mds_op_bias	op_bias;
 
 	/* Used by readdir */
 	u64			op_offset;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 261857e4540d..ae2fddd044ea 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -335,9 +335,9 @@ static void ldlm_ns_release(struct kobject *kobj)
 }
 
 static struct kobj_type ldlm_ns_ktype = {
-	.default_attrs  = ldlm_ns_attrs,
-	.sysfs_ops      = &lustre_sysfs_ops,
-	.release        = ldlm_ns_release,
+	.default_attrs	= ldlm_ns_attrs,
+	.sysfs_ops	= &lustre_sysfs_ops,
+	.release	= ldlm_ns_release,
 };
 
 static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6afaa9028864..07cb2c92c197 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2636,7 +2636,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -EFAULT;
 
 		return ll_file_futimes_3(file, &lfu);
-        }
+	}
 	case LL_IOC_LADVISE: {
 		struct llapi_ladvise_hdr *ladvise_hdr;
 		int alloc_size = sizeof(*ladvise_hdr);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 102d143691b2..0f7c0272d630 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -204,7 +204,7 @@ struct vvp_object {
 	 *
 	 * \see ll_vm_open(), ll_vm_close().
 	 */
-	atomic_t                vob_mmap_cnt;
+	atomic_t		vob_mmap_cnt;
 
 	/**
 	 * various flags
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 22f178a3abe2..a1d27061ac19 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -209,7 +209,7 @@ static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 	if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
 		entry_count = comp_v1->lcm_entry_count;
 		is_composite = true;
-        }
+	}
 
 	for (i = 0; i < entry_count; i++) {
 		if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 6db4d5eb46cd..395ef772fc17 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -536,7 +536,7 @@ void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 		       DEXT ": id: %u, flags: %x, magic 0x%08X, layout_gen %u, stripe count %u, sstripe size %u, pool: [" LOV_POOLNAMEF "]\n",
 		       PEXT(&lse->lsme_extent), lse->lsme_id, lse->lsme_flags,
 		       lse->lsme_magic, lse->lsme_layout_gen,
-                       lse->lsme_stripe_count, lse->lsme_stripe_size,
+		       lse->lsme_stripe_count, lse->lsme_stripe_size,
 		       lse->lsme_pool_name);
 		if (!lsme_inited(lse) ||
 		    lse->lsme_pattern & LOV_PATTERN_F_RELEASED)
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index bad9538706f0..652ed6a20af3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1336,19 +1336,19 @@ static const struct obd_ops lov_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= lov_setup,
 	.cleanup	= lov_cleanup,
-	.connect        = lov_connect,
-	.disconnect     = lov_disconnect,
-	.statfs         = lov_statfs,
-	.statfs_async   = lov_statfs_async,
-	.iocontrol      = lov_iocontrol,
-	.get_info       = lov_get_info,
-	.set_info_async = lov_set_info_async,
-	.notify         = lov_notify,
-	.pool_new       = lov_pool_new,
-	.pool_rem       = lov_pool_remove,
-	.pool_add       = lov_pool_add,
-	.pool_del       = lov_pool_del,
-	.quotactl       = lov_quotactl,
+	.connect	= lov_connect,
+	.disconnect	= lov_disconnect,
+	.statfs		= lov_statfs,
+	.statfs_async	= lov_statfs_async,
+	.iocontrol	= lov_iocontrol,
+	.get_info	= lov_get_info,
+	.set_info_async	= lov_set_info_async,
+	.notify		= lov_notify,
+	.pool_new	= lov_pool_new,
+	.pool_rem	= lov_pool_remove,
+	.pool_add	= lov_pool_add,
+	.pool_del	= lov_pool_del,
+	.quotactl	= lov_quotactl,
 };
 
 struct kmem_cache *lov_oinfo_slab;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 3ff0bf1c4a22..ec872e8ae9be 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1818,18 +1818,18 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 static const struct obd_ops mgc_obd_ops = {
-	.owner          = THIS_MODULE,
-	.setup          = mgc_setup,
-	.precleanup     = mgc_precleanup,
-	.cleanup        = mgc_cleanup,
-	.add_conn       = client_import_add_conn,
-	.del_conn       = client_import_del_conn,
-	.connect        = client_connect_import,
-	.disconnect     = client_disconnect_export,
-	.set_info_async = mgc_set_info_async,
-	.get_info       = mgc_get_info,
-	.import_event   = mgc_import_event,
-	.process_config = mgc_process_config,
+	.owner		= THIS_MODULE,
+	.setup		= mgc_setup,
+	.precleanup	= mgc_precleanup,
+	.cleanup	= mgc_cleanup,
+	.add_conn	= client_import_add_conn,
+	.del_conn	= client_import_del_conn,
+	.connect	= client_connect_import,
+	.disconnect	= client_disconnect_export,
+	.set_info_async	= mgc_set_info_async,
+	.get_info	= mgc_get_info,
+	.import_event	= mgc_import_event,
+	.process_config	= mgc_process_config,
 };
 
 static int __init mgc_init(void)
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 1d1a6b2d436e..c91704d87042 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -313,9 +313,9 @@ struct obd_device *class_newdev(const char *type_name, const char *name,
 
 	llog_group_init(&newdev->obd_olg);
 	/* Detach drops this */
-        atomic_set(&newdev->obd_refcount, 1);
-        lu_ref_init(&newdev->obd_reference);
-        lu_ref_add(&newdev->obd_reference, "newdev", newdev);
+	atomic_set(&newdev->obd_refcount, 1);
+	lu_ref_init(&newdev->obd_reference);
+	lu_ref_add(&newdev->obd_reference, "newdev", newdev);
 
 	newdev->obd_conn_inprogress = 0;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 69a56cca99f2..d4f1eddd96ca 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -73,7 +73,7 @@ struct lu_site_bkt_data {
 	 *
 	 * \see htable_lookup().
 	 */
-	wait_queue_head_t	       lsb_marche_funebre;
+	wait_queue_head_t		lsb_marche_funebre;
 };
 
 enum {
@@ -935,10 +935,10 @@ static void lu_obj_hop_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
 static struct cfs_hash_ops lu_site_hash_ops = {
 	.hs_hash	= lu_obj_hop_hash,
 	.hs_key		= lu_obj_hop_key,
-	.hs_keycmp      = lu_obj_hop_keycmp,
-	.hs_object      = lu_obj_hop_object,
+	.hs_keycmp	= lu_obj_hop_keycmp,
+	.hs_object	= lu_obj_hop_object,
 	.hs_get		= lu_obj_hop_get,
-	.hs_put_locked  = lu_obj_hop_put_locked,
+	.hs_put_locked	= lu_obj_hop_put_locked,
 };
 
 static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
index 71490b75c7ae..e9e0bcf39d4e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
@@ -105,7 +105,7 @@ static ssize_t static_uintvalue_store(struct kobject *kobj,
 }
 
 #define LUSTRE_STATIC_UINT_ATTR(name, value)				\
-static struct static_lustre_uintvalue_attr lustre_sattr_##name =        \
+static struct static_lustre_uintvalue_attr lustre_sattr_##name =	\
 	{ __ATTR(name, 0644, static_uintvalue_show,			\
 		 static_uintvalue_store), value }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 442b4355d946..765b5a7b9662 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2989,26 +2989,26 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 static const struct obd_ops osc_obd_ops = {
-	.owner          = THIS_MODULE,
-	.setup          = osc_setup,
-	.precleanup     = osc_precleanup,
-	.cleanup        = osc_cleanup,
-	.add_conn       = client_import_add_conn,
-	.del_conn       = client_import_del_conn,
-	.connect        = client_connect_import,
-	.reconnect      = osc_reconnect,
-	.disconnect     = osc_disconnect,
-	.statfs         = osc_statfs,
-	.statfs_async   = osc_statfs_async,
-	.create         = osc_create,
-	.destroy        = osc_destroy,
-	.getattr        = osc_getattr,
-	.setattr        = osc_setattr,
-	.iocontrol      = osc_iocontrol,
-	.set_info_async = osc_set_info_async,
-	.import_event   = osc_import_event,
-	.process_config = osc_process_config,
-	.quotactl       = osc_quotactl,
+	.owner		= THIS_MODULE,
+	.setup		= osc_setup,
+	.precleanup	= osc_precleanup,
+	.cleanup	= osc_cleanup,
+	.add_conn	= client_import_add_conn,
+	.del_conn	= client_import_del_conn,
+	.connect	= client_connect_import,
+	.reconnect	= osc_reconnect,
+	.disconnect	= osc_disconnect,
+	.statfs		= osc_statfs,
+	.statfs_async	= osc_statfs_async,
+	.create		= osc_create,
+	.destroy	= osc_destroy,
+	.getattr	= osc_getattr,
+	.setattr	= osc_setattr,
+	.iocontrol	= osc_iocontrol,
+	.set_info_async	= osc_set_info_async,
+	.import_event	= osc_import_event,
+	.process_config	= osc_process_config,
+	.quotactl	= osc_quotactl,
 };
 
 struct list_head osc_shrink_list = LIST_HEAD_INIT(osc_shrink_list);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index c2f49a3e0454..5dde3495aaf4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1508,7 +1508,7 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding));
 	LASSERTF(LCME_FL_INIT == 0x00000010UL, "found 0x%.8xUL\n",
-	         (unsigned int)LCME_FL_INIT);
+		 (unsigned int)LCME_FL_INIT);
 
 	/* Checks for struct lov_comp_md_v1 */
 	LASSERTF((int)sizeof(struct lov_comp_md_v1) == 32, "found %lld\n",
