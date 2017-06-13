From: Greg Kroah-Hartman <greg@kroah.com>
Date: Tue, 13 Jun 2017 11:26:14 +0200
Subject: [lustre-devel] [PATCH] drivers: staging/lustre: lmv_obd.c -
 suppress Sparse user cast warning
In-Reply-To: <20170607200906.6af6jd7vmfnpq2gt@mikesart-cos>
References: <20170607200906.6af6jd7vmfnpq2gt@mikesart-cos>
Message-ID: <20170613092613.GG5677@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 07, 2017 at 02:09:06PM -0600, Michael Sartain wrote:
> Comment above assignment states that uarg does not point to user space memory
> (ll_dir_ioctl does copy_from_user), so this is a valid cast. This patch adds a
> __force annotation to suppress the "cast removes address space of expression"
> Sparse warning.
> 
> Signed-off-by: Michael Sartain <mikesart@fastmail.com>
> ---
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 271e18966f50..a6473a06dcf7 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -989,7 +989,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
>  		 * Note: this is from llite(see ll_dir_ioctl()), @uarg does not
>  		 * point to user space memory for FID2MDTIDX.
>  		 */
> -		*(__u32 *)uarg = mdt_index;
> +		*(__force __u32 *)uarg = mdt_index;

Really?  This is correct?  If so, ugh, something is really wrong with
the lustre code and it should be fixed "correctly".

thanks,

greg k-h
