From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:13:54 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/6] lustre: convert list_for_each in
 ksocknal_close_conn_locked()
In-Reply-To: <153292233965.26104.17508687927758478856.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
 <153292233965.26104.17508687927758478856.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020413420.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> The use of list_for_each in ksocknal_close_conn_locked() cannot be
> trivially converted to list_for_each_entry() as the new
> loop variable has NULL tests outside the loop.
> 
> Change these to use a goto inside the loop.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   15 ++++-----------
>  1 file changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index f495e0faeac4..ea95bff79996 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -1402,7 +1402,6 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
>  	struct ksock_peer *peer = conn->ksnc_peer;
>  	struct ksock_route *route;
>  	struct ksock_conn *conn2;
> -	struct list_head *tmp;
>  
>  	LASSERT(!peer->ksnp_error);
>  	LASSERT(!conn->ksnc_closing);
> @@ -1417,19 +1416,13 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
>  		LASSERT(!route->ksnr_deleted);
>  		LASSERT(route->ksnr_connected & (1 << conn->ksnc_type));
>  
> -		conn2 = NULL;
> -		list_for_each(tmp, &peer->ksnp_conns) {
> -			conn2 = list_entry(tmp, struct ksock_conn, ksnc_list);
> -
> +		list_for_each_entry(conn2, &peer->ksnp_conns, ksnc_list) {
>  			if (conn2->ksnc_route == route &&
>  			    conn2->ksnc_type == conn->ksnc_type)
> -				break;
> -
> -			conn2 = NULL;
> +				goto conn2_found;
>  		}
> -		if (!conn2)
> -			route->ksnr_connected &= ~(1 << conn->ksnc_type);
> -
> +		route->ksnr_connected &= ~(1 << conn->ksnc_type);
> +	conn2_found:
>  		conn->ksnc_route = NULL;
>  
>  		ksocknal_route_decref(route);     /* drop conn's ref on route */
> 
> 
> 
