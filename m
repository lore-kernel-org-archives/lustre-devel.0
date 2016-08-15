From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 Aug 2016 18:55:01 +0200
Subject: [lustre-devel] [PATCH 07/15] lustre: ->kss_scratch... are
	unused now
In-Reply-To: <1469255832-746785-8-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
	<1469255832-746785-8-git-send-email-green@linuxhacker.ru>
Message-ID: <20160815165501.GA23625@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jul 23, 2016 at 02:37:04AM -0400, Oleg Drokin wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> index d5efb42..84a915c 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> @@ -86,10 +86,6 @@ struct ksock_sched {				/* per scheduler state */
>  	int                     kss_nconns;     /* # connections assigned to
>  						 * this scheduler */
>  	struct ksock_sched_info *kss_info;	/* owner of it */
> -	union {
> -		struct bio_vec          kss_scratch_bvec[LNET_MAX_IOV];
> -		struct kvec             kss_scratch_iov[LNET_MAX_IOV];

kss_scratch_iov is still being used in the tree :(

Oleg, can you fix this up based on the current staging-testing branch
and resend the rest of this series?

Also, whenever you forward on patches to me, be sure to add your
signed-off-by to it, you forgot to do that on Al's patches...

thanks,

greg k-h
