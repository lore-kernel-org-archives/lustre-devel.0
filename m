From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 01:46:42 +0000 (GMT)
Subject: [lustre-devel] [PATCH 6/9] lustre: obdclass: health_check to
 report unhealthy upon LBUG
In-Reply-To: <154295732803.2850.16198081335816276527.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732803.2850.16198081335816276527.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260146120.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Bruno Faccini <bruno.faccini@intel.com>
> 
> When a LBUG has occurred, without panic_on_lbug being set, health_check
> /proc file must return an unhealthy state.

I pushed this one to Greg which was disliked since it breaks the one item 
per sysfs rule. See 

https://lore.kernel.org/patchwork/patch/755571

I did start a proper port to sysfs at 
https://review.whamcloud.com/#/c/25631

but it needs to be updated. I do like Andreas idea of a sysfs and debugfs
file since lctl get_param will return the results from both together.
We could land it as is and update the sysfs handling at a latter date 
(shouldn't be too far down the road). Here is my review in case you want
to land it.

Reviewed-by: James Simmons <jsimmons@infradead.org>

> Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7486
> Reviewed-on: http://review.whamcloud.com/17981
> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> index 6669c235dd51..5fd30a8e2b44 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> @@ -173,8 +173,10 @@ health_check_show(struct kobject *kobj, struct attribute *attr, char *buf)
>  	int i;
>  	size_t len = 0;
>  
> -	if (libcfs_catastrophe)
> +	if (libcfs_catastrophe) {
>  		return sprintf(buf, "LBUG\n");
> +		healthy = false;
> +	}
>  
>  	read_lock(&obd_dev_lock);
>  	for (i = 0; i < class_devno_max(); i++) {
> 
> 
> 
