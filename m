From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 03:40:46 +0000
Subject: [lustre-devel] [PATCH 14/34] lnet: rename lnet_find_net_locked
 to lnet_find_rnet_locked
In-Reply-To: <153628137179.8267.355535015389180735.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137179.8267.355535015389180735.stgit@noble>
Message-ID: <1B50CEB8-1F64-4C77-8BA0-B37377C5D9B1@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:53 PM, "NeilBrown" <neilb@suse.com> wrote:

    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
     drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
     drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +-
     drivers/staging/lustre/lnet/lnet/router.c          |    4 ++--
     4 files changed, 5 insertions(+), 5 deletions(-)
    
    diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    index e32dbb854d80..faa3f19dd844 100644
    --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    @@ -430,7 +430,7 @@ int lnet_rtrpools_adjust(int tiny, int small, int large);
     int lnet_rtrpools_enable(void);
     void lnet_rtrpools_disable(void);
     void lnet_rtrpools_free(int keep_pools);
    -struct lnet_remotenet *lnet_find_net_locked(__u32 net);
    +struct lnet_remotenet *lnet_find_rnet_locked(__u32 net);
     int lnet_dyn_add_ni(lnet_pid_t requested_pid,
     		    struct lnet_ioctl_config_data *conf);
     int lnet_dyn_del_ni(__u32 net);
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 09ea7e506128..c3c568e63342 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1909,7 +1909,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     	net = list_entry(net_head.next, struct lnet_net, net_list);
     
     	lnet_net_lock(LNET_LOCK_EX);
    -	rnet = lnet_find_net_locked(net->net_id);
    +	rnet = lnet_find_rnet_locked(net->net_id);
     	lnet_net_unlock(LNET_LOCK_EX);
     	/*
     	 * make sure that the net added doesn't invalidate the current
    diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
    index 02cd1a5a466f..00a89221c9b3 100644
    --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
    +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
    @@ -1022,7 +1022,7 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
     	 * If @rtr_nid is not LNET_NID_ANY, return the gateway with
     	 * rtr_nid nid, otherwise find the best gateway I can use
     	 */
    -	rnet = lnet_find_net_locked(LNET_NIDNET(target));
    +	rnet = lnet_find_rnet_locked(LNET_NIDNET(target));
     	if (!rnet)
     		return NULL;
     
    diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
    index 5493d13de6d9..1fce991fcb0e 100644
    --- a/drivers/staging/lustre/lnet/lnet/router.c
    +++ b/drivers/staging/lustre/lnet/lnet/router.c
    @@ -220,7 +220,7 @@ lnet_rtr_decref_locked(struct lnet_peer *lp)
     }
     
     struct lnet_remotenet *
    -lnet_find_net_locked(__u32 net)
    +lnet_find_rnet_locked(__u32 net)
     {
     	struct lnet_remotenet *rnet;
     	struct list_head *rn_list;
    @@ -347,7 +347,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
     
     	LASSERT(!the_lnet.ln_shutdown);
     
    -	rnet2 = lnet_find_net_locked(net);
    +	rnet2 = lnet_find_rnet_locked(net);
     	if (!rnet2) {
     		/* new network */
     		list_add_tail(&rnet->lrn_list, lnet_net2rnethash(net));
    
    
    
