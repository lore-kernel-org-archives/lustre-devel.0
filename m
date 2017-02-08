From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 8 Feb 2017 00:38:58 +0000
Subject: [lustre-devel] [PATCH 06/24] lustre: Convert to
	separately	allocated bdi
In-Reply-To: <20170202173422.3240-7-jack@suse.cz>
References: <20170202173422.3240-1-jack@suse.cz>
	<20170202173422.3240-7-jack@suse.cz>
Message-ID: <4CFDE4F9-4A4C-4A69-A3C5-AAEA1641D3CF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Christoph Hellwig <hch@infradead.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Feb 2, 2017, at 10:34, Jan Kara <jack@suse.cz> wrote:
> 
> Allocate struct backing_dev_info separately instead of embedding it
> inside superblock. This unifies handling of bdi among users.
> 
> CC: Oleg Drokin <oleg.drokin@intel.com>
> CC: Andreas Dilger <andreas.dilger@intel.com>
> CC: James Simmons <jsimmons@infradead.org>
> CC: lustre-devel at lists.lustre.org
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> .../staging/lustre/lustre/include/lustre_disk.h    |  4 ----
> drivers/staging/lustre/lustre/llite/llite_lib.c    | 24 +++-------------------
> 2 files changed, 3 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
> index 8886458748c1..a676bccabd43 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_disk.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
> @@ -133,13 +133,9 @@ struct lustre_sb_info {
> 	struct obd_export	 *lsi_osd_exp;
> 	char			  lsi_osd_type[16];
> 	char			  lsi_fstype[16];
> -	struct backing_dev_info   lsi_bdi;     /* each client mountpoint needs
> -						* own backing_dev_info
> -						*/
> };
> 
> #define LSI_UMOUNT_FAILOVER	      0x00200000
> -#define LSI_BDI_INITIALIZED	      0x00400000
> 
> #define     s2lsi(sb)	((struct lustre_sb_info *)((sb)->s_fs_info))
> #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index 25f5aed97f63..4f07d2e60d40 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -861,15 +861,6 @@ void ll_lli_init(struct ll_inode_info *lli)
> 	mutex_init(&lli->lli_layout_mutex);
> }
> 
> -static inline int ll_bdi_register(struct backing_dev_info *bdi)
> -{
> -	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
> -
> -	bdi->name = "lustre";
> -	return bdi_register(bdi, NULL, "lustre-%d",
> -			    atomic_inc_return(&ll_bdi_num));
> -}
> -
> int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
> {
> 	struct lustre_profile *lprof = NULL;
> @@ -879,6 +870,7 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
> 	char  *profilenm = get_profile_name(sb);
> 	struct config_llog_instance *cfg;
> 	int    err;
> +	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
> 
> 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
> 
> @@ -901,16 +893,11 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
> 	if (err)
> 		goto out_free;
> 
> -	err = bdi_init(&lsi->lsi_bdi);
> -	if (err)
> -		goto out_free;
> -	lsi->lsi_flags |= LSI_BDI_INITIALIZED;
> -	lsi->lsi_bdi.capabilities = 0;
> -	err = ll_bdi_register(&lsi->lsi_bdi);
> +	err = super_setup_bdi_name(sb, "lustre-%d",
> +				   atomic_inc_return(&ll_bdi_num));
> 	if (err)
> 		goto out_free;
> 
> -	sb->s_bdi = &lsi->lsi_bdi;
> 	/* kernel >= 2.6.38 store dentry operations in sb->s_d_op. */
> 	sb->s_d_op = &ll_d_ops;
> 
> @@ -1031,11 +1018,6 @@ void ll_put_super(struct super_block *sb)
> 	if (profilenm)
> 		class_del_profile(profilenm);
> 
> -	if (lsi->lsi_flags & LSI_BDI_INITIALIZED) {
> -		bdi_destroy(&lsi->lsi_bdi);
> -		lsi->lsi_flags &= ~LSI_BDI_INITIALIZED;
> -	}
> -
> 	ll_free_sbi(sb);
> 	lsi->lsi_llsbi = NULL;
> 
> -- 
> 2.10.2
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
