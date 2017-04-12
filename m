From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 12 Apr 2017 08:15:49 +0200
Subject: [lustre-devel] [PATCH v2] Fix endianness issues in mdc_request.c
In-Reply-To: <1491970957-26525-1-git-send-email-skanda.kashyap@gmail.com>
References: <20170411051501.GA21419@kroah.com>
	<1491970957-26525-1-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <20170412061549.GB32351@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Apr 11, 2017 at 09:22:37PM -0700, skanda.kashyap at gmail.com wrote:
> From: Skanda Guruanand <skanda.kashyap@gmail.com>

Your subject is odd, please match other commits made for this driver
when you resend it.

> Sparse generates warnings where cast to restricted types are made.
> This commit changes types of struct fields to match endianness.

Why do you have info below --- that should be up here?

> 
> Signed-off-by: Skanda Guruanand <skanda.kashyap@gmail.com>
> ---
> I have modified struct lu_dirpage in lustre_idl.h file to remove the sparse warnings
> where cast to restricted types are made.
> 
> Following warnings were removed by this fix.
> 
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast to restricted __le64
> 
> I have not got a chance to test it as I don't have a big endian system. I feel the change
> is reasonably correct as the elements of the structure lu_dirpage are always converted from
> little-endian format to processor's native format.
> 
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

I need a bit more confidence that this is the correct change before I
can take it.  What can you do to provide that?

thanks,

greg k-h
