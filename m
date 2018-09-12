From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:34:14 +0000
Subject: [lustre-devel] [PATCH 26/34] lnet: only valid lnd_type when
 net_id is unique.
In-Reply-To: <153628137230.8267.13002746471298616108.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137230.8267.13002746471298616108.stgit@noble>
Message-ID: <74A69DE4-7A94-4BDC-96E9-9F45C2108D61@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    If it isn't unique, we won't add it, so no need to validate.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |    7 ++++---
     1 file changed, 4 insertions(+), 3 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index ab4d093c04da..0dfd3004f735 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1366,13 +1366,14 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     	__u32			lnd_type;
     	struct lnet_lnd		*lnd;
     
    -	lnd_type = LNET_NETTYP(net->net_id);
    -
     	INIT_LIST_HEAD(&local_ni_list);
    -	LASSERT(libcfs_isknown_lnd(lnd_type));
     
     	/* Make sure this new NI is unique. */
     	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets)) {
    +		lnd_type = LNET_NETTYP(net->net_id);
    +
    +		LASSERT(libcfs_isknown_lnd(lnd_type));
    +
     		mutex_lock(&the_lnet.ln_lnd_mutex);
     		lnd = lnet_find_lnd_by_type(lnd_type);
     
    
    
    
