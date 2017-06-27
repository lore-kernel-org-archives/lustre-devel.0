From: Jeff Layton <jlayton@poochiereds.net>
Date: Tue, 27 Jun 2017 15:36:10 -0400
Subject: [lustre-devel] [PATCH 3/3] staging/lustre, 9p, ceph, cifs,
 dlm: negate remote pids for F_GETLK
In-Reply-To: <3154a78290017da7bbbcb920456b860dbfe9ba26.1498572504.git.bcodding@redhat.com>
References: <cover.1498572504.git.bcodding@redhat.com>
	<3154a78290017da7bbbcb920456b860dbfe9ba26.1498572504.git.bcodding@redhat.com>
Message-ID: <1498592170.4830.8.camel@poochiereds.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ron Minnich <rminnich-4OHPYypu0djtX7QSmKvirg@public.gmane.org>, Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sage Weil <sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Christine Caulfield <ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Teigland <teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Vitaly Fertman <vitaly_fertman-qCPWdT176rRBDgjK7y7TUQ@public.gmane.org>, "John L. Hammond" <john.hammond-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andriy
Cc: lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Tue, 2017-06-27 at 11:18 -0400, Benjamin Coddington wrote:
> In the previous patch, the locks API will expect that if a filesystem
> returns a remote pid as opposed to a local pid for F_GETLK, that remote pid
> will be <= 0.  This signifies that the pid is remote, and the locks API
> will forego translating that pid into the pid namespace of the local
> calling process.  Since local pids will never be larger than PID_MAX_LIMIT
> (which is currently defined as <= 4 million), but pid_t is an unsigned int,
> we should have plenty of room to represent remote pids with negative
> numbers if we assume that remote pid numbers are similarly limited.  If
> this is not the case, then we run the risk of having a remote pid returned
> for which there is also a corresponding local pid.  This is a problem we
> have now, but this patch should reduce the chances of that occurring, while
> also returning those remote pid numbers, for whatever that may be worth.
>
> This patch updates lustre, 9p, ceph, cifs, and dlm to negate the remote pid
> returned for F_GETLK lock requests.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c | 2 +-
>  fs/9p/vfs_file.c                                | 2 +-
>  fs/ceph/locks.c                                 | 2 +-
>  fs/cifs/cifssmb.c                               | 2 +-
>  fs/dlm/plock.c                                  | 2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> index b7f28b39c7b3..abcbf075acc0 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> @@ -596,7 +596,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
>  		default:
>  			getlk->fl_type = F_UNLCK;
>  		}
> -		getlk->fl_pid = (pid_t)lock->l_policy_data.l_flock.pid;
> +		getlk->fl_pid = -(pid_t)lock->l_policy_data.l_flock.pid;
>  		getlk->fl_start = (loff_t)lock->l_policy_data.l_flock.start;
>  		getlk->fl_end = (loff_t)lock->l_policy_data.l_flock.end;
>  	} else {
> diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
> index 3de3b4a89d89..43c242e17132 100644
> --- a/fs/9p/vfs_file.c
> +++ b/fs/9p/vfs_file.c
> @@ -288,7 +288,7 @@ static int v9fs_file_getlock(struct file *filp, struct file_lock *fl)
>  			fl->fl_end = OFFSET_MAX;
>  		else
>  			fl->fl_end = glock.start + glock.length - 1;
> -		fl->fl_pid = glock.proc_id;
> +		fl->fl_pid = -glock.proc_id;
>  	}
>  	kfree(glock.client_id);
>  	return res;
> diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
> index 6806dbeaee19..0fd5c288ce4e 100644
> --- a/fs/ceph/locks.c
> +++ b/fs/ceph/locks.c
> @@ -79,7 +79,7 @@ static int ceph_lock_message(u8 lock_type, u16 operation, struct file *file,
>  	err = ceph_mdsc_do_request(mdsc, inode, req);
>  
>  	if (operation == CEPH_MDS_OP_GETFILELOCK) {
> -		fl->fl_pid = le64_to_cpu(req->r_reply_info.filelock_reply->pid);
> +		fl->fl_pid = -le64_to_cpu(req->r_reply_info.filelock_reply->pid);
>  		if (CEPH_LOCK_SHARED == req->r_reply_info.filelock_reply->type)
>  			fl->fl_type = F_RDLCK;
>  		else if (CEPH_LOCK_EXCL == req->r_reply_info.filelock_reply->type)
> diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
> index fbb0d4cbda41..cb367050f972 100644
> --- a/fs/cifs/cifssmb.c
> +++ b/fs/cifs/cifssmb.c
> @@ -2515,7 +2515,7 @@ CIFSSMBPosixLock(const unsigned int xid, struct cifs_tcon *tcon,
>  			pLockData->fl_start = le64_to_cpu(parm_data->start);
>  			pLockData->fl_end = pLockData->fl_start +
>  					le64_to_cpu(parm_data->length) - 1;
> -			pLockData->fl_pid = le32_to_cpu(parm_data->pid);
> +			pLockData->fl_pid = -le32_to_cpu(parm_data->pid);
>  		}
>  	}
>  
> diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
> index d401425f602a..e631b1689228 100644
> --- a/fs/dlm/plock.c
> +++ b/fs/dlm/plock.c
> @@ -367,7 +367,7 @@ int dlm_posix_get(dlm_lockspace_t *lockspace, u64 number, struct file *file,
>  		locks_init_lock(fl);
>  		fl->fl_type = (op->info.ex) ? F_WRLCK : F_RDLCK;
>  		fl->fl_flags = FL_POSIX;
> -		fl->fl_pid = op->info.pid;
> +		fl->fl_pid = -op->info.pid;
>  		fl->fl_start = op->info.start;
>  		fl->fl_end = op->info.end;
>  		rv = 0;


I think this is probably a reasonable thing to do, given that we also
report OFD locks today with an l_pid of -1. The pid on any sort of
distributed fs is pretty meaningless anyway.

I think this all looks good. I'll plan to merge it for -next in a bit
and do some testing with it.

Thanks!
-- 
Jeff Layton <jlayton@poochiereds.net>
