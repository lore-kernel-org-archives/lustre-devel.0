From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 30 Jan 2018 01:49:17 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: return of an
 error code should be negative
In-Reply-To: <1517117095-12643-1-git-send-email-pundirsumit11@gmail.com>
References: <1517117095-12643-1-git-send-email-pundirsumit11@gmail.com>
Message-ID: <0FF5C462-31A2-4D8F-9288-EE941D37826B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sumit Pundir <pundirsumit11@gmail.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Jan 27, 2018, at 22:24, Sumit Pundir <pundirsumit11@gmail.com> wrote:
> 
> Return value of error codes should typically be negative.
> Issue reported by checkpatch.pl
> 
> Signed-off-by: Sumit Pundir <pundirsumit11@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/framework.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
> index c7697f6..0ca1e3a 100644
> --- a/drivers/staging/lustre/lnet/selftest/framework.c
> +++ b/drivers/staging/lustre/lnet/selftest/framework.c
> @@ -187,7 +187,7 @@ sfw_del_session_timer(void)
> 		return 0;
> 	}
> 
> -	return EBUSY; /* racing with sfw_session_expired() */
> +	return -EBUSY; /* racing with sfw_session_expired() */
> }
> 
> static void
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
