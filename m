From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:02:19 +0000
Subject: [lustre-devel] [PATCH 19/34] lnet: simplify lnet_islocalnet()
In-Reply-To: <153628137199.8267.13740900509571445302.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137199.8267.13740900509571445302.stgit@noble>
Message-ID: <670A90DC-85E2-48A2-98AB-AF9AC036F371@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:54 PM, "NeilBrown" <neilb@suse.com> wrote:

    Having lnet_get_net_locked() makes this (a little) simpler.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |   14 +++++---------
     1 file changed, 5 insertions(+), 9 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 618fdf8141f0..546d5101360f 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -764,20 +764,16 @@ lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni)
     EXPORT_SYMBOL(lnet_cpt_of_nid);
     
     int
    -lnet_islocalnet(__u32 net)
    +lnet_islocalnet(__u32 net_id)
     {
    -	struct lnet_ni *ni;
    -	int cpt;
    +	struct lnet_net *net;
    +	int		cpt;
     
     	cpt = lnet_net_lock_current();
    -
    -	ni = lnet_net2ni_locked(net, cpt);
    -	if (ni)
    -		lnet_ni_decref_locked(ni, cpt);
    -
    +	net = lnet_get_net_locked(net_id);
     	lnet_net_unlock(cpt);
     
    -	return !!ni;
    +	return !!net;
     }
     
     bool
    
    
    
