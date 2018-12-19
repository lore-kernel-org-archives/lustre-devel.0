From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 19 Dec 2018 09:46:06 +0000
Subject: [lustre-devel] [RPC] parallel directory operations for mainline
 Linux
In-Reply-To: <8736rsbdx1.fsf@notabene.neil.brown.name>
References: <8736rsbdx1.fsf@notabene.neil.brown.name>
Message-ID: <302424F1-E6A8-4635-943A-B6FA5B3E9F61@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 22, 2018, at 21:44, NeilBrown <neilb@suse.com> wrote:
> 
> 
> One of the remaining features of ldiskfs which is not in ext4fs is
> parallel directory ops.
> It would not be possible to get this upstream without VFS support
> for parallel directory ops.  Lustre doesn't use the VFS interfaces
> so this lack is not an immediate problem for lustre, but it is a
> real problem for upstreaming.
> 
> This patch (which seems to work in my testing so far, but is probably
> still buggy) adds VFS support for parallel dir ops - create and remove.
> I haven't attempted rename - it would be complex for various reasons and
> while I'm sure it is possible, I'm not sure it is worth the effort.
> 
> With this patch a filesystem can indicate that it supports parallel ops
> by setting a flag on a directory.  The VFS will then get exclusive
> access to the dentry - instead of the whole directory - when
> performing the operation.
> 
> A filesystem which supports this much have its own locking to ensure
> that lookup, readdir, create, unlink can all happen in parallel.
> For NFS this is easy as the server takes care of those details, so
> this patch also adds parallel-ops support for NFS.
> For a filesystem like ext4 it would mean adding some locking to
> the internal data structures.
> 
> I've had a bit of a look at the parallel-ops patch for ldiskfs and I
> think it is over-engineered.  We don't need a new locking primitive.
> 
> I suspect I would start by adding a seqlock to each htree node.
> This allows reads to proceed locklessly when no changes are happening
> (if they are careful not to get confused by an inconsistent node).
> A modification would normally find the relevant leaf with a similar
> lockless walk, then lock the leaf, verify the seq-lock on the parent
> hasn't changed, and perform the update.
> In the rarer case when a leaf needs to split or merge something more
> heavy handed would be needed - possibly lock the whole tree - possibly
> just lock a higher node.
> 
> I don't expect to look at ext4 parallel ops in more detail in the
> immediate future, and I don't plan to post this upstream until we have
> credible support in ext4.  So I'm just posting it here now in case
> anyone else want to explore how to make ext4 work with this.

Why not start with the existing pdirops patch for ext4, which has been
in production use for many years already and works very well?  Since
this doesn't affect the on-disk structures at all, it would be
possible to improve/replace it in the future if needed.

I had a quick pass through your patch, and it seems reasonable.
The main question is whether the VFS interface is suitable for
use with ext4 with (some) pdirops patch, or does it need some more
changes?  Unfortunately, even with the pdirops patch applied, ext4
does not use this locking directly from the VFS methods, since
there was no reason to add overhead to the normal interface.  The
htree locks are only supplied when calling into the code directly
from Lustre.

Cheers, Andreas

> From 827c01aee1cb74b72e5dbb2f40c01666b914bc15 Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.com>
> Date: Fri, 16 Nov 2018 19:58:53 +1100
> Subject: [PATCH] VFS: support parallel updates in the one directory.
> 
> Some filesystems can support parallel modifications to a directory,
> either because the modification happen on a remote server which does
> its own locking (e.g. NFS) or because they can internally lock just
> a part of a directory (e.g. many local filesystems, with a bit of
> work).
> 
> To support these, we introduce support for parallel modification:
> unlink (including rmdir) and create.
> 
> If a filesystem supports parallel modification in a given directory,
> it sets S_PAR_UNLINK on the inode for that directory.
> lookup_open() and the new lookup_hash_modify() (similar to
> __lookup_hash()) notice the flag and take a shared
> lock on the directory.
> 
> Once a dentry for the target name has been obtained,
> DCACHE_PAR_UPDATE is set on it, waiting if necessary.
> Once this is set, the thread has exclusive access to the
> name and can call into the filesystem to perform
> the required action.
> 
> Some files do *not* complete the lookup that precedes
> a create, but leave the dentry d_in_lookup() and unhashed,
> so often a dentry will have both DCACHE_PAR_LOOKUP and
> DCACHE_PAR_UPDATE set at the same time.  To allow
> for this, we need the 'wq' that is used when DCACHE_PAR_LOOKUP is
> cleared, to exist until the creation is complete.  We also
> need to re-initialize it if it might get re-used.
> 
> As NFS trivially supports parallel unlinks, this patch also adds the
> flag to all NFS directories.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> fs/dcache.c            |  37 ++++++++++
> fs/namei.c             | 189 ++++++++++++++++++++++++++++++++++++++++++-------
> fs/nfs/dir.c           |   2 +-
> fs/nfs/inode.c         |   2 +
> fs/nfs/unlink.c        |   4 +-
> include/linux/dcache.h |  43 +++++++++++
> include/linux/fs.h     |   1 +
> 7 files changed, 249 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 2593153471cf..3821ce0bc37f 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -3030,6 +3030,43 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
> }
> EXPORT_SYMBOL(d_tmpfile);
> 
> +/*
> + * Lock a dentry to unlink or create in an S_PAR_UPDATE directory.
> + * After a successful return the dentry will not be modified by any other
> + * thread, and still has the given name and parent.
> + * On unsuccessful return it is not locked, because it was either unlinked
> + * or renamed in the mean-time.  If it was instantiated or created,
> + * we still return success, so caller might need to test if the dentry
> + * is negative or positive.
> + */
> +bool d_lock_modify(struct dentry *dentry,
> +		   struct dentry *base, const struct qstr *name)
> +{
> +	bool ret = true;
> +
> +	spin_lock(&dentry->d_lock);
> +	if (dentry->d_flags & DCACHE_PAR_UPDATE)
> +		___wait_var_event(&dentry->d_flags,
> +				  !(dentry->d_flags & DCACHE_PAR_UPDATE),
> +				  TASK_UNINTERRUPTIBLE, 0, 0,
> +				  (spin_unlock(&dentry->d_lock),
> +				   schedule(),
> +				   spin_lock(&dentry->d_lock))
> +			);
> +	if (d_unhashed(dentry) && d_is_positive(dentry))
> +		/* name was unlinked while we waited */
> +		ret = false;
> +	else if (dentry->d_parent != base ||
> +		 dentry->d_name.hash != name->hash ||
> +		 !d_same_name(dentry, base, name))
> +		/* dentry was renamed - possibly silly-rename */
> +		ret = false;
> +	else
> +		dentry->d_flags |= DCACHE_PAR_UPDATE;
> +	spin_unlock(&dentry->d_lock);
> +	return ret;
> +}
> +
> static __initdata unsigned long dhash_entries;
> static int __init set_dhash_entries(char *str)
> {
> diff --git a/fs/namei.c b/fs/namei.c
> index 0cab6494978c..ab6ccc03b9f4 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1551,6 +1551,91 @@ static struct dentry *__lookup_hash(const struct qstr *name,
> 	return dentry;
> }
> 
> +/*
> + * Parent directory is not locked.  We take either an exclusive
> + * or shared lock depending on the fs preference, and then
> + * get the DCACHE_PAR_UPDATE bit.
> + */
> +static struct dentry *lookup_hash_modify(const struct qstr *name,
> +					 struct dentry *base, unsigned int flags,
> +					 wait_queue_head_t *wq)
> +{
> +	struct dentry *dentry;
> +	struct inode *dir = base->d_inode;
> +	bool shared = (dir->i_flags & S_PAR_UPDATE) && wq;
> +	int err;
> +
> +	if (shared)
> +		inode_lock_shared_nested(dir, I_MUTEX_PARENT);
> +	else
> +		inode_lock_nested(dir, I_MUTEX_PARENT);
> +
> +retry:
> +	dentry = lookup_dcache(name, base, flags);
> +	if (!dentry) {
> +		/* Don't create child dentry for a dead directory. */
> +		err = -ENOENT;
> +		if (unlikely(IS_DEADDIR(dir)))
> +			goto out_err;
> +
> +		if (shared)
> +			dentry = d_alloc_parallel(base, name, wq);
> +		else
> +			dentry = d_alloc(base, name);
> +
> +		if (!IS_ERR(dentry) &&
> +		    (!shared || d_in_lookup(dentry))) {
> +			struct dentry *old;
> +
> +			old = dir->i_op->lookup(dir, dentry, flags);
> +			/*
> +			 * Note: dentry might still be d_unhashed() and
> +			 * d_in_lookup() if the fs will do the lookup
> +			 * at 'create' time.
> +			 */
> +			if (unlikely(old)) {
> +				d_lookup_done(dentry);
> +				dput(dentry);
> +				dentry = old;
> +			}
> +		}
> +	}
> +	if (IS_ERR(dentry)) {
> +		err = PTR_ERR(dentry);
> +		goto out_err;
> +	}
> +	if (!shared || d_lock_modify(dentry, base, name))
> +		return dentry;
> +
> +	/* Failed to get lock due to race with unlink or rename */
> +	d_lookup_done(dentry);
> +	init_waitqueue_head(wq);
> +	dput(dentry);
> +	goto retry;
> +
> +out_err:
> +	if (shared)
> +		inode_unlock_shared(dir);
> +	else
> +		inode_unlock(dir);
> +	return ERR_PTR(err);
> +}
> +
> +static void lookup_done_modify(struct path *path, struct dentry *dentry,
> +			       wait_queue_head_t *wq)
> +{
> +	struct inode *dir = path->dentry->d_inode;
> +	bool shared = (dir->i_flags & S_PAR_UPDATE) && wq;
> +
> +	if (shared) {
> +		d_lookup_done(dentry);
> +		d_unlock_modify(dentry);
> +		inode_unlock_shared(dir);
> +	} else {
> +		inode_unlock(dir);
> +	}
> +}
> +
> static int lookup_fast(struct nameidata *nd,
> 		       struct path *path, struct inode **inode,
> 		       unsigned *seqp)
> @@ -3136,6 +3221,7 @@ static int lookup_open(struct nameidata *nd, struct path *path,
> 	int error, create_error = 0;
> 	umode_t mode = op->mode;
> 	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> +	bool have_par_update = false;
> 
> 	if (unlikely(IS_DEADDIR(dir_inode)))
> 		return -ENOENT;
> @@ -3201,10 +3287,22 @@ static int lookup_open(struct nameidata *nd, struct path *path,
> 	}
> 
> 	if (dir_inode->i_op->atomic_open) {
> +		/* dentry is negative or d_in_lookup().  If this is a shared-lock
> +		 * create we need to get DCACHE_PAR_UPDATE to ensure exclusion
> +		 */
> +		if ((open_flag & O_CREAT) &&
> +		    (dir->d_inode->i_flags & S_PAR_UPDATE)) {
> +			if (!d_lock_create(dentry))
> +				/* already exists, non-atomic open */
> +				goto out_no_open;
> +			have_par_update = true;
> +		}
> 		error = atomic_open(nd, dentry, path, file, op, open_flag,
> 				    mode);
> 		if (unlikely(error == -ENOENT) && create_error)
> 			error = create_error;
> +		if (have_par_update)
> +			d_unlock_modify(dentry);
> 		return error;
> 	}
> 
> @@ -3222,6 +3320,13 @@ static int lookup_open(struct nameidata *nd, struct path *path,
> 			dentry = res;
> 		}
> 	}
> +	/* If dentry is negative and this is a shared-lock
> +	 * create we need to get DCACHE_PAR_UPDATE to ensure exclusion
> +	 */
> +	if ((open_flag & O_CREAT) &&
> +	    !dentry->d_inode &&
> +	    (dir->d_inode->i_flags & S_PAR_UPDATE))
> +		have_par_update = d_lock_create(dentry);
> 
> 	/* Negative dentry, just create the file */
> 	if (!dentry->d_inode && (open_flag & O_CREAT)) {
> @@ -3242,11 +3347,15 @@ static int lookup_open(struct nameidata *nd, struct path *path,
> 		goto out_dput;
> 	}
> out_no_open:
> +	if (have_par_update)
> +		d_unlock_modify(dentry);
> 	path->dentry = dentry;
> 	path->mnt = nd->path.mnt;
> 	return 0;
> 
> out_dput:
> +	if (have_par_update)
> +		d_unlock_modify(dentry);
> 	dput(dentry);
> 	return error;
> }
> @@ -3266,6 +3375,7 @@ static int do_last(struct nameidata *nd,
> 	struct inode *inode;
> 	struct path path;
> 	int error;
> +	bool shared;
> 
> 	nd->flags &= ~LOOKUP_PARENT;
> 	nd->flags |= op->intent;
> @@ -3317,12 +3427,13 @@ static int do_last(struct nameidata *nd,
> 		 * dropping this one anyway.
> 		 */
> 	}
> -	if (open_flag & O_CREAT)
> +	shared = !!(dir->d_inode->i_flags & S_PAR_UPDATE);
> +	if ((open_flag & O_CREAT) && !shared)
> 		inode_lock(dir->d_inode);
> 	else
> 		inode_lock_shared(dir->d_inode);
> 	error = lookup_open(nd, &path, file, op, got_write);
> -	if (open_flag & O_CREAT)
> +	if ((open_flag & O_CREAT) && !shared)
> 		inode_unlock(dir->d_inode);
> 	else
> 		inode_unlock_shared(dir->d_inode);
> @@ -3600,7 +3711,8 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
> }
> 
> static struct dentry *filename_create(int dfd, struct filename *name,
> -				struct path *path, unsigned int lookup_flags)
> +				      struct path *path, unsigned int lookup_flags,
> +				      wait_queue_head_t *wq)
> {
> 	struct dentry *dentry = ERR_PTR(-EEXIST);
> 	struct qstr last;
> @@ -3632,8 +3744,7 @@ static struct dentry *filename_create(int dfd, struct filename *name,
> 	 * Do the final lookup.
> 	 */
> 	lookup_flags |= LOOKUP_CREATE | LOOKUP_EXCL;
> -	inode_lock_nested(path->dentry->d_inode, I_MUTEX_PARENT);
> -	dentry = __lookup_hash(&last, path->dentry, lookup_flags);
> +	dentry = lookup_hash_modify(&last, path->dentry, lookup_flags, wq);
> 	if (IS_ERR(dentry))
> 		goto unlock;
> 
> @@ -3658,10 +3769,10 @@ static struct dentry *filename_create(int dfd, struct filename *name,
> 	putname(name);
> 	return dentry;
> fail:
> +	lookup_done_modify(path, dentry, wq);
> 	dput(dentry);
> 	dentry = ERR_PTR(error);
> unlock:
> -	inode_unlock(path->dentry->d_inode);
> 	if (!err2)
> 		mnt_drop_write(path->mnt);
> out:
> @@ -3674,23 +3785,34 @@ struct dentry *kern_path_create(int dfd, const char *pathname,
> 				struct path *path, unsigned int lookup_flags)
> {
> 	return filename_create(dfd, getname_kernel(pathname),
> -				path, lookup_flags);
> +			       path, lookup_flags, NULL);
> }
> EXPORT_SYMBOL(kern_path_create);
> 
> -void done_path_create(struct path *path, struct dentry *dentry)
> +void __done_path_create(struct path *path, struct dentry *dentry,
> +			wait_queue_head_t *wq)
> {
> +	lookup_done_modify(path, dentry, wq);
> 	dput(dentry);
> -	inode_unlock(path->dentry->d_inode);
> 	mnt_drop_write(path->mnt);
> 	path_put(path);
> }
> +void done_path_create(struct path *path, struct dentry *dentry)
> +{
> +	__done_path_create(path, dentry, NULL);
> +}
> EXPORT_SYMBOL(done_path_create);
> 
> +inline struct dentry *user_path_create_wq(int dfd, const char __user *pathname,
> +					  struct path *path, unsigned int lookup_flags,
> +					  wait_queue_head_t *wq)
> +{
> +	return filename_create(dfd, getname(pathname), path, lookup_flags, wq);
> +}
> inline struct dentry *user_path_create(int dfd, const char __user *pathname,
> -				struct path *path, unsigned int lookup_flags)
> +				       struct path *path, unsigned int lookup_flags)
> {
> -	return filename_create(dfd, getname(pathname), path, lookup_flags);
> +	return filename_create(dfd, getname(pathname), path, lookup_flags, NULL);
> }
> EXPORT_SYMBOL(user_path_create);
> 
> @@ -3747,12 +3869,13 @@ long do_mknodat(int dfd, const char __user *filename, umode_t mode,
> 	struct path path;
> 	int error;
> 	unsigned int lookup_flags = 0;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> 
> 	error = may_mknod(mode);
> 	if (error)
> 		return error;
> retry:
> -	dentry = user_path_create(dfd, filename, &path, lookup_flags);
> +	dentry = user_path_create_wq(dfd, filename, &path, lookup_flags, &wq);
> 	if (IS_ERR(dentry))
> 		return PTR_ERR(dentry);
> 
> @@ -3776,7 +3899,7 @@ long do_mknodat(int dfd, const char __user *filename, umode_t mode,
> 			break;
> 	}
> out:
> -	done_path_create(&path, dentry);
> +	__done_path_create(&path, dentry, &wq);
> 	if (retry_estale(error, lookup_flags)) {
> 		lookup_flags |= LOOKUP_REVAL;
> 		goto retry;
> @@ -3827,9 +3950,10 @@ long do_mkdirat(int dfd, const char __user *pathname, umode_t mode)
> 	struct path path;
> 	int error;
> 	unsigned int lookup_flags = LOOKUP_DIRECTORY;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> 
> retry:
> -	dentry = user_path_create(dfd, pathname, &path, lookup_flags);
> +	dentry = user_path_create_wq(dfd, pathname, &path, lookup_flags, &wq);
> 	if (IS_ERR(dentry))
> 		return PTR_ERR(dentry);
> 
> @@ -3838,7 +3962,7 @@ long do_mkdirat(int dfd, const char __user *pathname, umode_t mode)
> 	error = security_path_mkdir(&path, dentry, mode);
> 	if (!error)
> 		error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
> -	done_path_create(&path, dentry);
> +	__done_path_create(&path, dentry, &wq);
> 	if (retry_estale(error, lookup_flags)) {
> 		lookup_flags |= LOOKUP_REVAL;
> 		goto retry;
> @@ -3904,6 +4028,7 @@ long do_rmdir(int dfd, const char __user *pathname)
> 	struct qstr last;
> 	int type;
> 	unsigned int lookup_flags = 0;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> retry:
> 	name = filename_parentat(dfd, getname(pathname), lookup_flags,
> 				&path, &last, &type);
> @@ -3926,8 +4051,7 @@ long do_rmdir(int dfd, const char __user *pathname)
> 	if (error)
> 		goto exit1;
> 
> -	inode_lock_nested(path.dentry->d_inode, I_MUTEX_PARENT);
> -	dentry = __lookup_hash(&last, path.dentry, lookup_flags);
> +	dentry = lookup_hash_modify(&last, path.dentry, lookup_flags, &wq);
> 	error = PTR_ERR(dentry);
> 	if (IS_ERR(dentry))
> 		goto exit2;
> @@ -3940,9 +4064,9 @@ long do_rmdir(int dfd, const char __user *pathname)
> 		goto exit3;
> 	error = vfs_rmdir(path.dentry->d_inode, dentry);
> exit3:
> +	lookup_done_modify(&path, dentry, &wq);
> 	dput(dentry);
> exit2:
> -	inode_unlock(path.dentry->d_inode);
> 	mnt_drop_write(path.mnt);
> exit1:
> 	path_put(&path);
> @@ -3965,7 +4089,8 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
>  * @dentry:	victim
>  * @delegated_inode: returns victim inode, if the inode is delegated.
>  *
> - * The caller must hold dir->i_mutex.
> + * The caller must either hold a write-lock on dir->i_rwsem, or
> + * a readlock having atomically cleared DCACHE_PAR_UNLINK.
>  *
>  * If vfs_unlink discovers a delegation, it will return -EWOULDBLOCK and
>  * return a reference to the inode in delegated_inode.  The caller
> @@ -4022,6 +4147,11 @@ EXPORT_SYMBOL(vfs_unlink);
>  * directory's i_mutex.  Truncate can take a long time if there is a lot of
>  * writeout happening, and we don't want to prevent access to the directory
>  * while waiting on the I/O.
> + * If both the directory and the target dentry have DCACHE_PAR_UNLINK set,
> + * we do the unlink with a shared lock on the directory while clearing
> + * DCACHE_PAR_UNLINK on the target.  IF the flags is not set, then either
> + * the filesystem doesn't support parallel unlinks, or we are racing with
> + * another thread unlinking the same name.
>  */
> long do_unlinkat(int dfd, struct filename *name)
> {
> @@ -4033,6 +4163,7 @@ long do_unlinkat(int dfd, struct filename *name)
> 	struct inode *inode = NULL;
> 	struct inode *delegated_inode = NULL;
> 	unsigned int lookup_flags = 0;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> retry:
> 	name = filename_parentat(dfd, name, lookup_flags, &path, &last, &type);
> 	if (IS_ERR(name))
> @@ -4045,9 +4176,9 @@ long do_unlinkat(int dfd, struct filename *name)
> 	error = mnt_want_write(path.mnt);
> 	if (error)
> 		goto exit1;
> +
> retry_deleg:
> -	inode_lock_nested(path.dentry->d_inode, I_MUTEX_PARENT);
> -	dentry = __lookup_hash(&last, path.dentry, lookup_flags);
> +	dentry = lookup_hash_modify(&last, path.dentry, lookup_flags, &wq);
> 	error = PTR_ERR(dentry);
> 	if (!IS_ERR(dentry)) {
> 		/* Why not before? Because we want correct error value */
> @@ -4062,14 +4193,15 @@ long do_unlinkat(int dfd, struct filename *name)
> 			goto exit2;
> 		error = vfs_unlink(path.dentry->d_inode, dentry, &delegated_inode);
> exit2:
> +		lookup_done_modify(&path, dentry, &wq);
> 		dput(dentry);
> 	}
> -	inode_unlock(path.dentry->d_inode);
> 	if (inode)
> 		iput(inode);	/* truncate the inode here */
> 	inode = NULL;
> 	if (delegated_inode) {
> 		error = break_deleg_wait(&delegated_inode);
> +		init_waitqueue_head(&wq);
> 		if (!error)
> 			goto retry_deleg;
> 	}
> @@ -4079,6 +4211,7 @@ long do_unlinkat(int dfd, struct filename *name)
> 	if (retry_estale(error, lookup_flags)) {
> 		lookup_flags |= LOOKUP_REVAL;
> 		inode = NULL;
> +		init_waitqueue_head(&wq);
> 		goto retry;
> 	}
> 	putname(name);
> @@ -4139,12 +4272,13 @@ long do_symlinkat(const char __user *oldname, int newdfd,
> 	struct dentry *dentry;
> 	struct path path;
> 	unsigned int lookup_flags = 0;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> 
> 	from = getname(oldname);
> 	if (IS_ERR(from))
> 		return PTR_ERR(from);
> retry:
> -	dentry = user_path_create(newdfd, newname, &path, lookup_flags);
> +	dentry = user_path_create_wq(newdfd, newname, &path, lookup_flags, &wq);
> 	error = PTR_ERR(dentry);
> 	if (IS_ERR(dentry))
> 		goto out_putname;
> @@ -4152,7 +4286,7 @@ long do_symlinkat(const char __user *oldname, int newdfd,
> 	error = security_path_symlink(&path, dentry, from->name);
> 	if (!error)
> 		error = vfs_symlink(path.dentry->d_inode, dentry, from->name);
> -	done_path_create(&path, dentry);
> +	__done_path_create(&path, dentry, &wq);
> 	if (retry_estale(error, lookup_flags)) {
> 		lookup_flags |= LOOKUP_REVAL;
> 		goto retry;
> @@ -4270,6 +4404,7 @@ int do_linkat(int olddfd, const char __user *oldname, int newdfd,
> 	struct inode *delegated_inode = NULL;
> 	int how = 0;
> 	int error;
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> 
> 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
> 		return -EINVAL;
> @@ -4291,8 +4426,8 @@ int do_linkat(int olddfd, const char __user *oldname, int newdfd,
> 	if (error)
> 		return error;
> 
> -	new_dentry = user_path_create(newdfd, newname, &new_path,
> -					(how & LOOKUP_REVAL));
> +	new_dentry = user_path_create_wq(newdfd, newname, &new_path,
> +				      (how & LOOKUP_REVAL), &wq);
> 	error = PTR_ERR(new_dentry);
> 	if (IS_ERR(new_dentry))
> 		goto out;
> @@ -4308,7 +4443,7 @@ int do_linkat(int olddfd, const char __user *oldname, int newdfd,
> 		goto out_dput;
> 	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
> out_dput:
> -	done_path_create(&new_path, new_dentry);
> +	__done_path_create(&new_path, new_dentry, &wq);
> 	if (delegated_inode) {
> 		error = break_deleg_wait(&delegated_inode);
> 		if (!error) {
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 71b2e390becf..9a3c51f3040b 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -57,7 +57,7 @@ static void nfs_readdir_clear_array(struct page*);
> const struct file_operations nfs_dir_operations = {
> 	.llseek		= nfs_llseek_dir,
> 	.read		= generic_read_dir,
> -	.iterate	= nfs_readdir,
> +	.iterate_shared	= nfs_readdir,
> 	.open		= nfs_opendir,
> 	.release	= nfs_closedir,
> 	.fsync		= nfs_fsync_dir,
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 5b1eee4952b7..9a6dac08cc79 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -453,6 +453,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
> 
> 		/* We can't support update_atime(), since the server will reset it */
> 		inode->i_flags |= S_NOATIME|S_NOCMTIME;
> +		/* Parallel updates to directory are trivial */
> +		inode->i_flags |= S_PAR_UPDATE;
> 		inode->i_mode = fattr->mode;
> 		nfsi->cache_validity = 0;
> 		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> index fd61bf0fce63..2ac7a7be10e6 100644
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -467,6 +467,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
> 	sdentry = NULL;
> 	do {
> 		int slen;
> +		d_unlock_modify(sdentry);
> 		dput(sdentry);
> 		sillycounter++;
> 		slen = scnprintf(silly, sizeof(silly),
> @@ -484,7 +485,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
> 		 */
> 		if (IS_ERR(sdentry))
> 			goto out;
> -	} while (d_inode(sdentry) != NULL); /* need negative lookup */
> +	} while (!d_lock_create(sdentry)); /* need negative lookup */
> 
> 	ihold(inode);
> 
> @@ -529,6 +530,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
> 	rpc_put_task(task);
> out_dput:
> 	iput(inode);
> +	d_unlock_modify(sdentry);
> 	dput(sdentry);
> out:
> 	return error;
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index ef4b70f64f33..befa52ec4f6b 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -12,7 +12,9 @@
> #include <linux/rcupdate.h>
> #include <linux/lockref.h>
> #include <linux/stringhash.h>
> +#include <linux/sched.h>
> #include <linux/wait.h>
> +#include <linux/wait_bit.h>
> 
> struct path;
> struct vfsmount;
> @@ -216,6 +218,7 @@ struct dentry_operations {
> 
> #define DCACHE_PAR_LOOKUP		0x10000000 /* being looked up (with parent locked shared) */
> #define DCACHE_DENTRY_CURSOR		0x20000000
> +#define DCACHE_PAR_UPDATE		0x40000000 /* Being created or unlinked with shared lock */
> 
> extern seqlock_t rename_lock;
> 
> @@ -599,4 +602,44 @@ struct name_snapshot {
> void take_dentry_name_snapshot(struct name_snapshot *, struct dentry *);
> void release_dentry_name_snapshot(struct name_snapshot *);
> 
> +/*
> + * Lock a dentry in an S_PAR_UPDATE directory prior to creating
> + * an object with that name.  Will fail if the object is created
> + * or instantiated while we waited.
> + */
> +static inline bool d_lock_create(struct dentry *dentry)
> +{
> +	spin_lock(&dentry->d_lock);
> +	if (dentry->d_flags & DCACHE_PAR_UPDATE)
> +		___wait_var_event(&dentry->d_flags,
> +				  !(dentry->d_flags & DCACHE_PAR_UPDATE),
> +				  TASK_UNINTERRUPTIBLE, 0, 0,
> +				  (spin_unlock(&dentry->d_lock),
> +				   schedule(),
> +				   spin_lock(&dentry->d_lock))
> +			);
> +	if (d_inode(dentry) == NULL) {
> +		dentry->d_flags |= DCACHE_PAR_UPDATE;
> +		spin_unlock(&dentry->d_lock);
> +		return true;
> +	} else {
> +		spin_unlock(&dentry->d_lock);
> +		return false;
> +	}
> +}
> +bool d_lock_modify(struct dentry *dentry,
> +		   struct dentry *base, const struct qstr *name);
> +
> +static inline void d_unlock_modify(struct dentry *dentry)
> +{
> +	if (IS_ERR_OR_NULL(dentry))
> +		return;
> +	if (dentry->d_flags & DCACHE_PAR_UPDATE) {
> +		spin_lock(&dentry->d_lock);
> +		dentry->d_flags &= ~DCACHE_PAR_UPDATE;
> +		spin_unlock(&dentry->d_lock);
> +		wake_up_var(&dentry->d_flags);
> +	}
> +}
> +
> #endif	/* __LINUX_DCACHE_H */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index c95c0807471f..15b1c3223438 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1947,6 +1947,7 @@ struct super_operations {
> #define S_DAX		0	/* Make all the DAX code disappear */
> #endif
> #define S_ENCRYPTED	16384	/* Encrypted file (using fs/crypto/) */
> +#define S_PAR_UPDATE	32768	/* Parallel directory operations supported */
> 
> /*
>  * Note that nosuid etc flags are inode-specific: setting some file-system
> -- 
> 2.14.0.rc0.dirty
> 
> <signature.asc>_______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
