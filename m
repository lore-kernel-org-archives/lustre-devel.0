From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 5 Dec 2016 17:48:11 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: mgc: make
	llog_process_lock static
In-Reply-To: <1480904481-20149-1-git-send-email-sandeepjain.linux@gmail.com>
References: <1480904481-20149-1-git-send-email-sandeepjain.linux@gmail.com>
Message-ID: <57EFF4DF-FEA7-40D5-AD29-4DF3E16D047B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "<sandeepjain.linux@gmail.com>" <sandeepjain.linux@gmail.com>
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


On Dec 4, 2016, at 9:21 PM, <sandeepjain.linux@gmail.com> <sandeepjain.linux@gmail.com> wrote:

> From: Sandeep Jain <sandeepjain.linux@gmail.com>
> 
> Fix following sparse warning.
> mgc_request.c:376:1:
> warning: symbol 'llog_process_lock' was not declared. Should it be static?
> 
> Signed-off-by: Sandeep Jain <sandeepjain.linux@gmail.com>

Acked-by: Oleg Drokin <oleg.drokin@intel.com>

> ---
> drivers/staging/lustre/lustre/mgc/mgc_request.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index 23600fb..e98a2ce 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -373,7 +373,7 @@ static int config_log_add(struct obd_device *obd, char *logname,
> 	return rc;
> }
> 
> -DEFINE_MUTEX(llog_process_lock);
> +static DEFINE_MUTEX(llog_process_lock);
> 
> /** Stop watching for updates on this log.
>  */
> -- 
> 2.7.4
