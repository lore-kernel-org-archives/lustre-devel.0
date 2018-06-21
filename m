From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jun 2018 02:35:26 +0100 (BST)
Subject: [lustre-devel] [PATCH 09/24] lustre: don't use spare bits in
 iattr.ia_valid
In-Reply-To: <152904669036.10587.17899565981649604892.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669036.10587.17899565981649604892.stgit@noble>
Message-ID: <alpine.LFD.2.21.1806210233170.3886@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Using spare bits in iattr.ia_valid is not safe as the
> bits might get used for some other purpose without
> us noticing.
> lustre currently used 4 spare bit, but they are all
> defined in different places so this isn't immediately
> obvious.
> 
> This patch brings all those bit definitions together
> and defined a new op_data field (op_xvalid) to hold
> the extra validity bits.
> 
> It also replaces sa_valid in struct cl_setattr_io
> with sa_avalid and sa_xvalid.  Changing the name is
> helpful as sa_valid already has another use within
> lustre.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Nak: I see regressions with this patch.

[12368.453655] Lustre: DEBUG MARKER: == sanity test 240: race between ldlm 
enqueue and the connection RPC (no ASSERT) ===================== 21:
16:30 (1529543790)
[12368.760832] BUG: Dentry 
000000002646a847{i=200004282000008,n=f237.sanity}  still in use (1) 
[unmount of lustre lustre]
[12368.773746] WARNING: CPU: 1 PID: 10861 at fs/dcache.c:1514 
umount_check+0x66/0x70
[12368.783364] Modules linked in: ext4(E) mbcache(E) jbd2(E) loop(E) 
lustre(CE) obdecho(CE) mgc(CE) lov(CE) osc(CE) mdc(CE) lmv(CE) fid(CE) fld
(CE) ptlrpc(CE) obdclass(CE) ksocklnd(CE) sha512_generic(E) lnet(CE) 
libcfs(CE) xt_comment(E) xt_multiport(E) nfsv3(E) nfs_acl(E) sg(E) ip6t_RE
JECT(E) nf_reject_ipv6(E) nf_conntrack_ipv6(E) nf_defrag_ipv6(E) 
ip6table_filter(E) ip6_tables(E) ipt_REJECT(E) nf_reject_ipv4(E) 
nf_conntrack_
ipv4(E) nf_defrag_ipv4(E) xt_conntrack(E) nf_conntrack(E) libcrc32c(E) 
iptable_filter(E) dm_mirror(E) dm_region_hash(E) dm_log(E) dm_mod(E) ib_
isert(E) iscsi_target_mod(E) mgag200(E) ttm(E) target_core_mod(E) 
drm_kms_helper(E) rpcrdma(E) x86_pkg_temp_thermal(E) drm(E) 
crc32_pclmul(E) i
b_ucm(E) rdma_ucm(E) ib_uverbs(E) fb_sys_fops(E) syscopyarea(E) ib_iser(E) 
mpt3sas(E) sysfillrect(E)
[12368.869470]  ipmi_si(E) sysimgblt(E) raid_class(E) ib_umad(E) 
rdma_cm(E) ipmi_devintf(E) scsi_transport_sas(E) wmi(E) ib_ipoib(E) 
ipmi_msgha
ndler(E) iw_cm(E) libiscsi(E) ib_cm(E) scsi_transport_iscsi(E) mlx4_ib(E) 
ib_core(E) binfmt_misc(E) ip_tables(E) rpcsec_gss_krb5(E) auth_rpcgss
(E) nfsv4(E) dns_resolver(E) nfs(E) lockd(E) grace(E) fscache(E) 
mlx4_en(E) mlx4_core(E) igb(E) i2c_algo_bit(E) devlink(E) crc32c_intel(E) 
i2c_
core(E) sunrpc(E)
[12368.917172] CPU: 1 PID: 10861 Comm: umount Tainted: G        WC  E     
4.17.0+ #1
[12368.926825] Hardware name: Supermicro X9DRT/X9DRT, BIOS 3.0a 02/19/2014
[12368.935595] RIP: 0010:umount_check+0x66/0x70
[12368.941993] RSP: 0018:ffffc90007313da8 EFLAGS: 00010286
[12368.949342] RAX: 000000000000006a RBX: ffff8810557dcb40 RCX: 
0000000000000000
[12368.958619] RDX: 0000000000000001 RSI: ffff88085fc954f8 RDI: 
ffff88085fc954f8
[12368.967868] RBP: ffff880fec9ef600 R08: 0000000000000000 R09: 
0000000000000896
[12368.977102] R10: 00000000000003ff R11: 0000000000aaaaaa R12: 
ffffffff8124a320
[12368.986315] R13: ffff8810557dcbe0 R14: ffff880fec9ef690 R15: 
ffff8810557dcbe0
[12368.995505] FS:  00007fc174af5880(0000) GS:ffff88085fc80000(0000) 
knlGS:0000000000000000
[12369.005631] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[12369.013395] CR2: 00007fc174b04000 CR3: 0000000822922002 CR4: 
00000000000606e0
[12369.022530] Call Trace:
[12369.026962]  d_walk+0xe1/0x270
[12369.031970]  do_one_tree+0x22/0x40
[12369.037280]  shrink_dcache_for_umount+0x28/0x80
[12369.043685]  generic_shutdown_super+0x1a/0x110
[12369.049977]  kill_anon_super+0xe/0x20
[12369.055463]  deactivate_locked_super+0x39/0x70
[12369.061708]  cleanup_mnt+0x3b/0x70
[12369.066871]  task_work_run+0x7c/0xa0
[12369.072174]  exit_to_usermode_loop+0x5a/0x7e
[12369.078140]  do_syscall_64+0x2b7/0x347
[12369.083547]  ? do_page_fault+0x2d/0x110
[12369.089008]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[12369.095655] RIP: 0033:0x7fc173d69bd7
[12369.100789] RSP: 002b:00007ffc4c89fcc8 EFLAGS: 00000246 ORIG_RAX: 
00000000000000a6
[12369.109902] RAX: 0000000000000000 RBX: 000056521cd63040 RCX: 
00007fc173d69bd7
[12369.118564] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 
000056521cd642b0
[12369.127188] RBP: 000056521cd642b0 R08: 0000000000000000 R09: 
000000000000000f
[12369.135778] R10: 00007ffc4c89f720 R11: 0000000000000246 R12: 
00007fc1748e4d58
[12369.144336] R13: 0000000000000000 R14: 000056521cd648a0 R15: 
000056521cd63040
[12369.152868] Code: 00 00 48 8b 40 28 4c 8b 08 48 8b 46 30 48 85 c0 74 1d 
48 8b 50 40 48 89 0c 24 48 c7 c7 58 5c e6 81 48 89 f1 31 c0 e8 38 cf ea ff 
<0f> 0b eb b2 31 d2 eb e3 66 90 66 66 66 66 90 55 48 89 fd 53 48 
[12369.174646] ---[ end trace 053c2a5a718d3440 ]---
[12369.385564] Lustre: Unmounted lustre-client
[12369.393247] VFS: Busy inodes after unmount of lustre. Self-destruct in 
5 seconds.  Have a nice day...

When I remove this patch things go back to normal. This will not show up
if you do a ONLY="240" sh ./sanity.sh. You have to run the sanity.sh in
total to make this show up.

> ---
>  drivers/staging/lustre/lustre/include/cl_object.h  |    5 +++-
>  .../staging/lustre/lustre/include/lustre_compat.h  |    6 -----
>  .../lustre/include/lustre_patchless_compat.h       |    8 -------
>  drivers/staging/lustre/lustre/include/obd.h        |    7 ++++++
>  drivers/staging/lustre/lustre/llite/file.c         |   12 ++++++----
>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    5 +++-
>  .../staging/lustre/lustre/llite/llite_internal.h   |    5 +++-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |   21 ++++++++++--------
>  drivers/staging/lustre/lustre/llite/vvp_io.c       |    8 +++----
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    5 +++-
>  drivers/staging/lustre/lustre/lov/lov_io.c         |    3 ++-
>  drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   13 ++++++-----
>  drivers/staging/lustre/lustre/osc/osc_io.c         |   23 ++++++++++----------
>  13 files changed, 63 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index 6f7b991be809..caa66763c70d 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -1773,7 +1773,8 @@ struct cl_io {
>  		struct cl_setattr_io {
>  			struct ost_lvb   sa_attr;
>  			unsigned int		 sa_attr_flags;
> -			unsigned int     sa_valid;
> +			unsigned int     sa_avalid;
> +			unsigned int     sa_xvalid;
>  			int		sa_stripe_index;
>  			const struct lu_fid	*sa_parent_fid;
>  		} ci_setattr;
> @@ -2304,7 +2305,7 @@ static inline int cl_io_is_mkwrite(const struct cl_io *io)
>  static inline int cl_io_is_trunc(const struct cl_io *io)
>  {
>  	return io->ci_type == CIT_SETATTR &&
> -		(io->u.ci_setattr.sa_valid & ATTR_SIZE);
> +		(io->u.ci_setattr.sa_avalid & ATTR_SIZE);
>  }
>  
>  struct cl_io *cl_io_top(struct cl_io *io);
> diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
> index 3c6db0d632dc..6d1a433e32c5 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_compat.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
> @@ -41,12 +41,6 @@
>  
>  #include <lustre_patchless_compat.h>
>  
> -/*
> - * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
> - * ATTR_* attributes (see bug 13828)
> - */
> -#define ATTR_BLOCKS    (1 << 27)
> -
>  #define current_ngroups current_cred()->group_info->ngroups
>  #define current_groups current_cred()->group_info->small_block
>  
> diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> index dca1e3dbd183..1bbe1a779ae9 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> @@ -41,12 +41,4 @@
>  #include <linux/hash.h>
>  #include <linux/pagemap.h>
>  
> -#ifndef ATTR_CTIME_SET
> -/*
> - * set ATTR_CTIME_SET to a high value to avoid any risk of collision with other
> - * ATTR_* attributes (see bug 13828)
> - */
> -#define ATTR_CTIME_SET (1 << 28)
> -#endif
> -
>  #endif /* LUSTRE_PATCHLESS_COMPAT_H */
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index b1907bbffb19..d38b6bc6b246 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -723,6 +723,7 @@ struct md_op_data {
>  
>  	/* iattr fields and blocks. */
>  	struct iattr	    op_attr;
> +	unsigned int		op_xvalid; /* eXtra validity flags */
>  	unsigned int	    op_attr_flags;
>  	__u64		   op_valid;
>  	loff_t		  op_attr_blocks;
> @@ -751,6 +752,12 @@ struct md_op_data {
>  	__u32			op_default_stripe_offset;
>  };
>  
> +/* Flags for op_xvalid */
> +#define OP_ATTR_CTIME_SET	(1 << 0)
> +#define OP_ATTR_BLOCKS		(1 << 1)
> +#define OP_ATTR_OWNEROVERRIDE	(1 << 2)
> +#define OP_ATTR_FLAGS		(1 << 3)
> +
>  struct md_callback {
>  	int (*md_blocking_ast)(struct ldlm_lock *lock,
>  			       struct ldlm_lock_desc *desc,
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index e888ed6e74bc..e642996db53f 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -93,9 +93,10 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
>  	op_data->op_attr.ia_mtime = inode->i_mtime;
>  	op_data->op_attr.ia_ctime = inode->i_ctime;
>  	op_data->op_attr.ia_size = i_size_read(inode);
> -	op_data->op_attr.ia_valid |= ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
> -				     ATTR_MTIME | ATTR_MTIME_SET |
> -				     ATTR_CTIME | ATTR_CTIME_SET;
> +	op_data->op_attr.ia_valid |= (ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
> +				      ATTR_MTIME | ATTR_MTIME_SET |
> +				      ATTR_CTIME);
> +	op_data->op_xvalid |= OP_ATTR_CTIME_SET;
>  	op_data->op_attr_blocks = inode->i_blocks;
>  	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
>  	op_data->op_handle = och->och_fh;
> @@ -161,7 +162,8 @@ static int ll_close_inode_openhandle(struct inode *inode,
>  		op_data->op_bias |= MDS_HSM_RELEASE;
>  		op_data->op_data_version = *(__u64 *)data;
>  		op_data->op_lease_handle = och->och_lease_handle;
> -		op_data->op_attr.ia_valid |= ATTR_SIZE | ATTR_BLOCKS;
> +		op_data->op_attr.ia_valid |= ATTR_SIZE;
> +		op_data->op_xvalid |= OP_ATTR_BLOCKS;
>  		break;
>  
>  	default:
> @@ -1906,7 +1908,7 @@ static int ll_hsm_import(struct inode *inode, struct file *file,
>  
>  	inode_lock(inode);
>  
> -	rc = ll_setattr_raw(file->f_path.dentry, attr, true);
> +	rc = ll_setattr_raw(file->f_path.dentry, attr, 0, true);
>  	if (rc == -ENODATA)
>  		rc = 0;
>  
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> index d7ea39ce0cb2..9d1f3881f860 100644
> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> @@ -80,7 +80,7 @@ u16 cl_inode_fini_refcheck;
>  static DEFINE_MUTEX(cl_inode_fini_guard);
>  
>  int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
> -		   unsigned int attr_flags)
> +		   unsigned int xvalid, unsigned int attr_flags)
>  {
>  	struct lu_env *env;
>  	struct cl_io  *io;
> @@ -100,7 +100,8 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
>  	io->u.ci_setattr.sa_attr.lvb_ctime = LTIME_S(attr->ia_ctime);
>  	io->u.ci_setattr.sa_attr.lvb_size = attr->ia_size;
>  	io->u.ci_setattr.sa_attr_flags = attr_flags;
> -	io->u.ci_setattr.sa_valid = attr->ia_valid;
> +	io->u.ci_setattr.sa_avalid = attr->ia_valid;
> +	io->u.ci_setattr.sa_xvalid = xvalid;
>  	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&obj->co_lu);
>  
>  again:
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 28cff58690d6..b750a48fd0e1 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -805,7 +805,8 @@ void ll_kill_super(struct super_block *sb);
>  struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock);
>  void ll_dir_clear_lsm_md(struct inode *inode);
>  void ll_clear_inode(struct inode *inode);
> -int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import);
> +int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
> +		   unsigned int xvalid, bool hsm_import);
>  int ll_setattr(struct dentry *de, struct iattr *attr);
>  int ll_statfs(struct dentry *de, struct kstatfs *sfs);
>  int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
> @@ -1330,7 +1331,7 @@ int ll_getparent(struct file *file, struct getparent __user *arg);
>  
>  /* lcommon_cl.c */
>  int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
> -		   unsigned int attr_flags);
> +		   unsigned int xvalid, unsigned int attr_flags);
>  
>  extern struct lu_env *cl_inode_fini_env;
>  extern u16 cl_inode_fini_refcheck;
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index 36066c839160..cd0f2517a3b3 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -1429,7 +1429,8 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
>   *
>   * In case of HSMimport, we only set attr on MDS.
>   */
> -int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
> +int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
> +		   unsigned int xvalid, bool hsm_import)
>  {
>  	struct inode *inode = d_inode(dentry);
>  	struct ll_inode_info *lli = ll_i2info(inode);
> @@ -1470,7 +1471,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
>  	/* We mark all of the fields "set" so MDS/OST does not re-set them */
>  	if (attr->ia_valid & ATTR_CTIME) {
>  		attr->ia_ctime = current_time(inode);
> -		attr->ia_valid |= ATTR_CTIME_SET;
> +		xvalid |= OP_ATTR_CTIME_SET;
>  	}
>  	if (!(attr->ia_valid & ATTR_ATIME_SET) &&
>  	    (attr->ia_valid & ATTR_ATIME)) {
> @@ -1506,12 +1507,13 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
>  		 * If we are changing file size, file content is
>  		 * modified, flag it.
>  		 */
> -		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
> +		xvalid |= OP_ATTR_OWNEROVERRIDE;
>  		op_data->op_bias |= MDS_DATA_MODIFIED;
>  		clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
>  	}
>  
>  	op_data->op_attr = *attr;
> +	op_data->op_xvalid = xvalid;
>  
>  	rc = ll_md_setattr(dentry, op_data);
>  	if (rc)
> @@ -1532,7 +1534,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
>  		 * setting times to past, but it is necessary due to possible
>  		 * time de-synchronization between MDT inode and OST objects
>  		 */
> -		rc = cl_setattr_ost(ll_i2info(inode)->lli_clob, attr, 0);
> +		rc = cl_setattr_ost(ll_i2info(inode)->lli_clob,
> +				    attr, xvalid, 0);
>  	}
>  
>  	/*
> @@ -1589,10 +1592,11 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
>  int ll_setattr(struct dentry *de, struct iattr *attr)
>  {
>  	int mode = d_inode(de)->i_mode;
> +	unsigned int xvalid = 0;
>  
>  	if ((attr->ia_valid & (ATTR_CTIME | ATTR_SIZE | ATTR_MODE)) ==
>  			      (ATTR_CTIME | ATTR_SIZE | ATTR_MODE))
> -		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
> +		xvalid |= OP_ATTR_OWNEROVERRIDE;
>  
>  	if (((attr->ia_valid & (ATTR_MODE | ATTR_FORCE | ATTR_SIZE)) ==
>  			       (ATTR_SIZE | ATTR_MODE)) &&
> @@ -1613,7 +1617,7 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
>  	    !(attr->ia_valid & ATTR_KILL_SGID))
>  		attr->ia_valid |= ATTR_KILL_SGID;
>  
> -	return ll_setattr_raw(de, attr, false);
> +	return ll_setattr_raw(de, attr, xvalid, false);
>  }
>  
>  int ll_statfs_internal(struct super_block *sb, struct obd_statfs *osfs,
> @@ -1946,7 +1950,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
>  			return PTR_ERR(op_data);
>  
>  		op_data->op_attr_flags = flags;
> -		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
> +		op_data->op_xvalid |= OP_ATTR_FLAGS;
>  		rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &req);
>  		ll_finish_md_op_data(op_data);
>  		ptlrpc_req_finished(req);
> @@ -1963,8 +1967,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
>  		if (!attr)
>  			return -ENOMEM;
>  
> -		attr->ia_valid = ATTR_ATTR_FLAG;
> -		rc = cl_setattr_ost(obj, attr, flags);
> +		rc = cl_setattr_ost(obj, attr, OP_ATTR_FLAGS, flags);
>  		kfree(attr);
>  		return rc;
>  	}
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
> index e7a4778e02e4..e65523f7628d 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
> @@ -556,7 +556,7 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
>  		if (new_size == 0)
>  			enqflags = CEF_DISCARD_DATA;
>  	} else {
> -		unsigned int valid = io->u.ci_setattr.sa_valid;
> +		unsigned int valid = io->u.ci_setattr.sa_avalid;
>  
>  		if (!(valid & TIMES_SET_FLAGS))
>  			return 0;
> @@ -603,11 +603,11 @@ static int vvp_io_setattr_time(const struct lu_env *env,
>  
>  	cl_object_attr_lock(obj);
>  	attr->cat_ctime = io->u.ci_setattr.sa_attr.lvb_ctime;
> -	if (io->u.ci_setattr.sa_valid & ATTR_ATIME_SET) {
> +	if (io->u.ci_setattr.sa_avalid & ATTR_ATIME_SET) {
>  		attr->cat_atime = io->u.ci_setattr.sa_attr.lvb_atime;
>  		valid |= CAT_ATIME;
>  	}
> -	if (io->u.ci_setattr.sa_valid & ATTR_MTIME_SET) {
> +	if (io->u.ci_setattr.sa_avalid & ATTR_MTIME_SET) {
>  		attr->cat_mtime = io->u.ci_setattr.sa_attr.lvb_mtime;
>  		valid |= CAT_MTIME;
>  	}
> @@ -632,7 +632,7 @@ static int vvp_io_setattr_start(const struct lu_env *env,
>  		inode_lock(inode);
>  	}
>  
> -	if (io->u.ci_setattr.sa_valid & TIMES_SET_FLAGS)
> +	if (io->u.ci_setattr.sa_avalid & TIMES_SET_FLAGS)
>  		return vvp_io_setattr_time(env, ios);
>  
>  	return 0;
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 65f94e6ecaad..9f427a7c7b03 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -1983,8 +1983,9 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
>  	struct lmv_obd	  *lmv = &obd->u.lmv;
>  	struct lmv_tgt_desc     *tgt;
>  
> -	CDEBUG(D_INODE, "SETATTR for " DFID ", valid 0x%x\n",
> -	       PFID(&op_data->op_fid1), op_data->op_attr.ia_valid);
> +	CDEBUG(D_INODE, "SETATTR for " DFID ", valid 0x%x/0x%x\n",
> +	       PFID(&op_data->op_fid1), op_data->op_attr.ia_valid,
> +		op_data->op_xvalid);
>  
>  	op_data->op_flags |= MF_MDC_CANCEL_FID1;
>  	tgt = lmv_find_target(lmv, &op_data->op_fid1);
> diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
> index b823f8a21856..50982848bca4 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_io.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_io.c
> @@ -77,7 +77,8 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
>  		io->u.ci_setattr.sa_attr = parent->u.ci_setattr.sa_attr;
>  		io->u.ci_setattr.sa_attr_flags =
>  					parent->u.ci_setattr.sa_attr_flags;
> -		io->u.ci_setattr.sa_valid = parent->u.ci_setattr.sa_valid;
> +		io->u.ci_setattr.sa_avalid = parent->u.ci_setattr.sa_avalid;
> +		io->u.ci_setattr.sa_xvalid = parent->u.ci_setattr.sa_xvalid;
>  		io->u.ci_setattr.sa_stripe_index = stripe;
>  		io->u.ci_setattr.sa_parent_fid =
>  					parent->u.ci_setattr.sa_parent_fid;
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
> index d582968987ff..ad7c13be5e3c 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
> @@ -234,7 +234,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
>  	set_mrc_cr_flags(rec, cr_flags);
>  }
>  
> -static inline __u64 attr_pack(unsigned int ia_valid)
> +static inline __u64 attr_pack(unsigned int ia_valid, unsigned int ia_xvalid)
>  {
>  	__u64 sa_valid = 0;
>  
> @@ -258,19 +258,19 @@ static inline __u64 attr_pack(unsigned int ia_valid)
>  		sa_valid |= MDS_ATTR_MTIME_SET;
>  	if (ia_valid & ATTR_FORCE)
>  		sa_valid |= MDS_ATTR_FORCE;
> -	if (ia_valid & ATTR_ATTR_FLAG)
> +	if (ia_xvalid & OP_ATTR_FLAGS)
>  		sa_valid |= MDS_ATTR_ATTR_FLAG;
>  	if (ia_valid & ATTR_KILL_SUID)
>  		sa_valid |=  MDS_ATTR_KILL_SUID;
>  	if (ia_valid & ATTR_KILL_SGID)
>  		sa_valid |= MDS_ATTR_KILL_SGID;
> -	if (ia_valid & ATTR_CTIME_SET)
> +	if (ia_xvalid & OP_ATTR_CTIME_SET)
>  		sa_valid |= MDS_ATTR_CTIME_SET;
>  	if (ia_valid & ATTR_OPEN)
>  		sa_valid |= MDS_ATTR_FROM_OPEN;
> -	if (ia_valid & ATTR_BLOCKS)
> +	if (ia_xvalid & OP_ATTR_BLOCKS)
>  		sa_valid |= MDS_ATTR_BLOCKS;
> -	if (ia_valid & MDS_OPEN_OWNEROVERRIDE)
> +	if (ia_xvalid & OP_ATTR_OWNEROVERRIDE)
>  		/* NFSD hack (see bug 5781) */
>  		sa_valid |= MDS_OPEN_OWNEROVERRIDE;
>  	return sa_valid;
> @@ -286,7 +286,8 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
>  	rec->sa_suppgid = -1;
>  
>  	rec->sa_fid    = op_data->op_fid1;
> -	rec->sa_valid  = attr_pack(op_data->op_attr.ia_valid);
> +	rec->sa_valid  = attr_pack(op_data->op_attr.ia_valid,
> +				   op_data->op_xvalid);
>  	rec->sa_mode   = op_data->op_attr.ia_mode;
>  	rec->sa_uid    = from_kuid(&init_user_ns, op_data->op_attr.ia_uid);
>  	rec->sa_gid    = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
> diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
> index 67734a8ed331..955525f69958 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_io.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_io.c
> @@ -499,7 +499,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
>  	struct obdo *oa = &oio->oi_oa;
>  	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
>  	__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
> -	unsigned int ia_valid = io->u.ci_setattr.sa_valid;
> +	unsigned int ia_avalid = io->u.ci_setattr.sa_avalid;
> +	unsigned int ia_xvalid = io->u.ci_setattr.sa_xvalid;
>  	int result = 0;
>  
>  	/* truncate cache dirty pages first */
> @@ -514,20 +515,20 @@ static int osc_io_setattr_start(const struct lu_env *env,
>  			struct ost_lvb *lvb = &io->u.ci_setattr.sa_attr;
>  			unsigned int cl_valid = 0;
>  
> -			if (ia_valid & ATTR_SIZE) {
> +			if (ia_avalid & ATTR_SIZE) {
>  				attr->cat_size = size;
>  				attr->cat_kms = size;
>  				cl_valid = CAT_SIZE | CAT_KMS;
>  			}
> -			if (ia_valid & ATTR_MTIME_SET) {
> +			if (ia_avalid & ATTR_MTIME_SET) {
>  				attr->cat_mtime = lvb->lvb_mtime;
>  				cl_valid |= CAT_MTIME;
>  			}
> -			if (ia_valid & ATTR_ATIME_SET) {
> +			if (ia_avalid & ATTR_ATIME_SET) {
>  				attr->cat_atime = lvb->lvb_atime;
>  				cl_valid |= CAT_ATIME;
>  			}
> -			if (ia_valid & ATTR_CTIME_SET) {
> +			if (ia_xvalid & OP_ATTR_CTIME_SET) {
>  				attr->cat_ctime = lvb->lvb_ctime;
>  				cl_valid |= CAT_CTIME;
>  			}
> @@ -542,19 +543,19 @@ static int osc_io_setattr_start(const struct lu_env *env,
>  		obdo_set_parent_fid(oa, io->u.ci_setattr.sa_parent_fid);
>  		oa->o_stripe_idx = io->u.ci_setattr.sa_stripe_index;
>  		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP;
> -		if (ia_valid & ATTR_CTIME) {
> +		if (ia_avalid & ATTR_CTIME) {
>  			oa->o_valid |= OBD_MD_FLCTIME;
>  			oa->o_ctime = attr->cat_ctime;
>  		}
> -		if (ia_valid & ATTR_ATIME) {
> +		if (ia_avalid & ATTR_ATIME) {
>  			oa->o_valid |= OBD_MD_FLATIME;
>  			oa->o_atime = attr->cat_atime;
>  		}
> -		if (ia_valid & ATTR_MTIME) {
> +		if (ia_avalid & ATTR_MTIME) {
>  			oa->o_valid |= OBD_MD_FLMTIME;
>  			oa->o_mtime = attr->cat_mtime;
>  		}
> -		if (ia_valid & ATTR_SIZE) {
> +		if (ia_avalid & ATTR_SIZE) {
>  			oa->o_size = size;
>  			oa->o_blocks = OBD_OBJECT_EOF;
>  			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
> @@ -566,14 +567,14 @@ static int osc_io_setattr_start(const struct lu_env *env,
>  		} else {
>  			LASSERT(oio->oi_lockless == 0);
>  		}
> -		if (ia_valid & ATTR_ATTR_FLAG) {
> +		if (ia_xvalid & OP_ATTR_FLAGS) {
>  			oa->o_flags = io->u.ci_setattr.sa_attr_flags;
>  			oa->o_valid |= OBD_MD_FLFLAGS;
>  		}
>  
>  		init_completion(&cbargs->opc_sync);
>  
> -		if (ia_valid & ATTR_SIZE)
> +		if (ia_avalid & ATTR_SIZE)
>  			result = osc_punch_base(osc_export(cl2osc(obj)),
>  						oa, osc_async_upcall,
>  						cbargs, PTLRPCD_SET);
> 
> 
> 
