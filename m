From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 17:30:33 +1000
Subject: [lustre-devel] [PATCH 32/38] lustre: osc: restore
 cl_loi_list_lock
In-Reply-To: <1534475441-15543-33-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-33-git-send-email-jsimmons@infradead.org>
Message-ID: <87sh3dqwkm.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> Access to struct client_obd should be protected with the spinlock
> cl_loi_list_lock. This was dropped during the port to sysfs so
> restore the proper locking.
>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/osc/lproc_osc.c | 36 +++++++++++++++++++++++----
>  1 file changed, 31 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> index 3c31e98..5fb7a16 100644
> --- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
> +++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> @@ -80,8 +80,13 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
>  	struct obd_device *dev = container_of(kobj, struct obd_device,
>  					      obd_kset.kobj);
>  	struct client_obd *cli = &dev->u.cli;
> +	ssize_t len;
>  
> -	return sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
> +	spin_lock(&cli->cl_loi_list_lock);
> +	len = sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
> +	spin_unlock(&cli->cl_loi_list_lock);

Why do you think a spinlock is needed here?
How could you even end up with an incorrect value?

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/6be5aed0/attachment.sig>
