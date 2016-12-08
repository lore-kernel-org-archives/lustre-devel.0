From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Dec 2016 00:44:38 +0000 (GMT)
Subject: [lustre-devel] [PATCH 1/8] staging/lustre/llite: move
 root_squash from sysfs to debugfs
In-Reply-To: <1481150494-1853127-2-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
	<1481150494-1853127-2-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1612080043170.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> root_squash control got accidentally moved to sysfs instead of
> debugfs, and the write side of it was also broken expecting a
> userspace buffer.
> It contains both uid and gid values in a single file, so debugfs
> is a clear place for it.

I see why this was missed. The uid/gid pair I needed for my testing
was missing so the test was skipped. I fixed it up and tested this
patch out. Now it passes.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Fixes: c948390f10ccc "fix inconsistencies of root squash feature"
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/llite/lproc_llite.c | 27 +++++++++++++----------
>  1 file changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 03682c1..f3ee584 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -924,27 +924,29 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
>  }
>  LPROC_SEQ_FOPS(ll_unstable_stats);
>  
> -static ssize_t root_squash_show(struct kobject *kobj, struct attribute *attr,
> -				char *buf)
> +static int ll_root_squash_seq_show(struct seq_file *m, void *v)
>  {
> -	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> -					      ll_kobj);
> +	struct super_block *sb = m->private;
> +	struct ll_sb_info *sbi = ll_s2sbi(sb);
>  	struct root_squash_info *squash = &sbi->ll_squash;
>  
> -	return sprintf(buf, "%u:%u\n", squash->rsi_uid, squash->rsi_gid);
> +	seq_printf(m, "%u:%u\n", squash->rsi_uid, squash->rsi_gid);
> +	return 0;
>  }
>  
> -static ssize_t root_squash_store(struct kobject *kobj, struct attribute *attr,
> -				 const char *buffer, size_t count)
> +static ssize_t ll_root_squash_seq_write(struct file *file,
> +					const char __user *buffer,
> +					size_t count, loff_t *off)
>  {
> -	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> -					      ll_kobj);
> +	struct seq_file *m = file->private_data;
> +	struct super_block *sb = m->private;
> +	struct ll_sb_info *sbi = ll_s2sbi(sb);
>  	struct root_squash_info *squash = &sbi->ll_squash;
>  
>  	return lprocfs_wr_root_squash(buffer, count, squash,
> -				      ll_get_fsname(sbi->ll_sb, NULL, 0));
> +				      ll_get_fsname(sb, NULL, 0));
>  }
> -LUSTRE_RW_ATTR(root_squash);
> +LPROC_SEQ_FOPS(ll_root_squash);
>  
>  static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
>  {
> @@ -997,6 +999,8 @@ static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
>  	{ "statahead_stats",  &ll_statahead_stats_fops, NULL, 0 },
>  	{ "unstable_stats",   &ll_unstable_stats_fops, NULL },
>  	{ "sbi_flags",	      &ll_sbi_flags_fops, NULL, 0 },
> +	{ .name =       "root_squash",
> +	  .fops =       &ll_root_squash_fops			},
>  	{ .name =		"nosquash_nids",
>  	  .fops =		&ll_nosquash_nids_fops		},
>  	{ NULL }
> @@ -1027,7 +1031,6 @@ static struct attribute *llite_attrs[] = {
>  	&lustre_attr_max_easize.attr,
>  	&lustre_attr_default_easize.attr,
>  	&lustre_attr_xattr_cache.attr,
> -	&lustre_attr_root_squash.attr,
>  	NULL,
>  };
>  
> -- 
> 2.7.4
> 
> 
