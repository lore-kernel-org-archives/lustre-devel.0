From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:49:48 +0000
Subject: [lustre-devel] [PATCH 32/34] lnet: lnet_dyn_del_ni: fix
 ping_info count
In-Reply-To: <153628137252.8267.5413803631901452139.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137252.8267.5413803631901452139.stgit@noble>
Message-ID: <065B4E44-A590-4DFB-99D3-1E80DA91FE78@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    - use correct interface count for lnet_ping_info_setup().
    - also rename 'net' to 'net_id' so the name 'net' is free
      to identify the lnet_net.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |   35 +++++++++++++++++------------
     1 file changed, 20 insertions(+), 15 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 2ce0a7212dc2..ff5149da2d79 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -2109,40 +2109,45 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     }
     
     int
    -lnet_dyn_del_ni(__u32 net)
    +lnet_dyn_del_ni(__u32 net_id)
     {
    -	struct lnet_ni *ni;
    +	struct lnet_net *net;
     	struct lnet_ping_info *pinfo;
     	struct lnet_handle_md md_handle;
     	int rc;
    +	int		  net_ni_count;
     
     	/* don't allow userspace to shutdown the LOLND */
    -	if (LNET_NETTYP(net) == LOLND)
    +	if (LNET_NETTYP(net_id) == LOLND)
     		return -EINVAL;
     
     	mutex_lock(&the_lnet.ln_api_mutex);
    +
    +	lnet_net_lock(0);
    +
    +	net = lnet_get_net_locked(net_id);
    +	if (net == NULL) {
    +		rc = -EINVAL;
    +		goto out;
    +	}
    +
    +	net_ni_count = lnet_get_net_ni_count_locked(net);
    +
    +	lnet_net_unlock(0);
    +
     	/* create and link a new ping info, before removing the old one */
     	rc = lnet_ping_info_setup(&pinfo, &md_handle,
    -				  lnet_get_ni_count() - 1, false);
    +				  lnet_get_ni_count() - net_ni_count, false);
     	if (rc)
     		goto out;
     
    -	ni = lnet_net2ni(net);
    -	if (!ni) {
    -		rc = -EINVAL;
    -		goto failed;
    -	}
    -
    -	lnet_shutdown_lndni(ni);
    +	lnet_shutdown_lndnet(net);
     
     	if (!lnet_count_acceptor_nets())
     		lnet_acceptor_stop();
     
     	lnet_ping_target_update(pinfo, md_handle);
    -	goto out;
    -failed:
    -	lnet_ping_md_unlink(pinfo, &md_handle);
    -	lnet_ping_info_free(pinfo);
    +
     out:
     	mutex_unlock(&the_lnet.ln_api_mutex);
     
    
    
    
