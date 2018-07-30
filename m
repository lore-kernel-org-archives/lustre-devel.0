From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 30 Jul 2018 21:09:56 +0000
Subject: [lustre-devel] [PATCH 6/6] lustre: convert list_for_each() in
 ksocknal_debug_peerhash()
In-Reply-To: <153292233972.26104.9739049020807431895.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
 <153292233972.26104.9739049020807431895.stgit@noble>
Message-ID: <84837363-BB4D-40D4-9FA2-2F8A02915B04@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 29, 2018, at 21:45, NeilBrown <neilb@suse.com> wrote:
> 
> This list_for_each() loop searches for a particular entry,
> then acts of in.  It currently acts after the loop by testing
> if the variable is NULL.  When we convert to list_for_each_entry()
> it won't be NULL.
> 
> Change the code so the acting happens inside the loop.
> list_for_each_entry() {
>    if (this isn't it)
>        continue;
>    act on entry;
>    goto done; // break out of 2 loops
> }
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   64 +++++++++-----------
> 1 file changed, 28 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 33335713b371..f0b0480686dc 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -2462,52 +2462,44 @@ static void
> ksocknal_debug_peerhash(struct lnet_ni *ni)
> {
> 	struct ksock_peer *peer = NULL;
> -	struct list_head *tmp;
> 	int i;
> 
> 	read_lock(&ksocknal_data.ksnd_global_lock);
> 
> 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
> -		list_for_each(tmp, &ksocknal_data.ksnd_peers[i]) {
> -			peer = list_entry(tmp, struct ksock_peer, ksnp_list);
> -
> -			if (peer->ksnp_ni == ni)
> -				break;
> +		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
> +			struct ksock_route *route;
> +			struct ksock_conn  *conn;
> 
> -			peer = NULL;
> -		}
> -	}
> +			if (peer->ksnp_ni != ni)
> +				continue;
> 
> -	if (peer) {
> -		struct ksock_route *route;
> -		struct ksock_conn  *conn;
> -
> -		CWARN("Active peer on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
> -		      libcfs_id2str(peer->ksnp_id),
> -		      atomic_read(&peer->ksnp_refcount),
> -		      peer->ksnp_sharecount, peer->ksnp_closing,
> -		      peer->ksnp_accepting, peer->ksnp_error,
> -		      peer->ksnp_zc_next_cookie,
> -		      !list_empty(&peer->ksnp_tx_queue),
> -		      !list_empty(&peer->ksnp_zc_req_list));
> -
> -		list_for_each(tmp, &peer->ksnp_routes) {
> -			route = list_entry(tmp, struct ksock_route, ksnr_list);
> -			CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
> -			      atomic_read(&route->ksnr_refcount),
> -			      route->ksnr_scheduled, route->ksnr_connecting,
> -			      route->ksnr_connected, route->ksnr_deleted);
> -		}
> +			CWARN("Active peer on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
> +			      libcfs_id2str(peer->ksnp_id),
> +			      atomic_read(&peer->ksnp_refcount),
> +			      peer->ksnp_sharecount, peer->ksnp_closing,
> +			      peer->ksnp_accepting, peer->ksnp_error,
> +			      peer->ksnp_zc_next_cookie,
> +			      !list_empty(&peer->ksnp_tx_queue),
> +			      !list_empty(&peer->ksnp_zc_req_list));
> +
> +			list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
> +				CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
> +				      atomic_read(&route->ksnr_refcount),
> +				      route->ksnr_scheduled, route->ksnr_connecting,
> +				      route->ksnr_connected, route->ksnr_deleted);
> +			}
> 
> -		list_for_each(tmp, &peer->ksnp_conns) {
> -			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
> -			CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
> -			      atomic_read(&conn->ksnc_conn_refcount),
> -			      atomic_read(&conn->ksnc_sock_refcount),
> -			      conn->ksnc_type, conn->ksnc_closing);
> +			list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
> +				CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
> +				      atomic_read(&conn->ksnc_conn_refcount),
> +				      atomic_read(&conn->ksnc_sock_refcount),
> +				      conn->ksnc_type, conn->ksnc_closing);
> +			}
> +			goto done;
> 		}
> 	}
> -
> +done:
> 	read_unlock(&ksocknal_data.ksnd_global_lock);
> }
> 
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud




-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180730/ec2a82cb/attachment.sig>
