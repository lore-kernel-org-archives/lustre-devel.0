From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:12:46 +0100 (BST)
Subject: [lustre-devel] [PATCH 1/6] lustre: convert list_for_each() to
 list_for_each_entry().
In-Reply-To: <153292233953.26104.11218548856426762220.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
 <153292233953.26104.11218548856426762220.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020412330.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 30 Jul 2018, NeilBrown wrote:

> Where we have
>   struct list_head *tmp;
>   list_for_each(tmp,....) {
>      foo = list_entry(tmp, ....);
>      ...
>   }
> 
> convert to
>   list_for_each_entry(foo, .....) {
>   .....
>   }
> 
> This patch only changes instances which are straight forward, where
> neither the 'tmp' variable nor the 'foo' variable is not used outside
> the loop in any way that isn't trivially correct.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   17 ++-----
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   20 ++------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   51 +++++---------------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   20 ++------
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   29 ++---------
>  drivers/staging/lustre/lnet/lnet/config.c          |   17 ++-----
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    9 +---
>  drivers/staging/lustre/lnet/lnet/router.c          |   47 ++++--------------
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    7 +--
>  drivers/staging/lustre/lustre/obdclass/genops.c    |    4 --
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    4 --
>  11 files changed, 53 insertions(+), 172 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 830a5bf34c16..e15ad94151bd 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -386,11 +386,9 @@ struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid)
>  	 * that this creates
>  	 */
>  	struct list_head *peer_list = kiblnd_nid2peerlist(nid);
> -	struct list_head *tmp;
>  	struct kib_peer *peer;
>  
> -	list_for_each(tmp, peer_list) {
> -		peer = list_entry(tmp, struct kib_peer, ibp_list);
> +	list_for_each_entry(peer, peer_list, ibp_list) {
>  		LASSERT(!kiblnd_peer_idle(peer));
>  
>  		if (peer->ibp_nid != nid)
> @@ -419,15 +417,13 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
>  				lnet_nid_t *nidp, int *count)
>  {
>  	struct kib_peer *peer;
> -	struct list_head *ptmp;
>  	int i;
>  	unsigned long flags;
>  
>  	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
>  
>  	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
> -		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
> -			peer = list_entry(ptmp, struct kib_peer, ibp_list);
> +		list_for_each_entry(peer, &kiblnd_data.kib_peers[i], ibp_list) {
>  			LASSERT(!kiblnd_peer_idle(peer));
>  
>  			if (peer->ibp_ni != ni)
> @@ -526,28 +522,23 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
>  static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
>  {
>  	struct kib_peer *peer;
> -	struct list_head *ptmp;
>  	struct kib_conn *conn;
> -	struct list_head *ctmp;
>  	int i;
>  	unsigned long flags;
>  
>  	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
>  
>  	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
> -		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
> -			peer = list_entry(ptmp, struct kib_peer, ibp_list);
> +		list_for_each_entry(peer, &kiblnd_data.kib_peers[i], ibp_list) {
>  			LASSERT(!kiblnd_peer_idle(peer));
>  
>  			if (peer->ibp_ni != ni)
>  				continue;
>  
> -			list_for_each(ctmp, &peer->ibp_conns) {
> +			list_for_each_entry(conn, &peer->ibp_conns, ibc_list) {
>  				if (index-- > 0)
>  					continue;
>  
> -				conn = list_entry(ctmp, struct kib_conn,
> -						  ibc_list);
>  				kiblnd_conn_addref(conn);
>  				read_unlock_irqrestore(
>  					&kiblnd_data.kib_global_lock,
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index bda67d49597d..2f7a64f2f13a 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -225,11 +225,9 @@ kiblnd_post_rx(struct kib_rx *rx, int credit)
>  static struct kib_tx *
>  kiblnd_find_waiting_tx_locked(struct kib_conn *conn, int txtype, __u64 cookie)
>  {
> -	struct list_head *tmp;
> -
> -	list_for_each(tmp, &conn->ibc_active_txs) {
> -		struct kib_tx *tx = list_entry(tmp, struct kib_tx, tx_list);
> +	struct kib_tx *tx;
>  
> +	list_for_each_entry(tx, &conn->ibc_active_txs, tx_list) {
>  		LASSERT(!tx->tx_queued);
>  		LASSERT(tx->tx_sending || tx->tx_waiting);
>  
> @@ -3142,11 +3140,8 @@ static int
>  kiblnd_check_txs_locked(struct kib_conn *conn, struct list_head *txs)
>  {
>  	struct kib_tx *tx;
> -	struct list_head *ttmp;
> -
> -	list_for_each(ttmp, txs) {
> -		tx = list_entry(ttmp, struct kib_tx, tx_list);
>  
> +	list_for_each_entry(tx, txs, tx_list) {
>  		if (txs != &conn->ibc_active_txs) {
>  			LASSERT(tx->tx_queued);
>  		} else {
> @@ -3182,10 +3177,8 @@ kiblnd_check_conns(int idx)
>  	LIST_HEAD(closes);
>  	LIST_HEAD(checksends);
>  	struct list_head *peers = &kiblnd_data.kib_peers[idx];
> -	struct list_head *ptmp;
>  	struct kib_peer *peer;
>  	struct kib_conn *conn;
> -	struct list_head *ctmp;
>  	unsigned long flags;
>  
>  	/*
> @@ -3195,15 +3188,12 @@ kiblnd_check_conns(int idx)
>  	 */
>  	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
>  
> -	list_for_each(ptmp, peers) {
> -		peer = list_entry(ptmp, struct kib_peer, ibp_list);
> +	list_for_each_entry(peer, peers, ibp_list) {
>  
> -		list_for_each(ctmp, &peer->ibp_conns) {
> +		list_for_each_entry(conn, &peer->ibp_conns, ibc_list) {
>  			int timedout;
>  			int sendnoop;
>  
> -			conn = list_entry(ctmp, struct kib_conn, ibc_list);
> -
>  			LASSERT(conn->ibc_state == IBLND_CONN_ESTABLISHED);
>  
>  			spin_lock(&conn->ibc_lock);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index a48b1b9a850b..491d2ed5b673 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -250,9 +250,7 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
>  		       int *port, int *conn_count, int *share_count)
>  {
>  	struct ksock_peer *peer;
> -	struct list_head *ptmp;
>  	struct ksock_route *route;
> -	struct list_head *rtmp;
>  	int i;
>  	int j;
>  	int rc = -ENOENT;
> @@ -260,8 +258,7 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
>  	read_lock(&ksocknal_data.ksnd_global_lock);
>  
>  	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
> -		list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
> -			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
> +		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
>  
>  			if (peer->ksnp_ni != ni)
>  				continue;
> @@ -295,13 +292,11 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
>  				goto out;
>  			}
>  
> -			list_for_each(rtmp, &peer->ksnp_routes) {
> +			list_for_each_entry(route, &peer->ksnp_routes,
> +					    ksnr_list) {
>  				if (index-- > 0)
>  					continue;
>  
> -				route = list_entry(rtmp, struct ksock_route,
> -						   ksnr_list);
> -
>  				*id = peer->ksnp_id;
>  				*myip = route->ksnr_myipaddr;
>  				*peer_ip = route->ksnr_ipaddr;
> @@ -368,7 +363,6 @@ ksocknal_associate_route_conn_locked(struct ksock_route *route,
>  static void
>  ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
>  {
> -	struct list_head *tmp;
>  	struct ksock_conn *conn;
>  	struct ksock_route *route2;
>  
> @@ -379,9 +373,7 @@ ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
>  	LASSERT(!route->ksnr_connected);
>  
>  	/* LASSERT(unique) */
> -	list_for_each(tmp, &peer->ksnp_routes) {
> -		route2 = list_entry(tmp, struct ksock_route, ksnr_list);
> -
> +	list_for_each_entry(route2, &peer->ksnp_routes, ksnr_list) {
>  		if (route2->ksnr_ipaddr == route->ksnr_ipaddr) {
>  			CERROR("Duplicate route %s %pI4h\n",
>  			       libcfs_id2str(peer->ksnp_id),
> @@ -395,9 +387,7 @@ ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
>  	/* peer's routelist takes over my ref on 'route' */
>  	list_add_tail(&route->ksnr_list, &peer->ksnp_routes);
>  
> -	list_for_each(tmp, &peer->ksnp_conns) {
> -		conn = list_entry(tmp, struct ksock_conn, ksnc_list);
> -
> +	list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
>  		if (conn->ksnc_ipaddr != route->ksnr_ipaddr)
>  			continue;
>  
> @@ -624,28 +614,22 @@ static struct ksock_conn *
>  ksocknal_get_conn_by_idx(struct lnet_ni *ni, int index)
>  {
>  	struct ksock_peer *peer;
> -	struct list_head *ptmp;
>  	struct ksock_conn *conn;
> -	struct list_head *ctmp;
>  	int i;
>  
>  	read_lock(&ksocknal_data.ksnd_global_lock);
>  
>  	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
> -		list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
> -			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
> -
> +		list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i], ksnp_list) {
>  			LASSERT(!peer->ksnp_closing);
>  
>  			if (peer->ksnp_ni != ni)
>  				continue;
>  
> -			list_for_each(ctmp, &peer->ksnp_conns) {
> +			list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
>  				if (index-- > 0)
>  					continue;
>  
> -				conn = list_entry(ctmp, struct ksock_conn,
> -						  ksnc_list);
>  				ksocknal_conn_addref(conn);
>  				read_unlock(&ksocknal_data.ksnd_global_lock);
>  				return conn;
> @@ -1025,7 +1009,6 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
>  	LIST_HEAD(zombies);
>  	struct lnet_process_id peerid;
> -	struct list_head *tmp;
>  	__u64 incarnation;
>  	struct ksock_conn *conn;
>  	struct ksock_conn *conn2;
> @@ -1226,8 +1209,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	 * loopback connection
>  	 */
>  	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
> -		list_for_each(tmp, &peer->ksnp_conns) {
> -			conn2 = list_entry(tmp, struct ksock_conn, ksnc_list);
> +		list_for_each_entry(conn2, &peer->ksnp_conns, ksnc_list) {
>  
>  			if (conn2->ksnc_ipaddr != conn->ksnc_ipaddr ||
>  			    conn2->ksnc_myipaddr != conn->ksnc_myipaddr ||
> @@ -1266,9 +1248,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	 * by routes in my peer to match my own route entries so I don't
>  	 * continually create duplicate routes.
>  	 */
> -	list_for_each(tmp, &peer->ksnp_routes) {
> -		route = list_entry(tmp, struct ksock_route, ksnr_list);
> -
> +	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
>  		if (route->ksnr_ipaddr != conn->ksnc_ipaddr)
>  			continue;
>  
> @@ -1980,9 +1960,7 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
>  	int rc;
>  	int i;
>  	int j;
> -	struct list_head *ptmp;
>  	struct ksock_peer *peer;
> -	struct list_head *rtmp;
>  	struct ksock_route *route;
>  
>  	if (!ipaddress || !netmask)
> @@ -2005,18 +1983,15 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
>  		iface->ksni_npeers = 0;
>  
>  		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
> -			list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
> -				peer = list_entry(ptmp, struct ksock_peer,
> -						  ksnp_list);
> +			list_for_each_entry(peer, &ksocknal_data.ksnd_peers[i],
> +					    ksnp_list) {
>  
>  				for (j = 0; j < peer->ksnp_n_passive_ips; j++)
>  					if (peer->ksnp_passive_ips[j] == ipaddress)
>  						iface->ksni_npeers++;
>  
> -				list_for_each(rtmp, &peer->ksnp_routes) {
> -					route = list_entry(rtmp, struct ksock_route,
> -							   ksnr_list);
> -
> +				list_for_each_entry(route, &peer->ksnp_routes,
> +						    ksnr_list) {
>  					if (route->ksnr_myipaddr == ipaddress)
>  						iface->ksni_nroutes++;
>  				}
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index d531847305e4..a5c0e8a9bc40 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -561,18 +561,16 @@ struct ksock_conn *
>  ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
>  			  int nonblk)
>  {
> -	struct list_head *tmp;
> +	struct ksock_conn *c;
>  	struct ksock_conn *conn;
>  	struct ksock_conn *typed = NULL;
>  	struct ksock_conn *fallback = NULL;
>  	int tnob = 0;
>  	int fnob = 0;
>  
> -	list_for_each(tmp, &peer->ksnp_conns) {
> -		struct ksock_conn *c;
> +	list_for_each_entry(c, &peer->ksnp_conns, ksnc_list) {
>  		int nob, rc;
>  
> -		c = list_entry(tmp, struct ksock_conn, ksnc_list);
>  		nob = atomic_read(&c->ksnc_tx_nob) +
>  		      c->ksnc_sock->sk->sk_wmem_queued;
>  
> @@ -729,12 +727,9 @@ struct ksock_route *
>  ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
>  {
>  	time64_t now = ktime_get_seconds();
> -	struct list_head *tmp;
>  	struct ksock_route *route;
>  
> -	list_for_each(tmp, &peer->ksnp_routes) {
> -		route = list_entry(tmp, struct ksock_route, ksnr_list);
> -
> +	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
>  		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
>  
>  		/* connections being established */
> @@ -765,11 +760,9 @@ ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
>  struct ksock_route *
>  ksocknal_find_connecting_route_locked(struct ksock_peer *peer)
>  {
> -	struct list_head *tmp;
>  	struct ksock_route *route;
>  
> -	list_for_each(tmp, &peer->ksnp_routes) {
> -		route = list_entry(tmp, struct ksock_route, ksnr_list);
> +	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
>  
>  		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
>  
> @@ -2180,13 +2173,10 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
>  {
>  	/* We're called with a shared lock on ksnd_global_lock */
>  	struct ksock_conn *conn;
> -	struct list_head *ctmp;
>  
> -	list_for_each(ctmp, &peer->ksnp_conns) {
> +	list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
>  		int error;
>  
> -		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
> -
>  		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
>  		LASSERT(!conn->ksnc_closing);
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 51a81075f8d5..14b797802a85 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -269,12 +269,9 @@ static struct lnet_lnd *
>  lnet_find_lnd_by_type(__u32 type)
>  {
>  	struct lnet_lnd *lnd;
> -	struct list_head *tmp;
>  
>  	/* holding lnd mutex */
> -	list_for_each(tmp, &the_lnet.ln_lnds) {
> -		lnd = list_entry(tmp, struct lnet_lnd, lnd_list);
> -
> +	list_for_each_entry(lnd, &the_lnet.ln_lnds, lnd_list) {
>  		if (lnd->lnd_type == type)
>  			return lnd;
>  	}
> @@ -653,14 +650,11 @@ lnet_unprepare(void)
>  struct lnet_ni  *
>  lnet_net2ni_locked(__u32 net, int cpt)
>  {
> -	struct list_head *tmp;
>  	struct lnet_ni *ni;
>  
>  	LASSERT(cpt != LNET_LOCK_EX);
>  
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> -
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (LNET_NIDNET(ni->ni_nid) == net) {
>  			lnet_ni_addref_locked(ni, cpt);
>  			return ni;
> @@ -767,13 +761,10 @@ struct lnet_ni  *
>  lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
>  {
>  	struct lnet_ni *ni;
> -	struct list_head *tmp;
>  
>  	LASSERT(cpt != LNET_LOCK_EX);
>  
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> -
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (ni->ni_nid == nid) {
>  			lnet_ni_addref_locked(ni, cpt);
>  			return ni;
> @@ -803,14 +794,11 @@ lnet_count_acceptor_nis(void)
>  {
>  	/* Return the # of NIs that need the acceptor. */
>  	int count = 0;
> -	struct list_head *tmp;
>  	struct lnet_ni *ni;
>  	int cpt;
>  
>  	cpt = lnet_net_lock_current();
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> -
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (ni->ni_lnd->lnd_accept)
>  			count++;
>  	}
> @@ -1731,18 +1719,16 @@ static int
>  lnet_get_net_config(struct lnet_ioctl_config_data *config)
>  {
>  	struct lnet_ni *ni;
> -	struct list_head *tmp;
>  	int idx = config->cfg_count;
>  	int cpt, i = 0;
>  	int rc = -ENOENT;
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (i++ != idx)
>  			continue;
>  
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
>  		lnet_ni_lock(ni);
>  		lnet_fill_ni_info(ni, config);
>  		lnet_ni_unlock(ni);
> @@ -2119,7 +2105,6 @@ int
>  LNetGetId(unsigned int index, struct lnet_process_id *id)
>  {
>  	struct lnet_ni *ni;
> -	struct list_head *tmp;
>  	int cpt;
>  	int rc = -ENOENT;
>  
> @@ -2127,12 +2112,10 @@ LNetGetId(unsigned int index, struct lnet_process_id *id)
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (index--)
>  			continue;
>  
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> -
>  		id->nid = ni->ni_nid;
>  		id->pid = the_lnet.ln_pid;
>  		rc = 0;
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 26b799e66e53..96336ecdacaf 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -81,12 +81,9 @@ lnet_issep(char c)
>  int
>  lnet_net_unique(__u32 net, struct list_head *nilist)
>  {
> -	struct list_head *tmp;
>  	struct lnet_ni *ni;
>  
> -	list_for_each(tmp, nilist) {
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> -
> +	list_for_each_entry(ni, nilist, ni_list) {
>  		if (LNET_NIDNET(ni->ni_nid) == net)
>  			return 0;
>  	}
> @@ -942,7 +939,6 @@ lnet_splitnets(char *source, struct list_head *nets)
>  	int len;
>  	struct lnet_text_buf *tb;
>  	struct lnet_text_buf *tb2;
> -	struct list_head *t;
>  	char *sep;
>  	char *bracket;
>  	__u32 net;
> @@ -983,9 +979,7 @@ lnet_splitnets(char *source, struct list_head *nets)
>  			return -EINVAL;
>  		}
>  
> -		list_for_each(t, nets) {
> -			tb2 = list_entry(t, struct lnet_text_buf, ltb_list);
> -
> +		list_for_each_entry(tb2, nets, ltb_list) {
>  			if (tb2 == tb)
>  				continue;
>  
> @@ -1074,14 +1068,11 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
>  			break;
>  
>  		dup = 0;
> -		list_for_each(t, &current_nets) {
> -			tb = list_entry(t, struct lnet_text_buf, ltb_list);
> +		list_for_each_entry(tb, &current_nets, ltb_list) {
>  			net1 = lnet_netspec2net(tb->ltb_text);
>  			LASSERT(net1 != LNET_NIDNET(LNET_NID_ANY));
>  
> -			list_for_each(t2, &matched_nets) {
> -				tb2 = list_entry(t2, struct lnet_text_buf,
> -						 ltb_list);
> +			list_for_each_entry(tb2, &matched_nets, ltb_list) {
>  				net2 = lnet_netspec2net(tb2->ltb_text);
>  				LASSERT(net2 != LNET_NIDNET(LNET_NID_ANY));
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 19cab374b6bc..edcafac055ed 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -2288,7 +2288,6 @@ EXPORT_SYMBOL(LNetGet);
>  int
>  LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  {
> -	struct list_head *e;
>  	struct lnet_ni *ni;
>  	struct lnet_remotenet *rnet;
>  	__u32 dstnet = LNET_NIDNET(dstnid);
> @@ -2307,9 +2306,7 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each(e, &the_lnet.ln_nis) {
> -		ni = list_entry(e, struct lnet_ni, ni_list);
> -
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		if (ni->ni_nid == dstnid) {
>  			if (srcnidp)
>  				*srcnidp = dstnid;
> @@ -2346,9 +2343,7 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  	}
>  
>  	rn_list = lnet_net2rnethash(dstnet);
> -	list_for_each(e, rn_list) {
> -		rnet = list_entry(e, struct lnet_remotenet, lrn_list);
> -
> +	list_for_each_entry(rnet, rn_list, lrn_list) {
>  		if (rnet->lrn_net == dstnet) {
>  			struct lnet_route *route;
>  			struct lnet_route *shortest = NULL;
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 965087b7359c..53373372b526 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -292,10 +292,10 @@ int
>  lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  	       unsigned int priority)
>  {
> -	struct list_head *e;
>  	struct lnet_remotenet *rnet;
>  	struct lnet_remotenet *rnet2;
>  	struct lnet_route *route;
> +	struct lnet_route *route2;
>  	struct lnet_ni *ni;
>  	int add_route;
>  	int rc;
> @@ -359,10 +359,8 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  
>  	/* Search for a duplicate route (it's a NOOP if it is) */
>  	add_route = 1;
> -	list_for_each(e, &rnet2->lrn_routes) {
> -		struct lnet_route *route2;
> +	list_for_each_entry(route2, &rnet2->lrn_routes, lr_list) {
>  
> -		route2 = list_entry(e, struct lnet_route, lr_list);
>  		if (route2->lr_gateway == route->lr_gateway) {
>  			add_route = 0;
>  			break;
> @@ -411,8 +409,6 @@ lnet_check_routes(void)
>  	struct lnet_remotenet *rnet;
>  	struct lnet_route *route;
>  	struct lnet_route *route2;
> -	struct list_head *e1;
> -	struct list_head *e2;
>  	int cpt;
>  	struct list_head *rn_list;
>  	int i;
> @@ -421,17 +417,13 @@ lnet_check_routes(void)
>  
>  	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
>  		rn_list = &the_lnet.ln_remote_nets_hash[i];
> -		list_for_each(e1, rn_list) {
> -			rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
> -
> +		list_for_each_entry(rnet, rn_list, lrn_list) {
>  			route2 = NULL;
> -			list_for_each(e2, &rnet->lrn_routes) {
> +			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
>  				lnet_nid_t nid1;
>  				lnet_nid_t nid2;
>  				int net;
>  
> -				route = list_entry(e2, struct lnet_route, lr_list);
> -
>  				if (!route2) {
>  					route2 = route;
>  					continue;
> @@ -466,8 +458,6 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
>  	struct lnet_peer *gateway;
>  	struct lnet_remotenet *rnet;
>  	struct lnet_route *route;
> -	struct list_head *e1;
> -	struct list_head *e2;
>  	int rc = -ENOENT;
>  	struct list_head *rn_list;
>  	int idx = 0;
> @@ -486,16 +476,12 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
>  		rn_list = lnet_net2rnethash(net);
>  
>   again:
> -	list_for_each(e1, rn_list) {
> -		rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
> -
> +	list_for_each_entry(rnet, rn_list, lrn_list) {
>  		if (!(net == LNET_NIDNET(LNET_NID_ANY) ||
>  		      net == rnet->lrn_net))
>  			continue;
>  
> -		list_for_each(e2, &rnet->lrn_routes) {
> -			route = list_entry(e2, struct lnet_route, lr_list);
> -
> +		list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
>  			gateway = route->lr_gateway;
>  			if (!(gw_nid == LNET_NID_ANY ||
>  			      gw_nid == gateway->lp_nid))
> @@ -576,8 +562,6 @@ int
>  lnet_get_route(int idx, __u32 *net, __u32 *hops,
>  	       lnet_nid_t *gateway, __u32 *alive, __u32 *priority)
>  {
> -	struct list_head *e1;
> -	struct list_head *e2;
>  	struct lnet_remotenet *rnet;
>  	struct lnet_route *route;
>  	int cpt;
> @@ -588,13 +572,8 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
>  
>  	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
>  		rn_list = &the_lnet.ln_remote_nets_hash[i];
> -		list_for_each(e1, rn_list) {
> -			rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
> -
> -			list_for_each(e2, &rnet->lrn_routes) {
> -				route = list_entry(e2, struct lnet_route,
> -						   lr_list);
> -
> +		list_for_each_entry(rnet, rn_list, lrn_list) {
> +			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
>  				if (!idx--) {
>  					*net      = rnet->lrn_net;
>  					*hops     = route->lr_hops;
> @@ -784,7 +763,6 @@ static void
>  lnet_wait_known_routerstate(void)
>  {
>  	struct lnet_peer *rtr;
> -	struct list_head *entry;
>  	int all_known;
>  
>  	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
> @@ -793,9 +771,7 @@ lnet_wait_known_routerstate(void)
>  		int cpt = lnet_net_lock_current();
>  
>  		all_known = 1;
> -		list_for_each(entry, &the_lnet.ln_routers) {
> -			rtr = list_entry(entry, struct lnet_peer, lp_rtr_list);
> -
> +		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
>  			if (!rtr->lp_alive_count) {
>  				all_known = 0;
>  				break;
> @@ -1223,7 +1199,6 @@ static int
>  lnet_router_checker(void *arg)
>  {
>  	struct lnet_peer *rtr;
> -	struct list_head *entry;
>  
>  	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
>  		__u64 version;
> @@ -1234,9 +1209,7 @@ lnet_router_checker(void *arg)
>  rescan:
>  		version = the_lnet.ln_routers_version;
>  
> -		list_for_each(entry, &the_lnet.ln_routers) {
> -			rtr = list_entry(entry, struct lnet_peer, lp_rtr_list);
> -
> +		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
>  			cpt2 = lnet_cpt_of_nid_locked(rtr->lp_nid);
>  			if (cpt != cpt2) {
>  				lnet_net_unlock(cpt);
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index 3afde0141db5..e73b956d15e4 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -1327,7 +1327,6 @@ lstcon_rpc_cleanup_wait(void)
>  {
>  	struct lstcon_rpc_trans *trans;
>  	struct lstcon_rpc *crpc;
> -	struct list_head *pacer;
>  	struct list_head zlist;
>  
>  	/* Called with hold of global mutex */
> @@ -1335,10 +1334,8 @@ lstcon_rpc_cleanup_wait(void)
>  	LASSERT(console_session.ses_shutdown);
>  
>  	while (!list_empty(&console_session.ses_trans_list)) {
> -		list_for_each(pacer, &console_session.ses_trans_list) {
> -			trans = list_entry(pacer, struct lstcon_rpc_trans,
> -					   tas_link);
> -
> +		list_for_each_entry(trans, &console_session.ses_trans_list,
> +				    tas_link) {
>  			CDEBUG(D_NET, "Session closed, wakeup transaction %s\n",
>  			       lstcon_rpc_trans_name(trans->tas_opc));
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index 234f383ce6d9..8454b4470b8c 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -84,12 +84,10 @@ static void obd_device_free(struct obd_device *obd)
>  
>  static struct obd_type *class_search_type(const char *name)
>  {
> -	struct list_head *tmp;
>  	struct obd_type *type;
>  
>  	spin_lock(&obd_types_lock);
> -	list_for_each(tmp, &obd_types) {
> -		type = list_entry(tmp, struct obd_type, typ_chain);
> +	list_for_each_entry(type, &obd_types, typ_chain) {
>  		if (strcmp(type->typ_name, name) == 0) {
>  			spin_unlock(&obd_types_lock);
>  			return type;
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index 484b8d6db6ef..3022706c6985 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -950,12 +950,10 @@ static int cl_echo_cancel0(struct lu_env *env, struct echo_device *ed,
>  {
>  	struct echo_client_obd *ec = ed->ed_ec;
>  	struct echo_lock       *ecl = NULL;
> -	struct list_head	     *el;
>  	int found = 0, still_used = 0;
>  
>  	spin_lock(&ec->ec_lock);
> -	list_for_each(el, &ec->ec_locks) {
> -		ecl = list_entry(el, struct echo_lock, el_chain);
> +	list_for_each_entry(ecl, &ec->ec_locks, el_chain) {
>  		CDEBUG(D_INFO, "ecl: %p, cookie: %#llx\n", ecl, ecl->el_cookie);
>  		found = (ecl->el_cookie == cookie);
>  		if (found) {
> 
> 
> 
