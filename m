From: NeilBrown <neilb@suse.com>
Date: Wed, 17 Oct 2018 17:11:33 +1100
Subject: [lustre-devel] [PATCH 03/10] lustre: lnd: rework map_on_demand
 behavior
In-Reply-To: <1539543332-28679-4-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
 <1539543332-28679-4-git-send-email-jsimmons@infradead.org>
Message-ID: <87bm7tdrvu.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> @@ -1320,9 +1324,8 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
>  {
>  	LASSERT(!fpo->fpo_map_count);
>  
> -	if (fpo->fpo_is_fmr) {
> -		if (fpo->fmr.fpo_fmr_pool)
> -			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
> +	if (fpo->fpo_is_fmr && fpo->fmr.fpo_fmr_pool) {
> +		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
>  	} else {
>  		struct kib_fast_reg_descriptor *frd;
>  		int i = 0;

This change looks strange.
With the new code: if fpo_fmr_pool is NULL, then the fpo_pool_list is
destroyed, even though fpo_is_fmr.

Are we sure that is correct??
I don't really understand this code so it might be correct, but the
change looks wrong.

Can someone please confirm that it really is right - and maybe explain
why?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181017/a6c3f1f4/attachment.sig>
