From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 08:55:10 +1000
Subject: [lustre-devel] [PATCH 30/31] lustre: fid: race between
 client_fid_fini and seq_client_flush
In-Reply-To: <1533003983-29311-31-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-31-git-send-email-jsimmons@infradead.org>
Message-ID: <87y3drqalt.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 30 2018, James Simmons wrote:

> From: Fan Yong <fan.yong@intel.com>
>
> When the client mount failed or umount, the client_fid_fini() will
> be called. At that time, the async connection failure will trigger
> seq_client_flush() which parameter may have been released by the
> client_fid_fini() by race.
>
> Introduce client_obd::cl_seq_rwsem to protect client_obd::cl_seq.

This looks odd..

I think the cl_seq_rwsem is being used like a refcount on cl_seq,
to prevent it from being freed while it is still in use.
If I'm correct, then I would much prefer that a refcount was used.

Is this more than just a disguised refcount?

NeilBrown


>
> Signed-off-by: Fan Yong <fan.yong@intel.com>
> WC-id: https://jira.whamcloud.com/browse/LU-9224
> Reviewed-on: https://review.whamcloud.com/26079
> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/fid/fid_request.c | 21 +++++++++++++++------
>  drivers/staging/lustre/lustre/include/obd.h     |  1 +
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c   |  2 ++
>  drivers/staging/lustre/lustre/mdc/mdc_request.c | 11 +++++++++--
>  4 files changed, 27 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
> index a34fd90..f91242c 100644
> --- a/drivers/staging/lustre/lustre/fid/fid_request.c
> +++ b/drivers/staging/lustre/lustre/fid/fid_request.c
> @@ -343,11 +343,14 @@ int client_fid_init(struct obd_device *obd,
>  {
>  	struct client_obd *cli = &obd->u.cli;
>  	char *prefix;
> -	int rc;
> +	int rc = 0;
>  
> +	down_write(&cli->cl_seq_rwsem);
>  	cli->cl_seq = kzalloc(sizeof(*cli->cl_seq), GFP_NOFS);
> -	if (!cli->cl_seq)
> -		return -ENOMEM;
> +	if (!cli->cl_seq) {
> +		rc = -ENOMEM;
> +		goto out_free_lock;
> +	}
>  
>  	prefix = kzalloc(MAX_OBD_NAME + 5, GFP_NOFS);
>  	if (!prefix) {
> @@ -361,10 +364,14 @@ int client_fid_init(struct obd_device *obd,
>  	seq_client_init(cli->cl_seq, exp, type, prefix);
>  	kfree(prefix);
>  
> -	return 0;
>  out_free_seq:
> -	kfree(cli->cl_seq);
> -	cli->cl_seq = NULL;
> +	if (rc) {
> +		kfree(cli->cl_seq);
> +		cli->cl_seq = NULL;
> +	}
> +out_free_lock:
> +	up_write(&cli->cl_seq_rwsem);
> +
>  	return rc;
>  }
>  EXPORT_SYMBOL(client_fid_init);
> @@ -373,11 +380,13 @@ int client_fid_fini(struct obd_device *obd)
>  {
>  	struct client_obd *cli = &obd->u.cli;
>  
> +	down_write(&cli->cl_seq_rwsem);
>  	if (cli->cl_seq) {
>  		seq_client_fini(cli->cl_seq);
>  		kfree(cli->cl_seq);
>  		cli->cl_seq = NULL;
>  	}
> +	up_write(&cli->cl_seq_rwsem);
>  
>  	return 0;
>  }
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 333c703..3c0dbb6 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -333,6 +333,7 @@ struct client_obd {
>  
>  	/* sequence manager */
>  	struct lu_client_seq    *cl_seq;
> +	struct rw_semaphore	 cl_seq_rwsem;
>  
>  	atomic_t	     cl_resends; /* resend count */
>  
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> index c36d1e4..32eda4f 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> @@ -308,6 +308,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
>  	}
>  
>  	init_rwsem(&cli->cl_sem);
> +	cli->cl_seq = NULL;
> +	init_rwsem(&cli->cl_seq_rwsem);
>  	cli->cl_conn_count = 0;
>  	memcpy(server_uuid.uuid, lustre_cfg_buf(lcfg, 2),
>  	       min_t(unsigned int, LUSTRE_CFG_BUFLEN(lcfg, 2),
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index c2f0a54..a759da2 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -2517,8 +2517,10 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
>  		 * Flush current sequence to make client obtain new one
>  		 * from server in case of disconnect/reconnect.
>  		 */
> +		down_read(&cli->cl_seq_rwsem);
>  		if (cli->cl_seq)
>  			seq_client_flush(cli->cl_seq);
> +		up_read(&cli->cl_seq_rwsem);
>  
>  		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_INACTIVE);
>  		break;
> @@ -2557,9 +2559,14 @@ int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
>  		  struct lu_fid *fid, struct md_op_data *op_data)
>  {
>  	struct client_obd *cli = &exp->exp_obd->u.cli;
> -	struct lu_client_seq *seq = cli->cl_seq;
> +	int rc = -EIO;
>  
> -	return seq_client_alloc_fid(env, seq, fid);
> +	down_read(&cli->cl_seq_rwsem);
> +	if (cli->cl_seq)
> +		rc = seq_client_alloc_fid(env, cli->cl_seq, fid);
> +	up_read(&cli->cl_seq_rwsem);
> +
> +	return rc;
>  }
>  
>  static struct obd_uuid *mdc_get_uuid(struct obd_export *exp)
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/cce690fa/attachment.sig>
