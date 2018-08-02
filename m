From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:13:32 +0100 (BST)
Subject: [lustre-devel] [PATCH 3/6] lustre: convert list_for_each in
 ksocknal_create_routes
In-Reply-To: <153292233962.26104.2678883514539213796.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
 <153292233962.26104.2678883514539213796.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020413220.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> The two list_for_each() loops in ksocknal_create_routes() cannot be
> trivially converted to list_for_each_entry() as the new loop variable
> is expected to be NULL after the loop, if the loop completed normally.
> 
> If the loop did not complete normally - if an interesting entry was
> found - a 'continue' is required in the higher level loop.  Change
> this 'continue' to a 'goto' so it can be called in the inner loop, and
> we don't need to check for a variable being NULL.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   29 +++++---------------
>  1 file changed, 7 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 491d2ed5b673..f495e0faeac4 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -846,7 +846,6 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
>  	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
>  	struct lnet_ni *ni = peer->ksnp_ni;
>  	struct ksock_net *net = ni->ni_data;
> -	struct list_head *rtmp;
>  	struct ksock_route *route;
>  	struct ksock_interface *iface;
>  	struct ksock_interface *best_iface;
> @@ -894,17 +893,9 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
>  		}
>  
>  		/* Already got a route? */
> -		route = NULL;
> -		list_for_each(rtmp, &peer->ksnp_routes) {
> -			route = list_entry(rtmp, struct ksock_route, ksnr_list);
> -
> -			if (route->ksnr_ipaddr == newroute->ksnr_ipaddr)
> -				break;
> -
> -			route = NULL;
> -		}
> -		if (route)
> -			continue;
> +		list_for_each_entry(route, &peer->ksnp_routes, ksnr_list)
> +			if (route->ksnr_ipaddr != newroute->ksnr_ipaddr)
> +				goto next_ipaddr;
>  
>  		best_iface = NULL;
>  		best_nroutes = 0;
> @@ -917,17 +908,9 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
>  			iface = &net->ksnn_interfaces[j];
>  
>  			/* Using this interface already? */
> -			list_for_each(rtmp, &peer->ksnp_routes) {
> -				route = list_entry(rtmp, struct ksock_route,
> -						   ksnr_list);
> -
> +			list_for_each_entry(route, &peer->ksnp_routes, ksnr_list)
>  				if (route->ksnr_myipaddr == iface->ksni_ipaddr)
> -					break;
> -
> -				route = NULL;
> -			}
> -			if (route)
> -				continue;
> +					goto next_iface;
>  
>  			this_netmatch = (!((iface->ksni_ipaddr ^
>  					   newroute->ksnr_ipaddr) &
> @@ -942,6 +925,7 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
>  			best_iface = iface;
>  			best_netmatch = this_netmatch;
>  			best_nroutes = iface->ksni_nroutes;
> +		next_iface:;
>  		}
>  
>  		if (!best_iface)
> @@ -952,6 +936,7 @@ ksocknal_create_routes(struct ksock_peer *peer, int port,
>  
>  		ksocknal_add_route_locked(peer, newroute);
>  		newroute = NULL;
> +	next_ipaddr:;
>  	}
>  
>  	write_unlock_bh(global_lock);
> 
> 
> 
