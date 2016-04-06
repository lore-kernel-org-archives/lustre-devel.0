From: James Simmons <jsimmons@infradead.org>
Date: Wed, 6 Apr 2016 19:55:52 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging/lustre/obdclass: fix build
 warning
In-Reply-To: <1459867534-4507-1-git-send-email-sudipm.mukherjee@gmail.com>
References: <1459867534-4507-1-git-send-email-sudipm.mukherjee@gmail.com>
Message-ID: <alpine.LFD.2.20.1604061955160.18149@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org


> While building with W=1 we were getting the warning:
> 
> drivers/staging/lustre/lustre/obdclass/cl_object.c:1056:16:
> 	warning: old-style function definition
>  struct lu_env *cl_env_percpu_get()
>                 ^
> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Acked-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lustre/obdclass/cl_object.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index 395b92c..d84ec00 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -1053,7 +1053,7 @@ void cl_env_percpu_put(struct lu_env *env)
>  }
>  EXPORT_SYMBOL(cl_env_percpu_put);
>  
> -struct lu_env *cl_env_percpu_get()
> +struct lu_env *cl_env_percpu_get(void)
>  {
>  	struct cl_env *cle;
>  
> -- 
> 1.9.1
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
