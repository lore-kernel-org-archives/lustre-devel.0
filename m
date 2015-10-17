From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 16 Oct 2015 22:40:49 -0700
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: workitem.c: replace
 IS_PO2 with is_power_of_2
In-Reply-To: <2519058141bb445670678a4f7dfbca2eabde4477.1445032901.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<2519058141bb445670678a4f7dfbca2eabde4477.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <20151017054049.GB25392@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 17, 2015 at 12:06:59AM +0200, Aya Mahfouz wrote:
> Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
> macros. In this case, it is CDEBUG. Note that the replacement changes
> the types involved, because the parameter of IS_PO2 is of type long long
> and the return type is int, while the parameter of is_power_of_2 is of
> type long and the return type is bool. This, however, has no impact,
> because the actual argument is always of type int, and the return value
> is always used as a boolean.
> 
> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> ---
>  drivers/staging/lustre/lustre/libcfs/workitem.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
> index e1143a5..377e1ea 100644
> --- a/drivers/staging/lustre/lustre/libcfs/workitem.c
> +++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
> @@ -41,6 +41,8 @@
>  
>  #define DEBUG_SUBSYSTEM S_LNET
>  
> +#include <linux/log2.h>
> +
>  #include "../../include/linux/libcfs/libcfs.h"
>  
>  #define CFS_WS_NAME_LEN	 16
> @@ -325,7 +327,7 @@ cfs_wi_sched_destroy(struct cfs_wi_sched *sched)
>  
>  	spin_lock(&cfs_wi_data.wi_glock);
>  	while (sched->ws_nthreads > 0) {
> -		CDEBUG(IS_PO2(++i) ? D_WARNING : D_NET,
> +		CDEBUG(is_power_of_2(++i) ? D_WARNING : D_NET,

Same question about 0 here as well.

thanks,

greg k-h
