From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 19:07:33 +0000 (GMT)
Subject: [lustre-devel] [PATCH 21/37] lustre: remove several
 MAX_STRING_SIZE defines.
In-Reply-To: <155053494593.24125.427229089746560574.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494593.24125.427229089746560574.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241855300.1485@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Some of these are unused.
> One is used in a minimal way where it is easier to use
> an explicit number.

While I dislike mystery meat type defines like MAX_STRING_SIZE I also 
don't like using raw numbers. In the past using raw numbers has causes
problems when requirements changed that were not easy to track down
why the new bug appeared. Mind you the same problem exist for constants 
like MAX_STRING_SIZE which provides no real meaning to why the magically 
number 128 is used. 
 
This number seems to be a limiting factor in the naming of sysfs directory
and file naming. I kind of see why this number has no meaning. So such
a number belongs in one place, lprocfs_status.h. Now sysfs attributes
can have any naming style they want, within reason :-) As for directories
that is limited by MAX_OBD_NAME. What do you know MAX_OBD_NAME is equal
too MAX_STRING_SIZE (hint hint) :-) 

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 --
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 ++----
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 ----
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 --
>  .../lustre/lustre/obdclass/lprocfs_status.c        |    2 --
>  5 files changed, 2 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index 74c7644d6ef8..261857e4540d 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -392,8 +392,6 @@ static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
>  	return 0;
>  }
>  
> -#undef MAX_STRING_SIZE
> -
>  struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
>  {
>  	LASSERT(res);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index d97abbfddccf..fda6d9b07952 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -906,8 +906,6 @@ void ll_lli_init(struct ll_inode_info *lli)
>  	memset(lli->lli_jobid, 0, LUSTRE_JOBID_SIZE);
>  }
>  
> -#define MAX_STRING_SIZE 128
> -
>  int ll_fill_super(struct super_block *sb)
>  {
>  	struct lustre_profile *lprof = NULL;
> @@ -916,7 +914,7 @@ int ll_fill_super(struct super_block *sb)
>  	char *dt = NULL, *md = NULL;
>  	char *profilenm = get_profile_name(sb);
>  	struct config_llog_instance *cfg;
> -	char name[MAX_STRING_SIZE];
> +	char name[128];
>  	char *ptr;
>  	int len;
>  	int err;
> @@ -960,7 +958,7 @@ int ll_fill_super(struct super_block *sb)
>  		len -= 7;
>  
>  	/* Mount info */
> -	snprintf(name, MAX_STRING_SIZE, "%.*s-%px", len,
> +	snprintf(name, sizeof(name), "%.*s-%px", len,
>  		 lsi->lsi_lmd->lmd_profile, sb);
>  
>  	/* Call ll_debugsfs_register_super() before lustre_process_log()
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index db2fbf1f3a50..5ed703d7bb1e 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -1187,8 +1187,6 @@ static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
>  	{ NULL }
>  };
>  
> -#define MAX_STRING_SIZE 128
> -
>  static struct attribute *llite_attrs[] = {
>  	&lustre_attr_blocksize.attr,
>  	&lustre_attr_stat_blocksize.attr,
> @@ -1434,8 +1432,6 @@ void ll_debugfs_unregister_super(struct super_block *sb)
>  	lprocfs_free_stats(&sbi->ll_stats);
>  }
>  
> -#undef MAX_STRING_SIZE
> -
>  #define pct(a, b) (b ? a * 100 / b : 0)
>  
>  static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 35dff0e96bf7..138e124bd05e 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -273,8 +273,6 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
>  	return rc;
>  }
>  
> -#define MAX_STRING_SIZE 128
> -
>  static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
>  {
>  	struct lmv_obd *lmv = &obd->u.lmv;
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index aed33068ff3c..a179b0d6979e 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -271,8 +271,6 @@ static int lprocfs_no_percpu_stats;
>  module_param(lprocfs_no_percpu_stats, int, 0644);
>  MODULE_PARM_DESC(lprocfs_no_percpu_stats, "Do not alloc percpu data for lprocfs stats");
>  
> -#define MAX_STRING_SIZE 128
> -
>  /* lprocfs API calls */
>  
>  static const struct file_operations lprocfs_generic_fops = { };
> 
> 
> 
