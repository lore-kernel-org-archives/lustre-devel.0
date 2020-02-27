From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:46 -0500
Subject: [lustre-devel] [PATCH 358/622] lustre: llite: Add persistent cache
 on client
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-359-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

PCC is a new framework which provides a group of local cache
on Lustre client side. No global namespace will be provided
by PCC. Each client uses its own local storage as a cache for
itself. Local file system is used to manage the data on local
caches. Cached I/O is directed to local filesystem while
normal I/O is directed to OSTs.

PCC uses HSM for data synchronization. It uses HSM copytool
to restore file from local caches to Lustre OSTs. Each PCC
has a copytool instance running with unique archive number.
Any remote access from another Lustre client would trigger
the data synchronization. If a client with PCC goes offline,
the cached data becomes inaccessible for other client
temporarilly. And after the PCC client reboots and the copytool
restarts, the data will be accessible again.

ToDo:
1) Make PCC exclusive with HSM.
2) Strong size consistence for PCC cached file among clients.
3) Support to cache partial content of a file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: f172b1168857 ("LU-10092 llite: Add persistent cache on client")
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/32963
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-12438
Lustre-commit: b5a6ec93ce56 ("LU-12438 llite: vfs_read/write removed, use kernel_read/write")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35223
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                 |    2 +
 fs/lustre/llite/Makefile                |    2 +-
 fs/lustre/llite/dir.c                   |   74 +++
 fs/lustre/llite/file.c                  |  164 ++++-
 fs/lustre/llite/llite_internal.h        |   25 +
 fs/lustre/llite/llite_lib.c             |   45 +-
 fs/lustre/llite/llite_mmap.c            |    8 +
 fs/lustre/llite/lproc_llite.c           |   45 +-
 fs/lustre/llite/namei.c                 |   79 ++-
 fs/lustre/llite/pcc.c                   | 1042 +++++++++++++++++++++++++++++++
 fs/lustre/llite/pcc.h                   |  129 ++++
 fs/lustre/llite/super25.c               |   10 +
 fs/lustre/lmv/lmv_intent.c              |    6 +-
 fs/lustre/lmv/lmv_obd.c                 |    1 +
 fs/lustre/mdc/mdc_lib.c                 |    6 +
 include/uapi/linux/lustre/lustre_idl.h  |    8 +-
 include/uapi/linux/lustre/lustre_user.h |   50 +-
 17 files changed, 1654 insertions(+), 42 deletions(-)
 create mode 100644 fs/lustre/llite/pcc.c
 create mode 100644 fs/lustre/llite/pcc.h

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 2f878d6..f53c303 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -796,6 +796,8 @@ struct md_op_data {
 	bool			op_post_migrate;
 	/* used to access dir with bash hash */
 	u32			op_stripe_index;
+	/* Archive ID for PCC attach */
+	u32			op_archive_id;
 };
 
 struct md_callback {
diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index 811b9ab..c88a1b0 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -7,6 +7,6 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_io.o vvp_object.o \
-	    lproc_llite.o
+	    lproc_llite.o pcc.o
 
 lustre-$(CONFIG_LUSTRE_FS_POSIX_ACL) += acl.o
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index a1dce52..337582b 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1917,6 +1917,80 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
+	case LL_IOC_PCC_DETACH: {
+		struct lu_pcc_detach *detach;
+		struct lu_fid *fid;
+		struct inode *inode2;
+		unsigned long ino;
+
+		/*
+		 * The reason why a dir IOCTL is used to detach a PCC-cached
+		 * file rather than making it a file IOCTL is:
+		 * When PCC caching a file, it will attach the file firstly,
+		 * and increase the refcount of PCC inode (pcci->pcci_refcount)
+		 * from 0 to 1.
+		 * When detaching a PCC-cached file, it will check whether the
+		 * refcount is 1. If so, the file can be detached successfully.
+		 * Otherwise, it means there are some users opened and using
+		 * the file currently, and it will return -EBUSY.
+		 * Each open on the PCC-cached file will increase the refcount
+		 * of the PCC inode;
+		 * Each close on the PCC-cached file will decrease the refcount
+		 * of the PCC inode;
+		 * When used a file IOCTL to detach a PCC-cached file, it needs
+		 * to open it at first, which will increase the refcount. So
+		 * during the process of the detach IOCTL, it will return
+		 * -EBUSY as the PCC inode refcount is larger than 1. Someone
+		 * might argue that here it can just decrease the refcount
+		 * of the PCC inode, return succeed and make the close of
+		 * IOCTL file handle to perform the real detach. But this
+		 * may result in inconsistent state of a PCC file. i.e. Process
+		 * A got a successful return form the detach IOCTL; Process B
+		 * opens the file before Process A finally closed the IOCTL
+		 * file handle. It makes the following I/O of Process B will
+		 * direct into PCC although the file was already detached from
+		 * the view of Process A.
+		 * Using a dir IOCTL does not exist the problem above.
+		 */
+		detach = kzalloc(sizeof(*detach), GFP_KERNEL);
+		if (!detach)
+			return -ENOMEM;
+
+		if (copy_from_user(detach,
+				   (const struct lu_pcc_detach __user *)arg,
+				   sizeof(*detach))) {
+			rc = -EFAULT;
+			goto out_detach;
+		}
+
+		fid = &detach->pccd_fid;
+		ino = cl_fid_build_ino(fid, ll_need_32bit_api(sbi));
+		inode2 = ilookup5(inode->i_sb, ino, ll_test_inode_by_fid, fid);
+		if (!inode2) {
+			/* Target inode is not in inode cache, and PCC file
+			 * has aleady released, return immdiately.
+			 */
+			rc = 0;
+			goto out_detach;
+		}
+
+		if (!S_ISREG(inode2->i_mode)) {
+			rc = -EINVAL;
+			goto out_iput;
+		}
+
+		if (!inode_owner_or_capable(inode2)) {
+			rc = -EPERM;
+			goto out_iput;
+		}
+
+		rc = pcc_ioctl_detach(inode2);
+out_iput:
+		iput(inode2);
+out_detach:
+		kfree(detach);
+		return rc;
+	}
 	default:
 		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
 				     (void __user *)arg);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 88d5c2d..95e7c73 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -56,6 +56,11 @@ struct split_param {
 	u16		sp_mirror_id;
 };
 
+struct pcc_param {
+	u64	pa_data_version;
+	u32	pa_archive_id;
+};
+
 static int
 ll_put_grouplock(struct inode *inode, struct file *file, unsigned long arg);
 
@@ -70,6 +75,8 @@ static struct ll_file_data *ll_file_data_get(void)
 	if (!fd)
 		return NULL;
 	fd->fd_write_failed = false;
+	pcc_file_init(&fd->fd_pcc_file);
+
 	return fd;
 }
 
@@ -192,6 +199,17 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		break;
 	}
 
+	case MDS_PCC_ATTACH: {
+		struct pcc_param *param = data;
+
+		LASSERT(data);
+		op_data->op_bias |= MDS_HSM_RELEASE | MDS_PCC_ATTACH;
+		op_data->op_archive_id = param->pa_archive_id;
+		op_data->op_data_version = param->pa_data_version;
+		op_data->op_lease_handle = och->och_lease_handle;
+		break;
+	}
+
 	case MDS_HSM_RELEASE:
 		LASSERT(data);
 		op_data->op_bias |= MDS_HSM_RELEASE;
@@ -378,6 +396,8 @@ int ll_file_release(struct inode *inode, struct file *file)
 		return 0;
 	}
 
+	pcc_file_release(inode, file);
+
 	if (!S_ISDIR(inode->i_mode)) {
 		if (lli->lli_clob)
 			lov_read_and_clear_async_rc(lli->lli_clob);
@@ -833,6 +853,10 @@ int ll_file_open(struct inode *inode, struct file *file)
 		if (rc)
 			goto out_och_free;
 	}
+	rc = pcc_file_open(inode, file);
+	if (rc)
+		goto out_och_free;
+
 	mutex_unlock(&lli->lli_och_mutex);
 	fd = NULL;
 
@@ -858,6 +882,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 out_openerr:
 		if (lli->lli_opendir_key == fd)
 			ll_deauthorize_statahead(inode, fd);
+
 		if (fd)
 			ll_file_data_put(fd);
 	} else {
@@ -1632,6 +1657,22 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t result;
 	u16 refcheck;
 	ssize_t rc2;
+	bool cached = false;
+
+	/**
+	 * Currently when PCC read failed, we do not fall back to the
+	 * normal read path, just return the error.
+	 * The resaon is that: for RW-PCC, the file data may be modified
+	 * in the PCC and inconsistent with the data on OSTs (or file
+	 * data has been removed from the Lustre file system), at this
+	 * time, fallback to the normal read path may read the wrong
+	 * data.
+	 * TODO: for RO-PCC (readonly PCC), fall back to normal read
+	 * path: read data from data copy on OSTs.
+	 */
+	result = pcc_file_read_iter(iocb, to, &cached);
+	if (cached)
+		return result;
 
 	ll_ras_enter(iocb->ki_filp);
 
@@ -1725,6 +1766,21 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct vvp_io_args *args;
 	ssize_t rc_tiny = 0, rc_normal;
 	u16 refcheck;
+	bool cached = false;
+	int result;
+
+	/**
+	 * When PCC write failed, we do not fall back to the normal
+	 * write path, just return the error. The reason is that:
+	 * PCC is actually a HSM device, and HSM does not handle the
+	 * failure especially -ENOSPC due to space used out; Moreover,
+	 * the fallback to normal I/O path for ENOSPC failure, needs
+	 * to restore the file data to OSTs first and redo the write
+	 * again, making the logic of PCC very complex.
+	 */
+	result = pcc_file_write_iter(iocb, from, &cached);
+	if (cached)
+		return result;
 
 	/* NB: we can't do direct IO for tiny writes because they use the page
 	 * cache, we can't do sync writes because tiny writes can't flush
@@ -2979,13 +3035,15 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct obd_client_handle *och = NULL;
 	struct split_param sp;
-	bool lease_broken;
+	struct pcc_param param;
+	bool lease_broken = false;
 	fmode_t fmode = 0;
 	enum mds_op_bias bias = 0;
 	struct file *layout_file = NULL;
 	void *data = NULL;
 	size_t data_size = 0;
-	long rc;
+	bool attached = false;
+	long rc, rc2 = 0;
 
 	mutex_lock(&lli->lli_och_mutex);
 	if (fd->fd_lease_och) {
@@ -2994,10 +3052,8 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	}
 	mutex_unlock(&lli->lli_och_mutex);
 
-	if (!och) {
-		rc = -ENOLCK;
-		goto out;
-	}
+	if (!och)
+		return -ENOLCK;
 
 	fmode = och->och_flags;
 
@@ -3005,19 +3061,19 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	case LL_LEASE_RESYNC_DONE:
 		if (ioc->lil_count > IOC_IDS_MAX) {
 			rc = -EINVAL;
-			goto out;
+			goto out_lease_close;
 		}
 
 		data_size = offsetof(typeof(*ioc), lil_ids[ioc->lil_count]);
 		data = kzalloc(data_size, GFP_KERNEL);
 		if (!data) {
 			rc = -ENOMEM;
-			goto out;
+			goto out_lease_close;
 		}
 
 		if (copy_from_user(data, (void __user *)arg, data_size)) {
 			rc = -EFAULT;
-			goto out;
+			goto out_lease_close;
 		}
 
 		bias = MDS_CLOSE_RESYNC_DONE;
@@ -3027,25 +3083,25 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 
 		if (ioc->lil_count != 1) {
 			rc = -EINVAL;
-			goto out;
+			goto out_lease_close;
 		}
 
 		arg += sizeof(*ioc);
 		if (copy_from_user(&fd, (void __user *)arg, sizeof(u32))) {
 			rc = -EFAULT;
-			goto out;
+			goto out_lease_close;
 		}
 
 		layout_file = fget(fd);
 		if (!layout_file) {
 			rc = -EBADF;
-			goto out;
+			goto out_lease_close;
 		}
 
 		if ((file->f_flags & O_ACCMODE) == O_RDONLY ||
 		    (layout_file->f_flags & O_ACCMODE) == O_RDONLY) {
 			rc = -EPERM;
-			goto out;
+			goto out_lease_close;
 		}
 
 		data = file_inode(layout_file);
@@ -3058,26 +3114,26 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 
 		if (ioc->lil_count != 2) {
 			rc = -EINVAL;
-			goto out;
+			goto out_lease_close;
 		}
 
 		arg += sizeof(*ioc);
 		if (copy_from_user(&fdv, (void __user *)arg, sizeof(u32))) {
 			rc = -EFAULT;
-			goto out;
+			goto out_lease_close;
 		}
 
 		arg += sizeof(u32);
 		if (copy_from_user(&mirror_id, (void __user *)arg,
 				   sizeof(u32))) {
 			rc = -EFAULT;
-			goto out;
+			goto out_lease_close;
 		}
 
 		layout_file = fget(fdv);
 		if (!layout_file) {
 			rc = -EBADF;
-			goto out;
+			goto out_lease_close;
 		}
 
 		sp.sp_inode = file_inode(layout_file);
@@ -3086,11 +3142,37 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		bias = MDS_CLOSE_LAYOUT_SPLIT;
 		break;
 	}
+	case LL_LEASE_PCC_ATTACH:
+		if (ioc->lil_count != 1)
+			return -EINVAL;
+
+		arg += sizeof(*ioc);
+		if (copy_from_user(&param.pa_archive_id, (void __user *)arg,
+				   sizeof(u32))) {
+			rc2 = -EFAULT;
+			goto out_lease_close;
+		}
+
+		rc2 = pcc_readwrite_attach(file, inode, param.pa_archive_id);
+		if (rc2)
+			goto out_lease_close;
+
+		attached = true;
+		/* Grab latest data version */
+		rc2 = ll_data_version(inode, &param.pa_data_version,
+				     LL_DV_WR_FLUSH);
+		if (rc2)
+			goto out_lease_close;
+
+		data = &param;
+		bias = MDS_PCC_ATTACH;
+		break;
 	default:
 		/* without close intent */
 		break;
 	}
 
+out_lease_close:
 	rc = ll_lease_close_intent(och, inode, &lease_broken, bias, data);
 	if (rc < 0)
 		goto out;
@@ -3112,6 +3194,12 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		if (layout_file)
 			fput(layout_file);
 		break;
+	case LL_LEASE_PCC_ATTACH:
+		if (!rc)
+			rc = rc2;
+		rc = pcc_readwrite_attach_fini(file, inode, lease_broken,
+					       rc, attached);
+		break;
 	}
 
 	if (!rc)
@@ -3633,6 +3721,33 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		rc = ll_heat_set(inode, flags);
 		return rc;
 	}
+	case LL_IOC_PCC_STATE: {
+		struct lu_pcc_state __user *ustate =
+			(struct lu_pcc_state __user *)arg;
+		struct lu_pcc_state *state;
+
+		state = kzalloc(sizeof(*state), GFP_KERNEL);
+		if (!state)
+			return -ENOMEM;
+
+		if (copy_from_user(state, ustate, sizeof(*state))) {
+			rc = -EFAULT;
+			goto out_state;
+		}
+
+		rc = pcc_ioctl_state(inode, state);
+		if (rc)
+			goto out_state;
+
+		if (copy_to_user(ustate, state, sizeof(*state))) {
+			rc = -EFAULT;
+			goto out_state;
+		}
+
+out_state:
+		kfree(state);
+		return rc;
+	}
 	default:
 		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
 				     (void __user *)arg);
@@ -3740,13 +3855,20 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ptlrpc_request *req;
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
 	int rc, err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
+	/* pcc cache path */
+	if (pcc_file)
+		return file_inode(pcc_file)->i_fop->fsync(pcc_file,
+					start, end, datasync);
+
 	rc = file_write_and_wait_range(file, start, end);
 	inode_lock(inode);
 
@@ -4294,6 +4416,11 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		return rc;
 
 	if (S_ISREG(inode->i_mode)) {
+		bool cached = false;
+
+		rc = pcc_inode_getattr(inode, &cached);
+		if (cached && rc < 0)
+			return rc;
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
 		 * inode is up-to-date so glimpse is useless.
@@ -4301,7 +4428,8 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		 * restore the MDT holds the layout lock so the glimpse will
 		 * block up to the end of restore (getattr will block)
 		 */
-		if (!test_bit(LLIF_FILE_RESTORING, &lli->lli_flags)) {
+		if (!cached && !test_bit(LLIF_FILE_RESTORING,
+					 &lli->lli_flags)) {
 			rc = ll_glimpse_size(inode);
 			if (rc < 0)
 				return rc;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9e413c2..f2ea856 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -49,6 +49,7 @@
 #include <linux/posix_acl_xattr.h>
 #include "vvp_internal.h"
 #include "range_lock.h"
+#include "pcc.h"
 
 /** Only used on client-side for indicating the tail of dir hash/offset. */
 #define LL_DIR_END_OFF	  0x7fffffffffffffffULL
@@ -205,6 +206,9 @@ struct ll_inode_info {
 			 * accurate if the file is shared by different jobs.
 			 */
 			char				lli_jobid[LUSTRE_JOBID_SIZE];
+
+			struct mutex		 lli_pcc_lock;
+			struct pcc_inode	*lli_pcc_inode;
 		};
 	};
 
@@ -297,6 +301,11 @@ static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 	return container_of(inode, struct ll_inode_info, lli_vfs_inode);
 }
 
+static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
+{
+	return ll_i2info(inode)->lli_pcc_inode;
+}
+
 /* default to about 64M of readahead on a given system. */
 #define SBI_DEFAULT_READAHEAD_MAX		MiB_TO_PAGES(64UL)
 
@@ -552,6 +561,9 @@ struct ll_sb_info {
 
 	/* filesystem fsname */
 	char			ll_fsname[LUSTRE_MAXFSNAME + 1];
+
+	/* Persistent Client Cache */
+	struct pcc_super	ll_pcc_super;
 };
 
 #define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
@@ -672,6 +684,7 @@ struct ll_file_data {
 	 * layout version for verification to OST objects
 	 */
 	u32 fd_layout_version;
+	struct pcc_file fd_pcc_file;
 };
 
 void llite_tunables_unregister(void);
@@ -1355,6 +1368,18 @@ static inline void d_lustre_revalidate(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 }
 
+static inline dev_t ll_compat_encode_dev(dev_t dev)
+{
+	/* The compat_sys_*stat*() syscalls will fail unless the
+	 * device majors and minors are both less than 256. Note that
+	 * the value returned here will be passed through
+	 * old_encode_dev() in cp_compat_stat(). And so we are not
+	 * trying to return a valid compat (u16) device number, just
+	 * one that will pass the old_valid_dev() check.
+	 */
+	return MKDEV(MAJOR(dev) & 0xff, MINOR(dev) & 0xff);
+}
+
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
 int ll_layout_refresh(struct inode *inode, u32 *gen);
 int ll_layout_restore(struct inode *inode, loff_t start, u64 length);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 0633cc5..d46bc99 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -128,6 +128,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_squash.rsi_gid = 0;
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
 	spin_lock_init(&sbi->ll_squash.rsi_lock);
+	pcc_super_init(&sbi->ll_pcc_super);
 
 	/* Per-filesystem file heat */
 	sbi->ll_heat_decay_weight = SBI_DEFAULT_HEAT_DECAY_WEIGHT;
@@ -139,13 +140,13 @@ static void ll_free_sbi(struct super_block *sb)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 
+	if (!list_empty(&sbi->ll_squash.rsi_nosquash_nids))
+		cfs_free_nidlist(&sbi->ll_squash.rsi_nosquash_nids);
 	if (sbi->ll_cache) {
-		if (!list_empty(&sbi->ll_squash.rsi_nosquash_nids))
-			cfs_free_nidlist(&sbi->ll_squash.rsi_nosquash_nids);
 		cl_cache_decref(sbi->ll_cache);
 		sbi->ll_cache = NULL;
 	}
-
+	pcc_super_fini(&sbi->ll_pcc_super);
 	kfree(sbi);
 }
 
@@ -215,7 +216,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
 				   OBD_CONNECT2_LSOM |
-				   OBD_CONNECT2_ASYNC_DISCARD;
+				   OBD_CONNECT2_ASYNC_DISCARD |
+				   OBD_CONNECT2_PCC;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -953,6 +955,8 @@ void ll_lli_init(struct ll_inode_info *lli)
 		spin_lock_init(&lli->lli_heat_lock);
 		obd_heat_clear(lli->lli_heat_instances, OBD_HEAT_COUNT);
 		lli->lli_heat_flags = 0;
+		mutex_init(&lli->lli_pcc_lock);
+		lli->lli_pcc_inode = NULL;
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
@@ -1486,6 +1490,8 @@ void ll_clear_inode(struct inode *inode)
 		LASSERT(!lli->lli_opendir_key);
 		LASSERT(!lli->lli_sai);
 		LASSERT(lli->lli_opendir_pid == 0);
+	} else {
+		pcc_inode_free(inode);
 	}
 
 	md_null_inode(sbi->ll_md_exp, ll_inode2fid(inode));
@@ -1709,15 +1715,28 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	if (attr->ia_valid & (ATTR_SIZE | ATTR_ATIME | ATTR_ATIME_SET |
 			      ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME) ||
 	    xvalid & OP_XVALID_CTIME_SET) {
-		/* For truncate and utimes sending attributes to OSTs, setting
-		 * mtime/atime to the past will be performed under PW [0:EOF]
-		 * extent lock (new_size:EOF for truncate).  It may seem
-		 * excessive to send mtime/atime updates to OSTs when not
-		 * setting times to past, but it is necessary due to possible
-		 * time de-synchronization between MDT inode and OST objects
-		 */
-		rc = cl_setattr_ost(ll_i2info(inode)->lli_clob,
-				    attr, xvalid, 0);
+		bool cached = false;
+
+		rc = pcc_inode_setattr(inode, attr, &cached);
+		if (cached) {
+			if (rc) {
+				CERROR("%s: PCC inode "DFID" setattr failed: rc = %d\n",
+				       ll_i2sbi(inode)->ll_fsname,
+				       PFID(&lli->lli_fid), rc);
+				goto out;
+			}
+		} else {
+			/* For truncate and utimes sending attributes to OSTs,
+			 * setting mtime/atime to the past will be performed
+			 * under PW [0:EOF] extent lock (new_size:EOF for
+			 * truncate). It may seem excessive to send mtime/atime
+			 * updates to OSTs when not setting times to past, but
+			 * it is necessary due to possible time
+			 * de-synchronization between MDT inode and OST objects
+			 */
+			rc = cl_setattr_ost(ll_i2info(inode)->lli_clob,
+					    attr, xvalid, 0);
+		}
 	}
 
 	/*
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 37ce508..fc2331b 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -505,6 +505,14 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(file);
 	int rc;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+
+	/* pcc cache path */
+	if (pcc_file) {
+		vma->vm_file = pcc_file;
+		return file_inode(pcc_file)->i_fop->mmap(pcc_file, vma);
+	}
 
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 165d37f..8cb4983 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1317,7 +1317,46 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 
 LPROC_SEQ_FOPS(ll_nosquash_nids);
 
-static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
+static int ll_pcc_seq_show(struct seq_file *m, void *v)
+{
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+
+	return pcc_super_dump(&sbi->ll_pcc_super, m);
+}
+
+static ssize_t ll_pcc_seq_write(struct file *file, const char __user *buffer,
+				size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	int rc;
+	char *kernbuf;
+
+	if (count >= LPROCFS_WR_PCC_MAX_CMD)
+		return -EINVAL;
+
+	if (!(exp_connect_flags2(sbi->ll_md_exp) & OBD_CONNECT2_PCC))
+		return -EOPNOTSUPP;
+
+	kernbuf = kzalloc(count + 1, GFP_KERNEL);
+	if (!kernbuf)
+		return -ENOMEM;
+
+	if (copy_from_user(kernbuf, buffer, count)) {
+		rc = -EFAULT;
+		goto out_free_kernbuff;
+	}
+
+	rc = pcc_cmd_handle(kernbuf, count, &sbi->ll_pcc_super);
+out_free_kernbuff:
+	kfree(kernbuf);
+	return rc ? rc : count;
+}
+LPROC_SEQ_FOPS(ll_pcc);
+
+struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	{ .name	=	"site",
 	  .fops	=	&ll_site_stats_fops			},
 	{ .name	=	"max_cached_mb",
@@ -1329,9 +1368,11 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	{ .name	=	"sbi_flags",
 	  .fops	=	&ll_sbi_flags_fops			},
 	{ .name =	"root_squash",
-	  .fops =       &ll_root_squash_fops			},
+	  .fops =	&ll_root_squash_fops			},
 	{ .name =	"nosquash_nids",
 	  .fops =	&ll_nosquash_nids_fops			},
+	{ .name =	"pcc",
+	  .fops =	&ll_pcc_fops,				},
 	{ NULL }
 };
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index fb5caaf..4f39b2c 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -711,14 +711,21 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	return rc;
 }
 
+struct pcc_create_attach {
+	struct pcc_dataset *pca_dataset;
+	struct dentry *pca_dentry;
+};
+
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 				   struct lookup_intent *it, void **secctx,
-				   u32 *secctxlen)
+				   u32 *secctxlen,
+				   struct pcc_create_attach *pca)
 {
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
 	struct dentry *save = dentry, *retval;
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data = NULL;
+	struct lov_user_md *lum = NULL;
 	char secctx_name[XATTR_NAME_MAX + 1];
 	struct inode *inode;
 	u32 opc;
@@ -806,6 +813,42 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		}
 	}
 
+	if (pca && pca->pca_dataset) {
+		struct pcc_dataset *dataset = pca->pca_dataset;
+
+		lum = kzalloc(sizeof(*lum), GFP_NOFS);
+		if (!lum) {
+			retval = ERR_PTR(-ENOMEM);
+			goto out;
+		}
+
+		lum->lmm_magic = LOV_USER_MAGIC_V1;
+		lum->lmm_pattern = LOV_PATTERN_F_RELEASED | LOV_PATTERN_RAID0;
+		lum->lmm_stripe_size = 0;
+		lum->lmm_stripe_count = 0;
+		lum->lmm_stripe_offset = 0;
+
+		op_data->op_data = lum;
+		op_data->op_data_size = sizeof(*lum);
+		op_data->op_archive_id = dataset->pccd_id;
+
+		rc = obd_fid_alloc(NULL, ll_i2mdexp(parent), &op_data->op_fid2,
+				   op_data);
+		if (rc) {
+			retval = ERR_PTR(rc);
+			goto out;
+		}
+
+		rc = pcc_inode_create(dataset, &op_data->op_fid2,
+				      &pca->pca_dentry);
+		if (rc) {
+			retval = ERR_PTR(rc);
+			goto out;
+		}
+
+		it->it_flags |= MDS_OPEN_PCC;
+	}
+
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
 			    &ll_md_blocking_ast, 0);
 	/*
@@ -878,6 +921,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		ll_finish_md_op_data(op_data);
 	}
 
+	kfree(lum);
+
 	ptlrpc_req_finished(req);
 	return retval;
 }
@@ -903,7 +948,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = NULL;
 	else
 		itp = &it;
-	de = ll_lookup_it(parent, dentry, itp, NULL, NULL);
+	de = ll_lookup_it(parent, dentry, itp, NULL, NULL, NULL);
 
 	if (itp)
 		ll_intent_release(itp);
@@ -923,6 +968,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	void *secctx = NULL;
 	u32 secctxlen = 0;
 	struct dentry *de;
+	struct ll_sb_info *sbi;
+	struct pcc_create_attach pca = {NULL, NULL};
+	struct pcc_dataset *dataset = NULL;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE,
@@ -952,14 +1000,24 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		return -ENOMEM;
 
 	it->it_op = IT_OPEN;
-	if (open_flags & O_CREAT)
+	if (open_flags & O_CREAT) {
 		it->it_op |= IT_CREAT;
+		sbi = ll_i2sbi(dir);
+		/* Volatile file is used for HSM restore, so do not use PCC */
+		if (!filename_is_volatile(dentry->d_name.name,
+					  dentry->d_name.len, NULL)) {
+			dataset = pcc_dataset_get(&sbi->ll_pcc_super,
+						  ll_i2info(dir)->lli_projid,
+						  0);
+			pca.pca_dataset = dataset;
+		}
+	}
 	it->it_create_mode = (mode & S_IALLUGO) | S_IFREG;
 	it->it_flags = (open_flags & ~O_ACCMODE) | OPEN_FMODE(open_flags);
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
 	/* Dentry added to dcache tree in ll_lookup_it */
-	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen);
+	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
 	else if (de)
@@ -976,9 +1034,20 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 					dput(de);
 				goto out_release;
 			}
+			if (dataset && dentry->d_inode) {
+				rc = pcc_inode_create_fini(dataset,
+							   dentry->d_inode,
+							   pca.pca_dentry);
+				if (rc) {
+					if (de)
+						dput(de);
+					goto out_release;
+				}
+			}
 
 			file->f_mode |= FMODE_CREATED;
 		}
+
 		if (d_really_is_positive(dentry) &&
 		    it_disposition(it, DISP_OPEN_OPEN)) {
 			/* Open dentry. */
@@ -1003,6 +1072,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	}
 
 out_release:
+	if (dataset)
+		pcc_dataset_put(dataset);
 	ll_intent_release(it);
 	kfree(it);
 
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
new file mode 100644
index 0000000..53e5cda
--- /dev/null
+++ b/fs/lustre/llite/pcc.c
@@ -0,0 +1,1042 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2017, DDN Storage Corporation.
+ */
+/*
+ * Persistent Client Cache
+ *
+ * PCC is a new framework which provides a group of local cache on Lustre
+ * client side. It works in two modes: RW-PCC enables a read-write cache on the
+ * local SSDs of a single client; RO-PCC provides a read-only cache on the
+ * local SSDs of multiple clients. Less overhead is visible to the applications
+ * and network latencies and lock conflicts can be significantly reduced.
+ *
+ * For RW-PCC, no global namespace will be provided. Each client uses its own
+ * local storage as a cache for itself. Local file system is used to manage
+ * the data on local caches. Cached I/O is directed to local file system while
+ * normal I/O is directed to OSTs. RW-PCC uses HSM for data synchronization.
+ * It uses HSM copytool to restore file from local caches to Lustre OSTs. Each
+ * PCC has a copytool instance running with unique archive number. Any remote
+ * access from another Lustre client would trigger the data synchronization. If
+ * a client with RW-PCC goes offline, the cached data becomes inaccessible for
+ * other client temporarily. And after the RW-PCC client reboots and the
+ * copytool restarts, the data will be accessible again.
+ *
+ * Following is what will happen in different conditions for RW-PCC:
+ *
+ * > When file is being created on RW-PCC
+ *
+ * A normal HSM released file is created on MDT;
+ * An empty mirror file is created on local cache;
+ * The HSM status of the Lustre file will be set to archived and released;
+ * The archive number will be set to the proper value.
+ *
+ * > When file is being prefetched to RW-PCC
+ *
+ * An file is copied to the local cache;
+ * The HSM status of the Lustre file will be set to archived and released;
+ * The archive number will be set to the proper value.
+ *
+ * > When file is being accessed from PCC
+ *
+ * Data will be read directly from local cache;
+ * Metadata will be read from MDT, except file size;
+ * File size will be got from local cache.
+ *
+ * > When PCC cached file is being accessed on another client
+ *
+ * RW-PCC cached files are automatically restored when a process on another
+ * client tries to read or modify them. The corresponding I/O will block
+ * waiting for the released file to be restored. This is transparent to the
+ * process.
+ *
+ * For RW-PCC, when a file is being created, a rule-based policy is used to
+ * determine whether it will be cached. Rule-based caching of newly created
+ * files can determine which file can use a cache on PCC directly without any
+ * admission control.
+ *
+ * RW-PCC design can accelerate I/O intensive applications with one-to-one
+ * mappings between files and accessing clients. However, in several use cases,
+ * files will never be updated, but need to be read simultaneously from many
+ * clients. RO-PCC implements a read-only caching on Lustre clients using
+ * SSDs. RO-PCC is based on the same framework as RW-PCC, expect
+ * that no HSM mechanism is used.
+ *
+ * The main advantages to use this SSD cache on the Lustre clients via PCC
+ * is that:
+ * - The I/O stack becomes much simpler for the cached data, as there is no
+ *   interference with I/Os from other clients, which enables easier
+ *   performance optimizations;
+ * - The requirements on the HW inside the client nodes are small, any kind of
+ *   SSDs or even HDDs can be used as cache devices;
+ * - Caching reduces the pressure on the object storage targets (OSTs), as
+ *   small or random I/Os can be regularized to big sequential I/Os and
+ *   temporary files do not even need to be flushed to OSTs.
+ *
+ * PCC can accelerate applications with certain I/O patterns:
+ * - small-sized random writes (< 1MB) from a single client
+ * - repeated read of data that is larger than RAM
+ * - clients with high network latency
+ *
+ * Author: Li Xi <lixi@ddn.com>
+ * Author: Qian Yingjin <qian@ddn.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_LLITE
+
+#include "pcc.h"
+#include <linux/namei.h>
+#include <linux/file.h>
+#include <linux/mount.h>
+#include "llite_internal.h"
+
+struct kmem_cache *pcc_inode_slab;
+
+void pcc_super_init(struct pcc_super *super)
+{
+	spin_lock_init(&super->pccs_lock);
+	INIT_LIST_HEAD(&super->pccs_datasets);
+}
+
+/**
+ * pcc_dataset_add - Add a Cache policy to control which files need be
+ * cached and where it will be cached.
+ *
+ * @super: superblock of pcc
+ * @pathname: root path of pcc
+ * @id: HSM archive ID
+ * @projid: files with specified project ID will be cached.
+ */
+static int
+pcc_dataset_add(struct pcc_super *super, const char *pathname,
+		u32 archive_id, u32 projid)
+{
+	int rc;
+	struct pcc_dataset *dataset;
+	struct pcc_dataset *tmp;
+	bool found = false;
+
+	dataset = kzalloc(sizeof(*dataset), GFP_NOFS);
+	if (!dataset)
+		return -ENOMEM;
+
+	rc = kern_path(pathname, LOOKUP_DIRECTORY, &dataset->pccd_path);
+	if (unlikely(rc)) {
+		kfree(dataset);
+		return rc;
+	}
+	strncpy(dataset->pccd_pathname, pathname, PATH_MAX);
+	dataset->pccd_id = archive_id;
+	dataset->pccd_projid = projid;
+	atomic_set(&dataset->pccd_refcount, 1);
+
+	spin_lock(&super->pccs_lock);
+	list_for_each_entry(tmp, &super->pccs_datasets, pccd_linkage) {
+		if (tmp->pccd_id == archive_id) {
+			found = true;
+			break;
+		}
+	}
+	if (!found)
+		list_add(&dataset->pccd_linkage, &super->pccs_datasets);
+	spin_unlock(&super->pccs_lock);
+
+	if (found) {
+		pcc_dataset_put(dataset);
+		rc = -EEXIST;
+	}
+
+	return rc;
+}
+
+struct pcc_dataset *
+pcc_dataset_get(struct pcc_super *super, u32 projid, u32 archive_id)
+{
+	struct pcc_dataset *dataset;
+	struct pcc_dataset *selected = NULL;
+
+	if (projid == 0 && archive_id == 0)
+		return NULL;
+
+	/*
+	 * archive ID is unique in the list, projid might be duplicate,
+	 * we just return last added one as first priority.
+	 */
+	spin_lock(&super->pccs_lock);
+	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
+		if (projid && dataset->pccd_projid != projid)
+			continue;
+		if (archive_id && dataset->pccd_id != archive_id)
+			continue;
+		atomic_inc(&dataset->pccd_refcount);
+		selected = dataset;
+		break;
+	}
+	spin_unlock(&super->pccs_lock);
+	if (selected)
+		CDEBUG(D_CACHE, "matched projid %u, PCC create\n",
+		       selected->pccd_projid);
+	return selected;
+}
+
+void
+pcc_dataset_put(struct pcc_dataset *dataset)
+{
+	if (atomic_dec_and_test(&dataset->pccd_refcount)) {
+		path_put(&dataset->pccd_path);
+		kfree(dataset);
+	}
+}
+
+static int
+pcc_dataset_del(struct pcc_super *super, char *pathname)
+{
+	struct list_head *l, *tmp;
+	struct pcc_dataset *dataset;
+	int rc = -ENOENT;
+
+	spin_lock(&super->pccs_lock);
+	list_for_each_safe(l, tmp, &super->pccs_datasets) {
+		dataset = list_entry(l, struct pcc_dataset, pccd_linkage);
+		if (strcmp(dataset->pccd_pathname, pathname) == 0) {
+			list_del(&dataset->pccd_linkage);
+			pcc_dataset_put(dataset);
+			rc = 0;
+			break;
+		}
+	}
+	spin_unlock(&super->pccs_lock);
+	return rc;
+}
+
+static void
+pcc_dataset_dump(struct pcc_dataset *dataset, struct seq_file *m)
+{
+	seq_printf(m, "%s:\n", dataset->pccd_pathname);
+	seq_printf(m, "  rwid: %u\n", dataset->pccd_id);
+	seq_printf(m, "  autocache: projid=%u\n", dataset->pccd_projid);
+}
+
+int
+pcc_super_dump(struct pcc_super *super, struct seq_file *m)
+{
+	struct pcc_dataset *dataset;
+
+	spin_lock(&super->pccs_lock);
+	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
+		pcc_dataset_dump(dataset, m);
+	}
+	spin_unlock(&super->pccs_lock);
+	return 0;
+}
+
+void pcc_super_fini(struct pcc_super *super)
+{
+	struct pcc_dataset *dataset, *tmp;
+
+	list_for_each_entry_safe(dataset, tmp,
+				 &super->pccs_datasets, pccd_linkage) {
+		list_del(&dataset->pccd_linkage);
+		pcc_dataset_put(dataset);
+	}
+}
+
+static bool pathname_is_valid(const char *pathname)
+{
+	/* Needs to be absolute path */
+	if (!pathname || strlen(pathname) == 0 ||
+	    strlen(pathname) >= PATH_MAX || pathname[0] != '/')
+		return false;
+	return true;
+}
+
+static struct pcc_cmd *
+pcc_cmd_parse(char *buffer, unsigned long count)
+{
+	static struct pcc_cmd *cmd;
+	char *token;
+	char *val;
+	unsigned long tmp;
+	int rc = 0;
+
+	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (!cmd) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	/* clear all setting */
+	if (strncmp(buffer, "clear", 5) == 0) {
+		cmd->pccc_cmd = PCC_CLEAR_ALL;
+		rc = 0;
+		goto out;
+	}
+
+	val = buffer;
+	token = strsep(&val, " ");
+	if (!val || strlen(val) == 0) {
+		rc = -EINVAL;
+		goto out_free_cmd;
+	}
+
+	/* Type of the command */
+	if (strcmp(token, "add") == 0) {
+		cmd->pccc_cmd = PCC_ADD_DATASET;
+	} else if (strcmp(token, "del") == 0) {
+		cmd->pccc_cmd = PCC_DEL_DATASET;
+	} else {
+		rc = -EINVAL;
+		goto out_free_cmd;
+	}
+
+	/* Pathname of the dataset */
+	token = strsep(&val, " ");
+	if ((!val && cmd->pccc_cmd != PCC_DEL_DATASET) ||
+	    !pathname_is_valid(token)) {
+		rc = -EINVAL;
+		goto out_free_cmd;
+	}
+	cmd->pccc_pathname = token;
+
+	if (cmd->pccc_cmd == PCC_ADD_DATASET) {
+		/* archive ID */
+		token = strsep(&val, " ");
+		if (!val) {
+			rc = -EINVAL;
+			goto out_free_cmd;
+		}
+
+		rc = kstrtoul(token, 10, &tmp);
+		if (rc != 0) {
+			rc = -EINVAL;
+			goto out_free_cmd;
+		}
+		if (tmp == 0) {
+			rc = -EINVAL;
+			goto out_free_cmd;
+		}
+		cmd->u.pccc_add.pccc_id = tmp;
+
+		token = val;
+		rc = kstrtoul(token, 10, &tmp);
+		if (rc != 0) {
+			rc = -EINVAL;
+			goto out_free_cmd;
+		}
+		if (tmp == 0) {
+			rc = -EINVAL;
+			goto out_free_cmd;
+		}
+		cmd->u.pccc_add.pccc_projid = tmp;
+	}
+
+	goto out;
+out_free_cmd:
+	kfree(cmd);
+out:
+	if (rc)
+		cmd = ERR_PTR(rc);
+	return cmd;
+}
+
+int pcc_cmd_handle(char *buffer, unsigned long count,
+		   struct pcc_super *super)
+{
+	int rc = 0;
+	struct pcc_cmd *cmd;
+
+	cmd = pcc_cmd_parse(buffer, count);
+	if (IS_ERR(cmd))
+		return PTR_ERR(cmd);
+
+	switch (cmd->pccc_cmd) {
+	case PCC_ADD_DATASET:
+		rc = pcc_dataset_add(super, cmd->pccc_pathname,
+				      cmd->u.pccc_add.pccc_id,
+				      cmd->u.pccc_add.pccc_projid);
+		break;
+	case PCC_DEL_DATASET:
+		rc = pcc_dataset_del(super, cmd->pccc_pathname);
+		break;
+	case PCC_CLEAR_ALL:
+		pcc_super_fini(super);
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+
+	kfree(cmd);
+	return rc;
+}
+
+static inline void pcc_inode_lock(struct inode *inode)
+{
+	mutex_lock(&ll_i2info(inode)->lli_pcc_lock);
+}
+
+static inline void pcc_inode_unlock(struct inode *inode)
+{
+	mutex_unlock(&ll_i2info(inode)->lli_pcc_lock);
+}
+
+static void pcc_inode_init(struct pcc_inode *pcci)
+{
+	atomic_set(&pcci->pcci_refcount, 0);
+	pcci->pcci_type = LU_PCC_NONE;
+}
+
+static void pcc_inode_fini(struct pcc_inode *pcci)
+{
+	path_put(&pcci->pcci_path);
+	pcci->pcci_type = LU_PCC_NONE;
+	kmem_cache_free(pcc_inode_slab, pcci);
+}
+
+static void pcc_inode_get(struct pcc_inode *pcci)
+{
+	atomic_inc(&pcci->pcci_refcount);
+}
+
+static void pcc_inode_put(struct pcc_inode *pcci)
+{
+	if (atomic_dec_and_test(&pcci->pcci_refcount))
+		pcc_inode_fini(pcci);
+}
+
+void pcc_inode_free(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci = lli->lli_pcc_inode;
+
+	if (pcci) {
+		WARN_ON(atomic_read(&pcci->pcci_refcount) > 1);
+		pcc_inode_put(pcci);
+		lli->lli_pcc_inode = NULL;
+	}
+}
+
+/*
+ * TODO:
+ * As Andreas suggested, we'd better use new layout to
+ * reduce overhead:
+ * (fid->f_oid >> 16 & oxFFFF)/FID
+ */
+#define MAX_PCC_DATABASE_PATH (6 * 5 + FID_NOBRACE_LEN + 1)
+static int pcc_fid2dataset_path(char *buf, int sz, struct lu_fid *fid)
+{
+	return snprintf(buf, sz, "%04x/%04x/%04x/%04x/%04x/%04x/"
+			DFID_NOBRACE,
+			(fid)->f_oid       & 0xFFFF,
+			(fid)->f_oid >> 16 & 0xFFFF,
+			(unsigned int)((fid)->f_seq       & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
+			PFID(fid));
+}
+
+void pcc_file_init(struct pcc_file *pccf)
+{
+	pccf->pccf_file = NULL;
+	pccf->pccf_type = LU_PCC_NONE;
+}
+
+int pcc_file_open(struct inode *inode, struct file *file)
+{
+	struct pcc_inode *pcci;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct pcc_file *pccf = &fd->fd_pcc_file;
+	struct file *pcc_file;
+	struct path *path;
+	struct qstr *dname;
+	int rc = 0;
+
+	if (!S_ISREG(inode->i_mode))
+		return 0;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (!pcci)
+		goto out_unlock;
+
+	if (atomic_read(&pcci->pcci_refcount) == 0)
+		goto out_unlock;
+
+	pcc_inode_get(pcci);
+	WARN_ON(pccf->pccf_file);
+
+	path = &pcci->pcci_path;
+	dname = &path->dentry->d_name;
+	CDEBUG(D_CACHE, "opening pcc file '%.*s'\n", dname->len,
+	       dname->name);
+	pcc_file = dentry_open(path, file->f_flags, current_cred());
+	if (IS_ERR_OR_NULL(pcc_file)) {
+		rc = pcc_file ? PTR_ERR(pcc_file) : -EINVAL;
+		pcc_inode_put(pcci);
+	} else {
+		pccf->pccf_file = pcc_file;
+		pccf->pccf_type = pcci->pcci_type;
+	}
+
+out_unlock:
+	pcc_inode_unlock(inode);
+	return rc;
+}
+
+void pcc_file_release(struct inode *inode, struct file *file)
+{
+	struct pcc_inode *pcci;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct pcc_file *pccf;
+	struct path *path;
+	struct qstr *dname;
+
+	if (!S_ISREG(inode->i_mode) || !fd)
+		return;
+
+	pccf = &fd->fd_pcc_file;
+	pcc_inode_lock(inode);
+	if (!pccf->pccf_file)
+		goto out;
+
+	pcci = ll_i2pcci(inode);
+	LASSERT(pcci);
+	path = &pcci->pcci_path;
+	dname = &path->dentry->d_name;
+	CDEBUG(D_CACHE, "releasing pcc file \"%.*s\"\n", dname->len,
+	       dname->name);
+	pcc_inode_put(pcci);
+	fput(pccf->pccf_file);
+	pccf->pccf_file = NULL;
+out:
+	pcc_inode_unlock(inode);
+}
+
+ssize_t pcc_file_read_iter(struct kiocb *iocb,
+			   struct iov_iter *iter, bool *cached)
+{
+	struct file *file = iocb->ki_filp;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct pcc_file *pccf = &fd->fd_pcc_file;
+	ssize_t result;
+
+	if (!pccf->pccf_file) {
+		*cached = false;
+		return 0;
+	}
+	*cached = true;
+	iocb->ki_filp = pccf->pccf_file;
+
+	result = generic_file_read_iter(iocb, iter);
+	iocb->ki_filp = file;
+
+	return result;
+}
+
+ssize_t pcc_file_write_iter(struct kiocb *iocb,
+			    struct iov_iter *iter, bool *cached)
+{
+	struct file *file = iocb->ki_filp;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct pcc_file *pccf = &fd->fd_pcc_file;
+	ssize_t result;
+
+	if (!pccf->pccf_file) {
+		*cached = false;
+		return 0;
+	}
+	*cached = true;
+
+	if (pccf->pccf_type != LU_PCC_READWRITE)
+		return -EWOULDBLOCK;
+
+	iocb->ki_filp = pccf->pccf_file;
+
+	/* Since file->fop->write_iter makes write calls via
+	 * the normal vfs interface to the local PCC file system,
+	 * the inode lock is not needed.
+	 */
+	result = file->f_op->write_iter(iocb, iter);
+	iocb->ki_filp = file;
+	return result;
+}
+
+int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
+		      bool *cached)
+{
+	int rc = 0;
+	struct pcc_inode *pcci;
+	struct iattr attr2 = *attr;
+	struct dentry *pcc_dentry;
+
+	if (!S_ISREG(inode->i_mode)) {
+		*cached = false;
+		return 0;
+	}
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (!pcci || atomic_read(&pcci->pcci_refcount) == 0)
+		goto out_unlock;
+
+	*cached = true;
+	attr2.ia_valid = attr->ia_valid & (ATTR_SIZE | ATTR_ATIME |
+			 ATTR_ATIME_SET | ATTR_MTIME | ATTR_MTIME_SET |
+			 ATTR_CTIME);
+	pcc_dentry = pcci->pcci_path.dentry;
+	inode_lock(pcc_dentry->d_inode);
+	rc = pcc_dentry->d_inode->i_op->setattr(pcc_dentry, &attr2);
+	inode_unlock(pcc_dentry->d_inode);
+out_unlock:
+	pcc_inode_unlock(inode);
+	return rc;
+}
+
+int pcc_inode_getattr(struct inode *inode, bool *cached)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci;
+	struct kstat stat;
+	s64 atime;
+	s64 mtime;
+	s64 ctime;
+	int rc = 0;
+
+	if (!S_ISREG(inode->i_mode)) {
+		*cached = false;
+		return 0;
+	}
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (!pcci || atomic_read(&pcci->pcci_refcount) == 0)
+		goto out_unlock;
+
+	*cached = true;
+	rc = vfs_getattr(&pcci->pcci_path, &stat,
+			 STATX_BASIC_STATS, AT_STATX_SYNC_AS_STAT);
+	if (rc)
+		goto out_unlock;
+
+	ll_inode_size_lock(inode);
+	if (test_and_clear_bit(LLIF_UPDATE_ATIME, &lli->lli_flags) ||
+	    inode->i_atime.tv_sec < lli->lli_atime)
+		inode->i_atime.tv_sec = lli->lli_atime;
+
+	inode->i_mtime.tv_sec = lli->lli_mtime;
+	inode->i_ctime.tv_sec = lli->lli_ctime;
+
+	atime = inode->i_atime.tv_sec;
+	mtime = inode->i_mtime.tv_sec;
+	ctime = inode->i_ctime.tv_sec;
+
+	if (atime < stat.atime.tv_sec)
+		atime = stat.atime.tv_sec;
+
+	if (ctime < stat.ctime.tv_sec)
+		ctime = stat.ctime.tv_sec;
+
+	if (mtime < stat.mtime.tv_sec)
+		mtime = stat.mtime.tv_sec;
+
+	i_size_write(inode, stat.size);
+	inode->i_blocks = stat.blocks;
+
+	inode->i_atime.tv_sec = atime;
+	inode->i_mtime.tv_sec = mtime;
+	inode->i_ctime.tv_sec = ctime;
+
+	ll_inode_size_unlock(inode);
+
+out_unlock:
+	pcc_inode_unlock(inode);
+	return rc;
+}
+
+/* Create directory under base if directory does not exist */
+static struct dentry *
+pcc_mkdir(struct dentry *base, const char *name, umode_t mode)
+{
+	int rc;
+	struct dentry *dentry;
+	struct inode *dir = base->d_inode;
+
+	inode_lock(dir);
+	dentry = lookup_one_len(name, base, strlen(name));
+	if (IS_ERR(dentry))
+		goto out;
+
+	if (d_is_positive(dentry))
+		goto out;
+
+	rc = vfs_mkdir(dir, dentry, mode);
+	if (rc) {
+		dput(dentry);
+		dentry = ERR_PTR(rc);
+		goto out;
+	}
+out:
+	inode_unlock(dir);
+	return dentry;
+}
+
+static struct dentry *
+pcc_mkdir_p(struct dentry *root, char *path, umode_t mode)
+{
+	char *ptr, *entry_name;
+	struct dentry *parent;
+	struct dentry *child = ERR_PTR(-EINVAL);
+
+	ptr = path;
+	while (*ptr == '/')
+		ptr++;
+
+	entry_name = ptr;
+	parent = dget(root);
+	while ((ptr = strchr(ptr, '/')) != NULL) {
+		*ptr = '\0';
+		child = pcc_mkdir(parent, entry_name, mode);
+		*ptr = '/';
+		if (IS_ERR(child))
+			break;
+		dput(parent);
+		parent = child;
+		ptr++;
+		entry_name = ptr;
+	}
+
+	return child;
+}
+
+/* Create file under base. If file already exist, return failure */
+static struct dentry *
+pcc_create(struct dentry *base, const char *name, umode_t mode)
+{
+	int rc;
+	struct dentry *dentry;
+	struct inode *dir = base->d_inode;
+
+	inode_lock(dir);
+	dentry = lookup_one_len(name, base, strlen(name));
+	if (IS_ERR(dentry))
+		goto out;
+
+	if (d_is_positive(dentry))
+		goto out;
+
+	rc = vfs_create(dir, dentry, mode, false);
+	if (rc) {
+		dput(dentry);
+		dentry = ERR_PTR(rc);
+		goto out;
+	}
+out:
+	inode_unlock(dir);
+	return dentry;
+}
+
+/* Must be called with pcci->pcci_lock held */
+static void pcc_inode_attach_init(struct pcc_dataset *dataset,
+				  struct pcc_inode *pcci,
+				  struct dentry *dentry,
+				  enum lu_pcc_type type)
+{
+	pcci->pcci_path.mnt = mntget(dataset->pccd_path.mnt);
+	pcci->pcci_path.dentry = dentry;
+	LASSERT(atomic_read(&pcci->pcci_refcount) == 0);
+	atomic_set(&pcci->pcci_refcount, 1);
+	pcci->pcci_type = type;
+	pcci->pcci_attr_valid = false;
+}
+
+static int __pcc_inode_create(struct pcc_dataset *dataset,
+			      struct lu_fid *fid,
+			      struct dentry **dentry)
+{
+	char *path;
+	struct dentry *base;
+	struct dentry *child;
+	int rc = 0;
+
+	path = kzalloc(MAX_PCC_DATABASE_PATH, GFP_NOFS);
+	if (!path)
+		return -ENOMEM;
+
+	pcc_fid2dataset_path(path, MAX_PCC_DATABASE_PATH, fid);
+
+	base = pcc_mkdir_p(dataset->pccd_path.dentry, path, 0700);
+	if (IS_ERR(base)) {
+		rc = PTR_ERR(base);
+		goto out;
+	}
+
+	snprintf(path, MAX_PCC_DATABASE_PATH, DFID_NOBRACE, PFID(fid));
+	child = pcc_create(base, path, 0600);
+	if (IS_ERR(child)) {
+		rc = PTR_ERR(child);
+		goto out_base;
+	}
+	*dentry = child;
+
+out_base:
+	dput(base);
+out:
+	kfree(path);
+	return rc;
+}
+
+int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
+		     struct dentry **pcc_dentry)
+{
+	return __pcc_inode_create(dataset, fid, pcc_dentry);
+}
+
+int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
+			  struct dentry *pcc_dentry)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci;
+
+	LASSERT(!ll_i2pcci(inode));
+	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
+	if (!pcci)
+		return -ENOMEM;
+
+	pcc_inode_init(pcci);
+	pcc_inode_lock(inode);
+	pcc_inode_attach_init(dataset, pcci, pcc_dentry, LU_PCC_READWRITE);
+	lli->lli_pcc_inode = pcci;
+	pcc_inode_unlock(inode);
+
+	return 0;
+}
+
+static int pcc_filp_write(struct file *filp, const void *buf, ssize_t count,
+			  loff_t *offset)
+{
+	while (count > 0) {
+		ssize_t size;
+
+		size = kernel_write(filp, buf, count, offset);
+		if (size < 0)
+			return size;
+		count -= size;
+		buf += size;
+	}
+	return 0;
+}
+
+static int pcc_copy_data(struct file *src, struct file *dst)
+{
+	int rc = 0;
+	ssize_t rc2;
+	loff_t pos, offset = 0;
+	size_t buf_len = 1048576;
+	void *buf;
+
+	buf = kvzalloc(buf_len, GFP_NOFS);
+	if (!buf)
+		return -ENOMEM;
+
+	while (1) {
+		pos = offset;
+		rc2 = kernel_read(src, buf, buf_len, &pos);
+		if (rc2 < 0) {
+			rc = rc2;
+			goto out_free;
+		} else if (rc2 == 0)
+			break;
+
+		pos = offset;
+		rc = pcc_filp_write(dst, buf, rc2, &pos);
+		if (rc < 0)
+			goto out_free;
+		offset += rc2;
+	}
+
+out_free:
+	kvfree(buf);
+	return rc;
+}
+
+int pcc_readwrite_attach(struct file *file, struct inode *inode,
+			 u32 archive_id)
+{
+	struct pcc_dataset *dataset;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci;
+	struct dentry *dentry;
+	struct file *pcc_filp;
+	struct path path;
+	int rc;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (!pcci) {
+		pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
+		if (!pcci) {
+			pcc_inode_unlock(inode);
+			return -ENOMEM;
+		}
+
+		pcc_inode_init(pcci);
+	} else if (atomic_read(&pcci->pcci_refcount) > 0) {
+		pcc_inode_unlock(inode);
+		return -EEXIST;
+	}
+	pcc_inode_unlock(inode);
+
+	dataset = pcc_dataset_get(&ll_i2sbi(inode)->ll_pcc_super, 0,
+				  archive_id);
+	if (!dataset) {
+		rc = -ENOENT;
+		goto out_free_pcci;
+	}
+
+	rc = __pcc_inode_create(dataset, &lli->lli_fid, &dentry);
+	if (rc)
+		goto out_dataset_put;
+
+	path.mnt = dataset->pccd_path.mnt;
+	path.dentry = dentry;
+	pcc_filp = dentry_open(&path, O_TRUNC | O_WRONLY | O_LARGEFILE,
+			       current_cred());
+	if (IS_ERR_OR_NULL(pcc_filp)) {
+		rc = pcc_filp ? PTR_ERR(pcc_filp) : -EINVAL;
+		goto out_dentry;
+	}
+
+	rc = pcc_copy_data(file, pcc_filp);
+	if (rc)
+		goto out_fput;
+
+	pcc_inode_lock(inode);
+	if (lli->lli_pcc_inode) {
+		rc = -EEXIST;
+		goto out_unlock;
+	}
+	pcc_inode_attach_init(dataset, pcci, dentry, LU_PCC_READWRITE);
+	lli->lli_pcc_inode = pcci;
+out_unlock:
+	pcc_inode_unlock(inode);
+out_fput:
+	fput(pcc_filp);
+out_dentry:
+	if (rc)
+		dput(dentry);
+out_dataset_put:
+	pcc_dataset_put(dataset);
+out_free_pcci:
+	if (rc)
+		kmem_cache_free(pcc_inode_slab, pcci);
+	return rc;
+
+}
+
+int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
+			      bool lease_broken, int rc, bool attached)
+{
+	struct pcc_inode *pcci = ll_i2pcci(inode);
+
+	if ((rc || lease_broken) && attached && pcci)
+		pcc_inode_put(pcci);
+
+	return rc;
+}
+
+int pcc_ioctl_detach(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci = lli->lli_pcc_inode;
+	int rc = 0;
+	int count;
+
+	pcc_inode_lock(inode);
+	if (!pcci)
+		goto out_unlock;
+
+	count = atomic_read(&pcci->pcci_refcount);
+	if (count > 1) {
+		rc = -EBUSY;
+		goto out_unlock;
+	} else if (count == 0)
+		goto out_unlock;
+
+	pcc_inode_put(pcci);
+	lli->lli_pcc_inode = NULL;
+out_unlock:
+	pcc_inode_unlock(inode);
+
+	return rc;
+}
+
+int pcc_ioctl_state(struct inode *inode, struct lu_pcc_state *state)
+{
+	int rc = 0;
+	int count;
+	char *buf;
+	char *path;
+	int buf_len = sizeof(state->pccs_path);
+	struct pcc_inode *pcci;
+
+	if (buf_len <= 0)
+		return -EINVAL;
+
+	buf = kzalloc(buf_len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (!pcci) {
+		state->pccs_type = LU_PCC_NONE;
+		goto out_unlock;
+	}
+
+	count = atomic_read(&pcci->pcci_refcount);
+	if (count == 0) {
+		state->pccs_type = LU_PCC_NONE;
+		goto out_unlock;
+	}
+	state->pccs_type = pcci->pcci_type;
+	state->pccs_open_count = count - 1;
+	state->pccs_flags = pcci->pcci_attr_valid ?
+			    PCC_STATE_FLAG_ATTR_VALID : 0;
+	path = dentry_path_raw(pcci->pcci_path.dentry, buf, buf_len);
+	if (IS_ERR(path)) {
+		rc = PTR_ERR(path);
+		goto out_unlock;
+	}
+
+	if (strlcpy(state->pccs_path, path, buf_len) >= buf_len) {
+		rc = -ENAMETOOLONG;
+		goto out_unlock;
+	}
+
+out_unlock:
+	pcc_inode_unlock(inode);
+	kfree(buf);
+	return rc;
+}
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
new file mode 100644
index 0000000..0f960b9
--- /dev/null
+++ b/fs/lustre/llite/pcc.h
@@ -0,0 +1,129 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2017, DDN Storage Corporation.
+ */
+/*
+ *
+ * Persistent Client Cache
+ *
+ * Author: Li Xi <lixi@ddn.com>
+ */
+
+#ifndef LLITE_PCC_H
+#define LLITE_PCC_H
+
+#include <linux/types.h>
+#include <linux/fs.h>
+#include <linux/seq_file.h>
+#include <uapi/linux/lustre/lustre_user.h>
+
+extern struct kmem_cache *pcc_inode_slab;
+
+#define LPROCFS_WR_PCC_MAX_CMD 4096
+
+struct pcc_dataset {
+	u32			pccd_id;	 /* Archive ID */
+	u32			pccd_projid;	 /* Project ID */
+	char			pccd_pathname[PATH_MAX]; /* full path */
+	struct path		pccd_path;	 /* Root path */
+	struct list_head	pccd_linkage;  /* Linked to pccs_datasets */
+	atomic_t		pccd_refcount; /* reference count */
+};
+
+struct pcc_super {
+	spinlock_t		pccs_lock;	/* Protect pccs_datasets */
+	struct list_head	pccs_datasets;	/* List of datasets */
+};
+
+struct pcc_inode {
+	/* Cache path on local file system */
+	struct path			 pcci_path;
+	/*
+	 * If reference count is 0, then the cache is not inited, if 1, then
+	 * no one is using it.
+	 */
+	atomic_t			 pcci_refcount;
+	/* Whether readonly or readwrite PCC */
+	enum lu_pcc_type		 pcci_type;
+	/* Whether the inode is cached locally */
+	bool				 pcci_attr_valid;
+};
+
+struct pcc_file {
+	/* Opened cache file */
+	struct file		*pccf_file;
+	/* Whether readonly or readwrite PCC */
+	enum lu_pcc_type	 pccf_type;
+};
+
+enum pcc_cmd_type {
+	PCC_ADD_DATASET = 0,
+	PCC_DEL_DATASET,
+	PCC_CLEAR_ALL,
+};
+
+struct pcc_cmd {
+	enum pcc_cmd_type			 pccc_cmd;
+	char					*pccc_pathname;
+	union {
+		struct pcc_cmd_add {
+			u32			 pccc_id;
+			u32			 pccc_projid;
+		} pccc_add;
+		struct pcc_cmd_del {
+			u32			 pccc_pad;
+		} pccc_del;
+	} u;
+};
+
+void pcc_super_init(struct pcc_super *super);
+void pcc_super_fini(struct pcc_super *super);
+int pcc_cmd_handle(char *buffer, unsigned long count,
+		   struct pcc_super *super);
+int
+pcc_super_dump(struct pcc_super *super, struct seq_file *m);
+int pcc_readwrite_attach(struct file *file,
+			 struct inode *inode, u32 arch_id);
+int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
+			      bool lease_broken, int rc, bool attached);
+int pcc_ioctl_detach(struct inode *inode);
+int pcc_ioctl_state(struct inode *inode, struct lu_pcc_state *state);
+void pcc_file_init(struct pcc_file *pccf);
+int pcc_file_open(struct inode *inode, struct file *file);
+void pcc_file_release(struct inode *inode, struct file *file);
+ssize_t pcc_file_read_iter(struct kiocb *iocb, struct iov_iter *iter,
+			   bool *cached);
+ssize_t pcc_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
+			    bool *cached);
+int pcc_inode_getattr(struct inode *inode, bool *cached);
+int pcc_inode_setattr(struct inode *inode, struct iattr *attr, bool *cached);
+int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
+		     struct dentry **pcc_dentry);
+int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
+			  struct dentry *pcc_dentry);
+struct pcc_dataset *
+pcc_dataset_get(struct pcc_super *super, u32 projid, u32 archive_id);
+void pcc_dataset_put(struct pcc_dataset *dataset);
+void pcc_inode_free(struct inode *inode);
+#endif /* LLITE_PCC_H */
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 6cae48c..afd51a6 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -222,6 +222,14 @@ static int __init lustre_init(void)
 	if (!ll_file_data_slab)
 		goto out_cache;
 
+	pcc_inode_slab = kmem_cache_create("ll_pcc_inode",
+					   sizeof(struct pcc_inode), 0,
+					   SLAB_HWCACHE_ALIGN, NULL);
+	if (!pcc_inode_slab) {
+		rc = -ENOMEM;
+		goto out_cache;
+	}
+
 	rc = llite_tunables_register();
 	if (rc)
 		goto out_cache;
@@ -258,6 +266,7 @@ static int __init lustre_init(void)
 out_cache:
 	kmem_cache_destroy(ll_inode_cachep);
 	kmem_cache_destroy(ll_file_data_slab);
+	kmem_cache_destroy(pcc_inode_slab);
 	return rc;
 }
 
@@ -278,6 +287,7 @@ static void __exit lustre_exit(void)
 	rcu_barrier();
 	kmem_cache_destroy(ll_inode_cachep);
 	kmem_cache_destroy(ll_file_data_slab);
+	kmem_cache_destroy(pcc_inode_slab);
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 3efd977..f62cd7c 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -356,7 +356,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_mds = tgt->ltd_index;
 	} else {
 		LASSERT(fid_is_sane(&op_data->op_fid1));
-		LASSERT(fid_is_zero(&op_data->op_fid2));
+		LASSERT(it->it_flags & MDS_OPEN_PCC ||
+			fid_is_zero(&op_data->op_fid2));
 		LASSERT(op_data->op_name);
 
 		tgt = lmv_locate_tgt(lmv, op_data);
@@ -367,7 +368,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	/* If it is ready to open the file by FID, do not need
 	 * allocate FID at all, otherwise it will confuse MDT
 	 */
-	if ((it->it_op & IT_CREAT) && !(it->it_flags & MDS_OPEN_BY_FID)) {
+	if ((it->it_op & IT_CREAT) && !(it->it_flags & MDS_OPEN_BY_FID ||
+					it->it_flags & MDS_OPEN_PCC)) {
 		/*
 		 * For lookup(IT_CREATE) cases allocate new fid and setup FLD
 		 * for it.
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 20ae322..bd64ebc 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3480,6 +3480,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.set_info_async		= lmv_set_info_async,
 	.notify			= lmv_notify,
 	.get_uuid		= lmv_get_uuid,
+	.fid_alloc		= lmv_fid_alloc,
 	.iocontrol		= lmv_iocontrol,
 	.quotactl		= lmv_quotactl
 };
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index f0e5a84..be77944b 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -294,6 +294,10 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		cr_flags |= MDS_OPEN_HAS_EA;
 		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
 		memcpy(tmp, lmm, lmmlen);
+		if (cr_flags & MDS_OPEN_PCC) {
+			LASSERT(op_data);
+			rec->cr_archive_id = op_data->op_archive_id;
+		}
 	}
 	set_mrc_cr_flags(rec, cr_flags);
 }
@@ -504,6 +508,8 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 			memcpy(req_capsule_client_get(&req->rq_pill, &RMF_U32),
 				op_data->op_data, count * sizeof(u32));
 		}
+	} else if (bias & MDS_PCC_ATTACH) {
+		data->cd_archive_id = op_data->op_archive_id;
 	}
 }
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a26f3ae..2e54dd1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1719,6 +1719,7 @@ enum mds_op_bias {
 	MDS_CLOSE_RESYNC_DONE	= 1 << 16,
 	MDS_CLOSE_LAYOUT_SPLIT	= 1 << 17,
 	MDS_TRUNC_KEEP_LEASE	= 1 << 18,
+	MDS_PCC_ATTACH		= 1 << 19,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
@@ -1741,7 +1742,10 @@ struct mdt_rec_create {
 	struct lu_fid	cr_fid2;
 	struct lustre_handle cr_open_handle_old; /* in case of open replay */
 	__s64		cr_time;
-	__u64		cr_rdev;
+	union {
+		__u64		cr_rdev;
+		__u32		cr_archive_id;
+	};
 	__u64		cr_ioepoch;
 	__u64		cr_padding_1;	/* rr_blocks */
 	__u32		cr_mode;
@@ -2963,6 +2967,8 @@ struct close_data {
 		struct close_data_resync_done	cd_resync;
 		/* split close */
 		__u16				cd_mirror_id;
+		/* PCC release */
+		__u32				cd_archive_id;
 	};
 };
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d66c883..2b12612 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -268,6 +268,7 @@ enum ll_lease_flags {
 	LL_LEASE_RESYNC_DONE	= 0x2,
 	LL_LEASE_LAYOUT_MERGE	= 0x4,
 	LL_LEASE_LAYOUT_SPLIT	= 0x8,
+	LL_LEASE_PCC_ATTACH	= 0x10,
 };
 
 #define IOC_IDS_MAX	4096
@@ -356,6 +357,8 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 #define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
 #define LL_IOC_HEAT_SET			_IOW('f', 251, __u64)
+#define LL_IOC_PCC_DETACH		_IOW('f', 252, struct lu_pcc_detach)
+#define LL_IOC_PCC_STATE		_IOR('f', 252, struct lu_pcc_state)
 
 #define LL_STATFS_LMV		1
 #define LL_STATFS_LOV		2
@@ -1048,11 +1051,15 @@ enum la_valid {
 					      */
 #define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
 #define MDS_OPEN_RESYNC    04000000000000ULL /* FLR: file resync */
+#define MDS_OPEN_PCC      010000000000000ULL /* PCC: auto RW-PCC cache attach
+					      * for newly created file
+					      */
 
 #define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
 			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
 			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
-			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC)
+			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC |	\
+			      MDS_OPEN_PCC)
 
 /********* Changelogs **********/
 /** Changelog record types */
@@ -2062,6 +2069,47 @@ struct lu_heat {
 	__u64 lh_heat[0];
 };
 
+enum lu_pcc_type {
+	LU_PCC_NONE = 0,
+	LU_PCC_READWRITE,
+	LU_PCC_MAX
+};
+
+static inline const char *pcc_type2string(enum lu_pcc_type type)
+{
+	switch (type) {
+	case LU_PCC_NONE:
+		return "none";
+	case LU_PCC_READWRITE:
+		return "readwrite";
+	default:
+		return "fault";
+	}
+}
+
+struct lu_pcc_attach {
+	__u32 pcca_type; /* PCC type */
+	__u32 pcca_id; /* archive ID for readwrite, group ID for readonly */
+};
+
+struct lu_pcc_detach {
+	/* fid of the file to detach */
+	struct lu_fid	pccd_fid;
+};
+
+enum lu_pcc_state_flags {
+	/* Whether the inode attr is cached locally */
+	PCC_STATE_FLAG_ATTR_VALID	= 0x1,
+};
+
+struct lu_pcc_state {
+	__u32	pccs_type; /* enum lu_pcc_type */
+	__u32	pccs_open_count;
+	__u32	pccs_flags; /* enum lu_pcc_state_flags */
+	__u32	pccs_padding;
+	char	pccs_path[PATH_MAX];
+};
+
 /** @} lustreuser */
 
 #endif /* _LUSTRE_USER_H */
-- 
1.8.3.1
