From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Jan 2017 23:34:15 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: use i_blocksize()
In-Reply-To: <b441c1f131ea37b0a1da3a4fba26d1b27058d983.1484894827.git.geliangtang@gmail.com>
References: <0a58b38c7ddfbbc8f56cb8d815114bd4357a6016.1484895399.git.geliangtang@gmail.com>
	<b441c1f131ea37b0a1da3a4fba26d1b27058d983.1484894827.git.geliangtang@gmail.com>
Message-ID: <alpine.LFD.2.20.1701202333330.11070@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geliang Tang <geliangtang@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


> Since i_blocksize() helper has been defined in fs.h, use it instead
> of open-coding.

The i_blocksize() work hasn't landed to the staging-next tree
so this can't land just yet.
 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  drivers/staging/lustre/lustre/llite/file.c    | 2 +-
>  drivers/staging/lustre/lustre/obdclass/obdo.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index d93f06a..3ee546f 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -2967,7 +2967,7 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat)
>  	stat->atime = inode->i_atime;
>  	stat->mtime = inode->i_mtime;
>  	stat->ctime = inode->i_ctime;
> -	stat->blksize = 1 << inode->i_blkbits;
> +	stat->blksize = i_blocksize(inode);
>  
>  	stat->nlink = inode->i_nlink;
>  	stat->size = i_size_read(inode);
> diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
> index b1dfa16..b9be7db 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obdo.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
> @@ -84,7 +84,7 @@ void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
>  		newvalid |= OBD_MD_FLBLOCKS;
>  	}
>  	if (valid & OBD_MD_FLBLKSZ) {   /* optimal block size */
> -		dst->o_blksize = 1 << src->i_blkbits;
> +		dst->o_blksize = i_blocksize(src);
>  		newvalid |= OBD_MD_FLBLKSZ;
>  	}
>  	if (valid & OBD_MD_FLTYPE) {
> -- 
> 2.9.3
> 
> 
