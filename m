From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 3 Apr 2019 20:47:47 +0000
Subject: [lustre-devel] [PATCH 32/32] lustre: mgc: remove
 llog_process_lock
In-Reply-To: <155252231224.26912.7309623617839627723.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
 <155252231224.26912.7309623617839627723.stgit@noble.brown>
Message-ID: <E7F71FD4-B36B-4091-A769-B64EA6F3EC93@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 13, 2019, at 18:11, NeilBrown <neilb@suse.com> wrote:
> 
> This mutex is never used, so remove it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/mgc/mgc_request.c |    6 +-----
> 1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index a805705f357e..b2b20b41ed25 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -383,8 +383,6 @@ config_log_add(struct obd_device *obd, char *logname,
> 	return ERR_PTR(rc);
> }
> 
> -static DEFINE_MUTEX(llog_process_lock);
> -
> static inline void config_mark_cld_stop(struct config_llog_data *cld)
> {
> 	if (!cld)
> @@ -1535,9 +1533,7 @@ static int mgc_process_cfg_log(struct obd_device *mgc,
> 	__llog_ctxt_put(env, ctxt);
> 
> 	/*
> -	 * update settings on existing OBDs. doing it inside
> -	 * of llog_process_lock so no device is attaching/detaching
> -	 * in parallel.
> +	 * update settings on existing OBDs.
> 	 * the logname must be <fsname>-sptlrpc
> 	 */
> 	if (sptlrpc_started) {
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
