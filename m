From: Greg KH <gregkh@linuxfoundation.org>
Date: Sat, 8 Apr 2017 13:02:37 +0200
Subject: [lustre-devel] [PATCH v2] Remove sparse warnings in
	mdc_request.c
In-Reply-To: <1491283537-13023-1-git-send-email-skanda.kashyap@gmail.com>
References: <1592C3AC-DE8B-4A11-8053-02B82A61E1B3@intel.com>
	<1491283537-13023-1-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <20170408110237.GA6877@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Apr 03, 2017 at 10:25:37PM -0700, skanda.kashyap at gmail.com wrote:
> From: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> Signed-off-by: Skanda Guruanand <skanda.kashyap@gmail.com>

Changelog text goes between those two lines, right?

> 
> I have modified  struct lu_dirpage as suggested in lustre_idl.h file

Why the extra ' '?

> 
> CHECK   drivers/staging/lustre/lustre/mdc/mdc_request.c
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast
> to restricted __le64

Why is this all wrapped?




> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast
> to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast
> to restricted __le64
> 
> ---
>  drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index 60b827e..df48b8d 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -846,10 +846,10 @@ struct luda_type {
>  #endif
>  
>  struct lu_dirpage {
> -	__u64	    ldp_hash_start;
> -	__u64	    ldp_hash_end;
> -	__u32	    ldp_flags;
> -	__u32	    ldp_pad0;
> +	__le64	    ldp_hash_start;
> +	__le64	    ldp_hash_end;
> +	__le32	    ldp_flags;
> +	__le32	    ldp_pad0;


Are you sure this is correct?  How was it tested?

Also, please fix your subject to properly match those already made for
this driver...

thanks,

greg k-h
