From: Amir Shehata <ashehata@whamcloud.com>
Date: Tue, 31 Jul 2018 23:54:30 +0000
Subject: [lustre-devel] [PATCH 11/31] lustre: lnet: Fix route hops print
In-Reply-To: <877elbrpxh.fsf@notabene.neil.brown.name>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-12-git-send-email-jsimmons@infradead.org>,
 <877elbrpxh.fsf@notabene.neil.brown.name>
Message-ID: <3C0BF267DA2B2343B6A8D6013E6C43381AAE2A@LAX-EX-MB3.datadirect.datadirectnet.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The way hop and priority work in the code is they serve to select the preferred route. If you have multiple gateways leading to the same destination, you select the one with the highest priority (0 being the highest), followed by selecting the one with the least number of hops. If you don't specify hops, then it's actually treated as the least favoured if there are other routes with hops specified. If hops and priority are equivalent between routes, then you select the one with the most credits available, if that's equivalent you select in round robin.
 
In that sense hops and priority really serve the same purpose, select the preferred route. If it was up to me I would keep only one of them, but for historical reasons, both are kept.

Therefore, I'm not sure if "unlimited" actually relays the correct interpretation of that value. Note there could be user scripts out there that are already parsing the output. So by changing the -1 you could break the scripts. Also changing that will create an inconsistency between the server and client.

thanks
amir
________________________________________
From: NeilBrown [neilb at suse.com]
Sent: Tuesday, July 31, 2018 3:38 PM
To: James Simmons; Andreas Dilger; Oleg Drokin
Cc: Lustre Development List; Amir Shehata; James Simmons
Subject: Re: [PATCH 11/31] lustre: lnet: Fix route hops print

On Mon, Jul 30 2018, James Simmons wrote:

> From: Amir Shehata <ashehata@whamcloud.com>
>
> The default number of hops for  a route is -1. This is
> currently being printed as %u. Change that to %d to
> make it print out properly.

-1 hops???  I wish I could hop -1 times - it would be a good party
trick!!

What does -1 mean?  Unlimited (just a guess).  If so, could we print
"unlimited"??

I'm fine with having magic numbers in the code, but I don't like them to
leak out.

NeilBrown

>
> Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
> WC-id: https://jira.whamcloud.com/browse/LU-9078
> Reviewed-on: https://review.whamcloud.com/25250
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lnet/lnet/router_proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 8856798..aa98ce5 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -218,7 +218,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
>                       int alive = lnet_is_route_alive(route);
>
>                       s += snprintf(s, tmpstr + tmpsiz - s,
> -                                   "%-8s %4u %8u %7s %s\n",
> +                                   "%-8s %4d %8u %7s %s\n",
>                                     libcfs_net2str(net), hops,
>                                     priority,
>                                     alive ? "up" : "down",
> --
> 1.8.3.1
