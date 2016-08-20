From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:26 -0400
Subject: [lustre-devel] [PATCH 09/13] staging/lustre: Add spaces preferred
	around that '{+, -, *, /, |, <<, >>, &}'
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Emoly Liu <emoly.liu@intel.com>

This patch fixes all checkpatch occurences of
"CHECK: spaces preferred around that '{+,-,*,/,|,<<,>>,&}' (ctx:VxV)"
in Lustre code.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |  3 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      | 42 +++++++++++-----------
 .../lustre/lustre/include/lustre/lustre_user.h     |  2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |  2 +-
 .../staging/lustre/lustre/include/lustre_lite.h    |  2 +-
 .../staging/lustre/lustre/include/obd_support.h    | 13 +++----
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  4 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  4 +--
 drivers/staging/lustre/lustre/llite/dir.c          |  2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  4 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 21 ++++++-----
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 +--
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 14 ++++----
 drivers/staging/lustre/lustre/llite/namei.c        |  4 +--
 drivers/staging/lustre/lustre/llite/rw.c           |  5 +--
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |  4 +--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  3 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 14 ++++----
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  5 +--
 drivers/staging/lustre/lustre/obdclass/debug.c     |  4 +--
 drivers/staging/lustre/lustre/obdclass/genops.c    |  2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    | 12 +++----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  6 ++--
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  6 ++--
 .../staging/lustre/lustre/obdecho/echo_internal.h  |  4 +--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 12 ++++---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  6 ++--
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  4 +--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  2 +-
 37 files changed, 121 insertions(+), 105 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 6e25c1b..1e8421c 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1025,7 +1025,8 @@ enum lu_context_tag {
 	/**
 	 * Contexts usable in cache shrinker thread.
 	 */
-	LCT_SHRINKER  = LCT_MD_THREAD|LCT_DT_THREAD|LCT_CL_THREAD|LCT_NOREF
+	LCT_SHRINKER  = LCT_MD_THREAD | LCT_DT_THREAD | LCT_CL_THREAD |
+			LCT_NOREF
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 32471a6..7410a8a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1318,13 +1318,13 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_IBITS | OBD_CONNECT_FID | \
 				 OBD_CONNECT_FULL20)
 
-#define OBD_OCD_VERSION(major, minor, patch, fix) (((major)<<24) + \
-						  ((minor)<<16) + \
-						  ((patch)<<8) + (fix))
-#define OBD_OCD_VERSION_MAJOR(version) ((int)((version)>>24)&255)
-#define OBD_OCD_VERSION_MINOR(version) ((int)((version)>>16)&255)
-#define OBD_OCD_VERSION_PATCH(version) ((int)((version)>>8)&255)
-#define OBD_OCD_VERSION_FIX(version)   ((int)(version)&255)
+#define OBD_OCD_VERSION(major, minor, patch, fix) (((major) << 24) + \
+						   ((minor) << 16) + \
+						   ((patch) << 8) + (fix))
+#define OBD_OCD_VERSION_MAJOR(version) ((int)((version) >> 24) & 255)
+#define OBD_OCD_VERSION_MINOR(version) ((int)((version) >> 16) & 255)
+#define OBD_OCD_VERSION_PATCH(version) ((int)((version) >> 8) & 255)
+#define OBD_OCD_VERSION_FIX(version)   ((int)(version) & 255)
 
 /* This structure is used for both request and reply.
  *
@@ -2028,7 +2028,7 @@ void lustre_swab_generic_32s(__u32 *val);
 
 #define MDS_INODELOCK_MAXSHIFT 5
 /* This FULL lock is useful to take on unlink sort of operations */
-#define MDS_INODELOCK_FULL ((1<<(MDS_INODELOCK_MAXSHIFT+1))-1)
+#define MDS_INODELOCK_FULL ((1 << (MDS_INODELOCK_MAXSHIFT + 1)) - 1)
 
 /* NOTE: until Lustre 1.8.7/2.1.1 the fid_ver() was packed into name[2],
  * but was moved into name[1] along with the OID to avoid consuming the
@@ -3129,8 +3129,8 @@ struct llog_log_hdr {
 	__u32		   llh_cat_idx;
 	/* for a catalog the first plain slot is next to it */
 	struct obd_uuid	 llh_tgtuuid;
-	__u32		   llh_reserved[LLOG_HEADER_SIZE/sizeof(__u32) - 23];
-	__u32		   llh_bitmap[LLOG_BITMAP_BYTES/sizeof(__u32)];
+	__u32		   llh_reserved[LLOG_HEADER_SIZE / sizeof(__u32) - 23];
+	__u32		   llh_bitmap[LLOG_BITMAP_BYTES / sizeof(__u32)];
 	struct llog_rec_tail    llh_tail;
 } __packed;
 
@@ -3345,17 +3345,17 @@ void lustre_swab_lustre_capa(struct lustre_capa *c);
 
 /** lustre_capa::lc_opc */
 enum {
-	CAPA_OPC_BODY_WRITE   = 1<<0,  /**< write object data */
-	CAPA_OPC_BODY_READ    = 1<<1,  /**< read object data */
-	CAPA_OPC_INDEX_LOOKUP = 1<<2,  /**< lookup object fid */
-	CAPA_OPC_INDEX_INSERT = 1<<3,  /**< insert object fid */
-	CAPA_OPC_INDEX_DELETE = 1<<4,  /**< delete object fid */
-	CAPA_OPC_OSS_WRITE    = 1<<5,  /**< write oss object data */
-	CAPA_OPC_OSS_READ     = 1<<6,  /**< read oss object data */
-	CAPA_OPC_OSS_TRUNC    = 1<<7,  /**< truncate oss object */
-	CAPA_OPC_OSS_DESTROY  = 1<<8,  /**< destroy oss object */
-	CAPA_OPC_META_WRITE   = 1<<9,  /**< write object meta data */
-	CAPA_OPC_META_READ    = 1<<10, /**< read object meta data */
+	CAPA_OPC_BODY_WRITE   = 1 << 0,  /**< write object data */
+	CAPA_OPC_BODY_READ    = 1 << 1,  /**< read object data */
+	CAPA_OPC_INDEX_LOOKUP = 1 << 2,  /**< lookup object fid */
+	CAPA_OPC_INDEX_INSERT = 1 << 3,  /**< insert object fid */
+	CAPA_OPC_INDEX_DELETE = 1 << 4,  /**< delete object fid */
+	CAPA_OPC_OSS_WRITE    = 1 << 5,  /**< write oss object data */
+	CAPA_OPC_OSS_READ     = 1 << 6,  /**< read oss object data */
+	CAPA_OPC_OSS_TRUNC    = 1 << 7,  /**< truncate oss object */
+	CAPA_OPC_OSS_DESTROY  = 1 << 8,  /**< destroy oss object */
+	CAPA_OPC_META_WRITE   = 1 << 9,  /**< write object meta data */
+	CAPA_OPC_META_READ    = 1 << 10, /**< read object meta data */
 };
 
 #define CAPA_OPC_OSS_RW (CAPA_OPC_OSS_READ | CAPA_OPC_OSS_WRITE)
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index ef6f38f..5fc0c5c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -736,7 +736,7 @@ static inline void hsm_set_cl_error(int *flags, int error)
 	*flags |= (error << CLF_HSM_ERR_L);
 }
 
-#define CR_MAXSIZE cfs_size_round(2*NAME_MAX + 1 + \
+#define CR_MAXSIZE cfs_size_round(2 * NAME_MAX + 1 + \
 				  sizeof(struct changelog_ext_rec))
 
 struct changelog_rec {
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 743671a..6b042ac 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -603,7 +603,7 @@ static inline __u32 fid_flatten32(const struct lu_fid *fid)
 	 * (from OID), or up to 128M inodes without collisions for new files.
 	 */
 	ino = ((seq & 0x000fffffULL) << 12) + ((seq >> 8) & 0xfffff000) +
-	       (seq >> (64 - (40-8)) & 0xffffff00) +
+	       (seq >> (64 - (40 - 8)) & 0xffffff00) +
 	       (fid_oid(fid) & 0xff000fff) + ((fid_oid(fid) & 0x00fff000) << 8);
 
 	return ino ? ino : fid_oid(fid);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index b168977..ad9c3e0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -47,7 +47,7 @@
 
 /* 4UL * 1024 * 1024 */
 #define LL_MAX_BLKSIZE_BITS     (22)
-#define LL_MAX_BLKSIZE	  (1UL<<LL_MAX_BLKSIZE_BITS)
+#define LL_MAX_BLKSIZE	  (1UL << LL_MAX_BLKSIZE_BITS)
 
 /*
  * This is embedded into llite super-blocks to keep track of
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 845e64a..914d146 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -117,17 +117,17 @@ extern char obd_jobid_var[];
  * running on a backup server. (If it's too low, import_select_connection
  * will increase the timeout anyhow.)
  */
-#define INITIAL_CONNECT_TIMEOUT max(CONNECTION_SWITCH_MIN, obd_timeout/20)
+#define INITIAL_CONNECT_TIMEOUT max(CONNECTION_SWITCH_MIN, obd_timeout / 20)
 /* The max delay between connects is SWITCH_MAX + SWITCH_INC + INITIAL */
 #define RECONNECT_DELAY_MAX (CONNECTION_SWITCH_MAX + CONNECTION_SWITCH_INC + \
 			     INITIAL_CONNECT_TIMEOUT)
 /* The min time a target should wait for clients to reconnect in recovery */
-#define OBD_RECOVERY_TIME_MIN    (2*RECONNECT_DELAY_MAX)
+#define OBD_RECOVERY_TIME_MIN    (2 * RECONNECT_DELAY_MAX)
 #define OBD_IR_FACTOR_MIN	 1
 #define OBD_IR_FACTOR_MAX	 10
-#define OBD_IR_FACTOR_DEFAULT    (OBD_IR_FACTOR_MAX/2)
+#define OBD_IR_FACTOR_DEFAULT    (OBD_IR_FACTOR_MAX / 2)
 /* default timeout for the MGS to become IR_FULL */
-#define OBD_IR_MGS_TIMEOUT       (4*obd_timeout)
+#define OBD_IR_MGS_TIMEOUT       (4 * obd_timeout)
 #define LONG_UNLINK 300	  /* Unlink should happen before now */
 
 /**
@@ -520,7 +520,8 @@ do {									      \
 	POISON_PTR(ptr);						      \
 } while (0)
 
-#define KEY_IS(str) \
-	(keylen >= (sizeof(str)-1) && memcmp(key, str, (sizeof(str)-1)) == 0)
+#define KEY_IS(str)					\
+	(keylen >= (sizeof(str) - 1) &&			\
+	memcmp(key, str, (sizeof(str) - 1)) == 0)
 
 #endif
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index d6b61bc..2cf22bf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -463,8 +463,8 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	 * holding the lock even if app still believes it has it, since
 	 * server already dropped it anyway. Only for granted locks too.
 	 */
-	if ((lock->l_flags & (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) ==
-	    (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) {
+	if ((lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_LOCAL_ONLY)) ==
+	    (LDLM_FL_FAILED | LDLM_FL_LOCAL_ONLY)) {
 		if (lock->l_req_mode == lock->l_granted_mode &&
 		    lock->l_granted_mode != LCK_NL && !data)
 			ldlm_lock_decref_internal(lock, lock->l_req_mode);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index af487f9..5606dfb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -819,7 +819,7 @@ static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 		lock_res_and_lock(lock);
 		ldlm_set_cbpending(lock);
 		local_only = !!(lock->l_flags &
-				(LDLM_FL_LOCAL_ONLY|LDLM_FL_CANCEL_ON_BLOCK));
+				(LDLM_FL_LOCAL_ONLY | LDLM_FL_CANCEL_ON_BLOCK));
 		ldlm_cancel_callback(lock);
 		rc = ldlm_is_bl_ast(lock) ? LDLM_FL_BL_AST : LDLM_FL_CANCELING;
 		unlock_res_and_lock(lock);
@@ -1843,7 +1843,7 @@ static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
 	 * bug 17614: locks being actively cancelled. Get a reference
 	 * on a lock so that it does not disappear under us (e.g. due to cancel)
 	 */
-	if (!(lock->l_flags & (LDLM_FL_FAILED|LDLM_FL_CANCELING))) {
+	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_CANCELING))) {
 		list_add(&lock->l_pending_chain, list);
 		LDLM_LOCK_GET(lock);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 031c9e4..dd3e017 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -191,7 +191,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		if (body->valid & OBD_MD_FLSIZE)
 			i_size_write(inode, body->size);
 
-		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_SIZE-1)
+		nrdpgs = (request->rq_bulk->bd_nob_transferred + PAGE_SIZE - 1)
 			 >> PAGE_SHIFT;
 		SetPageUptodate(page0);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 58a7401..5c2ac5f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2474,7 +2474,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 			if (och) {
 				mode = och->och_flags &
-				       (FMODE_READ|FMODE_WRITE);
+				       (FMODE_READ | FMODE_WRITE);
 				rc = ll_lease_close(och, inode, &lease_broken);
 				if (rc == 0 && lease_broken)
 					mode = 0;
@@ -2847,7 +2847,7 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,
 	struct lustre_handle lockh;
 	ldlm_policy_data_t policy;
 	enum ldlm_mode mode = (l_req_mode == LCK_MINMODE) ?
-				(LCK_CR|LCK_CW|LCK_PR|LCK_PW) : l_req_mode;
+			      (LCK_CR | LCK_CW | LCK_PR | LCK_PW) : l_req_mode;
 	struct lu_fid *fid;
 	__u64 flags;
 	int i;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index eb715be..b8ddc27 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -648,7 +648,8 @@ static int ll_options(char *options, int *flags)
 			*flags |= tmp;
 			goto next;
 		}
-		tmp = ll_set_opt("noflock", s1, LL_SBI_FLOCK|LL_SBI_LOCALFLOCK);
+		tmp = ll_set_opt("noflock", s1,
+				 LL_SBI_FLOCK | LL_SBI_LOCALFLOCK);
 		if (tmp) {
 			*flags &= ~tmp;
 			goto next;
@@ -1332,14 +1333,14 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 {
 	int mode = d_inode(de)->i_mode;
 
-	if ((attr->ia_valid & (ATTR_CTIME|ATTR_SIZE|ATTR_MODE)) ==
-			      (ATTR_CTIME|ATTR_SIZE|ATTR_MODE))
+	if ((attr->ia_valid & (ATTR_CTIME | ATTR_SIZE | ATTR_MODE)) ==
+			      (ATTR_CTIME | ATTR_SIZE | ATTR_MODE))
 		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
 
-	if (((attr->ia_valid & (ATTR_MODE|ATTR_FORCE|ATTR_SIZE)) ==
-			       (ATTR_SIZE|ATTR_MODE)) &&
+	if (((attr->ia_valid & (ATTR_MODE | ATTR_FORCE | ATTR_SIZE)) ==
+			       (ATTR_SIZE | ATTR_MODE)) &&
 	    (((mode & S_ISUID) && !(attr->ia_mode & S_ISUID)) ||
-	     (((mode & (S_ISGID|S_IXGRP)) == (S_ISGID|S_IXGRP)) &&
+	     (((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) &&
 	      !(attr->ia_mode & S_ISGID))))
 		attr->ia_valid |= ATTR_FORCE;
 
@@ -1350,7 +1351,7 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 		attr->ia_valid |= ATTR_KILL_SUID;
 
 	if ((attr->ia_valid & ATTR_MODE) &&
-	    ((mode & (S_ISGID|S_IXGRP)) == (S_ISGID|S_IXGRP)) &&
+	    ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) &&
 	    !(attr->ia_mode & S_ISGID) &&
 	    !(attr->ia_valid & ATTR_KILL_SGID))
 		attr->ia_valid |= ATTR_KILL_SGID;
@@ -1517,9 +1518,11 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 		lli->lli_ctime = body->ctime;
 	}
 	if (body->valid & OBD_MD_FLMODE)
-		inode->i_mode = (inode->i_mode & S_IFMT)|(body->mode & ~S_IFMT);
+		inode->i_mode = (inode->i_mode & S_IFMT) |
+				(body->mode & ~S_IFMT);
 	if (body->valid & OBD_MD_FLTYPE)
-		inode->i_mode = (inode->i_mode & ~S_IFMT)|(body->mode & S_IFMT);
+		inode->i_mode = (inode->i_mode & ~S_IFMT) |
+				(body->mode & S_IFMT);
 	LASSERT(inode->i_mode != 0);
 	if (S_ISREG(inode->i_mode))
 		inode->i_blkbits = min(PTLRPC_MAX_BRW_BITS + 1,
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 66ee5db..9d03e79 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -126,7 +126,7 @@ restart:
 
 	fio = &io->u.ci_fault;
 	fio->ft_index      = index;
-	fio->ft_executable = vma->vm_flags&VM_EXEC;
+	fio->ft_executable = vma->vm_flags & VM_EXEC;
 
 	/*
 	 * disable VM_SEQ_READ and use VM_RAND_READ to make sure that
@@ -134,7 +134,7 @@ restart:
 	 * filemap_nopage. we do our readahead in ll_readpage.
 	 */
 	if (ra_flags)
-		*ra_flags = vma->vm_flags & (VM_RAND_READ|VM_SEQ_READ);
+		*ra_flags = vma->vm_flags & (VM_RAND_READ | VM_SEQ_READ);
 	vma->vm_flags &= ~VM_SEQ_READ;
 	vma->vm_flags |= VM_RAND_READ;
 
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index e86bf3c..7c43604 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -893,17 +893,17 @@ static const struct llite_file_opcode {
 	/* file operation */
 	{ LPROC_LL_DIRTY_HITS,     LPROCFS_TYPE_REGS, "dirty_pages_hits" },
 	{ LPROC_LL_DIRTY_MISSES,   LPROCFS_TYPE_REGS, "dirty_pages_misses" },
-	{ LPROC_LL_READ_BYTES,     LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_BYTES,
+	{ LPROC_LL_READ_BYTES,     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "read_bytes" },
-	{ LPROC_LL_WRITE_BYTES,    LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_BYTES,
+	{ LPROC_LL_WRITE_BYTES,    LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "write_bytes" },
-	{ LPROC_LL_BRW_READ,       LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_PAGES,
+	{ LPROC_LL_BRW_READ,       LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
 				   "brw_read" },
-	{ LPROC_LL_BRW_WRITE,      LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_PAGES,
+	{ LPROC_LL_BRW_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
 				   "brw_write" },
-	{ LPROC_LL_OSC_READ,       LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_BYTES,
+	{ LPROC_LL_OSC_READ,       LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "osc_read" },
-	{ LPROC_LL_OSC_WRITE,      LPROCFS_CNTR_AVGMINMAX|LPROCFS_TYPE_BYTES,
+	{ LPROC_LL_OSC_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "osc_write" },
 	{ LPROC_LL_IOCTL,	  LPROCFS_TYPE_REGS, "ioctl" },
 	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
@@ -1150,7 +1150,7 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 			   r, pct(r, read_tot), pct(read_cum, read_tot),
 			   w, pct(w, write_tot), pct(write_cum, write_tot));
 		start = end;
-		if (start == 1<<10) {
+		if (start == 1 << 10) {
 			start = 1;
 			units += 10;
 			unitp++;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 8350943..b4810a6 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -549,7 +549,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	    (inode_permission(parent, MAY_WRITE | MAY_EXEC) == 0))
 		return NULL;
 
-	if (flags & (LOOKUP_PARENT|LOOKUP_OPEN|LOOKUP_CREATE))
+	if (flags & (LOOKUP_PARENT | LOOKUP_OPEN | LOOKUP_CREATE))
 		itp = NULL;
 	else
 		itp = &it;
@@ -965,7 +965,7 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 
 	if (!IS_POSIXACL(dir) || !exp_connect_umask(ll_i2mdexp(dir)))
 		mode &= ~current_umask();
-	mode = (mode & (S_IRWXUGO|S_ISVTX)) | S_IFDIR;
+	mode = (mode & (S_IRWXUGO | S_ISVTX)) | S_IFDIR;
 	err = ll_new_node(dir, dentry, NULL, mode, 0, LUSTRE_OPC_MKDIR);
 
 	if (!err)
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 87393c4..5a799dc 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -651,7 +651,8 @@ static void ras_update_stride_detector(struct ll_readahead_state *ras,
 	if (!stride_io_mode(ras) && (stride_gap != 0 ||
 	    ras->ras_consecutive_stride_requests == 0)) {
 		ras->ras_stride_pages = ras->ras_consecutive_pages;
-		ras->ras_stride_length = stride_gap+ras->ras_consecutive_pages;
+		ras->ras_stride_length = ras->ras_consecutive_pages +
+					 stride_gap;
 	}
 	LASSERT(ras->ras_request_index == 0);
 	LASSERT(ras->ras_consecutive_stride_requests == 0);
@@ -663,7 +664,7 @@ static void ras_update_stride_detector(struct ll_readahead_state *ras,
 	}
 
 	ras->ras_stride_pages = ras->ras_consecutive_pages;
-	ras->ras_stride_length = stride_gap+ras->ras_consecutive_pages;
+	ras->ras_stride_length = stride_gap + ras->ras_consecutive_pages;
 
 	RAS_CDEBUG(ras);
 	return;
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index d98c7ac..3c35c09 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -161,7 +161,7 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	return result;
 }
 
-#define MAX_DIRECTIO_SIZE (2*1024*1024*1024UL)
+#define MAX_DIRECTIO_SIZE (2 * 1024 * 1024 * 1024UL)
 
 static inline int ll_get_user_pages(int rw, unsigned long user_addr,
 				    size_t size, struct page ***pages,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 3dd7e0e..883084e 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -102,8 +102,8 @@ static int __init lustre_init(void)
 
 	rc = -ENOMEM;
 	ll_inode_cachep = kmem_cache_create("lustre_inode_cache",
-					    sizeof(struct ll_inode_info),
-					    0, SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
+					    sizeof(struct ll_inode_info), 0,
+					    SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
 					    NULL);
 	if (!ll_inode_cachep)
 		goto out_cache;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 2c520b0..e4080ba 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -120,7 +120,7 @@ static int vvp_attr_set(const struct lu_env *env, struct cl_object *obj,
 	if (0 && valid & CAT_SIZE)
 		i_size_write(inode, attr->cat_size);
 	/* not currently necessary */
-	if (0 && valid & (CAT_UID|CAT_GID|CAT_SIZE))
+	if (0 && valid & (CAT_UID | CAT_GID | CAT_SIZE))
 		mark_inode_dirty(inode);
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 5053dea..d88b81d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -66,7 +66,8 @@ static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 	}
 
 	if (lmm->lmm_stripe_size == 0 ||
-	    (le32_to_cpu(lmm->lmm_stripe_size)&(LOV_MIN_STRIPE_SIZE-1)) != 0) {
+	    (le32_to_cpu(lmm->lmm_stripe_size) &
+	     (LOV_MIN_STRIPE_SIZE - 1)) != 0) {
 		CERROR("bad stripe size %u\n",
 		       le32_to_cpu(lmm->lmm_stripe_size));
 		lov_dump_lmm_common(D_WARNING, lmm);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9b92d55..bc71e4f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1916,8 +1916,9 @@ inactive_tgt:
 				break;
 			}
 
-			len_mapped_single_call = lcl_fm_ext[ext_count-1].fe_logical -
-				  lun_start + lcl_fm_ext[ext_count - 1].fe_length;
+			len_mapped_single_call =
+				lcl_fm_ext[ext_count - 1].fe_logical -
+				lun_start + lcl_fm_ext[ext_count - 1].fe_length;
 
 			/* Have we finished mapping on this device? */
 			if (req_fm_len <= len_mapped_single_call)
@@ -1926,14 +1927,15 @@ inactive_tgt:
 			/* Clear the EXTENT_LAST flag which can be present on
 			 * last extent
 			 */
-			if (lcl_fm_ext[ext_count-1].fe_flags & FIEMAP_EXTENT_LAST)
+			if (lcl_fm_ext[ext_count - 1].fe_flags &
+			    FIEMAP_EXTENT_LAST)
 				lcl_fm_ext[ext_count - 1].fe_flags &=
 							    ~FIEMAP_EXTENT_LAST;
 
 			curr_loc = lov_stripe_size(lsm,
-					   lcl_fm_ext[ext_count - 1].fe_logical+
-					   lcl_fm_ext[ext_count - 1].fe_length,
-					   cur_stripe);
+					lcl_fm_ext[ext_count - 1].fe_logical +
+					lcl_fm_ext[ext_count - 1].fe_length,
+					cur_stripe);
 			if (curr_loc >= fm_key->oa.o_size)
 				ost_eof = 1;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 4c2d217..639e086 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -92,7 +92,7 @@ static __u32 pool_hashfn(struct cfs_hash *hash_body, const void *key, unsigned m
 	for (i = 0; i < LOV_MAXPOOLNAME; i++) {
 		if (poolname[i] == '\0')
 			break;
-		result = (result << 4)^(result >> 28) ^  poolname[i];
+		result = (result << 4) ^ (result >> 28) ^  poolname[i];
 	}
 	return (result % mask);
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 06a1274..bac7e32 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -274,7 +274,7 @@ static struct ptlrpc_request *mdc_intent_open_pack(struct obd_export *exp,
 			else
 				mode = LCK_PR;
 		} else {
-			if (it->it_flags & (FMODE_WRITE|MDS_OPEN_TRUNC))
+			if (it->it_flags & (FMODE_WRITE | MDS_OPEN_TRUNC))
 				mode = LCK_CW;
 			else if (it->it_flags & __FMODE_EXEC)
 				mode = LCK_PR;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 5dba2c8..c48dc8a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -110,7 +110,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	__u64 bits;
 
 	bits = MDS_INODELOCK_UPDATE;
-	if (op_data->op_attr.ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID))
+	if (op_data->op_attr.ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID))
 		bits |= MDS_INODELOCK_LOOKUP;
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID1) &&
 	    (fid_is_sane(&op_data->op_fid1)) &&
@@ -431,7 +431,8 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT, oldlen + 1);
-	req_capsule_set_size(&req->rq_pill, &RMF_SYMTGT, RCL_CLIENT, newlen+1);
+	req_capsule_set_size(&req->rq_pill, &RMF_SYMTGT, RCL_CLIENT,
+			     newlen + 1);
 
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index 8acf672..0bd4ad2 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -48,10 +48,10 @@ int block_debug_setup(void *addr, int len, __u64 off, __u64 id)
 	LASSERT(addr);
 
 	put_unaligned_le64(off, addr);
-	put_unaligned_le64(id, addr+LPDS);
+	put_unaligned_le64(id, addr + LPDS);
 	addr += len - LPDS - LPDS;
 	put_unaligned_le64(off, addr);
-	put_unaligned_le64(id, addr+LPDS);
+	put_unaligned_le64(id, addr + LPDS);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 99c2da6..47c6420 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -509,7 +509,7 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid, int *next)
 			continue;
 		if (obd_uuid_equals(grp_uuid, &obd->obd_uuid)) {
 			if (next)
-				*next = i+1;
+				*next = i + 1;
 			read_unlock(&obd_dev_lock);
 			return obd;
 		}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 0eab123..8daf16e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1317,33 +1317,33 @@ static int class_config_parse_rec(struct llog_rec_hdr *rec, char *buf,
 	if (rc < 0)
 		return rc;
 
-	ptr += snprintf(ptr, end-ptr, "cmd=%05x ", lcfg->lcfg_command);
+	ptr += snprintf(ptr, end - ptr, "cmd=%05x ", lcfg->lcfg_command);
 	if (lcfg->lcfg_flags)
-		ptr += snprintf(ptr, end-ptr, "flags=%#08x ",
+		ptr += snprintf(ptr, end - ptr, "flags=%#08x ",
 				lcfg->lcfg_flags);
 
 	if (lcfg->lcfg_num)
-		ptr += snprintf(ptr, end-ptr, "num=%#08x ", lcfg->lcfg_num);
+		ptr += snprintf(ptr, end - ptr, "num=%#08x ", lcfg->lcfg_num);
 
 	if (lcfg->lcfg_nid) {
 		char nidstr[LNET_NIDSTR_SIZE];
 
 		libcfs_nid2str_r(lcfg->lcfg_nid, nidstr, sizeof(nidstr));
-		ptr += snprintf(ptr, end-ptr, "nid=%s(%#llx)\n     ",
+		ptr += snprintf(ptr, end - ptr, "nid=%s(%#llx)\n     ",
 				nidstr, lcfg->lcfg_nid);
 	}
 
 	if (lcfg->lcfg_command == LCFG_MARKER) {
 		struct cfg_marker *marker = lustre_cfg_buf(lcfg, 1);
 
-		ptr += snprintf(ptr, end-ptr, "marker=%d(%#x)%s '%s'",
+		ptr += snprintf(ptr, end - ptr, "marker=%d(%#x)%s '%s'",
 				marker->cm_step, marker->cm_flags,
 				marker->cm_tgtname, marker->cm_comment);
 	} else {
 		int i;
 
 		for (i = 0; i <  lcfg->lcfg_bufcount; i++) {
-			ptr += snprintf(ptr, end-ptr, "%d:%s  ", i,
+			ptr += snprintf(ptr, end - ptr, "%d:%s  ", i,
 					lustre_cfg_string(lcfg, i));
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index aa84a50e..cb85ad5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -37,7 +37,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
-#define D_MOUNT (D_SUPER|D_CONFIG/*|D_WARNING */)
+#define D_MOUNT (D_SUPER | D_CONFIG/*|D_WARNING */)
 #define PRINT_CMD CDEBUG
 
 #include "../include/obd.h"
@@ -758,7 +758,7 @@ static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 			exclude_list[lmd->lmd_exclude_count++] = index;
 		else
 			CDEBUG(D_MOUNT, "ignoring exclude %.*s: type = %#x\n",
-			       (uint)(s2-s1), s1, rc);
+			       (uint)(s2 - s1), s1, rc);
 		s1 = s2;
 		/* now we are pointing at ':' (next exclude)
 		 * or ',' (end of excludes)
@@ -1097,7 +1097,7 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 	struct lustre_sb_info *lsi;
 	int rc;
 
-	CDEBUG(D_MOUNT|D_VFSTRACE, "VFS Op: sb %p\n", sb);
+	CDEBUG(D_MOUNT | D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
 	lsi = lustre_init_lsi(sb);
 	if (!lsi)
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 8583a4a..6c833af 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -152,12 +152,14 @@ static void iattr_from_obdo(struct iattr *attr, struct obdo *oa, u32 valid)
 	}
 #if 0   /* you shouldn't be able to change a file's type with setattr */
 	if (valid & OBD_MD_FLTYPE) {
-		attr->ia_mode = (attr->ia_mode & ~S_IFMT)|(oa->o_mode & S_IFMT);
+		attr->ia_mode = (attr->ia_mode & ~S_IFMT) |
+				(oa->o_mode & S_IFMT);
 		attr->ia_valid |= ATTR_MODE;
 	}
 #endif
 	if (valid & OBD_MD_FLMODE) {
-		attr->ia_mode = (attr->ia_mode & S_IFMT)|(oa->o_mode & ~S_IFMT);
+		attr->ia_mode = (attr->ia_mode & S_IFMT) |
+				(oa->o_mode & ~S_IFMT);
 		attr->ia_valid |= ATTR_MODE;
 		if (!in_group_p(make_kgid(&init_user_ns, oa->o_gid)) &&
 		    !capable(CFS_CAP_FSETID))
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
index f5034a2..966414f 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_internal.h
+++ b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
@@ -33,9 +33,9 @@
 
 /* The persistent object (i.e. actually stores stuff!) */
 #define ECHO_PERSISTENT_OBJID    1ULL
-#define ECHO_PERSISTENT_SIZE     ((__u64)(1<<20))
+#define ECHO_PERSISTENT_SIZE     ((__u64)(1 << 20))
 
 /* block size to use for data verification */
-#define OBD_ECHO_BLOCK_SIZE	(4<<10)
+#define OBD_ECHO_BLOCK_SIZE	(4 << 10)
 
 #endif
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 53b5d73..1978a85 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2643,7 +2643,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 		goto out;
 
 	spin_lock(&oap->oap_lock);
-	oap->oap_async_flags |= ASYNC_READY|ASYNC_URGENT;
+	oap->oap_async_flags |= ASYNC_READY | ASYNC_URGENT;
 	spin_unlock(&oap->oap_lock);
 
 	if (memory_pressure_get())
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c8c3f1c..d41680b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -389,7 +389,7 @@ extern struct lu_device_type osc_device_type;
 extern struct lu_context_key osc_key;
 extern struct lu_context_key osc_session_key;
 
-#define OSC_FLAGS (ASYNC_URGENT|ASYNC_READY)
+#define OSC_FLAGS (ASYNC_URGENT | ASYNC_READY)
 
 int osc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 6e3dcd3..7ed1449 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -165,7 +165,7 @@ static int osc_io_submit(const struct lu_env *env,
 
 		cl_page_list_move(qout, qin, page);
 		spin_lock(&oap->oap_lock);
-		oap->oap_async_flags = ASYNC_URGENT|ASYNC_READY;
+		oap->oap_async_flags = ASYNC_URGENT | ASYNC_READY;
 		oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 		spin_unlock(&oap->oap_lock);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 536b868..4161718 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -794,7 +794,7 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 				long writing_bytes)
 {
-	u32 bits = OBD_MD_FLBLOCKS|OBD_MD_FLGRANT;
+	u32 bits = OBD_MD_FLBLOCKS | OBD_MD_FLGRANT;
 
 	LASSERT(!(oa->o_valid & bits));
 
@@ -827,7 +827,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		oa->o_undirty = 0;
 	} else {
 		long max_in_flight = (cli->cl_max_pages_per_rpc <<
-				      PAGE_SHIFT)*
+				      PAGE_SHIFT) *
 				     (cli->cl_max_rpcs_in_flight + 1);
 		oa->o_undirty = max(cli->cl_dirty_max, max_in_flight);
 	}
@@ -1463,7 +1463,8 @@ static int check_write_checksum(struct obdo *oa, const lnet_process_id_t *peer,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
 			   POSTID(&oa->o_oi), pga[0]->off,
-			   pga[page_count-1]->off + pga[page_count-1]->count - 1);
+			   pga[page_count - 1]->off +
+			   pga[page_count - 1]->count - 1);
 	CERROR("original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
 	       client_cksum, client_cksum_type,
 	       server_cksum, cksum_type, new_cksum);
@@ -1565,7 +1566,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		char *router = "";
 		enum cksum_type cksum_type;
 
-		cksum_type = cksum_type_unpack(body->oa.o_valid&OBD_MD_FLFLAGS ?
+		cksum_type = cksum_type_unpack(body->oa.o_valid &
+					       OBD_MD_FLFLAGS ?
 					       body->oa.o_flags : 0);
 		client_cksum = osc_checksum_bulk(rc, aa->aa_page_count,
 						 aa->aa_ppga, OST_READ,
@@ -1998,7 +2000,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	crattr->cra_oa = &body->oa;
 	cl_req_attr_set(env, clerq, crattr,
-			OBD_MD_FLMTIME|OBD_MD_FLCTIME|OBD_MD_FLATIME);
+			OBD_MD_FLMTIME | OBD_MD_FLCTIME | OBD_MD_FLATIME);
 
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 3292e6e..95056ed 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -307,7 +307,8 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 		 */
 		lwi = LWI_TIMEOUT_INTERVAL(
 			cfs_timeout_cap(cfs_time_seconds(timeout)),
-			(timeout > 1)?cfs_time_seconds(1):cfs_time_seconds(1)/2,
+			(timeout > 1) ? cfs_time_seconds(1) :
+			cfs_time_seconds(1) / 2,
 			NULL, NULL);
 		rc = l_wait_event(imp->imp_recovery_waitq,
 				  (atomic_read(&imp->imp_inflight) == 0),
@@ -698,7 +699,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	request->rq_send_state = LUSTRE_IMP_CONNECTING;
 	/* Allow a slightly larger reply for future growth compatibility */
 	req_capsule_set_size(&request->rq_pill, &RMF_CONNECT_DATA, RCL_SERVER,
-			     sizeof(struct obd_connect_data)+16*sizeof(__u64));
+			     sizeof(struct obd_connect_data) +
+			     16 * sizeof(__u64));
 	ptlrpc_request_set_replen(request);
 	request->rq_interpret_reply = ptlrpc_connect_interpret;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index bc93b75..327cf63 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -191,7 +191,7 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 	LASSERT(!*debugfs_root_ret);
 	LASSERT(!*stats_ret);
 
-	svc_stats = lprocfs_alloc_stats(EXTRA_MAX_OPCODES+LUSTRE_MAX_OPCODES,
+	svc_stats = lprocfs_alloc_stats(EXTRA_MAX_OPCODES + LUSTRE_MAX_OPCODES,
 					0);
 	if (!svc_stats)
 		return;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 0a374b6..1f55d64 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -412,7 +412,7 @@ static int ptlrpcd(void *arg)
 	 * an argument, describing its "scope".
 	 */
 	rc = lu_context_init(&env.le_ctx,
-			     LCT_CL_THREAD|LCT_REMEMBER|LCT_NOREF);
+			     LCT_CL_THREAD | LCT_REMEMBER | LCT_NOREF);
 	if (rc == 0) {
 		rc = lu_context_init(env.le_ses,
 				     LCT_SESSION | LCT_REMEMBER | LCT_NOREF);
@@ -567,7 +567,7 @@ int ptlrpcd_start(struct ptlrpcd_ctl *pc)
 	 * ptlrpcd thread (or a thread-set) has to be given an argument,
 	 * describing its "scope".
 	 */
-	rc = lu_context_init(&pc->pc_env.le_ctx, LCT_CL_THREAD|LCT_REMEMBER);
+	rc = lu_context_init(&pc->pc_env.le_ctx, LCT_CL_THREAD | LCT_REMEMBER);
 	if (rc != 0)
 		goto out;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 4788c49..998e5de 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2049,7 +2049,7 @@ static int ptlrpc_main(void *arg)
 	}
 
 	rc = lu_context_init(&env->le_ctx,
-			     svc->srv_ctx_tags|LCT_REMEMBER|LCT_NOREF);
+			     svc->srv_ctx_tags | LCT_REMEMBER | LCT_NOREF);
 	if (rc)
 		goto out_srv_fini;
 
-- 
2.7.4
