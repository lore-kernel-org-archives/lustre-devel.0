From: Oleg Drokin <oleg.drokin@intel.com>
Date: Sun, 19 Jun 2016 23:44:41 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: remove remote client
	support
In-Reply-To: <1466391233-4230-1-git-send-email-jsimmons@infradead.org>
References: <1466391233-4230-1-git-send-email-jsimmons@infradead.org>
Message-ID: <CCCC565B-A280-41E0-A9A8-25320751076E@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jun 19, 2016, at 10:53 PM, James Simmons wrote:

> From: Fan Yong <fan.yong@intel.com>
> 
> There are several obsolete sub commands for lfs to work with
> remote client. We do not support that anymore, and should be
> deleted along with any kernel code related to remote client.

I wish you reworked this message to say that it removes
remote something or other that's no longer in use.

I am not sure why Greag or kernel guys would care for lctl
commands, esp. considering those are not even part of this patch.

> Signed-off-by: Fan Yong <fan.yong@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6971
> Reviewed-on: http://review.whamcloud.com/19789
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Lai Siyao <lai.siyao@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> .../lustre/lustre/include/lustre/lustre_idl.h      |   40 +--
> .../lustre/lustre/include/lustre/lustre_user.h     |   15 +-
> .../staging/lustre/lustre/include/lustre_eacl.h    |   11 -
> .../staging/lustre/lustre/include/lustre_export.h  |   13 -
> drivers/staging/lustre/lustre/include/lustre_net.h |    1 -
> .../lustre/lustre/include/lustre_req_layout.h      |    2 +-
> drivers/staging/lustre/lustre/include/obd.h        |    3 -
> drivers/staging/lustre/lustre/include/obd_class.h  |   10 -
> drivers/staging/lustre/lustre/llite/Makefile       |    3 +-
> drivers/staging/lustre/lustre/llite/dir.c          |   29 +--
> drivers/staging/lustre/lustre/llite/file.c         |   15 -
> .../staging/lustre/lustre/llite/llite_internal.h   |   88 +----
> drivers/staging/lustre/lustre/llite/llite_lib.c    |   69 +---
> drivers/staging/lustre/lustre/llite/llite_rmtacl.c |  295 --------------
> drivers/staging/lustre/lustre/llite/lproc_llite.c  |    6 +-
> drivers/staging/lustre/lustre/llite/remote_perm.c  |  320 ---------------
> drivers/staging/lustre/lustre/llite/super25.c      |   19 -
> drivers/staging/lustre/lustre/llite/xattr.c        |   97 +-----
> drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   22 -
> drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   21 +-
> drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 +-
> drivers/staging/lustre/lustre/mdc/mdc_request.c    |   76 +----
> drivers/staging/lustre/lustre/obdclass/Makefile    |    3 +-
> drivers/staging/lustre/lustre/obdclass/acl.c       |  411 --------------------
> drivers/staging/lustre/lustre/osc/osc_cache.c      |    5 +-
> drivers/staging/lustre/lustre/osc/osc_page.c       |    4 +-
> drivers/staging/lustre/lustre/ptlrpc/layout.c      |   12 +-
> .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   13 -
> drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   48 ---
> 29 files changed, 55 insertions(+), 1598 deletions(-)
> delete mode 100644 drivers/staging/lustre/lustre/llite/llite_rmtacl.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/remote_perm.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/acl.c
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index fac7215..051864c 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -1237,8 +1237,16 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
> 						  */
> #define OBD_CONNECT_ATTRFID	       0x4000ULL /*Server can GetAttr By Fid*/
> #define OBD_CONNECT_NODEVOH	       0x8000ULL /*No open hndl on specl nodes*/
> -#define OBD_CONNECT_RMT_CLIENT	      0x10000ULL /*Remote client */
> -#define OBD_CONNECT_RMT_CLIENT_FORCE  0x20000ULL /*Remote client by force */
> +#define OBD_CONNECT_RMT_CLIENT	      0x10000ULL /* Remote client, never used
> +						  * in production. Removed in
> +						  * 2.9. Keep this flag to
> +						  * avoid reuse.
> +						  */
> +#define OBD_CONNECT_RMT_CLIENT_FORCE  0x20000ULL /* Remote client by force,
> +						  * never used in production.
> +						  * Removed in 2.9. Keep this
> +						  * flag to avoid reuse
> +						  */
> #define OBD_CONNECT_BRW_SIZE	      0x40000ULL /*Max bytes per rpc */
> #define OBD_CONNECT_QUOTA64	      0x80000ULL /*Not used since 2.4 */
> #define OBD_CONNECT_MDS_CAPA	     0x100000ULL /*MDS capability */
> @@ -1699,7 +1707,7 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
> #define OBD_MD_FLXATTRLS     (0x0000002000000000ULL) /* xattr list */
> #define OBD_MD_FLXATTRRM     (0x0000004000000000ULL) /* xattr remove */
> #define OBD_MD_FLACL	     (0x0000008000000000ULL) /* ACL */
> -#define OBD_MD_FLRMTPERM     (0x0000010000000000ULL) /* remote permission */
> +/*	OBD_MD_FLRMTPERM     (0x0000010000000000ULL) remote perm, obsolete */
> #define OBD_MD_FLMDSCAPA     (0x0000020000000000ULL) /* MDS capability */
> #define OBD_MD_FLOSSCAPA     (0x0000040000000000ULL) /* OSS capability */
> #define OBD_MD_FLCKSPLIT     (0x0000080000000000ULL) /* Check split on server */
> @@ -1711,10 +1719,10 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
> 						      */
> #define OBD_MD_FLOBJCOUNT    (0x0000400000000000ULL) /* for multiple destroy */
> 
> -#define OBD_MD_FLRMTLSETFACL (0x0001000000000000ULL) /* lfs lsetfacl case */
> -#define OBD_MD_FLRMTLGETFACL (0x0002000000000000ULL) /* lfs lgetfacl case */
> -#define OBD_MD_FLRMTRSETFACL (0x0004000000000000ULL) /* lfs rsetfacl case */
> -#define OBD_MD_FLRMTRGETFACL (0x0008000000000000ULL) /* lfs rgetfacl case */
> +/*	OBD_MD_FLRMTLSETFACL (0x0001000000000000ULL) lfs lsetfacl, obsolete */
> +/*	OBD_MD_FLRMTLGETFACL (0x0002000000000000ULL) lfs lgetfacl, obsolete */
> +/*	OBD_MD_FLRMTRSETFACL (0x0004000000000000ULL) lfs rsetfacl, obsolete */
> +/*	OBD_MD_FLRMTRGETFACL (0x0008000000000000ULL) lfs rgetfacl, obsolete */
> 
> #define OBD_MD_FLDATAVERSION (0x0010000000000000ULL) /* iversion sum */
> #define OBD_MD_FLRELEASED    (0x0020000000000000ULL) /* file released */
> @@ -2155,26 +2163,8 @@ enum {
> 	CFS_SETUID_PERM = 0x01,
> 	CFS_SETGID_PERM = 0x02,
> 	CFS_SETGRP_PERM = 0x04,
> -	CFS_RMTACL_PERM = 0x08,
> -	CFS_RMTOWN_PERM = 0x10
> -};
> -
> -/* inode access permission for remote user, the inode info are omitted,
> - * for client knows them.
> - */
> -struct mdt_remote_perm {
> -	__u32	   rp_uid;
> -	__u32	   rp_gid;
> -	__u32	   rp_fsuid;
> -	__u32	   rp_fsuid_h;
> -	__u32	   rp_fsgid;
> -	__u32	   rp_fsgid_h;
> -	__u32	   rp_access_perm; /* MAY_READ/WRITE/EXEC */
> -	__u32	   rp_padding;
> };
> 
> -void lustre_swab_mdt_remote_perm(struct mdt_remote_perm *p);
> -
> struct mdt_rec_setattr {
> 	__u32	   sa_opcode;
> 	__u32	   sa_cap;
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
> index a6e351a..ef6f38f 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
> @@ -211,7 +211,7 @@ struct ost_id {
> #define IOC_OBD_STATFS		  _IOWR('f', 164, struct obd_statfs *)
> #define IOC_LOV_GETINFO		 _IOWR('f', 165, struct lov_user_mds_data *)
> #define LL_IOC_FLUSHCTX		 _IOW('f', 166, long)
> -#define LL_IOC_RMTACL		   _IOW('f', 167, long)
> +/* LL_IOC_RMTACL			167 obsolete */
> #define LL_IOC_GETOBDCOUNT	      _IOR('f', 168, long)
> #define LL_IOC_LLOOP_ATTACH	     _IOWR('f', 169, long)
> #define LL_IOC_LLOOP_DETACH	     _IOWR('f', 170, long)
> @@ -538,19 +538,6 @@ struct identity_downcall_data {
> 	__u32			    idd_groups[0];
> };
> 
> -/* for non-mapped uid/gid */
> -#define NOBODY_UID      99
> -#define NOBODY_GID      99
> -
> -#define INVALID_ID      (-1)
> -
> -enum {
> -	RMT_LSETFACL    = 1,
> -	RMT_LGETFACL    = 2,
> -	RMT_RSETFACL    = 3,
> -	RMT_RGETFACL    = 4
> -};
> -
> /* lustre volatile file support
>  * file name header: .^L^S^T^R:volatile"
>  */
> diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
> index e5eadc4..d1039e1 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
> @@ -66,17 +66,6 @@ typedef struct {
> #define CFS_ACL_XATTR_COUNT(size, prefix) \
> 	(((size) - sizeof(prefix ## _header)) / sizeof(prefix ## _entry))
> 
> -extern ext_acl_xattr_header *
> -lustre_posix_acl_xattr_2ext(posix_acl_xattr_header *header, int size);
> -extern int
> -lustre_posix_acl_xattr_filter(posix_acl_xattr_header *header, size_t size,
> -			      posix_acl_xattr_header **out);
> -extern void
> -lustre_ext_acl_xattr_free(ext_acl_xattr_header *header);
> -extern ext_acl_xattr_header *
> -lustre_acl_xattr_merge2ext(posix_acl_xattr_header *posix_header, int size,
> -			   ext_acl_xattr_header *ext_header);
> -
> #endif /* CONFIG_FS_POSIX_ACL */
> 
> /** @} eacl */
> diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
> index 7c3ed55..6e7cc46 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_export.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_export.h
> @@ -176,19 +176,6 @@ static inline int exp_connect_lru_resize(struct obd_export *exp)
> 	return !!(exp_connect_flags(exp) & OBD_CONNECT_LRU_RESIZE);
> }
> 
> -static inline int exp_connect_rmtclient(struct obd_export *exp)
> -{
> -	return !!(exp_connect_flags(exp) & OBD_CONNECT_RMT_CLIENT);
> -}
> -
> -static inline int client_is_remote(struct obd_export *exp)
> -{
> -	struct obd_import *imp = class_exp2cliimp(exp);
> -
> -	return !!(imp->imp_connect_data.ocd_connect_flags &
> -		  OBD_CONNECT_RMT_CLIENT);
> -}
> -
> static inline int exp_connect_vbr(struct obd_export *exp)
> {
> 	return !!(exp_connect_flags(exp) & OBD_CONNECT_VBR);
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index dba4d1d..bdd2ed5 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -1384,7 +1384,6 @@ struct ptlrpc_request {
> 				 rq_bulk_write:1,    /* request bulk write */
> 				 /* server authentication flags */
> 				 rq_auth_gss:1,      /* authenticated by gss */
> -				 rq_auth_remote:1,   /* authed as remote user */
> 				 rq_auth_usr_root:1, /* authed as root */
> 				 rq_auth_usr_mdt:1,  /* authed as mdt */
> 				 rq_auth_usr_ost:1,  /* authed as ost */
> diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
> index d00aae5..544a43c 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
> @@ -160,7 +160,7 @@ extern struct req_format RQF_MDS_IS_SUBDIR;
> extern struct req_format RQF_MDS_DONE_WRITING;
> extern struct req_format RQF_MDS_REINT;
> extern struct req_format RQF_MDS_REINT_CREATE;
> -extern struct req_format RQF_MDS_REINT_CREATE_RMT_ACL;
> +extern struct req_format RQF_MDS_REINT_CREATE_ACL;
> extern struct req_format RQF_MDS_REINT_CREATE_SLAVE;
> extern struct req_format RQF_MDS_REINT_CREATE_SYM;
> extern struct req_format RQF_MDS_REINT_OPEN;
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index e654d42..9971ee5 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -1115,9 +1115,6 @@ struct md_ops {
> 			     ldlm_policy_data_t *, enum ldlm_mode,
> 			     enum ldlm_cancel_flags flags, void *opaque);
> 
> -	int (*get_remote_perm)(struct obd_export *, const struct lu_fid *,
> -			       __u32, struct ptlrpc_request **);
> -
> 	int (*intent_getattr_async)(struct obd_export *,
> 				    struct md_enqueue_info *,
> 				    struct ldlm_enqueue_info *);
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index 2196744..6482a93 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -1650,16 +1650,6 @@ static inline int md_init_ea_size(struct obd_export *exp, int easize,
> 					       cookiesize, def_cookiesize);
> }
> 
> -static inline int md_get_remote_perm(struct obd_export *exp,
> -				     const struct lu_fid *fid, __u32 suppgid,
> -				     struct ptlrpc_request **request)
> -{
> -	EXP_CHECK_MD_OP(exp, get_remote_perm);
> -	EXP_MD_COUNTER_INCREMENT(exp, get_remote_perm);
> -	return MDP(exp->exp_obd, get_remote_perm)(exp, fid, suppgid,
> -						  request);
> -}
> -
> static inline int md_intent_getattr_async(struct obd_export *exp,
> 					  struct md_enqueue_info *minfo,
> 					  struct ldlm_enqueue_info *einfo)
> diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
> index 19701e7..2cbb1b8 100644
> --- a/drivers/staging/lustre/lustre/llite/Makefile
> +++ b/drivers/staging/lustre/lustre/llite/Makefile
> @@ -1,8 +1,7 @@
> obj-$(CONFIG_LUSTRE_FS) += lustre.o
> lustre-y := dcache.o dir.o file.o llite_close.o llite_lib.o llite_nfs.o \
> 	    rw.o namei.o symlink.o llite_mmap.o \
> -	    xattr.o xattr_cache.o remote_perm.o llite_rmtacl.o \
> -	    rw26.o super25.o statahead.o \
> +	    xattr.o xattr_cache.o rw26.o super25.o statahead.o \
> 	    glimpse.o lcommon_cl.o lcommon_misc.o \
> 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
> 	    lproc_llite.o
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 99735f6..2f2c57e 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -1097,8 +1097,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
> 	case Q_QUOTAOFF:
> 	case Q_SETQUOTA:
> 	case Q_SETINFO:
> -		if (!capable(CFS_CAP_SYS_ADMIN) ||
> -		    sbi->ll_flags & LL_SBI_RMT_CLIENT)
> +		if (!capable(CFS_CAP_SYS_ADMIN))
> 			return -EPERM;
> 		break;
> 	case Q_GETQUOTA:
> @@ -1106,8 +1105,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
> 		      !uid_eq(current_euid(), make_kuid(&init_user_ns, id))) ||
> 		     (type == GRPQUOTA &&
> 		      !in_egroup_p(make_kgid(&init_user_ns, id)))) &&
> -		    (!capable(CFS_CAP_SYS_ADMIN) ||
> -		     sbi->ll_flags & LL_SBI_RMT_CLIENT))
> +		      !capable(CFS_CAP_SYS_ADMIN))
> 			return -EPERM;
> 		break;
> 	case Q_GETINFO:
> @@ -1118,9 +1116,6 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
> 	}
> 
> 	if (valid != QC_GENERAL) {
> -		if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
> -			return -EOPNOTSUPP;
> -
> 		if (cmd == Q_GETINFO)
> 			qctl->qc_cmd = Q_GETOINFO;
> 		else if (cmd == Q_GETQUOTA)
> @@ -1621,8 +1616,7 @@ free_lmm:
> 		struct obd_quotactl *oqctl;
> 		int error = 0;
> 
> -		if (!capable(CFS_CAP_SYS_ADMIN) ||
> -		    sbi->ll_flags & LL_SBI_RMT_CLIENT)
> +		if (!capable(CFS_CAP_SYS_ADMIN))
> 			return -EPERM;
> 
> 		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
> @@ -1645,8 +1639,7 @@ free_lmm:
> 	case OBD_IOC_POLL_QUOTACHECK: {
> 		struct if_quotacheck *check;
> 
> -		if (!capable(CFS_CAP_SYS_ADMIN) ||
> -		    sbi->ll_flags & LL_SBI_RMT_CLIENT)
> +		if (!capable(CFS_CAP_SYS_ADMIN))
> 			return -EPERM;
> 
> 		check = kzalloc(sizeof(*check), GFP_NOFS);
> @@ -1703,20 +1696,6 @@ out_quotactl:
> 		return ll_get_obd_name(inode, cmd, arg);
> 	case LL_IOC_FLUSHCTX:
> 		return ll_flush_ctx(inode);
> -#ifdef CONFIG_FS_POSIX_ACL
> -	case LL_IOC_RMTACL: {
> -		if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
> -			struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
> -
> -			rc = rct_add(&sbi->ll_rct, current_pid(), arg);
> -			if (!rc)
> -				fd->fd_flags |= LL_FILE_RMTACL;
> -			return rc;
> -		} else {
> -			return 0;
> -		}
> -	}
> -#endif
> 	case LL_IOC_GETOBDCOUNT: {
> 		int count, vallen;
> 		struct obd_export *exp;
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index b0c4548..2d50d1c 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -344,18 +344,6 @@ int ll_file_release(struct inode *inode, struct file *file)
> 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
> 	       PFID(ll_inode2fid(inode)), inode);
> 
> -#ifdef CONFIG_FS_POSIX_ACL
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
> -		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
> -
> -		if (unlikely(fd->fd_flags & LL_FILE_RMTACL)) {
> -			fd->fd_flags &= ~LL_FILE_RMTACL;
> -			rct_del(&sbi->ll_rct, current_pid());
> -			et_search_free(&sbi->ll_et, current_pid());
> -		}
> -	}
> -#endif
> -
> 	if (!is_root_inode(inode))
> 		ll_stats_ops_tally(sbi, LPROC_LL_RELEASE, 1);
> 	fd = LUSTRE_FPRIVATE(file);
> @@ -3156,9 +3144,6 @@ int ll_inode_permission(struct inode *inode, int mask)
> 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), inode mode %x mask %o\n",
> 	       PFID(ll_inode2fid(inode)), inode, inode->i_mode, mask);
> 
> -	if (ll_i2sbi(inode)->ll_flags & LL_SBI_RMT_CLIENT)
> -		return lustre_check_remote_perm(inode, mask);
> -
> 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_INODE_PERM, 1);
> 	rc = generic_permission(inode, mask);
> 
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 7c1a325..8fe63bd 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -72,9 +72,6 @@ struct ll_dentry_data {
> #define LLI_INODE_MAGIC		 0x111d0de5
> #define LLI_INODE_DEAD		  0xdeadd00d
> 
> -/* remote client permission cache */
> -#define REMOTE_PERM_HASHSIZE 16
> -
> struct ll_getname_data {
> 	struct dir_context ctx;
> 	char	    *lgd_name;      /* points to a buffer with NAME_MAX+1 size */
> @@ -82,19 +79,6 @@ struct ll_getname_data {
> 	int	      lgd_found;     /* inode matched? */
> };
> 
> -/* llite setxid/access permission for user on remote client */
> -struct ll_remote_perm {
> -	struct hlist_node	lrp_list;
> -	uid_t		   lrp_uid;
> -	gid_t		   lrp_gid;
> -	uid_t		   lrp_fsuid;
> -	gid_t		   lrp_fsgid;
> -	int		   lrp_access_perm; /* MAY_READ/WRITE/EXEC, this
> -					     * is access permission with
> -					     * lrp_fsuid/lrp_fsgid.
> -					     */
> -};
> -
> struct ll_grouplock {
> 	struct lu_env	*lg_env;
> 	struct cl_io	*lg_io;
> @@ -129,9 +113,6 @@ struct ll_inode_info {
> 	spinlock_t			lli_lock;
> 	struct posix_acl		*lli_posix_acl;
> 
> -	struct hlist_head		*lli_remote_perms;
> -	struct mutex				lli_rmtperm_mutex;
> -
> 	/* identifying fields for both metadata and data stacks. */
> 	struct lu_fid		   lli_fid;
> 	/* Parent fid for accessing default stripe data on parent directory
> @@ -141,8 +122,6 @@ struct ll_inode_info {
> 
> 	struct list_head	      lli_close_list;
> 
> -	unsigned long		      lli_rmtperm_time;
> -
> 	/* handle is to be sent to MDS later on done_writing and setattr.
> 	 * Open handle data are needed for the recovery to reconstruct
> 	 * the inode state on the MDS. XXX: recovery is not ready yet.
> @@ -407,7 +386,7 @@ enum stats_track_type {
> #define LL_SBI_FLOCK	     0x04
> #define LL_SBI_USER_XATTR	0x08 /* support user xattr */
> #define LL_SBI_ACL	       0x10 /* support ACL */
> -#define LL_SBI_RMT_CLIENT	0x40 /* remote client */
> +/* LL_SBI_RMT_CLIENT		 0x40	 remote client */
> #define LL_SBI_MDS_CAPA		 0x80 /* support mds capa, obsolete */
> #define LL_SBI_OSS_CAPA		0x100 /* support oss capa, obsolete */
> #define LL_SBI_LOCALFLOCK       0x200 /* Local flocks support by kernel */
> @@ -429,7 +408,7 @@ enum stats_track_type {
> 	"xattr",	\
> 	"acl",		\
> 	"???",		\
> -	"rmt_client",	\
> +	"???",		\
> 	"mds_capa",	\
> 	"oss_capa",	\
> 	"flock",	\
> @@ -445,26 +424,6 @@ enum stats_track_type {
> 	"xattr",	\
> }
> 
> -#define RCE_HASHES      32
> -
> -struct rmtacl_ctl_entry {
> -	struct list_head       rce_list;
> -	pid_t	    rce_key; /* hash key */
> -	int	      rce_ops; /* acl operation type */
> -};
> -
> -struct rmtacl_ctl_table {
> -	spinlock_t	rct_lock;
> -	struct list_head	rct_entries[RCE_HASHES];
> -};
> -
> -#define EE_HASHES       32
> -
> -struct eacl_table {
> -	spinlock_t	et_lock;
> -	struct list_head	et_entries[EE_HASHES];
> -};
> -
> struct ll_sb_info {
> 	/* this protects pglist and ra_info.  It isn't safe to
> 	 * grab from interrupt contexts
> @@ -529,8 +488,6 @@ struct ll_sb_info {
> 	dev_t			  ll_sdev_orig; /* save s_dev before assign for
> 						 * clustered nfs
> 						 */
> -	struct rmtacl_ctl_table   ll_rct;
> -	struct eacl_table	 ll_et;
> 	__kernel_fsid_t		  ll_fsid;
> 	struct kobject		 ll_kobj; /* sysfs object */
> 	struct super_block	*ll_sb; /* struct super_block (for sysfs code)*/
> @@ -982,14 +939,6 @@ ssize_t ll_getxattr(struct dentry *dentry, struct inode *inode,
> ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
> int ll_removexattr(struct dentry *dentry, const char *name);
> 
> -/* llite/remote_perm.c */
> -extern struct kmem_cache *ll_remote_perm_cachep;
> -extern struct kmem_cache *ll_rmtperm_hash_cachep;
> -
> -void free_rmtperm_hash(struct hlist_head *hash);
> -int ll_update_remote_perm(struct inode *inode, struct mdt_remote_perm *perm);
> -int lustre_check_remote_perm(struct inode *inode, int mask);
> -
> /**
>  * Common IO arguments for various VFS I/O interfaces.
>  */
> @@ -1003,40 +952,7 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
> void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len);
> void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
> 
> -/* llite/llite_rmtacl.c */
> -#ifdef CONFIG_FS_POSIX_ACL
> -struct eacl_entry {
> -	struct list_head	    ee_list;
> -	pid_t		 ee_key; /* hash key */
> -	struct lu_fid	 ee_fid;
> -	int		   ee_type; /* ACL type for ACCESS or DEFAULT */
> -	ext_acl_xattr_header *ee_acl;
> -};
> -
> -u64 rce_ops2valid(int ops);
> -struct rmtacl_ctl_entry *rct_search(struct rmtacl_ctl_table *rct, pid_t key);
> -int rct_add(struct rmtacl_ctl_table *rct, pid_t key, int ops);
> -int rct_del(struct rmtacl_ctl_table *rct, pid_t key);
> -void rct_init(struct rmtacl_ctl_table *rct);
> -void rct_fini(struct rmtacl_ctl_table *rct);
> -
> -void ee_free(struct eacl_entry *ee);
> -int ee_add(struct eacl_table *et, pid_t key, struct lu_fid *fid, int type,
> -	   ext_acl_xattr_header *header);
> -struct eacl_entry *et_search_del(struct eacl_table *et, pid_t key,
> -				 struct lu_fid *fid, int type);
> -void et_search_free(struct eacl_table *et, pid_t key);
> -void et_init(struct eacl_table *et);
> -void et_fini(struct eacl_table *et);
> -#else
> -static inline u64 rce_ops2valid(int ops)
> -{
> -	return 0;
> -}
> -#endif
> -
> /* statahead.c */
> -
> #define LL_SA_RPC_MIN	   2
> #define LL_SA_RPC_DEF	   32
> #define LL_SA_RPC_MAX	   8192
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index ac833db..ae6a571 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -171,8 +171,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 				  OBD_CONNECT_VERSION  | OBD_CONNECT_BRW_SIZE |
> 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID     |
> 				  OBD_CONNECT_AT       | OBD_CONNECT_LOV_V3   |
> -				  OBD_CONNECT_RMT_CLIENT | OBD_CONNECT_VBR    |
> -				  OBD_CONNECT_FULL20   | OBD_CONNECT_64BITHASH|
> +				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20  |
> +				  OBD_CONNECT_64BITHASH |
> 				  OBD_CONNECT_EINPROGRESS |
> 				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
> 				  OBD_CONNECT_LAYOUTLOCK |
> @@ -213,8 +213,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 
> 	/* real client */
> 	data->ocd_connect_flags |= OBD_CONNECT_REAL;
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
> -		data->ocd_connect_flags |= OBD_CONNECT_RMT_CLIENT_FORCE;
> 
> 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
> 
> @@ -307,18 +305,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 		sbi->ll_flags &= ~LL_SBI_ACL;
> 	}
> 
> -	if (data->ocd_connect_flags & OBD_CONNECT_RMT_CLIENT) {
> -		if (!(sbi->ll_flags & LL_SBI_RMT_CLIENT)) {
> -			sbi->ll_flags |= LL_SBI_RMT_CLIENT;
> -			LCONSOLE_INFO("client is set as remote by default.\n");
> -		}
> -	} else {
> -		if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
> -			sbi->ll_flags &= ~LL_SBI_RMT_CLIENT;
> -			LCONSOLE_INFO("client claims to be remote, but server rejected, forced to be local.\n");
> -		}
> -	}
> -
> 	if (data->ocd_connect_flags & OBD_CONNECT_64BITHASH)
> 		sbi->ll_flags |= LL_SBI_64BIT_HASH;
> 
> @@ -352,10 +338,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 				  OBD_CONNECT_REQPORTAL | OBD_CONNECT_BRW_SIZE |
> 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
> 				  OBD_CONNECT_SRVLOCK   | OBD_CONNECT_TRUNCLOCK|
> -				  OBD_CONNECT_AT | OBD_CONNECT_RMT_CLIENT |
> -				  OBD_CONNECT_OSS_CAPA | OBD_CONNECT_VBR|
> -				  OBD_CONNECT_FULL20 | OBD_CONNECT_64BITHASH |
> -				  OBD_CONNECT_MAXBYTES |
> +				  OBD_CONNECT_AT	| OBD_CONNECT_OSS_CAPA |
> +				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
> +				  OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES |
> 				  OBD_CONNECT_EINPROGRESS |
> 				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
> 				  OBD_CONNECT_LAYOUTLOCK | OBD_CONNECT_PINGLESS;
> @@ -378,8 +363,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 	}
> 
> 	data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
> -		data->ocd_connect_flags |= OBD_CONNECT_RMT_CLIENT_FORCE;
> 
> 	CDEBUG(D_RPCTRACE, "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d\n",
> 	       data->ocd_connect_flags,
> @@ -442,9 +425,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 	 * XXX: move this to after cbd setup?
> 	 */
> 	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS | OBD_MD_FLMODEASIZE;
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
> -		valid |= OBD_MD_FLRMTPERM;
> -	else if (sbi->ll_flags & LL_SBI_ACL)
> +	if (sbi->ll_flags & LL_SBI_ACL)
> 		valid |= OBD_MD_FLACL;
> 
> 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
> @@ -500,13 +481,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
> 		goto out_root;
> 	}
> 
> -#ifdef CONFIG_FS_POSIX_ACL
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
> -		rct_init(&sbi->ll_rct);
> -		et_init(&sbi->ll_et);
> -	}
> -#endif
> -
> 	checksum = sbi->ll_flags & LL_SBI_CHECKSUM;
> 	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
> 				 KEY_CHECKSUM, sizeof(checksum), &checksum,
> @@ -604,13 +578,6 @@ static void client_common_put_super(struct super_block *sb)
> {
> 	struct ll_sb_info *sbi = ll_s2sbi(sb);
> 
> -#ifdef CONFIG_FS_POSIX_ACL
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
> -		et_fini(&sbi->ll_et);
> -		rct_fini(&sbi->ll_rct);
> -	}
> -#endif
> -
> 	ll_close_thread_shutdown(sbi->ll_lcq);
> 
> 	cl_sb_fini(sb);
> @@ -700,11 +667,6 @@ static int ll_options(char *options, int *flags)
> 			*flags &= ~tmp;
> 			goto next;
> 		}
> -		tmp = ll_set_opt("remote_client", s1, LL_SBI_RMT_CLIENT);
> -		if (tmp) {
> -			*flags |= tmp;
> -			goto next;
> -		}
> 		tmp = ll_set_opt("user_fid2path", s1, LL_SBI_USER_FID2PATH);
> 		if (tmp) {
> 			*flags |= tmp;
> @@ -788,12 +750,9 @@ void ll_lli_init(struct ll_inode_info *lli)
> 	lli->lli_maxbytes = MAX_LFS_FILESIZE;
> 	spin_lock_init(&lli->lli_lock);
> 	lli->lli_posix_acl = NULL;
> -	lli->lli_remote_perms = NULL;
> -	mutex_init(&lli->lli_rmtperm_mutex);
> 	/* Do not set lli_fid, it has been initialized already. */
> 	fid_zero(&lli->lli_pfid);
> 	INIT_LIST_HEAD(&lli->lli_close_list);
> -	lli->lli_rmtperm_time = 0;
> 	lli->lli_pending_och = NULL;
> 	lli->lli_mds_read_och = NULL;
> 	lli->lli_mds_write_och = NULL;
> @@ -1075,17 +1034,9 @@ void ll_clear_inode(struct inode *inode)
> 
> 	ll_xattr_cache_destroy(inode);
> 
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
> -		LASSERT(!lli->lli_posix_acl);
> -		if (lli->lli_remote_perms) {
> -			free_rmtperm_hash(lli->lli_remote_perms);
> -			lli->lli_remote_perms = NULL;
> -		}
> -	}
> #ifdef CONFIG_FS_POSIX_ACL
> -	else if (lli->lli_posix_acl) {
> +	if (lli->lli_posix_acl) {
> 		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
> -		LASSERT(!lli->lli_remote_perms);
> 		posix_acl_release(lli->lli_posix_acl);
> 		lli->lli_posix_acl = NULL;
> 	}
> @@ -1537,12 +1488,8 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
> 			lli->lli_maxbytes = MAX_LFS_FILESIZE;
> 	}
> 
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
> -		if (body->valid & OBD_MD_FLRMTPERM)
> -			ll_update_remote_perm(inode, md->remote_perm);
> -	}
> #ifdef CONFIG_FS_POSIX_ACL
> -	else if (body->valid & OBD_MD_FLACL) {
> +	if (body->valid & OBD_MD_FLACL) {
> 		spin_lock(&lli->lli_lock);
> 		if (lli->lli_posix_acl)
> 			posix_acl_release(lli->lli_posix_acl);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
> deleted file mode 100644
> index edb92f9..0000000
> --- a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
> +++ /dev/null
> @@ -1,295 +0,0 @@
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
> - * Use is subject to license terms.
> - *
> - * Copyright (c) 2012, Intel Corporation.
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - *
> - * lustre/llite/llite_rmtacl.c
> - *
> - * Lustre Remote User Access Control List.
> - *
> - * Author: Fan Yong <fanyong@clusterfs.com>
> - */
> -
> -#define DEBUG_SUBSYSTEM S_LLITE
> -
> -#ifdef CONFIG_FS_POSIX_ACL
> -
> -#include "../include/lustre_lite.h"
> -#include "../include/lustre_eacl.h"
> -#include "llite_internal.h"
> -
> -static inline __u32 rce_hashfunc(uid_t id)
> -{
> -	return id & (RCE_HASHES - 1);
> -}
> -
> -static inline __u32 ee_hashfunc(uid_t id)
> -{
> -	return id & (EE_HASHES - 1);
> -}
> -
> -u64 rce_ops2valid(int ops)
> -{
> -	switch (ops) {
> -	case RMT_LSETFACL:
> -		return OBD_MD_FLRMTLSETFACL;
> -	case RMT_LGETFACL:
> -		return OBD_MD_FLRMTLGETFACL;
> -	case RMT_RSETFACL:
> -		return OBD_MD_FLRMTRSETFACL;
> -	case RMT_RGETFACL:
> -		return OBD_MD_FLRMTRGETFACL;
> -	default:
> -		return 0;
> -	}
> -}
> -
> -static struct rmtacl_ctl_entry *rce_alloc(pid_t key, int ops)
> -{
> -	struct rmtacl_ctl_entry *rce;
> -
> -	rce = kzalloc(sizeof(*rce), GFP_NOFS);
> -	if (!rce)
> -		return NULL;
> -
> -	INIT_LIST_HEAD(&rce->rce_list);
> -	rce->rce_key = key;
> -	rce->rce_ops = ops;
> -
> -	return rce;
> -}
> -
> -static void rce_free(struct rmtacl_ctl_entry *rce)
> -{
> -	if (!list_empty(&rce->rce_list))
> -		list_del(&rce->rce_list);
> -
> -	kfree(rce);
> -}
> -
> -static struct rmtacl_ctl_entry *__rct_search(struct rmtacl_ctl_table *rct,
> -					     pid_t key)
> -{
> -	struct rmtacl_ctl_entry *rce;
> -	struct list_head *head = &rct->rct_entries[rce_hashfunc(key)];
> -
> -	list_for_each_entry(rce, head, rce_list)
> -		if (rce->rce_key == key)
> -			return rce;
> -
> -	return NULL;
> -}
> -
> -struct rmtacl_ctl_entry *rct_search(struct rmtacl_ctl_table *rct, pid_t key)
> -{
> -	struct rmtacl_ctl_entry *rce;
> -
> -	spin_lock(&rct->rct_lock);
> -	rce = __rct_search(rct, key);
> -	spin_unlock(&rct->rct_lock);
> -	return rce;
> -}
> -
> -int rct_add(struct rmtacl_ctl_table *rct, pid_t key, int ops)
> -{
> -	struct rmtacl_ctl_entry *rce, *e;
> -
> -	rce = rce_alloc(key, ops);
> -	if (!rce)
> -		return -ENOMEM;
> -
> -	spin_lock(&rct->rct_lock);
> -	e = __rct_search(rct, key);
> -	if (unlikely(e)) {
> -		CWARN("Unexpected stale rmtacl_entry found: [key: %d] [ops: %d]\n",
> -		      (int)key, ops);
> -		rce_free(e);
> -	}
> -	list_add_tail(&rce->rce_list, &rct->rct_entries[rce_hashfunc(key)]);
> -	spin_unlock(&rct->rct_lock);
> -
> -	return 0;
> -}
> -
> -int rct_del(struct rmtacl_ctl_table *rct, pid_t key)
> -{
> -	struct rmtacl_ctl_entry *rce;
> -
> -	spin_lock(&rct->rct_lock);
> -	rce = __rct_search(rct, key);
> -	if (rce)
> -		rce_free(rce);
> -	spin_unlock(&rct->rct_lock);
> -
> -	return rce ? 0 : -ENOENT;
> -}
> -
> -void rct_init(struct rmtacl_ctl_table *rct)
> -{
> -	int i;
> -
> -	spin_lock_init(&rct->rct_lock);
> -	for (i = 0; i < RCE_HASHES; i++)
> -		INIT_LIST_HEAD(&rct->rct_entries[i]);
> -}
> -
> -void rct_fini(struct rmtacl_ctl_table *rct)
> -{
> -	struct rmtacl_ctl_entry *rce;
> -	int i;
> -
> -	spin_lock(&rct->rct_lock);
> -	for (i = 0; i < RCE_HASHES; i++)
> -		while (!list_empty(&rct->rct_entries[i])) {
> -			rce = list_entry(rct->rct_entries[i].next,
> -					 struct rmtacl_ctl_entry, rce_list);
> -			rce_free(rce);
> -		}
> -	spin_unlock(&rct->rct_lock);
> -}
> -
> -static struct eacl_entry *ee_alloc(pid_t key, struct lu_fid *fid, int type,
> -				   ext_acl_xattr_header *header)
> -{
> -	struct eacl_entry *ee;
> -
> -	ee = kzalloc(sizeof(*ee), GFP_NOFS);
> -	if (!ee)
> -		return NULL;
> -
> -	INIT_LIST_HEAD(&ee->ee_list);
> -	ee->ee_key = key;
> -	ee->ee_fid = *fid;
> -	ee->ee_type = type;
> -	ee->ee_acl = header;
> -
> -	return ee;
> -}
> -
> -void ee_free(struct eacl_entry *ee)
> -{
> -	if (!list_empty(&ee->ee_list))
> -		list_del(&ee->ee_list);
> -
> -	if (ee->ee_acl)
> -		lustre_ext_acl_xattr_free(ee->ee_acl);
> -
> -	kfree(ee);
> -}
> -
> -static struct eacl_entry *__et_search_del(struct eacl_table *et, pid_t key,
> -					  struct lu_fid *fid, int type)
> -{
> -	struct eacl_entry *ee;
> -	struct list_head *head = &et->et_entries[ee_hashfunc(key)];
> -
> -	LASSERT(fid);
> -	list_for_each_entry(ee, head, ee_list)
> -		if (ee->ee_key == key) {
> -			if (lu_fid_eq(&ee->ee_fid, fid) &&
> -			    ee->ee_type == type) {
> -				list_del_init(&ee->ee_list);
> -				return ee;
> -			}
> -		}
> -
> -	return NULL;
> -}
> -
> -struct eacl_entry *et_search_del(struct eacl_table *et, pid_t key,
> -				 struct lu_fid *fid, int type)
> -{
> -	struct eacl_entry *ee;
> -
> -	spin_lock(&et->et_lock);
> -	ee = __et_search_del(et, key, fid, type);
> -	spin_unlock(&et->et_lock);
> -	return ee;
> -}
> -
> -void et_search_free(struct eacl_table *et, pid_t key)
> -{
> -	struct eacl_entry *ee, *next;
> -	struct list_head *head = &et->et_entries[ee_hashfunc(key)];
> -
> -	spin_lock(&et->et_lock);
> -	list_for_each_entry_safe(ee, next, head, ee_list)
> -		if (ee->ee_key == key)
> -			ee_free(ee);
> -
> -	spin_unlock(&et->et_lock);
> -}
> -
> -int ee_add(struct eacl_table *et, pid_t key, struct lu_fid *fid, int type,
> -	   ext_acl_xattr_header *header)
> -{
> -	struct eacl_entry *ee, *e;
> -
> -	ee = ee_alloc(key, fid, type, header);
> -	if (!ee)
> -		return -ENOMEM;
> -
> -	spin_lock(&et->et_lock);
> -	e = __et_search_del(et, key, fid, type);
> -	if (unlikely(e)) {
> -		CWARN("Unexpected stale eacl_entry found: [key: %d] [fid: " DFID "] [type: %d]\n",
> -		      (int)key, PFID(fid), type);
> -		ee_free(e);
> -	}
> -	list_add_tail(&ee->ee_list, &et->et_entries[ee_hashfunc(key)]);
> -	spin_unlock(&et->et_lock);
> -
> -	return 0;
> -}
> -
> -void et_init(struct eacl_table *et)
> -{
> -	int i;
> -
> -	spin_lock_init(&et->et_lock);
> -	for (i = 0; i < EE_HASHES; i++)
> -		INIT_LIST_HEAD(&et->et_entries[i]);
> -}
> -
> -void et_fini(struct eacl_table *et)
> -{
> -	struct eacl_entry *ee;
> -	int i;
> -
> -	spin_lock(&et->et_lock);
> -	for (i = 0; i < EE_HASHES; i++)
> -		while (!list_empty(&et->et_entries[i])) {
> -			ee = list_entry(et->et_entries[i].next,
> -					struct eacl_entry, ee_list);
> -			ee_free(ee);
> -		}
> -	spin_unlock(&et->et_lock);
> -}
> -
> -#endif
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 6e9a8a5..18a7775 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -176,11 +176,7 @@ LUSTRE_RO_ATTR(filesfree);
> static ssize_t client_type_show(struct kobject *kobj, struct attribute *attr,
> 				char *buf)
> {
> -	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> -					      ll_kobj);
> -
> -	return sprintf(buf, "%s client\n",
> -			sbi->ll_flags & LL_SBI_RMT_CLIENT ? "remote" : "local");
> +	return sprintf(buf, "local client\n");
> }
> LUSTRE_RO_ATTR(client_type);
> 
> diff --git a/drivers/staging/lustre/lustre/llite/remote_perm.c b/drivers/staging/lustre/lustre/llite/remote_perm.c
> deleted file mode 100644
> index 9df9e78..0000000
> --- a/drivers/staging/lustre/lustre/llite/remote_perm.c
> +++ /dev/null
> @@ -1,320 +0,0 @@
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
> - * Use is subject to license terms.
> - *
> - * Copyright (c) 2011, 2012, Intel Corporation.
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - *
> - * lustre/llite/remote_perm.c
> - *
> - * Lustre Permission Cache for Remote Client
> - *
> - * Author: Lai Siyao <lsy@clusterfs.com>
> - * Author: Fan Yong <fanyong@clusterfs.com>
> - */
> -
> -#define DEBUG_SUBSYSTEM S_LLITE
> -
> -#include <linux/module.h>
> -#include <linux/types.h>
> -
> -#include "../include/lustre_lite.h"
> -#include "../include/lustre_ha.h"
> -#include "../include/lustre_dlm.h"
> -#include "../include/lprocfs_status.h"
> -#include "../include/lustre_disk.h"
> -#include "../include/lustre_param.h"
> -#include "llite_internal.h"
> -
> -struct kmem_cache *ll_remote_perm_cachep;
> -struct kmem_cache *ll_rmtperm_hash_cachep;
> -
> -static inline struct ll_remote_perm *alloc_ll_remote_perm(void)
> -{
> -	struct ll_remote_perm *lrp;
> -
> -	lrp = kmem_cache_zalloc(ll_remote_perm_cachep, GFP_KERNEL);
> -	if (lrp)
> -		INIT_HLIST_NODE(&lrp->lrp_list);
> -	return lrp;
> -}
> -
> -static inline void free_ll_remote_perm(struct ll_remote_perm *lrp)
> -{
> -	if (!lrp)
> -		return;
> -
> -	if (!hlist_unhashed(&lrp->lrp_list))
> -		hlist_del(&lrp->lrp_list);
> -	kmem_cache_free(ll_remote_perm_cachep, lrp);
> -}
> -
> -static struct hlist_head *alloc_rmtperm_hash(void)
> -{
> -	struct hlist_head *hash;
> -	int i;
> -
> -	hash = kmem_cache_zalloc(ll_rmtperm_hash_cachep, GFP_NOFS);
> -	if (!hash)
> -		return NULL;
> -
> -	for (i = 0; i < REMOTE_PERM_HASHSIZE; i++)
> -		INIT_HLIST_HEAD(hash + i);
> -
> -	return hash;
> -}
> -
> -void free_rmtperm_hash(struct hlist_head *hash)
> -{
> -	int i;
> -	struct ll_remote_perm *lrp;
> -	struct hlist_node *next;
> -
> -	if (!hash)
> -		return;
> -
> -	for (i = 0; i < REMOTE_PERM_HASHSIZE; i++)
> -		hlist_for_each_entry_safe(lrp, next, hash + i, lrp_list)
> -			free_ll_remote_perm(lrp);
> -	kmem_cache_free(ll_rmtperm_hash_cachep, hash);
> -}
> -
> -static inline int remote_perm_hashfunc(uid_t uid)
> -{
> -	return uid & (REMOTE_PERM_HASHSIZE - 1);
> -}
> -
> -/* NB: setxid permission is not checked here, instead it's done on
> - * MDT when client get remote permission.
> - */
> -static int do_check_remote_perm(struct ll_inode_info *lli, int mask)
> -{
> -	struct hlist_head *head;
> -	struct ll_remote_perm *lrp;
> -	int found = 0, rc;
> -
> -	if (!lli->lli_remote_perms)
> -		return -ENOENT;
> -
> -	head = lli->lli_remote_perms +
> -		remote_perm_hashfunc(from_kuid(&init_user_ns, current_uid()));
> -
> -	spin_lock(&lli->lli_lock);
> -	hlist_for_each_entry(lrp, head, lrp_list) {
> -		if (lrp->lrp_uid != from_kuid(&init_user_ns, current_uid()))
> -			continue;
> -		if (lrp->lrp_gid != from_kgid(&init_user_ns, current_gid()))
> -			continue;
> -		if (lrp->lrp_fsuid != from_kuid(&init_user_ns, current_fsuid()))
> -			continue;
> -		if (lrp->lrp_fsgid != from_kgid(&init_user_ns, current_fsgid()))
> -			continue;
> -		found = 1;
> -		break;
> -	}
> -
> -	if (!found) {
> -		rc = -ENOENT;
> -		goto out;
> -	}
> -
> -	CDEBUG(D_SEC, "found remote perm: %u/%u/%u/%u - %#x\n",
> -	       lrp->lrp_uid, lrp->lrp_gid, lrp->lrp_fsuid, lrp->lrp_fsgid,
> -	       lrp->lrp_access_perm);
> -	rc = ((lrp->lrp_access_perm & mask) == mask) ? 0 : -EACCES;
> -
> -out:
> -	spin_unlock(&lli->lli_lock);
> -	return rc;
> -}
> -
> -int ll_update_remote_perm(struct inode *inode, struct mdt_remote_perm *perm)
> -{
> -	struct ll_inode_info *lli = ll_i2info(inode);
> -	struct ll_remote_perm *lrp = NULL, *tmp = NULL;
> -	struct hlist_head *head, *perm_hash = NULL;
> -
> -	LASSERT(ll_i2sbi(inode)->ll_flags & LL_SBI_RMT_CLIENT);
> -
> -#if 0
> -	if (perm->rp_uid != current->uid ||
> -	    perm->rp_gid != current->gid ||
> -	    perm->rp_fsuid != current->fsuid ||
> -	    perm->rp_fsgid != current->fsgid) {
> -		/* user might setxid in this small period */
> -		CDEBUG(D_SEC,
> -		       "remote perm user %u/%u/%u/%u != current %u/%u/%u/%u\n",
> -		       perm->rp_uid, perm->rp_gid, perm->rp_fsuid,
> -		       perm->rp_fsgid, current->uid, current->gid,
> -		       current->fsuid, current->fsgid);
> -		return -EAGAIN;
> -	}
> -#endif
> -
> -	if (!lli->lli_remote_perms) {
> -		perm_hash = alloc_rmtperm_hash();
> -		if (!perm_hash) {
> -			CERROR("alloc lli_remote_perms failed!\n");
> -			return -ENOMEM;
> -		}
> -	}
> -
> -	spin_lock(&lli->lli_lock);
> -
> -	if (!lli->lli_remote_perms)
> -		lli->lli_remote_perms = perm_hash;
> -	else
> -		free_rmtperm_hash(perm_hash);
> -
> -	head = lli->lli_remote_perms + remote_perm_hashfunc(perm->rp_uid);
> -
> -again:
> -	hlist_for_each_entry(tmp, head, lrp_list) {
> -		if (tmp->lrp_uid != perm->rp_uid)
> -			continue;
> -		if (tmp->lrp_gid != perm->rp_gid)
> -			continue;
> -		if (tmp->lrp_fsuid != perm->rp_fsuid)
> -			continue;
> -		if (tmp->lrp_fsgid != perm->rp_fsgid)
> -			continue;
> -		free_ll_remote_perm(lrp);
> -		lrp = tmp;
> -		break;
> -	}
> -
> -	if (!lrp) {
> -		spin_unlock(&lli->lli_lock);
> -		lrp = alloc_ll_remote_perm();
> -		if (!lrp) {
> -			CERROR("alloc memory for ll_remote_perm failed!\n");
> -			return -ENOMEM;
> -		}
> -		spin_lock(&lli->lli_lock);
> -		goto again;
> -	}
> -
> -	lrp->lrp_access_perm = perm->rp_access_perm;
> -	if (lrp != tmp) {
> -		lrp->lrp_uid	 = perm->rp_uid;
> -		lrp->lrp_gid	 = perm->rp_gid;
> -		lrp->lrp_fsuid       = perm->rp_fsuid;
> -		lrp->lrp_fsgid       = perm->rp_fsgid;
> -		hlist_add_head(&lrp->lrp_list, head);
> -	}
> -	lli->lli_rmtperm_time = cfs_time_current();
> -	spin_unlock(&lli->lli_lock);
> -
> -	CDEBUG(D_SEC, "new remote perm@%p: %u/%u/%u/%u - %#x\n",
> -	       lrp, lrp->lrp_uid, lrp->lrp_gid, lrp->lrp_fsuid, lrp->lrp_fsgid,
> -	       lrp->lrp_access_perm);
> -
> -	return 0;
> -}
> -
> -int lustre_check_remote_perm(struct inode *inode, int mask)
> -{
> -	struct ll_inode_info *lli = ll_i2info(inode);
> -	struct ll_sb_info *sbi = ll_i2sbi(inode);
> -	struct ptlrpc_request *req = NULL;
> -	struct mdt_remote_perm *perm;
> -	unsigned long save;
> -	int i = 0, rc;
> -
> -	do {
> -		save = lli->lli_rmtperm_time;
> -		rc = do_check_remote_perm(lli, mask);
> -		if (!rc || (rc != -ENOENT && i))
> -			break;
> -
> -		might_sleep();
> -
> -		mutex_lock(&lli->lli_rmtperm_mutex);
> -		/* check again */
> -		if (save != lli->lli_rmtperm_time) {
> -			rc = do_check_remote_perm(lli, mask);
> -			if (!rc || (rc != -ENOENT && i)) {
> -				mutex_unlock(&lli->lli_rmtperm_mutex);
> -				break;
> -			}
> -		}
> -
> -		if (i++ > 5) {
> -			CERROR("check remote perm falls in dead loop!\n");
> -			LBUG();
> -		}
> -
> -		rc = md_get_remote_perm(sbi->ll_md_exp, ll_inode2fid(inode),
> -					ll_i2suppgid(inode), &req);
> -		if (rc) {
> -			mutex_unlock(&lli->lli_rmtperm_mutex);
> -			break;
> -		}
> -
> -		perm = req_capsule_server_swab_get(&req->rq_pill, &RMF_ACL,
> -						   lustre_swab_mdt_remote_perm);
> -		if (unlikely(!perm)) {
> -			mutex_unlock(&lli->lli_rmtperm_mutex);
> -			rc = -EPROTO;
> -			break;
> -		}
> -
> -		rc = ll_update_remote_perm(inode, perm);
> -		mutex_unlock(&lli->lli_rmtperm_mutex);
> -		if (rc == -ENOMEM)
> -			break;
> -
> -		ptlrpc_req_finished(req);
> -		req = NULL;
> -	} while (1);
> -	ptlrpc_req_finished(req);
> -	return rc;
> -}
> -
> -#if 0  /* NB: remote perms can't be freed in ll_mdc_blocking_ast of UPDATE lock,
> -	* because it will fail sanity test 48.
> -	*/
> -void ll_free_remote_perms(struct inode *inode)
> -{
> -	struct ll_inode_info *lli = ll_i2info(inode);
> -	struct hlist_head *hash = lli->lli_remote_perms;
> -	struct ll_remote_perm *lrp;
> -	struct hlist_node *node, *next;
> -	int i;
> -
> -	LASSERT(hash);
> -
> -	spin_lock(&lli->lli_lock);
> -
> -	for (i = 0; i < REMOTE_PERM_HASHSIZE; i++) {
> -		hlist_for_each_entry_safe(lrp, node, next, hash + i, lrp_list)
> -			free_ll_remote_perm(lrp);
> -	}
> -
> -	spin_unlock(&lli->lli_lock);
> -}
> -#endif
> diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
> index b40ea79..3dd7e0e 100644
> --- a/drivers/staging/lustre/lustre/llite/super25.c
> +++ b/drivers/staging/lustre/lustre/llite/super25.c
> @@ -114,19 +114,6 @@ static int __init lustre_init(void)
> 	if (!ll_file_data_slab)
> 		goto out_cache;
> 
> -	ll_remote_perm_cachep = kmem_cache_create("ll_remote_perm_cache",
> -						  sizeof(struct ll_remote_perm),
> -						      0, 0, NULL);
> -	if (!ll_remote_perm_cachep)
> -		goto out_cache;
> -
> -	ll_rmtperm_hash_cachep = kmem_cache_create("ll_rmtperm_hash_cache",
> -						   REMOTE_PERM_HASHSIZE *
> -						   sizeof(struct list_head),
> -						   0, 0, NULL);
> -	if (!ll_rmtperm_hash_cachep)
> -		goto out_cache;
> -
> 	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
> 	if (IS_ERR_OR_NULL(llite_root)) {
> 		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
> @@ -190,8 +177,6 @@ out_debugfs:
> out_cache:
> 	kmem_cache_destroy(ll_inode_cachep);
> 	kmem_cache_destroy(ll_file_data_slab);
> -	kmem_cache_destroy(ll_remote_perm_cachep);
> -	kmem_cache_destroy(ll_rmtperm_hash_cachep);
> 	return rc;
> }
> 
> @@ -209,10 +194,6 @@ static void __exit lustre_exit(void)
> 	vvp_global_fini();
> 
> 	kmem_cache_destroy(ll_inode_cachep);
> -	kmem_cache_destroy(ll_rmtperm_hash_cachep);
> -
> -	kmem_cache_destroy(ll_remote_perm_cachep);
> -
> 	kmem_cache_destroy(ll_file_data_slab);
> }
> 
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index 6ce790e..98303cf 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -107,11 +107,6 @@ int ll_setxattr_common(struct inode *inode, const char *name,
> 	struct ll_sb_info *sbi = ll_i2sbi(inode);
> 	struct ptlrpc_request *req = NULL;
> 	int xattr_type, rc;
> -#ifdef CONFIG_FS_POSIX_ACL
> -	struct rmtacl_ctl_entry *rce = NULL;
> -	posix_acl_xattr_header *new_value = NULL;
> -	ext_acl_xattr_header *acl = NULL;
> -#endif
> 	const char *pv = value;
> 
> 	xattr_type = get_xattr_type(name);
> @@ -139,62 +134,9 @@ int ll_setxattr_common(struct inode *inode, const char *name,
> 	    strcmp(name, "security.selinux") == 0)
> 		return -EOPNOTSUPP;
> 
> -#ifdef CONFIG_FS_POSIX_ACL
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT &&
> -	    (xattr_type == XATTR_ACL_ACCESS_T ||
> -	    xattr_type == XATTR_ACL_DEFAULT_T)) {
> -		rce = rct_search(&sbi->ll_rct, current_pid());
> -		if (!rce ||
> -		    (rce->rce_ops != RMT_LSETFACL &&
> -		    rce->rce_ops != RMT_RSETFACL))
> -			return -EOPNOTSUPP;
> -
> -		if (rce->rce_ops == RMT_LSETFACL) {
> -			struct eacl_entry *ee;
> -
> -			ee = et_search_del(&sbi->ll_et, current_pid(),
> -					   ll_inode2fid(inode), xattr_type);
> -			if (valid & OBD_MD_FLXATTR) {
> -				acl = lustre_acl_xattr_merge2ext(
> -						(posix_acl_xattr_header *)value,
> -						size, ee->ee_acl);
> -				if (IS_ERR(acl)) {
> -					ee_free(ee);
> -					return PTR_ERR(acl);
> -				}
> -				size =  CFS_ACL_XATTR_SIZE(\
> -						le32_to_cpu(acl->a_count), \
> -						ext_acl_xattr);
> -				pv = (const char *)acl;
> -			}
> -			ee_free(ee);
> -		} else if (rce->rce_ops == RMT_RSETFACL) {
> -			rc = lustre_posix_acl_xattr_filter(
> -						(posix_acl_xattr_header *)value,
> -						size, &new_value);
> -			if (unlikely(rc < 0))
> -				return rc;
> -			size = rc;
> -
> -			pv = (const char *)new_value;
> -		} else {
> -			return -EOPNOTSUPP;
> -		}
> -
> -		valid |= rce_ops2valid(rce->rce_ops);
> -	}
> -#endif
> 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
> 			 valid, name, pv, size, 0, flags,
> 			 ll_i2suppgid(inode), &req);
> -#ifdef CONFIG_FS_POSIX_ACL
> -	/*
> -	 * Release the posix ACL space.
> -	 */
> -	kfree(new_value);
> -	if (acl)
> -		lustre_ext_acl_xattr_free(acl);
> -#endif
> 	if (rc) {
> 		if (rc == -EOPNOTSUPP && xattr_type == XATTR_USER_T) {
> 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
> @@ -284,7 +226,6 @@ int ll_getxattr_common(struct inode *inode, const char *name,
> 	struct mdt_body *body;
> 	int xattr_type, rc;
> 	void *xdata;
> -	struct rmtacl_ctl_entry *rce = NULL;
> 	struct ll_inode_info *lli = ll_i2info(inode);
> 
> 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
> @@ -315,24 +256,11 @@ int ll_getxattr_common(struct inode *inode, const char *name,
> 		return -EOPNOTSUPP;
> 
> #ifdef CONFIG_FS_POSIX_ACL
> -	if (sbi->ll_flags & LL_SBI_RMT_CLIENT &&
> -	    (xattr_type == XATTR_ACL_ACCESS_T ||
> -	    xattr_type == XATTR_ACL_DEFAULT_T)) {
> -		rce = rct_search(&sbi->ll_rct, current_pid());
> -		if (!rce ||
> -		    (rce->rce_ops != RMT_LSETFACL &&
> -		    rce->rce_ops != RMT_LGETFACL &&
> -		    rce->rce_ops != RMT_RSETFACL &&
> -		    rce->rce_ops != RMT_RGETFACL))
> -			return -EOPNOTSUPP;
> -	}
> -
> 	/* posix acl is under protection of LOOKUP lock. when calling to this,
> 	 * we just have path resolution to the target inode, so we have great
> 	 * chance that cached ACL is uptodate.
> 	 */
> -	if (xattr_type == XATTR_ACL_ACCESS_T &&
> -	    !(sbi->ll_flags & LL_SBI_RMT_CLIENT)) {
> +	if (xattr_type == XATTR_ACL_ACCESS_T) {
> 		struct posix_acl *acl;
> 
> 		spin_lock(&lli->lli_lock);
> @@ -374,9 +302,7 @@ do_getxattr:
> 	} else {
> getxattr_nocache:
> 		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode),
> -				valid | (rce ? rce_ops2valid(rce->rce_ops) : 0),
> -				name, NULL, 0, size, 0, &req);
> -
> +				 valid, name, NULL, 0, size, 0, &req);
> 		if (rc < 0)
> 			goto out_xattr;
> 
> @@ -413,25 +339,6 @@ getxattr_nocache:
> 		rc = body->eadatasize;
> 	}
> 
> -#ifdef CONFIG_FS_POSIX_ACL
> -	if (rce && rce->rce_ops == RMT_LSETFACL) {
> -		ext_acl_xattr_header *acl;
> -
> -		acl = lustre_posix_acl_xattr_2ext(buffer, rc);
> -		if (IS_ERR(acl)) {
> -			rc = PTR_ERR(acl);
> -			goto out;
> -		}
> -
> -		rc = ee_add(&sbi->ll_et, current_pid(), ll_inode2fid(inode),
> -			    xattr_type, acl);
> -		if (unlikely(rc < 0)) {
> -			lustre_ext_acl_xattr_free(acl);
> -			goto out;
> -		}
> -	}
> -#endif
> -
> out_xattr:
> 	if (rc == -EOPNOTSUPP && xattr_type == XATTR_USER_T) {
> 		LCONSOLE_INFO(
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index ab4f4fb..6483f2c 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -2607,27 +2607,6 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
> 	return md_clear_open_replay_data(tgt->ltd_exp, och);
> }
> 
> -static int lmv_get_remote_perm(struct obd_export *exp,
> -			       const struct lu_fid *fid,
> -			       __u32 suppgid, struct ptlrpc_request **request)
> -{
> -	struct obd_device       *obd = exp->exp_obd;
> -	struct lmv_obd	  *lmv = &obd->u.lmv;
> -	struct lmv_tgt_desc     *tgt;
> -	int		      rc;
> -
> -	rc = lmv_check_connect(obd);
> -	if (rc)
> -		return rc;
> -
> -	tgt = lmv_find_target(lmv, fid);
> -	if (IS_ERR(tgt))
> -		return PTR_ERR(tgt);
> -
> -	rc = md_get_remote_perm(tgt->ltd_exp, fid, suppgid, request);
> -	return rc;
> -}
> -
> static int lmv_intent_getattr_async(struct obd_export *exp,
> 				    struct md_enqueue_info *minfo,
> 				    struct ldlm_enqueue_info *einfo)
> @@ -2791,7 +2770,6 @@ static struct md_ops lmv_md_ops = {
> 	.free_lustre_md		= lmv_free_lustre_md,
> 	.set_open_replay_data	= lmv_set_open_replay_data,
> 	.clear_open_replay_data	= lmv_clear_open_replay_data,
> -	.get_remote_perm	= lmv_get_remote_perm,
> 	.intent_getattr_async	= lmv_intent_getattr_async,
> 	.revalidate_lock	= lmv_revalidate_lock
> };
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> index b395420..d55a5d8 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> @@ -343,10 +343,6 @@ static struct ptlrpc_request *mdc_intent_open_pack(struct obd_export *exp,
> 	mdc_open_pack(req, op_data, it->it_create_mode, 0, it->it_flags, lmm,
> 		      lmmsize);
> 
> -	/* for remote client, fetch remote perm for current user */
> -	if (client_is_remote(exp))
> -		req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
> -				     sizeof(struct mdt_remote_perm));
> 	ptlrpc_request_set_replen(req);
> 	return req;
> }
> @@ -440,9 +436,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
> 	struct obd_device     *obddev = class_exp2obd(exp);
> 	u64		       valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE |
> 				       OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA |
> -				       OBD_MD_MEA |
> -				       (client_is_remote(exp) ?
> -					       OBD_MD_FLRMTPERM : OBD_MD_FLACL);
> +				       OBD_MD_MEA | OBD_MD_FLACL;
> 	struct ldlm_intent    *lit;
> 	int		    rc;
> 	int		    easize;
> @@ -474,9 +468,6 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
> 	mdc_getattr_pack(req, valid, it->it_flags, op_data, easize);
> 
> 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
> -	if (client_is_remote(exp))
> -		req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
> -				     sizeof(struct mdt_remote_perm));
> 	ptlrpc_request_set_replen(req);
> 	return req;
> }
> @@ -683,16 +674,6 @@ static int mdc_finish_enqueue(struct obd_export *exp,
> 					memcpy(lmm, eadata, body->eadatasize);
> 			}
> 		}
> -
> -		if (body->valid & OBD_MD_FLRMTPERM) {
> -			struct mdt_remote_perm *perm;
> -
> -			LASSERT(client_is_remote(exp));
> -			perm = req_capsule_server_swab_get(pill, &RMF_ACL,
> -						lustre_swab_mdt_remote_perm);
> -			if (!perm)
> -				return -EPROTO;
> -		}
> 	} else if (it->it_op & IT_LAYOUT) {
> 		/* maybe the lock was granted right away and layout
> 		 * is packed into RMF_DLM_LVB of req
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
> index 661488e..5dba2c8 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
> @@ -230,7 +230,7 @@ rebuild:
> 						MDS_INODELOCK_UPDATE);
> 
> 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
> -				   &RQF_MDS_REINT_CREATE_RMT_ACL);
> +				   &RQF_MDS_REINT_CREATE_ACL);
> 	if (!req) {
> 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
> 		return -ENOMEM;
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index f371e1d..f7e30b1 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -146,16 +146,6 @@ static int mdc_getattr_common(struct obd_export *exp,
> 			return -EPROTO;
> 	}
> 
> -	if (body->valid & OBD_MD_FLRMTPERM) {
> -		struct mdt_remote_perm *perm;
> -
> -		LASSERT(client_is_remote(exp));
> -		perm = req_capsule_server_swab_get(pill, &RMF_ACL,
> -						lustre_swab_mdt_remote_perm);
> -		if (!perm)
> -			return -EPROTO;
> -	}
> -
> 	return 0;
> }
> 
> @@ -186,11 +176,6 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
> 
> 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
> 			     op_data->op_mode);
> -	if (op_data->op_valid & OBD_MD_FLRMTPERM) {
> -		LASSERT(client_is_remote(exp));
> -		req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
> -				     sizeof(struct mdt_remote_perm));
> -	}
> 	ptlrpc_request_set_replen(req);
> 
> 	rc = mdc_getattr_common(exp, req);
> @@ -535,16 +520,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
> 	}
> 	rc = 0;
> 
> -	if (md->body->valid & OBD_MD_FLRMTPERM) {
> -		/* remote permission */
> -		LASSERT(client_is_remote(exp));
> -		md->remote_perm = req_capsule_server_swab_get(pill, &RMF_ACL,
> -						lustre_swab_mdt_remote_perm);
> -		if (!md->remote_perm) {
> -			rc = -EPROTO;
> -			goto out;
> -		}
> -	} else if (md->body->valid & OBD_MD_FLACL) {
> +	if (md->body->valid & OBD_MD_FLACL) {
> 		/* for ACL, it's possible that FLACL is set but aclsize is zero.
> 		 * only when aclsize != 0 there's an actual segment for ACL
> 		 * in reply buffer.
> @@ -1164,7 +1140,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
> 		goto out;
> 	}
> 
> -	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
> +	mdc_pack_body(req, NULL, 0, 0, -1, 0);
> 
> 	/* Copy hsm_progress struct */
> 	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
> @@ -1198,7 +1174,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, __u32 archives)
> 		goto out;
> 	}
> 
> -	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
> +	mdc_pack_body(req, NULL, 0, 0, -1, 0);
> 
> 	/* Copy hsm_progress struct */
> 	archive_mask = req_capsule_client_get(&req->rq_pill,
> @@ -1237,7 +1213,7 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
> 		return rc;
> 	}
> 
> -	mdc_pack_body(req, &op_data->op_fid1, OBD_MD_FLRMTPERM, 0,
> +	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
> 		      op_data->op_suppgids[0], 0);
> 
> 	ptlrpc_request_set_replen(req);
> @@ -1273,7 +1249,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
> 		goto out;
> 	}
> 
> -	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
> +	mdc_pack_body(req, NULL, 0, 0, -1, 0);
> 
> 	ptlrpc_request_set_replen(req);
> 
> @@ -1302,7 +1278,7 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
> 		return rc;
> 	}
> 
> -	mdc_pack_body(req, &op_data->op_fid1, OBD_MD_FLRMTPERM, 0,
> +	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
> 		      op_data->op_suppgids[0], 0);
> 
> 	ptlrpc_request_set_replen(req);
> @@ -1343,7 +1319,7 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
> 		return rc;
> 	}
> 
> -	mdc_pack_body(req, &op_data->op_fid1, OBD_MD_FLRMTPERM, 0,
> +	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
> 		      op_data->op_suppgids[0], 0);
> 
> 	/* Copy states */
> @@ -1390,7 +1366,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
> 		return rc;
> 	}
> 
> -	mdc_pack_body(req, NULL, OBD_MD_FLRMTPERM, 0, -1, 0);
> +	mdc_pack_body(req, NULL, 0, 0, -1, 0);
> 
> 	/* Copy hsm_request struct */
> 	req_hr = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_REQUEST);
> @@ -2428,41 +2404,6 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
> 	return rc;
> }
> 
> -/* get remote permission for current user on fid */
> -static int mdc_get_remote_perm(struct obd_export *exp, const struct lu_fid *fid,
> -			       __u32 suppgid, struct ptlrpc_request **request)
> -{
> -	struct ptlrpc_request  *req;
> -	int		    rc;
> -
> -	LASSERT(client_is_remote(exp));
> -
> -	*request = NULL;
> -	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_GETATTR);
> -	if (!req)
> -		return -ENOMEM;
> -
> -	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GETATTR);
> -	if (rc) {
> -		ptlrpc_request_free(req);
> -		return rc;
> -	}
> -
> -	mdc_pack_body(req, fid, OBD_MD_FLRMTPERM, 0, suppgid, 0);
> -
> -	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
> -			     sizeof(struct mdt_remote_perm));
> -
> -	ptlrpc_request_set_replen(req);
> -
> -	rc = ptlrpc_queue_wait(req);
> -	if (rc)
> -		ptlrpc_req_finished(req);
> -	else
> -		*request = req;
> -	return rc;
> -}
> -
> static struct obd_ops mdc_obd_ops = {
> 	.owner          = THIS_MODULE,
> 	.setup          = mdc_setup,
> @@ -2514,7 +2455,6 @@ static struct md_ops mdc_md_ops = {
> 	.free_lustre_md		= mdc_free_lustre_md,
> 	.set_open_replay_data	= mdc_set_open_replay_data,
> 	.clear_open_replay_data	= mdc_clear_open_replay_data,
> -	.get_remote_perm	= mdc_get_remote_perm,
> 	.intent_getattr_async	= mdc_intent_getattr_async,
> 	.revalidate_lock	= mdc_revalidate_lock
> };
> diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
> index c404eb3..df7e47f 100644
> --- a/drivers/staging/lustre/lustre/obdclass/Makefile
> +++ b/drivers/staging/lustre/lustre/obdclass/Makefile
> @@ -5,5 +5,4 @@ obdclass-y := linux/linux-module.o linux/linux-obdo.o linux/linux-sysctl.o \
> 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
> 	      lustre_handles.o lustre_peer.o statfs_pack.o \
> 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
> -	      cl_object.o cl_page.o cl_lock.o cl_io.o \
> -	      acl.o kernelcomm.o
> +	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
> diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
> deleted file mode 100644
> index 30d8b42..0000000
> --- a/drivers/staging/lustre/lustre/obdclass/acl.c
> +++ /dev/null
> @@ -1,411 +0,0 @@
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
> - * Use is subject to license terms.
> - *
> - * Copyright (c) 2012, Intel Corporation.
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - *
> - * lustre/obdclass/acl.c
> - *
> - * Lustre Access Control List.
> - *
> - * Author: Fan Yong <fanyong@clusterfs.com>
> - */
> -
> -#define DEBUG_SUBSYSTEM S_SEC
> -#include "../include/lu_object.h"
> -#include "../include/lustre_acl.h"
> -#include "../include/lustre_eacl.h"
> -#include "../include/obd_support.h"
> -
> -#ifdef CONFIG_FS_POSIX_ACL
> -
> -#define CFS_ACL_XATTR_VERSION POSIX_ACL_XATTR_VERSION
> -
> -enum {
> -	ES_UNK  = 0,    /* unknown stat */
> -	ES_UNC  = 1,    /* ACL entry is not changed */
> -	ES_MOD  = 2,    /* ACL entry is modified */
> -	ES_ADD  = 3,    /* ACL entry is added */
> -	ES_DEL  = 4     /* ACL entry is deleted */
> -};
> -
> -static inline void lustre_ext_acl_le_to_cpu(ext_acl_xattr_entry *d,
> -					    ext_acl_xattr_entry *s)
> -{
> -	d->e_tag	= le16_to_cpu(s->e_tag);
> -	d->e_perm       = le16_to_cpu(s->e_perm);
> -	d->e_id	 = le32_to_cpu(s->e_id);
> -	d->e_stat       = le32_to_cpu(s->e_stat);
> -}
> -
> -static inline void lustre_ext_acl_cpu_to_le(ext_acl_xattr_entry *d,
> -					    ext_acl_xattr_entry *s)
> -{
> -	d->e_tag	= cpu_to_le16(s->e_tag);
> -	d->e_perm       = cpu_to_le16(s->e_perm);
> -	d->e_id	 = cpu_to_le32(s->e_id);
> -	d->e_stat       = cpu_to_le32(s->e_stat);
> -}
> -
> -static inline void lustre_posix_acl_le_to_cpu(posix_acl_xattr_entry *d,
> -					      posix_acl_xattr_entry *s)
> -{
> -	d->e_tag	= le16_to_cpu(s->e_tag);
> -	d->e_perm       = le16_to_cpu(s->e_perm);
> -	d->e_id	 = le32_to_cpu(s->e_id);
> -}
> -
> -static inline void lustre_posix_acl_cpu_to_le(posix_acl_xattr_entry *d,
> -					      posix_acl_xattr_entry *s)
> -{
> -	d->e_tag	= cpu_to_le16(s->e_tag);
> -	d->e_perm       = cpu_to_le16(s->e_perm);
> -	d->e_id	 = cpu_to_le32(s->e_id);
> -}
> -
> -/* if "new_count == 0", then "new = {a_version, NULL}", NOT NULL. */
> -static int lustre_posix_acl_xattr_reduce_space(posix_acl_xattr_header **header,
> -					       int old_count, int new_count)
> -{
> -	int old_size = CFS_ACL_XATTR_SIZE(old_count, posix_acl_xattr);
> -	int new_size = CFS_ACL_XATTR_SIZE(new_count, posix_acl_xattr);
> -	posix_acl_xattr_header *new;
> -
> -	if (unlikely(old_count <= new_count))
> -		return old_size;
> -
> -	new = kmemdup(*header, new_size, GFP_NOFS);
> -	if (unlikely(!new))
> -		return -ENOMEM;
> -
> -	kfree(*header);
> -	*header = new;
> -	return new_size;
> -}
> -
> -/* if "new_count == 0", then "new = {0, NULL}", NOT NULL. */
> -static int lustre_ext_acl_xattr_reduce_space(ext_acl_xattr_header **header,
> -					     int old_count)
> -{
> -	int ext_count = le32_to_cpu((*header)->a_count);
> -	int ext_size = CFS_ACL_XATTR_SIZE(ext_count, ext_acl_xattr);
> -	ext_acl_xattr_header *new;
> -
> -	if (unlikely(old_count <= ext_count))
> -		return 0;
> -
> -	new = kmemdup(*header, ext_size, GFP_NOFS);
> -	if (unlikely(!new))
> -		return -ENOMEM;
> -
> -	kfree(*header);
> -	*header = new;
> -	return 0;
> -}
> -
> -/*
> - * Generate new extended ACL based on the posix ACL.
> - */
> -ext_acl_xattr_header *
> -lustre_posix_acl_xattr_2ext(posix_acl_xattr_header *header, int size)
> -{
> -	int count, i, esize;
> -	ext_acl_xattr_header *new;
> -
> -	if (unlikely(size < 0))
> -		return ERR_PTR(-EINVAL);
> -	else if (!size)
> -		count = 0;
> -	else
> -		count = CFS_ACL_XATTR_COUNT(size, posix_acl_xattr);
> -	esize = CFS_ACL_XATTR_SIZE(count, ext_acl_xattr);
> -	new = kzalloc(esize, GFP_NOFS);
> -	if (unlikely(!new))
> -		return ERR_PTR(-ENOMEM);
> -
> -	new->a_count = cpu_to_le32(count);
> -	for (i = 0; i < count; i++) {
> -		new->a_entries[i].e_tag  = header->a_entries[i].e_tag;
> -		new->a_entries[i].e_perm = header->a_entries[i].e_perm;
> -		new->a_entries[i].e_id   = header->a_entries[i].e_id;
> -		new->a_entries[i].e_stat = cpu_to_le32(ES_UNK);
> -	}
> -
> -	return new;
> -}
> -EXPORT_SYMBOL(lustre_posix_acl_xattr_2ext);
> -
> -/*
> - * Filter out the "nobody" entries in the posix ACL.
> - */
> -int lustre_posix_acl_xattr_filter(posix_acl_xattr_header *header, size_t size,
> -				  posix_acl_xattr_header **out)
> -{
> -	int count, i, j, rc = 0;
> -	__u32 id;
> -	posix_acl_xattr_header *new;
> -
> -	if (!size)
> -		return 0;
> -	if (size < sizeof(*new))
> -		return -EINVAL;
> -
> -	new = kzalloc(size, GFP_NOFS);
> -	if (unlikely(!new))
> -		return -ENOMEM;
> -
> -	new->a_version = cpu_to_le32(CFS_ACL_XATTR_VERSION);
> -	count = CFS_ACL_XATTR_COUNT(size, posix_acl_xattr);
> -	for (i = 0, j = 0; i < count; i++) {
> -		id = le32_to_cpu(header->a_entries[i].e_id);
> -		switch (le16_to_cpu(header->a_entries[i].e_tag)) {
> -		case ACL_USER_OBJ:
> -		case ACL_GROUP_OBJ:
> -		case ACL_MASK:
> -		case ACL_OTHER:
> -			if (id != ACL_UNDEFINED_ID) {
> -				rc = -EIO;
> -				goto _out;
> -			}
> -
> -			memcpy(&new->a_entries[j++], &header->a_entries[i],
> -			       sizeof(posix_acl_xattr_entry));
> -			break;
> -		case ACL_USER:
> -			if (id != NOBODY_UID)
> -				memcpy(&new->a_entries[j++],
> -				       &header->a_entries[i],
> -				       sizeof(posix_acl_xattr_entry));
> -			break;
> -		case ACL_GROUP:
> -			if (id != NOBODY_GID)
> -				memcpy(&new->a_entries[j++],
> -				       &header->a_entries[i],
> -				       sizeof(posix_acl_xattr_entry));
> -			break;
> -		default:
> -			rc = -EIO;
> -			goto _out;
> -		}
> -	}
> -
> -	/* free unused space. */
> -	rc = lustre_posix_acl_xattr_reduce_space(&new, count, j);
> -	if (rc >= 0) {
> -		size = rc;
> -		*out = new;
> -		rc = 0;
> -	}
> -
> -_out:
> -	if (rc) {
> -		kfree(new);
> -		size = rc;
> -	}
> -	return size;
> -}
> -EXPORT_SYMBOL(lustre_posix_acl_xattr_filter);
> -
> -/*
> - * Release the extended ACL space.
> - */
> -void lustre_ext_acl_xattr_free(ext_acl_xattr_header *header)
> -{
> -	kfree(header);
> -}
> -EXPORT_SYMBOL(lustre_ext_acl_xattr_free);
> -
> -static ext_acl_xattr_entry *
> -lustre_ext_acl_xattr_search(ext_acl_xattr_header *header,
> -			    posix_acl_xattr_entry *entry, int *pos)
> -{
> -	int once, start, end, i, j, count = le32_to_cpu(header->a_count);
> -
> -	once = 0;
> -	start = *pos;
> -	end = count;
> -
> -again:
> -	for (i = start; i < end; i++) {
> -		if (header->a_entries[i].e_tag == entry->e_tag &&
> -		    header->a_entries[i].e_id == entry->e_id) {
> -			j = i;
> -			if (++i >= count)
> -				i = 0;
> -			*pos = i;
> -			return &header->a_entries[j];
> -		}
> -	}
> -
> -	if (!once) {
> -		once = 1;
> -		start = 0;
> -		end = *pos;
> -		goto again;
> -	}
> -
> -	return NULL;
> -}
> -
> -/*
> - * Merge the posix ACL and the extended ACL into new extended ACL.
> - */
> -ext_acl_xattr_header *
> -lustre_acl_xattr_merge2ext(posix_acl_xattr_header *posix_header, int size,
> -			   ext_acl_xattr_header *ext_header)
> -{
> -	int ori_ext_count, posix_count, ext_count, ext_size;
> -	int i, j, pos = 0, rc = 0;
> -	posix_acl_xattr_entry pae;
> -	ext_acl_xattr_header *new;
> -	ext_acl_xattr_entry *ee, eae;
> -
> -	if (unlikely(size < 0))
> -		return ERR_PTR(-EINVAL);
> -	else if (!size)
> -		posix_count = 0;
> -	else
> -		posix_count = CFS_ACL_XATTR_COUNT(size, posix_acl_xattr);
> -	ori_ext_count = le32_to_cpu(ext_header->a_count);
> -	ext_count = posix_count + ori_ext_count;
> -	ext_size = CFS_ACL_XATTR_SIZE(ext_count, ext_acl_xattr);
> -
> -	new = kzalloc(ext_size, GFP_NOFS);
> -	if (unlikely(!new))
> -		return ERR_PTR(-ENOMEM);
> -
> -	for (i = 0, j = 0; i < posix_count; i++) {
> -		lustre_posix_acl_le_to_cpu(&pae, &posix_header->a_entries[i]);
> -		switch (pae.e_tag) {
> -		case ACL_USER_OBJ:
> -		case ACL_GROUP_OBJ:
> -		case ACL_MASK:
> -		case ACL_OTHER:
> -			if (pae.e_id != ACL_UNDEFINED_ID) {
> -				rc = -EIO;
> -				goto out;
> -		}
> -		case ACL_USER:
> -			/* ignore "nobody" entry. */
> -			if (pae.e_id == NOBODY_UID)
> -				break;
> -
> -			new->a_entries[j].e_tag =
> -					posix_header->a_entries[i].e_tag;
> -			new->a_entries[j].e_perm =
> -					posix_header->a_entries[i].e_perm;
> -			new->a_entries[j].e_id =
> -					posix_header->a_entries[i].e_id;
> -			ee = lustre_ext_acl_xattr_search(ext_header,
> -					&posix_header->a_entries[i], &pos);
> -			if (ee) {
> -				if (posix_header->a_entries[i].e_perm !=
> -								ee->e_perm)
> -					/* entry modified. */
> -					ee->e_stat =
> -					new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_MOD);
> -				else
> -					/* entry unchanged. */
> -					ee->e_stat =
> -					new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_UNC);
> -			} else {
> -				/* new entry. */
> -				new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_ADD);
> -			}
> -			break;
> -		case ACL_GROUP:
> -			/* ignore "nobody" entry. */
> -			if (pae.e_id == NOBODY_GID)
> -				break;
> -			new->a_entries[j].e_tag =
> -					posix_header->a_entries[i].e_tag;
> -			new->a_entries[j].e_perm =
> -					posix_header->a_entries[i].e_perm;
> -			new->a_entries[j].e_id =
> -					posix_header->a_entries[i].e_id;
> -			ee = lustre_ext_acl_xattr_search(ext_header,
> -					&posix_header->a_entries[i], &pos);
> -			if (ee) {
> -				if (posix_header->a_entries[i].e_perm !=
> -								ee->e_perm)
> -					/* entry modified. */
> -					ee->e_stat =
> -					new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_MOD);
> -				else
> -					/* entry unchanged. */
> -					ee->e_stat =
> -					new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_UNC);
> -			} else {
> -				/* new entry. */
> -				new->a_entries[j++].e_stat =
> -							cpu_to_le32(ES_ADD);
> -			}
> -			break;
> -		default:
> -			rc = -EIO;
> -			goto out;
> -		}
> -	}
> -
> -	/* process deleted entries. */
> -	for (i = 0; i < ori_ext_count; i++) {
> -		lustre_ext_acl_le_to_cpu(&eae, &ext_header->a_entries[i]);
> -		if (eae.e_stat == ES_UNK) {
> -			/* ignore "nobody" entry. */
> -			if ((eae.e_tag == ACL_USER && eae.e_id == NOBODY_UID) ||
> -			    (eae.e_tag == ACL_GROUP && eae.e_id == NOBODY_GID))
> -				continue;
> -
> -			new->a_entries[j].e_tag =
> -						ext_header->a_entries[i].e_tag;
> -			new->a_entries[j].e_perm =
> -						ext_header->a_entries[i].e_perm;
> -			new->a_entries[j].e_id = ext_header->a_entries[i].e_id;
> -			new->a_entries[j++].e_stat = cpu_to_le32(ES_DEL);
> -		}
> -	}
> -
> -	new->a_count = cpu_to_le32(j);
> -	/* free unused space. */
> -	rc = lustre_ext_acl_xattr_reduce_space(&new, ext_count);
> -
> -out:
> -	if (rc) {
> -		kfree(new);
> -		new = ERR_PTR(rc);
> -	}
> -	return new;
> -}
> -EXPORT_SYMBOL(lustre_acl_xattr_merge2ext);
> -
> -#endif
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 1a6df43..4c78b53 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -2367,7 +2367,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
> 	oap->oap_obj_off = offset;
> 	LASSERT(!(offset & ~PAGE_MASK));
> 
> -	if (!client_is_remote(exp) && capable(CFS_CAP_SYS_RESOURCE))
> +	if (capable(CFS_CAP_SYS_RESOURCE))
> 		oap->oap_brw_flags = OBD_BRW_NOQUOTA;
> 
> 	INIT_LIST_HEAD(&oap->oap_pending_item);
> @@ -2406,8 +2406,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
> 
> 	/* Set the OBD_BRW_SRVLOCK before the page is queued. */
> 	brw_flags |= ops->ops_srvlock ? OBD_BRW_SRVLOCK : 0;
> -	if (!client_is_remote(osc_export(osc)) &&
> -	    capable(CFS_CAP_SYS_RESOURCE)) {
> +	if (capable(CFS_CAP_SYS_RESOURCE)) {
> 		brw_flags |= OBD_BRW_NOQUOTA;
> 		cmd |= OBD_BRW_NOQUOTA;
> 	}
> diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
> index 57d8a5a..18c261b 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_page.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_page.c
> @@ -357,7 +357,6 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
> 		     enum cl_req_type crt, int brw_flags)
> {
> 	struct osc_async_page *oap = &opg->ops_oap;
> -	struct osc_object *obj = oap->oap_obj;
> 
> 	LASSERTF(oap->oap_magic == OAP_MAGIC, "Bad oap magic: oap %p, magic 0x%x\n",
> 		 oap, oap->oap_magic);
> @@ -372,8 +371,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
> 	if (osc_over_unstable_soft_limit(oap->oap_cli))
> 		oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
> 
> -	if (!client_is_remote(osc_export(obj)) &&
> -	    capable(CFS_CAP_SYS_RESOURCE)) {
> +	if (capable(CFS_CAP_SYS_RESOURCE)) {
> 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
> 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
> 	}
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
> index e6ff97d..ab5d851 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
> @@ -194,7 +194,7 @@ static const struct req_msg_field *mds_reint_create_slave_client[] = {
> 	&RMF_DLM_REQ
> };
> 
> -static const struct req_msg_field *mds_reint_create_rmt_acl_client[] = {
> +static const struct req_msg_field *mds_reint_create_acl_client[] = {
> 	&RMF_PTLRPC_BODY,
> 	&RMF_REC_REINT,
> 	&RMF_CAPA1,
> @@ -675,7 +675,7 @@ static struct req_format *req_formats[] = {
> 	&RQF_MDS_DONE_WRITING,
> 	&RQF_MDS_REINT,
> 	&RQF_MDS_REINT_CREATE,
> -	&RQF_MDS_REINT_CREATE_RMT_ACL,
> +	&RQF_MDS_REINT_CREATE_ACL,
> 	&RQF_MDS_REINT_CREATE_SLAVE,
> 	&RQF_MDS_REINT_CREATE_SYM,
> 	&RQF_MDS_REINT_OPEN,
> @@ -1238,10 +1238,10 @@ struct req_format RQF_MDS_REINT_CREATE =
> 			mds_reint_create_client, mdt_body_capa);
> EXPORT_SYMBOL(RQF_MDS_REINT_CREATE);
> 
> -struct req_format RQF_MDS_REINT_CREATE_RMT_ACL =
> -	DEFINE_REQ_FMT0("MDS_REINT_CREATE_RMT_ACL",
> -			mds_reint_create_rmt_acl_client, mdt_body_capa);
> -EXPORT_SYMBOL(RQF_MDS_REINT_CREATE_RMT_ACL);
> +struct req_format RQF_MDS_REINT_CREATE_ACL =
> +	DEFINE_REQ_FMT0("MDS_REINT_CREATE_ACL",
> +			mds_reint_create_acl_client, mdt_body_capa);
> +EXPORT_SYMBOL(RQF_MDS_REINT_CREATE_ACL);
> 
> struct req_format RQF_MDS_REINT_CREATE_SLAVE =
> 	DEFINE_REQ_FMT0("MDS_REINT_CREATE_EA",
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> index 9ff58a1..b514f18 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> @@ -1802,19 +1802,6 @@ void lustre_swab_obd_quotactl(struct obd_quotactl *q)
> }
> EXPORT_SYMBOL(lustre_swab_obd_quotactl);
> 
> -void lustre_swab_mdt_remote_perm(struct mdt_remote_perm *p)
> -{
> -	__swab32s(&p->rp_uid);
> -	__swab32s(&p->rp_gid);
> -	__swab32s(&p->rp_fsuid);
> -	__swab32s(&p->rp_fsuid_h);
> -	__swab32s(&p->rp_fsgid);
> -	__swab32s(&p->rp_fsgid_h);
> -	__swab32s(&p->rp_access_perm);
> -	__swab32s(&p->rp_padding);
> -};
> -EXPORT_SYMBOL(lustre_swab_mdt_remote_perm);
> -
> void lustre_swab_fid2path(struct getinfo_fid2path *gf)
> {
> 	lustre_swab_lu_fid(&gf->gf_fid);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
> index 9fd9de9..6cc2b2e 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
> @@ -1265,8 +1265,6 @@ void lustre_assert_wire_constants(void)
> 		 OBD_MD_FLXATTRRM);
> 	LASSERTF(OBD_MD_FLACL == (0x0000008000000000ULL), "found 0x%.16llxULL\n",
> 		 OBD_MD_FLACL);
> -	LASSERTF(OBD_MD_FLRMTPERM == (0x0000010000000000ULL), "found 0x%.16llxULL\n",
> -		 OBD_MD_FLRMTPERM);
> 	LASSERTF(OBD_MD_FLMDSCAPA == (0x0000020000000000ULL), "found 0x%.16llxULL\n",
> 		 OBD_MD_FLMDSCAPA);
> 	LASSERTF(OBD_MD_FLOSSCAPA == (0x0000040000000000ULL), "found 0x%.16llxULL\n",
> @@ -1277,14 +1275,6 @@ void lustre_assert_wire_constants(void)
> 		 OBD_MD_FLCROSSREF);
> 	LASSERTF(OBD_MD_FLGETATTRLOCK == (0x0000200000000000ULL), "found 0x%.16llxULL\n",
> 		 OBD_MD_FLGETATTRLOCK);
> -	LASSERTF(OBD_MD_FLRMTLSETFACL == (0x0001000000000000ULL), "found 0x%.16llxULL\n",
> -		 OBD_MD_FLRMTLSETFACL);
> -	LASSERTF(OBD_MD_FLRMTLGETFACL == (0x0002000000000000ULL), "found 0x%.16llxULL\n",
> -		 OBD_MD_FLRMTLGETFACL);
> -	LASSERTF(OBD_MD_FLRMTRSETFACL == (0x0004000000000000ULL), "found 0x%.16llxULL\n",
> -		 OBD_MD_FLRMTRSETFACL);
> -	LASSERTF(OBD_MD_FLRMTRGETFACL == (0x0008000000000000ULL), "found 0x%.16llxULL\n",
> -		 OBD_MD_FLRMTRGETFACL);
> 	LASSERTF(OBD_MD_FLDATAVERSION == (0x0010000000000000ULL), "found 0x%.16llxULL\n",
> 		 OBD_MD_FLDATAVERSION);
> 	CLASSERT(OBD_FL_INLINEDATA == 0x00000001);
> @@ -1891,44 +1881,6 @@ void lustre_assert_wire_constants(void)
> 	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->padding) == 4, "found %lld\n",
> 		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->padding));
> 
> -	/* Checks for struct mdt_remote_perm */
> -	LASSERTF((int)sizeof(struct mdt_remote_perm) == 32, "found %lld\n",
> -		 (long long)(int)sizeof(struct mdt_remote_perm));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_uid) == 0, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_uid));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_uid) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_uid));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_gid) == 4, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_gid));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_gid) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_gid));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_fsuid) == 8, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_fsuid));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_fsuid) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_fsuid));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_fsgid) == 16, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_fsgid));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_fsgid) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_fsgid));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_access_perm) == 24, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_access_perm));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_access_perm) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_access_perm));
> -	LASSERTF((int)offsetof(struct mdt_remote_perm, rp_padding) == 28, "found %lld\n",
> -		 (long long)(int)offsetof(struct mdt_remote_perm, rp_padding));
> -	LASSERTF((int)sizeof(((struct mdt_remote_perm *)0)->rp_padding) == 4, "found %lld\n",
> -		 (long long)(int)sizeof(((struct mdt_remote_perm *)0)->rp_padding));
> -	LASSERTF(CFS_SETUID_PERM == 0x00000001UL, "found 0x%.8xUL\n",
> -		(unsigned)CFS_SETUID_PERM);
> -	LASSERTF(CFS_SETGID_PERM == 0x00000002UL, "found 0x%.8xUL\n",
> -		(unsigned)CFS_SETGID_PERM);
> -	LASSERTF(CFS_SETGRP_PERM == 0x00000004UL, "found 0x%.8xUL\n",
> -		(unsigned)CFS_SETGRP_PERM);
> -	LASSERTF(CFS_RMTACL_PERM == 0x00000008UL, "found 0x%.8xUL\n",
> -		(unsigned)CFS_RMTACL_PERM);
> -	LASSERTF(CFS_RMTOWN_PERM == 0x00000010UL, "found 0x%.8xUL\n",
> -		(unsigned)CFS_RMTOWN_PERM);
> -
> 	/* Checks for struct mdt_rec_setattr */
> 	LASSERTF((int)sizeof(struct mdt_rec_setattr) == 136, "found %lld\n",
> 		 (long long)(int)sizeof(struct mdt_rec_setattr));
> -- 
> 1.7.1
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
