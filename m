From: NeilBrown <neilb@suse.com>
Date: Wed, 22 May 2019 16:53:08 +1000
Subject: [lustre-devel] [PATCH v2 10/29] lustre: obd_type: discard
 obd_type_lock
In-Reply-To: <1558356671-29599-11-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-11-git-send-email-jsimmons@infradead.org>
Message-ID: <87zhnfugiz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, May 20 2019, James Simmons wrote:

> From: NeilBrown <neilb@suse.com>
>
> This lock is only used to protect typ_refcnt, so change
> that to an atomic_t and discard the lock.
>
> The lock also covers calls to try_module_get and module_put,
> but this serves no purpose as it does not prevent the module
> from being unloaded.
>
> Finally, the return value for the call to try_module_get is
> ignored, which is not safe.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/lustre/include/obd.h         |  3 +--
>  fs/lustre/include/obd_class.h   |  1 -
>  fs/lustre/mdc/mdc_request.c     |  2 +-
>  fs/lustre/mgc/mgc_request.c     |  7 -------
>  fs/lustre/obdclass/genops.c     | 29 ++++++++++++++---------------
>  fs/lustre/obdclass/lu_object.c  |  2 +-
>  fs/lustre/obdclass/obd_config.c | 19 -------------------
>  7 files changed, 17 insertions(+), 46 deletions(-)
>
> diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
> index 4c58b91..61fb815 100644
> --- a/fs/lustre/include/obd.h
> +++ b/fs/lustre/include/obd.h
> @@ -102,9 +102,8 @@ struct obd_type {
>  	struct obd_ops		*typ_dt_ops;
>  	struct md_ops		*typ_md_ops;
>  	struct dentry		*typ_debugfs_entry;
> -	int			 typ_refcnt;
> +	atomic_t		 typ_refcnt;
>  	struct lu_device_type	*typ_lu;
> -	spinlock_t		 obd_type_lock;
>  	struct kobject		 typ_kobj;
>  };
>  #define typ_name typ_kobj.name
> diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
> index 742cb9a4..a853ed5 100644
> --- a/fs/lustre/include/obd_class.h
> +++ b/fs/lustre/include/obd_class.h
> @@ -210,7 +210,6 @@ struct lustre_profile {
>  struct lustre_profile *class_get_profile(const char *prof);
>  void class_del_profile(const char *prof);
>  void class_put_profile(struct lustre_profile *lprof);
> -void class_del_profiles(void);
>  
>  #if LUSTRE_TRACKS_LOCK_EXP_REFS
>  
> diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
> index bc764f9..705a4e3 100644
> --- a/fs/lustre/mdc/mdc_request.c
> +++ b/fs/lustre/mdc/mdc_request.c
> @@ -2542,7 +2542,7 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
>  static int mdc_precleanup(struct obd_device *obd)
>  {
>  	/* Failsafe, ok if racy */
> -	if (obd->obd_type->typ_refcnt <= 1)
> +	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
>  		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
>  
>  	mdc_changelog_cdev_finish(obd);
> diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
> index 84ba6d0..d8be54d 100644
> --- a/fs/lustre/mgc/mgc_request.c
> +++ b/fs/lustre/mgc/mgc_request.c
> @@ -712,13 +712,6 @@ static int mgc_precleanup(struct obd_device *obd)
>  
>  static int mgc_cleanup(struct obd_device *obd)
>  {
> -	/* COMPAT_146 - old config logs may have added profiles we don't
> -	 * know about
> -	 */
> -	if (obd->obd_type->typ_refcnt <= 1)
> -		/* Only for the last mgc */
> -		class_del_profiles();
> -

You didn't add any text to the change log describing this change!!!!

Could you please post it as a separate patch - it is only tangentially
related to the changes in this patch.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190522/2283efe8/attachment-0001.sig>
