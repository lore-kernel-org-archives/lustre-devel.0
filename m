From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:41:00 +0200
Subject: [lustre-devel] [PATCH v2 11/25] staging: lustre: libcfs:
 provide debugfs files for distance handling
In-Reply-To: <1527603725-30560-12-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-12-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601084100.GG19242@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:51AM -0400, James Simmons wrote:
> From: Amir Shehata <amir.shehata@intel.com>
> 
> On systems with large number of NUMA nodes and cores it is easy
> to incorrectly configure their use with Lustre. Provide debugfs
> files which can help track down any issues.
> 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
> Reviewed-on: http://review.whamcloud.com/18916
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> Changelog:
> 
> v1) Initial patch
> v2) Rebased patch. No code changes from original patch
> 
>  drivers/staging/lustre/lnet/libcfs/module.c | 53 +++++++++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
> index b438d456..d2dfc29 100644
> --- a/drivers/staging/lustre/lnet/libcfs/module.c
> +++ b/drivers/staging/lustre/lnet/libcfs/module.c
> @@ -468,6 +468,53 @@ static int proc_cpt_table(struct ctl_table *table, int write,
>  				    __proc_cpt_table);
>  }
>  
> +static int __proc_cpt_distance(void *data, int write,
> +			       loff_t pos, void __user *buffer, int nob)
> +{
> +	char *buf = NULL;
> +	int len = 4096;
> +	int rc = 0;
> +
> +	if (write)
> +		return -EPERM;
> +
> +	LASSERT(cfs_cpt_tab);

What is this assert really checking?  Why is it needed?

thanks,

greg k-h
