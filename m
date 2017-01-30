From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 30 Jan 2017 14:34:23 +0300
Subject: [lustre-devel] [PATCH 05/60] staging: lustre: llite: check
 request != NULL in ll_migrate
In-Reply-To: <1485648328-2141-6-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20170130113423.GB6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jan 28, 2017 at 07:04:33PM -0500, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> Check if the request is NULL, before retrieve reply body
> from the request.
> 
> Signed-off-by: wang di <di.wang@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7396
> Reviewed-on: http://review.whamcloud.com/17079
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/file.c | 41 +++++++++++++++++-------------
>  1 file changed, 23 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index a1e51a5..b681e15 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -2656,28 +2656,33 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
>  	if (!rc)
>  		ll_update_times(request, parent);
>  

I don't like how we return a non-NULL request on many error paths.  It
would be simpler to understand if mdc_rename() freed request on error.
So mdc_reint() fails but we still continue?  I don't understand that but
there are no comments about it.


> -	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
> -	if (!body) {
> -		rc = -EPROTO;
> -		goto out_free;
> -	}
> +	if (request) {
> +		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
> +		if (!body) {
> +			rc = -EPROTO;
> +			goto out_free;

We should call ptlrpc_req_finished(request) before returning on this
path.

regards,
dan carpenter
