From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Dec 2016 00:21:19 +0000 (GMT)
Subject: [lustre-devel] [PATCH 2/8] staging/lustre/ldlm: Correct
 itree_overlap_cb return type
In-Reply-To: <1481150494-1853127-3-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
	<1481150494-1853127-3-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1612080016330.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> As per interval_search() prototype, the callback should return
> enum, not int.
> This fixes correspondign sparse warning.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>

Reviewed-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index a4a291a..f4cbc89 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -1148,7 +1148,7 @@ static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
>  	return INTERVAL_ITER_STOP;
>  }
>  
> -static unsigned int itree_overlap_cb(struct interval_node *in, void *args)
> +static enum interval_iter itree_overlap_cb(struct interval_node *in, void *args)
>  {
>  	struct ldlm_interval *node = to_ldlm_interval(in);
>  	struct lock_match_data *data = args;
> -- 
> 2.7.4
> 
> 
