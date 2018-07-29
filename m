From: James Simmons <jsimmons@infradead.org>
Date: Sun, 29 Jul 2018 17:59:57 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/9] lustre: move lustre_check_exclusion
 to obd_config.c
In-Reply-To: <153232698489.26222.11036165790183672424.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
 <153232698489.26222.11036165790183672424.stgit@noble>
Message-ID: <alpine.LFD.2.21.1807291759230.2402@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> lustre_check_exclusion is only used in obd_config.c, so
> move the code there
> Note that a CDEBUG is changed from D_MOUNT to D_INFO.
> This prepares for obd_mount to move to llite/

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/obd_class.h  |    1 -
>  .../staging/lustre/lustre/obdclass/obd_config.c    |   25 ++++++++++++++++++++
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c |   25 --------------------
>  3 files changed, 25 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index ef8c46cb9bee..90dbafd38d71 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -1559,7 +1559,6 @@ extern int (*ptlrpc_put_connection_superhack)(struct ptlrpc_connection *c);
>  /* obd_mount.c */
>  int lustre_unregister_fs(void);
>  int lustre_register_fs(void);
> -int lustre_check_exclusion(struct super_block *sb, char *svname);
>  
>  /* sysctl.c */
>  int obd_sysctl_init(void);
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> index 382522fa1993..f3dd020d04ef 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> @@ -1258,6 +1258,31 @@ int server_name2index(const char *svname, __u32 *idx,
>  }
>  EXPORT_SYMBOL(server_name2index);
>  
> +/* Is this server on the exclusion list */
> +static int lustre_check_exclusion(struct super_block *sb, char *svname)
> +{
> +	struct lustre_sb_info *lsi = s2lsi(sb);
> +	struct lustre_mount_data *lmd = lsi->lsi_lmd;
> +	__u32 index;
> +	int i, rc;
> +
> +	rc = server_name2index(svname, &index, NULL);
> +	if (rc != LDD_F_SV_TYPE_OST)
> +		/* Only exclude OSTs */
> +		return 0;
> +
> +	CDEBUG(D_INFO, "Check exclusion %s (%d) in %d of %s\n", svname,
> +	       index, lmd->lmd_exclude_count, lmd->lmd_dev);
> +
> +	for (i = 0; i < lmd->lmd_exclude_count; i++) {
> +		if (index == lmd->lmd_exclude[i]) {
> +			CWARN("Excluding %s (on exclusion list)\n", svname);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
>  /** Parse a configuration llog, doing various manipulations on them
>   * for various reasons, (modifications for compatibility, skip obsolete
>   * records, change uuids, etc), then class_process_config() resulting
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> index 3420e87ad0cd..4e4a8c35105b 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> @@ -633,31 +633,6 @@ static void lmd_print(struct lustre_mount_data *lmd)
>  	}
>  }
>  
> -/* Is this server on the exclusion list */
> -int lustre_check_exclusion(struct super_block *sb, char *svname)
> -{
> -	struct lustre_sb_info *lsi = s2lsi(sb);
> -	struct lustre_mount_data *lmd = lsi->lsi_lmd;
> -	__u32 index;
> -	int i, rc;
> -
> -	rc = server_name2index(svname, &index, NULL);
> -	if (rc != LDD_F_SV_TYPE_OST)
> -		/* Only exclude OSTs */
> -		return 0;
> -
> -	CDEBUG(D_MOUNT, "Check exclusion %s (%d) in %d of %s\n", svname,
> -	       index, lmd->lmd_exclude_count, lmd->lmd_dev);
> -
> -	for (i = 0; i < lmd->lmd_exclude_count; i++) {
> -		if (index == lmd->lmd_exclude[i]) {
> -			CWARN("Excluding %s (on exclusion list)\n", svname);
> -			return 1;
> -		}
> -	}
> -	return 0;
> -}
> -
>  /* mount -v  -o exclude=lustre-OST0001:lustre-OST0002 -t lustre ... */
>  static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
>  {
> 
> 
> 
