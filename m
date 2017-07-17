From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 17 Jul 2017 13:11:04 +0530
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: constify
 attribute_group structures.
In-Reply-To: <1500270540-5928-5-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500270540-5928-1-git-send-email-arvind.yadav.cs@gmail.com>
	<1500270540-5928-5-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <84171e90-fd40-43f8-46b4-8645a60aab6e@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: john.hammond@intel.com, dmitry.eremin@intel.com, fan.yong@intel.com

Sorry for noise. Please ignore this. This change should not be separate.

~arvind

On Monday 17 July 2017 11:19 AM, Arvind Yadav wrote:
> attribute_groups are not supposed to change at runtime. All functions
> working with attribute_groups provided by <linux/sysfs.h> work
> with const attribute_group. So mark the non-const structs as const.
>
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
>   drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index bc19f19..ba41983 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1031,7 +1031,7 @@ static void obd_sysfs_release(struct kobject *kobj)
>   };
>   
>   int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
> -		      struct attribute_group *attrs)
> +		      const struct attribute_group *attrs)
>   {
>   	int rc = 0;
>   
