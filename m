From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 13:20:50 +1000
Subject: [lustre-devel] [PATCH 01/30] lustre: lnd: resolve IP query code
 in LND drivers
In-Reply-To: <1537205440-6656-2-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87bm8n60od.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> The recent IP querying code that landed to both ksocklnd and
> ko2iblnd have some bugs that prevent proper setup. The first
> bug in both drivers is that the IP address of ifa_local is in
> big endian format so on little endian systems the IP address
> is incorrect. Calling ntohl() on ifa_local gets the real IP
> address. The second bug located in ko2iblnd is that in_dev is
> always NULL. Add the call __in_dev_get_rtnl() to get in_dev
> and use that information to query the IP address.

Thanks!
I've added:
Fixes: 10e138e41a43 ("lustre: o2iblnd: get IP address more directly.")
Fixes: f703f71afd98 ("lustre: socklnd:  use for_each_netdev() instead of lnet_ipif_enumerate()")

and applied this.

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 12 +++++++++---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c |  2 +-
>  2 files changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 15953e4..6874e53 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -2468,8 +2468,7 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
>  	flags = dev_get_flags(netdev);
>  	if (!(flags & IFF_UP)) {
>  		CERROR("Can't query IPoIB interface %s: it's down\n", ifname);
> -		rtnl_unlock();
> -		return NULL;
> +		goto unlock;
>  	}
>  
>  	dev = kzalloc(sizeof(*dev), GFP_NOFS);
> @@ -2481,9 +2480,16 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
>  	INIT_LIST_HEAD(&dev->ibd_nets);
>  	INIT_LIST_HEAD(&dev->ibd_list); /* not yet in kib_devs */
>  	INIT_LIST_HEAD(&dev->ibd_fail_list);
> +
> +	in_dev = __in_dev_get_rtnl(netdev);
> +	if (!in_dev) {
> +		kfree(dev);
> +		goto unlock;
> +	}
> +
>  	for_primary_ifa(in_dev)
>  		if (strcmp(ifa->ifa_label, ifname) == 0) {
> -			dev->ibd_ifip = ifa->ifa_local;
> +			dev->ibd_ifip = ntohl(ifa->ifa_local);
>  			break;
>  		}
>  	endfor_ifa(in_dev);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 5b81040..750a7ce 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -2589,7 +2589,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
>  		}
>  		for_primary_ifa(in_dev)
>  			if (strcmp(ifa->ifa_label, name) == 0) {
> -				ksi->ksni_ipaddr = ifa->ifa_local;
> +				ksi->ksni_ipaddr = ntohl(ifa->ifa_local);
>  				ksi->ksni_netmask = ifa->ifa_mask;
>  				strlcpy(ksi->ksni_name,
>  					name, sizeof(ksi->ksni_name));
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/08db0d01/attachment.sig>
