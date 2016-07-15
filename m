From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 15 Jul 2016 01:01:35 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: iov fixes for
	kiblnd_send
In-Reply-To: <1468257501-20630-1-git-send-email-jsimmons@infradead.org>
References: <1468257501-20630-1-git-send-email-jsimmons@infradead.org>
Message-ID: <72A3B3D7-69A3-40D4-8B89-103EB342E894@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Lustre Development List <lustre-devel@lists.lustre.org>


On Jul 11, 2016, at 1:18 PM, James Simmons wrote:

> With the move to iov_iter handling two issues merged
> for the ko2iblnd driver. The first fix address a simple
> typo of the wrong flag being used with iov_iter_kvec.
> The second fix adds the payload offset to the payload
> size.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 13 ++++++++-----
> 1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 3d597dc..437e149 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -1519,12 +1519,15 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
> 	/* payload is either all vaddrs or all pages */
> 	LASSERT(!(payload_kiov && payload_iov));
> 
> -	if (payload_kiov)
> +	if (payload_kiov) {

The braces are in fact going to make checkpatch complain that we do not
need them here.

> 		iov_iter_bvec(&from, ITER_BVEC | WRITE,
> -				payload_kiov, payload_niov, payload_nob);
> -	else
> -		iov_iter_kvec(&from, ITER_BVEC | WRITE,
> -				payload_iov, payload_niov, payload_nob);
> +			      payload_kiov, payload_niov,
> +			      payload_nob + payload_offset);

Why are we adding the offset to number of bytes here?

> +	} else {
> +		iov_iter_kvec(&from, ITER_KVEC | WRITE,
> +			      payload_iov, payload_niov,
> +			      payload_nob + payload_offset);
> +	}
> 	iov_iter_advance(&from, payload_offset);

Ah, I guess we added it there to then subtract here?

Do you mind if I just merge this change into Al's patch with you as another
Signed-off-by line instead?
Since we caught this early, probably no point in having a breakage point in
the history as it might break a future bisect.


> 	switch (type) {
> -- 
> 2.7.4
