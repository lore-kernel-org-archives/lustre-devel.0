From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 04:03:59 +0000 (GMT)
Subject: [lustre-devel] [PATCH 16/21] lustre: obdclass: normalize a
 switch statement.
In-Reply-To: <154949781331.10620.12767117536447190491.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781331.10620.12767117536447190491.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110403490.5690@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Remove the unnecessary {}, and use "break" rather than
> "goto out;" for normal exit from the cases.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/class_obd.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> index 2ef4fd41cdd0..48d1dabafa65 100644
> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> @@ -518,7 +518,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
>  	}
>  
>  	switch (cmd) {
> -	case OBD_IOC_NO_TRANSNO: {
> +	case OBD_IOC_NO_TRANSNO:
>  		if (!obd->obd_attached) {
>  			CERROR("Device %d not attached\n", obd->obd_minor);
>  			err = -ENODEV;
> @@ -528,18 +528,16 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
>  		       obd->obd_name);
>  		obd->obd_no_transno = 1;
>  		err = 0;
> -		goto out;
> -	}
> +		break;
>  
> -	default: {
> +	default:
>  		err = obd_iocontrol(cmd, obd->obd_self_export, len, data, NULL);
>  		if (err)
>  			goto out;
>  
>  		if (copy_to_user((void __user *)arg, data, len))
>  			err = -EFAULT;
> -		goto out;
> -	}
> +		break;
>  	}
>  
>   out:
> 
> 
> 
