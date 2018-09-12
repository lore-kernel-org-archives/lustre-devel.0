From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:47:29 +0000
Subject: [lustre-devel] [PATCH 30/34] lnet: fix typo
In-Reply-To: <153628137245.8267.15918400233109764157.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137245.8267.15918400233109764157.stgit@noble>
Message-ID: <0AB7DCED-0F17-4FF1-9E71-C70713583B4B@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    to -> too
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |    2 +-
     1 file changed, 1 insertion(+), 1 deletion(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index f4efb48c4cf3..cf0ffb8ac84b 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1868,7 +1868,7 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
     	if (config->cfg_hdr.ioc_len > min_size)
     		tunable_size = config->cfg_hdr.ioc_len - min_size;
     
    -	/* Don't copy to much data to user space */
    +	/* Don't copy too much data to user space */
     	min_size = min(tunable_size, sizeof(ni->ni_lnd_tunables));
     	lnd_cfg = (struct lnet_ioctl_config_lnd_tunables *)net_config->cfg_bulk;
     
    
    
    
