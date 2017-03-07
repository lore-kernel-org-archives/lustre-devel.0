From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 7 Mar 2017 00:38:16 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: fix sparse warning
	about different address spaces
In-Reply-To: <1488412629-20859-1-git-send-email-mario.bambagini@gmail.com>
References: <1488412629-20859-1-git-send-email-mario.bambagini@gmail.com>
Message-ID: <D1A2D770-396F-4979-83A2-766E4B185F17@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mario Bambagini <mario.bambagini@gmail.com>
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org


On Mar 1, 2017, at 6:57 PM, Mario Bambagini wrote:

> fixed the following sparse warning by adding proper cast:
> drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74:    expected char const [noderef] <asn:1>*<noident>
> drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74:    got char *[assigned] sval
> 
> Signed-off-by: Mario Bambagini <mario.bambagini@gmail.com>

The patch is fine, but just be advised this whole function is going away real soon now
per Al Viro request (and also because it no longer does what it should).

> ---
> drivers/staging/lustre/lustre/obdclass/obd_config.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> index 9ca84c7..8fce88f 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> @@ -1052,7 +1052,8 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
> 
> 					oldfs = get_fs();
> 					set_fs(KERNEL_DS);
> -					rc = var->fops->write(&fakefile, sval,
> +					rc = var->fops->write(&fakefile,
> +						(const char __user *)sval,
> 								vallen, NULL);
> 					set_fs(oldfs);
> 				}
> -- 
> 2.1.4
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
