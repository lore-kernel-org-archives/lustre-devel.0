From: James Simmons <jsimmons@infradead.org>
Date: Thu, 13 Jul 2017 18:07:07 +0100 (BST)
Subject: [lustre-devel] [PATCH] lustre: check
	copy_from_iter/copy_to_iter return code
In-Reply-To: <20170710130833.1834210-1-arnd@arndb.de>
References: <20170710130833.1834210-1-arnd@arndb.de>
Message-ID: <alpine.LFD.2.20.1707131806080.14535@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Doug Oucharek <doug.s.oucharek@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Liang Zhen <liang.zhen@intel.com>, Nicholas Hanley <nicholasjhanley@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


> We now get a helpful warning for code that calls copy_{from,to}_iter
> without checking the return value, introduced by commit aa28de275a24
> ("iov_iter/hardening: move object size checks to inlined part").
> 
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_send':
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1643:2: error: ignoring return value of 'copy_from_iter', declared with attribute warn_unused_result [-Werror=unused-result]
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c: In function 'kiblnd_recv':
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:1744:3: error: ignoring return value of 'copy_to_iter', declared with attribute warn_unused_result [-Werror=unused-result]
> 
> In case we get short copies here, we may get incorrect behavior.
> I've added failure handling for both rx and tx now, returning
> -EFAULT as expected.
> 
> Cc: stable at vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> This warning now shows up in 'allmodconfig' builds, so it would be
> good to get it fixed quickly for 4.13, but my patch should not go
> in without careful review since I'm not familiar with with code
> and the error handling is a bit tricky here.
> 
> I added 'Cc: stable' since this is a preexisting condition that we
> only started warning about now.
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 85b242ec5f9b..70256a0ffd2e 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -1640,8 +1640,13 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
>  	ibmsg = tx->tx_msg;
>  	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
>  
> -	copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
> +	rc = copy_from_iter(&ibmsg->ibm_u.immediate.ibim_payload, IBLND_MSG_SIZE,
>  		       &from);

I have to Nak this to prevent it from landing but for some reason in my 
testing its returning zero from copy_from_iter.


> +	if (rc != IBLND_MSG_SIZE) {
> +		kiblnd_pool_free_node(&tx->tx_pool->tpo_pool, &tx->tx_list);
> +		return -EFAULT;
> +	}
> +
>  	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
>  	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
>  
> @@ -1741,8 +1746,14 @@ kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
>  			break;
>  		}
>  
> -		copy_to_iter(&rxmsg->ibm_u.immediate.ibim_payload,
> +		rc = copy_to_iter(&rxmsg->ibm_u.immediate.ibim_payload,
>  			     IBLND_MSG_SIZE, to);
> +		if (rc != IBLND_MSG_SIZE) {
> +			rc = -EFAULT;
> +			break;
> +		}
> +
> +		rc = 0;
>  		lnet_finalize(ni, lntmsg, 0);
>  		break;
>  
> -- 
> 2.9.0
> 
> 
