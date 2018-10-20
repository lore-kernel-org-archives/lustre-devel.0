From: James Simmons <jsimmons@infradead.org>
Date: Sat, 20 Oct 2018 20:06:24 +0100 (BST)
Subject: [lustre-devel] [PATCH] lustre: lprocfs: fix return value of
 lprocfs_read_helper
In-Reply-To: <87y3avc1fp.fsf@notabene.neil.brown.name>
References: <87y3avc1fp.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810202003470.16676@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


 
> This should be 'ret', not zero.

I bet that was one of my first patches to the linux lustre client since 
its a really old patch. Thanks for figuring that out.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Fixes: fdedd94509fd ("staging/lustre/lvfs: remove the lvfs layer")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index dc1d540e05c7..edac88440b41 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1509,7 +1509,7 @@ __s64 lprocfs_read_helper(struct lprocfs_counter *lc,
>  		break;
>  	}
>  
> -	return 0;
> +	return ret;
>  }
>  EXPORT_SYMBOL(lprocfs_read_helper);
>  
> -- 
> 2.14.0.rc0.dirty
> 
> 
