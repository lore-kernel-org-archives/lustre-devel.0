From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 01:58:17 +0000 (GMT)
Subject: [lustre-devel] [PATCH 11/14] staging/lustre/ptlrpc: Correctly
 calculate hrp->hrp_nthrs
In-Reply-To: <1478136304-867780-12-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
	<1478136304-867780-12-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1611070158050.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

On Wed, 2 Nov 2016, Oleg Drokin wrote:

> From: Amir Shehata <amir.shehata@intel.com>
> 
> cpu_pattern can specify exactly 1 cpu in a partition:
> "0[0]". That means CPT0 will have CPU 0. CPU 0 can have
> hyperthreading enabled. This combination would result in
> 
> weight = cfs_cpu_ht_nsiblings(0);
> hrp->hrp_nthrs = cfs_cpt_weight(ptlrpc_hr.hr_cpt_table, i);
> hrp->hrp_nthrs /= weight;
> 
> evaluating to 0. Where
> cfs_cpt_weight(ptlrpc_hr.hr_cpt_table, i) == 1
> weight == 2
> 
> Therefore, if hrp_nthrs becomes zero, just set it to 1.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Reviewed-on: http://review.whamcloud.com/19106
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8492
> Reviewed-by: Liang Zhen <liang.zhen@intel.com>
> Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/service.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index 72f3930..fc754e7 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -2541,8 +2541,9 @@ int ptlrpc_hr_init(void)
>  
>  		hrp->hrp_nthrs = cfs_cpt_weight(ptlrpc_hr.hr_cpt_table, i);
>  		hrp->hrp_nthrs /= weight;
> +		if (hrp->hrp_nthrs == 0)
> +			hrp->hrp_nthrs = 1;
>  
> -		LASSERT(hrp->hrp_nthrs > 0);
>  		hrp->hrp_thrs =
>  			kzalloc_node(hrp->hrp_nthrs * sizeof(*hrt), GFP_NOFS,
>  				     cfs_cpt_spread_node(ptlrpc_hr.hr_cpt_table,
> -- 
> 2.7.4
> 
> 
