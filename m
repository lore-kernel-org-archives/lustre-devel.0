From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:29:15 +0000
Subject: [lustre-devel] [PATCH 24/34] lnet: don't take lock over
 lnet_net_unique()
In-Reply-To: <153628137220.8267.9479780300443400770.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137220.8267.9479780300443400770.stgit@noble>
Message-ID: <EE958BB1-CC97-4227-94EF-D425DF40FAA3@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:54 PM, "NeilBrown" <neilb@suse.com> wrote:

    holding ln_api_mutex is enough to keep the list
    stable.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |    2 --
     1 file changed, 2 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 42e775e2a669..2b5c25a1dc7c 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1372,9 +1372,7 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     	LASSERT(libcfs_isknown_lnd(lnd_type));
     
     	/* Make sure this new NI is unique. */
    -	lnet_net_lock(LNET_LOCK_EX);
     	rc = lnet_net_unique(net->net_id, &the_lnet.ln_nets);
    -	lnet_net_unlock(LNET_LOCK_EX);
     	if (!rc) {
     		if (lnd_type == LOLND) {
     			lnet_net_free(net);
    
    
    
