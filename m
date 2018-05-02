From: James Simmons <jsimmons@infradead.org>
Date: Wed, 2 May 2018 04:05:39 +0100 (BST)
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: fix error deref
 in ll_splice_alias().
In-Reply-To: <152514675919.17843.11688659715084804936.stgit@noble>
References: <152514658325.17843.11455067361317157487.stgit@noble>
 <152514675919.17843.11688659715084804936.stgit@noble>
Message-ID: <alpine.LFD.2.21.1805020403530.2551@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> d_splice_alias() can return an ERR_PTR().
> If it does while debugging is enabled, the following
> CDEBUG() will dereference that error and crash.
> 
> So add appropriate checking, and provide a separate
> debug message for the error case.

Yeah!!! It fixed the issues. Thank you.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Reported-by: James Simmons <jsimmons@infradead.org>
> Fixes: e9d4f0b9f559 ("staging: lustre: llite: use d_splice_alias for directories.")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/llite/namei.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
> index 6c9ec462eb41..24a6873d86a2 100644
> --- a/drivers/staging/lustre/lustre/llite/namei.c
> +++ b/drivers/staging/lustre/lustre/llite/namei.c
> @@ -442,11 +442,15 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
>  	} else {
>  		struct dentry *new = d_splice_alias(inode, de);
>  
> +		if (IS_ERR(new))
> +			CDEBUG(D_DENTRY, "splice inode %p as %pd gives error %lu\n",
> +			       inode, de, PTR_ERR(new));
>  		if (new)
>  			de = new;
>  	}
> -	CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
> -	       de, d_inode(de), d_count(de), de->d_flags);
> +	if (!IS_ERR(de))
> +		CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
> +		       de, d_inode(de), d_count(de), de->d_flags);
>  	return de;
>  }
>  
> 
> 
> 
