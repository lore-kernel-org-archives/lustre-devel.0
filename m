From: James Simmons <jsimmons@infradead.org>
Date: Sun, 11 Feb 2018 21:39:05 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: return of an
 error code should be negative
In-Reply-To: <1517117095-12643-1-git-send-email-pundirsumit11@gmail.com>
References: <1517117095-12643-1-git-send-email-pundirsumit11@gmail.com>
Message-ID: <alpine.LFD.2.21.1802112138340.21780@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sumit Pundir <pundirsumit11@gmail.com>
Cc: devel@driverdev.osuosl.org, andreas.dilger@intel.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, lustre-devel@lists.lustre.org


> Return value of error codes should typically be negative.
> Issue reported by checkpatch.pl
>

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Sumit Pundir <pundirsumit11@gmail.com>
> ---
>  drivers/staging/lustre/lnet/selftest/framework.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
> index c7697f6..0ca1e3a 100644
> --- a/drivers/staging/lustre/lnet/selftest/framework.c
> +++ b/drivers/staging/lustre/lnet/selftest/framework.c
> @@ -187,7 +187,7 @@ sfw_del_session_timer(void)
>  		return 0;
>  	}
>  
> -	return EBUSY; /* racing with sfw_session_expired() */
> +	return -EBUSY; /* racing with sfw_session_expired() */
>  }
>  
>  static void
> -- 
> 2.7.4
> 
> 
