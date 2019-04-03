From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 3 Apr 2019 19:59:28 +0000
Subject: [lustre-devel] [PATCH 18/28] lustre: remove unused fields from
 struct obd_device
In-Reply-To: <155168109872.31333.16031201138302253309.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
 <155168109872.31333.16031201138302253309.stgit@noble.brown>
Message-ID: <57CCEFAA-C92E-496A-93E8-A3FA2E28A3A3@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 3, 2019, at 23:31, NeilBrown <neilb@suse.com> wrote:
> 
> One field is set but never access.
> Another is accessed but never set.
> Other are never mentioned at all.

Well, not on the client at least...

> Also remove the comment
> 	/* use separate field as it is set in interrupt to don't mess with
> 	 * protection of other bits using _bh lock
> 	 */
> 
> This is not correct - were it used, obd_recovery_expired would be part
> of the same 'unsigned long' as the other fields.

It probably should have been just an "unsigned long" rather than a bitfield.
In any case, it is no longer updated in interrupt context so it is irrelevant.

> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/include/obd.h        |   33 +++++++-------------
> drivers/staging/lustre/lustre/mgc/mgc_request.c    |    4 +-
> drivers/staging/lustre/lustre/obdclass/class_obd.c |    1 -
> .../staging/lustre/lustre/obdclass/obd_config.c    |    1 -
> 4 files changed, 14 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 3bdde312e4a6..93a47cf0ef68 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -539,27 +539,18 @@ struct obd_device {
> 	char			 obd_name[MAX_OBD_NAME];
> 
> 	/* bitfield modification is protected by obd_dev_lock */
> -	unsigned long obd_attached:1,      /* finished attach */
> -		      obd_set_up:1,	/* finished setup */
> -		      obd_version_recov:1, /* obd uses version checking */
> -		      obd_replayable:1,/* recovery is enabled; inform clients */
> -		      obd_no_transno:1,  /* no committed-transno notification */
> -		      obd_no_recov:1,      /* fail instead of retry messages */
> -		      obd_stopping:1,      /* started cleanup */
> -		      obd_starting:1,      /* started setup */
> -		      obd_force:1,	 /* cleanup with > 0 obd refcount */
> -		      obd_fail:1,	 /* cleanup with failover */
> -		      obd_no_conn:1,       /* deny new connections */
> -		      obd_inactive:1,      /* device active/inactive
> -					    * (for sysfs status only!!)
> -					    */
> -		      obd_no_ir:1,	 /* no imperative recovery. */
> -		      obd_process_conf:1,  /* device is processing mgs config */
> -		      obd_checksum_dump:1; /* dump pages upon cksum error */
> -	/* use separate field as it is set in interrupt to don't mess with
> -	 * protection of other bits using _bh lock
> -	 */
> -	unsigned long obd_recovery_expired:1;
> +	unsigned long obd_attached:1,	  /* finished attach */
> +		      obd_set_up:1,	  /* finished setup */
> +		      obd_no_recov:1,	  /* fail instead of retry messages */
> +		      obd_stopping:1,	  /* started cleanup */
> +		      obd_starting:1,	  /* started setup */
> +		      obd_force:1,	  /* cleanup with > 0 obd refcount */
> +		      obd_fail:1,	  /* cleanup with failover */
> +		      obd_inactive:1,	  /* device active/inactive
> +					   * (for sysfs status only!!)
> +					   */
> +		      obd_process_conf:1;/* device is processing mgs config */
> +
> 	/* uuid-export hash body */
> 	struct rhashtable	 obd_uuid_hash;
> 	wait_queue_head_t	 obd_refcount_waitq;
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index 5ce49e708287..6daadf24b894 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -991,10 +991,10 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
> 		if (vallen != sizeof(int))
> 			return -EINVAL;
> 		value = *(int *)val;
> -		CDEBUG(D_MGC, "InitRecov %s %d/d%d:i%d:r%d:or%d:%s\n",
> +		CDEBUG(D_MGC, "InitRecov %s %d/d%d:i%d:r%d:%s\n",
> 		       imp->imp_obd->obd_name, value,
> 		       imp->imp_deactive, imp->imp_invalid,
> -		       imp->imp_replayable, imp->imp_obd->obd_replayable,
> +		       imp->imp_replayable,
> 		       ptlrpc_import_state_name(imp->imp_state));
> 		/* Resurrect if we previously died */
> 		if ((imp->imp_state != LUSTRE_IMP_FULL &&
> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> index b8fc74044fe3..1fcbda128a58 100644
> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> @@ -525,7 +525,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
> 		}
> 		CDEBUG(D_HA, "%s: disabling committed-transno notification\n",
> 		       obd->obd_name);
> -		obd->obd_no_transno = 1;
> 		err = 0;
> 		break;
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> index 0cdadea4e63c..7b10206d6e52 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> @@ -487,7 +487,6 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
> 				LCONSOLE_WARN("Failing over %s\n",
> 					      obd->obd_name);
> 				obd->obd_fail = 1;
> -				obd->obd_no_transno = 1;
> 				obd->obd_no_recov = 1;
> 				if (OBP(obd, iocontrol)) {
> 					obd_iocontrol(OBD_IOC_SYNC,
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
