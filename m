From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 17 Jul 2017 13:12:29 +0530
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: ldlm: constify
 attribute_group structures.
In-Reply-To: <1500270540-5928-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500270540-5928-1-git-send-email-arvind.yadav.cs@gmail.com>
	<1500270540-5928-3-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <2032ba34-5f7b-259b-d224-a9eb8c73a4a5@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: john.hammond@intel.com, dmitry.eremin@intel.com, fan.yong@intel.com

Sorry for noise. Please ignore this.

~arvind


On Monday 17 July 2017 11:18 AM, Arvind Yadav wrote:
> attribute_groups are not supposed to change at runtime. All functions
> working with attribute_groups provided by <linux/sysfs.h> work
> with const attribute_group. So mark the non-const structs as const.
>
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
>   drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index fff930f..e0c3e5d 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -926,7 +926,7 @@ static ssize_t cancel_unused_locks_before_replay_store(struct kobject *kobj,
>   	NULL,
>   };
>   
> -static struct attribute_group ldlm_attr_group = {
> +static const struct attribute_group ldlm_attr_group = {
>   	.attrs = ldlm_attrs,
>   };
>   
