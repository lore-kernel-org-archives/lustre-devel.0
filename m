From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 01:34:19 +0000 (GMT)
Subject: [lustre-devel] [PATCH 5/9] lustre: llite: clear
 LLIF_FILE_RESTORING when done
In-Reply-To: <154295732800.2850.8303806531168774380.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732800.2850.8303806531168774380.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260133540.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Bruno Faccini <bruno.faccini@intel.com>
> 
> Clear LLIF_FILE_RESTORING if restore done to ensure to start again
> to glimpse new attrs.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-6560
> Reviewed-on: http://review.whamcloud.com/14609
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/llite/llite_lib.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index fac65845526a..b8693049f3b6 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -1905,8 +1905,14 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
>  	}
>  
>  	if (body->mbo_valid & OBD_MD_TSTATE) {
> +		/* Set LLIF_FILE_RESTORING if restore ongoing and
> +		 * clear it when done to ensure to start again
> +		 * glimpsing updated attrs
> +		 */
>  		if (body->mbo_t_state & MS_RESTORE)
>  			set_bit(LLIF_FILE_RESTORING, &lli->lli_flags);
> +		else
> +			clear_bit(LLIF_FILE_RESTORING, &lli->lli_flags);
>  	}
>  
>  	return 0;
> 
> 
> 
