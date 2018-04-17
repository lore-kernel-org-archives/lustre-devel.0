From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Apr 2018 10:14:49 +0300
Subject: [lustre-devel] [PATCH 11/25] staging: lustre: libcfs: invert
 error handling for cfs_cpt_table_print
In-Reply-To: <1523851807-16573-12-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-12-git-send-email-jsimmons@infradead.org>
Message-ID: <20180417071449.ufj7spey44qwiqdy@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:53AM -0400, James Simmons wrote:
> From: Amir Shehata <amir.shehata@intel.com>
> 
> Instead of setting rc to -EFBIG for several cases in the loop lets
> initialize rc to -EFBIG and just break out of the loop in case of
> failure. Just set rc to zero once we successfully finish the loop.
> 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
> Reviewed-on: http://review.whamcloud.com/18916
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> index bbf89b8..6d8dcd3 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> @@ -158,29 +158,26 @@ struct cfs_cpt_table *
>  cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
>  {
>  	char *tmp = buf;
> -	int rc = 0;
> +	int rc = -EFBIG;
>  	int i;
>  	int j;
>  
>  	for (i = 0; i < cptab->ctb_nparts; i++) {
> -		if (len > 0) {
> -			rc = snprintf(tmp, len, "%d\t:", i);
> -			len -= rc;
> -		}
> +		if (len <= 0)
> +			goto out;
> +
> +		rc = snprintf(tmp, len, "%d\t:", i);
> +		len -= rc;
>  
> -		if (len <= 0) {
> -			rc = -EFBIG;
> +		if (len <= 0)
>  			goto out;

This patch says it's a cleanup but the only thing it does is introduce
"forgot to set the error" bugs.

regards,
dan carpenter
