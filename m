From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 14:11:52 +1000
Subject: [lustre-devel] [PATCH 18/30] lustre: llite:
 llite.stat_blocksize param for fixed st_blksize
In-Reply-To: <1537205440-6656-19-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-19-git-send-email-jsimmons@infradead.org>
Message-ID: <87worb4jqv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> From: Andrew Perepechko <c17827@cray.com>
>
> llite.stat_blocksize is added to allow configurable st_blksize
> for stat(2). The latter is treated incorrectly by some
> applications. For example, glibc pre-2.25 uses this value for
> stdio buffering which completely ruins performance with random
> reads.
>
> The patch changes the behaviour of getattr rather than inode
> initialization so that change of the setting causes immediate
> effect without the need of reclaiming existing inodes.
>
> The patch is similar to the patch from bz # 12739 by Aurelien
> Degremont.
>
> Signed-off-by: Andrew Perepechko <c17827@cray.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9413
> Reviewed-on: https://review.whamcloud.com/26869
> Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/file.c         |  2 +-
>  .../staging/lustre/lustre/llite/llite_internal.h   |  6 +++-
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  | 33 ++++++++++++++++++++++
>  3 files changed, 39 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index b90c59c..94760eb 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -3267,7 +3267,7 @@ int ll_getattr(const struct path *path, struct kstat *stat,
>  	stat->atime = inode->i_atime;
>  	stat->mtime = inode->i_mtime;
>  	stat->ctime = inode->i_ctime;
> -	stat->blksize = 1 << inode->i_blkbits;
> +	stat->blksize = sbi->ll_stat_blksize ?: BIT(inode->i_blkbits);

I replaced the BIT() with (1<< ).

Thanks,
NeilBrown


>  
>  	stat->nlink = inode->i_nlink;
>  	stat->size = i_size_read(inode);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 9d9f623..dcb2fed 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -523,7 +523,11 @@ struct ll_sb_info {
>  	struct root_squash_info	  ll_squash;
>  	struct path		 ll_mnt;
>  
> -	__kernel_fsid_t		  ll_fsid;
> +	/* st_blksize returned by stat(2), when non-zero */
> +	unsigned int		 ll_stat_blksize;
> +
> +	__kernel_fsid_t		 ll_fsid;
> +
>  	struct kset		ll_kset;	/* sysfs object */
>  	struct completion	 ll_kobj_unregister;
>  };
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index f775b4f..d8ef090 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -128,6 +128,38 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
>  }
>  LUSTRE_RO_ATTR(blocksize);
>  
> +static ssize_t stat_blocksize_show(struct kobject *kobj, struct attribute *attr,
> +				   char *buf)
> +{
> +	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> +					      ll_kset.kobj);
> +
> +	return sprintf(buf, "%u\n", sbi->ll_stat_blksize);
> +}
> +
> +static ssize_t stat_blocksize_store(struct kobject *kobj,
> +				    struct attribute *attr,
> +				    const char *buffer,
> +				    size_t count)
> +{
> +	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> +					      ll_kset.kobj);
> +	unsigned int val;
> +	int rc;
> +
> +	rc = kstrtouint(buffer, 10, &val);
> +	if (rc)
> +		return rc;
> +
> +	if (val != 0 && (val < PAGE_SIZE || (val & (val - 1))) != 0)
> +		return -ERANGE;
> +
> +	sbi->ll_stat_blksize = val;
> +
> +	return count;
> +}
> +LUSTRE_RW_ATTR(stat_blocksize);
> +
>  static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
>  				char *buf)
>  {
> @@ -1123,6 +1155,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
>  
>  static struct attribute *llite_attrs[] = {
>  	&lustre_attr_blocksize.attr,
> +	&lustre_attr_stat_blocksize.attr,
>  	&lustre_attr_kbytestotal.attr,
>  	&lustre_attr_kbytesfree.attr,
>  	&lustre_attr_kbytesavail.attr,
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/af54ade6/attachment.sig>
