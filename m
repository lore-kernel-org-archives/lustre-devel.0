From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 30 Oct 2017 23:38:29 +0000
Subject: [lustre-devel] [PATCH] lustre: don't set f_version in ll_readdir
In-Reply-To: <20171030150012.2101-1-jlayton@kernel.org>
References: <20171030150012.2101-1-jlayton@kernel.org>
Message-ID: <884F92FF-0C9D-4B97-A034-865351D22D56@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 30, 2017, at 23:00, Jeff Layton <jlayton@kernel.org> wrote:
> 
> From: Jeff Layton <jlayton@redhat.com>
> 
> f_version is only ever used by filesystem-specific code. Generic
> VFS code never uses it.
> 
> Nothing in lustre ever looks at it, so just remove this.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/llite/dir.c | 3 ---
> 1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 1db3e7f345c5..9664447ffcd7 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -367,8 +367,6 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
> 	}
> 	ctx->pos = pos;
> 	ll_finish_md_op_data(op_data);
> -	filp->f_version = inode->i_version;
> -
> out:
> 	if (!rc)
> 		ll_stats_ops_tally(sbi, LPROC_LL_READDIR, 1);
> @@ -1675,7 +1673,6 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
> 			else
> 				fd->lfd_pos = offset;
> 			file->f_pos = offset;
> -			file->f_version = 0;
> 		}
> 		ret = offset;
> 	}
> -- 
> 2.13.6
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
