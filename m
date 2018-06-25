From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:27:08 +1000
Subject: [lustre-devel] [PATCH v3 24/26] staging: lustre: libcfs:
 restore debugfs table reporting for UMP
In-Reply-To: <1529875250-11531-25-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-25-git-send-email-jsimmons@infradead.org>
Message-ID: <87r2kv8xlf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> With the cleanup of the libcfs SMP handling the function
> cfs_cpt_table_print() was turned into an empty funciton.
> This function is called by a debugfs reporting function for
> debugging which now means for UMP machines it reports nothing
> which breaks previous behavior exposed to users. Restore the
> original behavior.

Which cleanup was this?
cfs_cpt_table_print seems to have been empty on UMP since at least

commit 3867ea5a4bc4d428f8d93557fb0fbc2cac2f2cdf
Author: Peng Tao <bergwolf@gmail.com>
Date:   Mon Jul 15 22:27:10 2013 +0800

    staging/lustre: fix build error when !CONFIG_SMP
    
    Three functions cfs_cpu_ht_nsiblings, cfs_cpt_cpumask and
    cfs_cpt_table_print are missing if !CONFIG_SMP.

5 years ago.

>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9856

This link seems completely irrelevant.

However, the patch looks sensible enough, so I've applied it.

Thanks,
NeilBrown


> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/include/linux/libcfs/libcfs_cpu.h  | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> index 29c5071..32776d2 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> @@ -218,6 +218,19 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  struct cfs_cpt_table;
>  #define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
>  
> +static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
> +				      char *buf, int len)
> +{
> +	int rc;
> +
> +	rc = snprintf(buf, len, "0\t: 0\n");
> +	len -= rc;
> +	if (len <= 0)
> +		return -EFBIG;
> +
> +	return rc;
> +}
> +
>  static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
>  					 char *buf, int len)
>  {
> @@ -237,12 +250,6 @@ static inline cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab,
>  	return NULL;
>  }
>  
> -static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf,
> -				      int len)
> -{
> -	return 0;
> -}
> -
>  static inline int cfs_cpt_number(struct cfs_cpt_table *cptab)
>  {
>  	return 1;
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/4454b313/attachment.sig>
