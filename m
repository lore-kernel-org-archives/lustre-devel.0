From: NeilBrown <neilb@suse.com>
Date: Mon, 20 Aug 2018 14:10:12 +1000
Subject: [lustre-devel] [PATCH v2 04/38] lustre: llite: remove ll_sb
In-Reply-To: <1534732789-22934-1-git-send-email-jsimmons@infradead.org>
References: <1534732789-22934-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87woslptjv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Aug 19 2018, James Simmons wrote:

> The only user of ll_sb in struct ll_sb_info is used to query the
> name locate in the file_system_type. We can get that information
> from using the super block located in struct path instead. This
> enables us to use struct ll_sb_info directly for every sysfs or
> debugfs entry.

The above no longer matches the below (and I do like the change in the
below).
So I've changed the above to:

--------
The only user of ll_sb in struct ll_sb_info is used to query the
name locate in the file_system_type.  That information is
now constant (always "lustre") so are can use a constant
instead.
This enables us to use struct ll_sb_info directly for every sysfs or
debugfs entry.
---------

Thanks,
NeilBrown


>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
> Reviewed-on: https://review.whamcloud.com/24031
> WC-bug-id: https://jira.whamcloud.com/browse/LU-10824
> Reviewed-on: https://review.whamcloud.com/33025
> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> Changelog)
> v1) initial patch
> v2) Remove use of ll_mnt in fstype sysfs file
>
>  drivers/staging/lustre/lustre/llite/llite_internal.h | 1 -
>  drivers/staging/lustre/lustre/llite/llite_lib.c      | 6 ++----
>  drivers/staging/lustre/lustre/llite/lproc_llite.c    | 5 +----
>  3 files changed, 3 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 2719bc53..92dc05d 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -524,7 +524,6 @@ struct ll_sb_info {
>  
>  	__kernel_fsid_t		  ll_fsid;
>  	struct kobject		 ll_kobj; /* sysfs object */
> -	struct super_block	*ll_sb; /* struct super_block (for sysfs code)*/
>  	struct completion	 ll_kobj_unregister;
>  };
>  
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index d16f5d1..d352287 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -62,7 +62,7 @@
>  #define log2(n) ffz(~(n))
>  #endif
>  
> -static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
> +static struct ll_sb_info *ll_init_sbi(void)
>  {
>  	struct ll_sb_info *sbi = NULL;
>  	unsigned long pages;
> @@ -129,8 +129,6 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
>  	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
>  	init_rwsem(&sbi->ll_squash.rsi_sem);
>  
> -	sbi->ll_sb = sb;
> -
>  	return sbi;
>  }
>  
> @@ -912,7 +910,7 @@ int ll_fill_super(struct super_block *sb)
>  	try_module_get(THIS_MODULE);
>  
>  	/* client additional sb info */
> -	sbi = ll_init_sbi(sb);
> +	sbi = ll_init_sbi();
>  	lsi->lsi_llsbi = sbi;
>  	if (!sbi) {
>  		module_put(THIS_MODULE);
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index a9ad328..858d276 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -212,10 +212,7 @@ static ssize_t client_type_show(struct kobject *kobj, struct attribute *attr,
>  static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
>  			   char *buf)
>  {
> -	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> -					      ll_kobj);
> -
> -	return sprintf(buf, "%s\n", sbi->ll_sb->s_type->name);
> +	return sprintf(buf, "lustre\n");
>  }
>  LUSTRE_RO_ATTR(fstype);
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180820/3cdd952c/attachment-0001.sig>
