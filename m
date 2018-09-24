From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 14:17:32 +1000
Subject: [lustre-devel] [PATCH 21/30] lustre: ldlm: use static
 initializer macros where possible
In-Reply-To: <1537205440-6656-22-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-22-git-send-email-jsimmons@infradead.org>
Message-ID: <87tvmf4jhf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> From: "John L. Hammond" <jhammond@whamcloud.com>
>
> In lustre/ldlm/ replace module load time initialization of several
> mutexes with static initialization using the kernel provided macros.
>
> Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9010
> Reviewed-on: https://review.whamcloud.com/24824
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/lustre_dlm.h | 3 +--
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 6 +-----
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 4 ++--
>  3 files changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> index a68c7a4..e2bbcaa 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> @@ -742,8 +742,7 @@ struct ldlm_lock {
>  	 * The lists this could be linked into are:
>  	 * waiting_locks_list (protected by waiting_locks_spinlock),
>  	 * then if the lock timed out, it is moved to
> -	 * expired_lock_thread.elt_expired_locks for further processing.
> -	 * Protected by elt_lock.
> +	 * expired_lock_list for further processing.
>  	 */
>  	struct list_head		l_pending_chain;
>  
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index a8de3d9..986c378 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -53,7 +53,7 @@
>  module_param(ldlm_cpts, charp, 0444);
>  MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
>  
> -static struct mutex	ldlm_ref_mutex;
> +static DEFINE_MUTEX(ldlm_ref_mutex);
>  static int ldlm_refcount;
>  
>  static struct kobject *ldlm_kobj;
> @@ -69,10 +69,6 @@ struct ldlm_cb_async_args {
>  
>  static struct ldlm_state *ldlm_state;
>  
> -#define ELT_STOPPED   0
> -#define ELT_READY     1
> -#define ELT_TERMINATE 2
> -

Arg... Why do people do this???
One patch - one change.
This change is irrelevant to this patch, so it just makes it harder
to review.

Grumble.

NeilBrown


>  struct ldlm_bl_pool {
>  	spinlock_t		blp_lock;
>  
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index 1907a5a..bd5622d 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -49,10 +49,10 @@
>  int ldlm_srv_namespace_nr;
>  int ldlm_cli_namespace_nr;
>  
> -struct mutex ldlm_srv_namespace_lock;
> +DEFINE_MUTEX(ldlm_srv_namespace_lock);
>  LIST_HEAD(ldlm_srv_namespace_list);
>  
> -struct mutex ldlm_cli_namespace_lock;
> +DEFINE_MUTEX(ldlm_cli_namespace_lock);
>  /* Client Namespaces that have active resources in them.
>   * Once all resources go away, ldlm_poold moves such namespaces to the
>   * inactive list
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/1956aaa2/attachment.sig>
