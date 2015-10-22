From: Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 22 Oct 2015 12:21:44 -0400 (EDT)
Subject: [lustre-devel] [PATCH 1/3] locks: introduce
	locks_lock_inode_wait()
In-Reply-To: <daf0d3941f34438c1fbdc94a5f3a47c2b22f3ee8.1445524157.git.bcodding@redhat.com>
References: <cover.1445524157.git.bcodding@redhat.com>
	<daf0d3941f34438c1fbdc94a5f3a47c2b22f3ee8.1445524157.git.bcodding@redhat.com>
Message-ID: <alpine.OSX.2.19.9992.1510221219010.6711@planck.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 22 Oct 2015, Benjamin Coddington wrote:

> Users of the locks API commonly call either posix_lock_file_wait() or
> flock_lock_file_wait() depending upon the lock type.  Add a new function
> locks_lock_inode_wait() which will check and call the correct function for
> the type of lock passed in.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/locks.c         |   24 ++++++++++++++++++++++++
>  include/linux/fs.h |   11 +++++++++++
>  2 files changed, 35 insertions(+), 0 deletions(-)
>
> diff --git a/fs/locks.c b/fs/locks.c
> index 2a54c80..68b1784 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1876,6 +1876,30 @@ int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
>  EXPORT_SYMBOL(flock_lock_inode_wait);
>
>  /**
> + * locks_lock_inode_wait - Apply a lock to an inode
> + * @inode: inode of the file to apply to
> + * @fl: The lock to be applied
> + *
> + * Apply a POSIX or FLOCK style lock request to an inode.
> + */
> +int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl)
> +{
> +	int res = 0;
> +	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> +		case FL_POSIX:
> +			res = posix_lock_inode_wait(inode, fl);
> +			break;
> +		case FL_FLOCK:
> +			res = flock_lock_inode_wait(inode, fl);
> +			break;
> +		default:
> +			BUG();
> +	}
> +	return res;
> +}
> +EXPORT_SYMBOL(locks_lock_inode_wait);
> +
> +/**
>   *	sys_flock: - flock() system call.
>   *	@fd: the file descriptor to lock.
>   *	@cmd: the type of lock to apply.
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 72d8a84..2e283b7 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1059,6 +1059,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
>  extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
>  extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
>  extern int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl);
> +extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl);
>  extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
>  extern void lease_get_mtime(struct inode *, struct timespec *time);
>  extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
> @@ -1177,6 +1178,11 @@ static inline int flock_lock_inode_wait(struct inode *inode,
>  	return -ENOLCK;
>  }
>
> +static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
> +{
> +	return -ENOLCK;
> +}
> +

So, this is obviously wrong - thank you 0-day robot.  Yes, I did build and
test against these patches, but went back and added this after I realized it
should work w/o CONFIG_FILE_LOCKING.  I'll re-send.

Ben

>  static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
>  {
>  	return 0;
> @@ -1225,6 +1231,11 @@ static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
>  	return flock_lock_inode_wait(file_inode(filp), fl);
>  }
>
> +static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
> +{
> +	return locks_lock_inode_wait(file_inode(filp), fl);
> +}
> +
>  struct fasync_struct {
>  	spinlock_t		fa_lock;
>  	int			magic;
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo at vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
