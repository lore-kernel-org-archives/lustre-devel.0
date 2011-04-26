From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 26 Apr 2011 10:38:14 -0600
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
Message-ID: <5870C1C1-3775-4CC8-B619-C79B6799D6E5@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-04-26, at 10:06 AM, Mark Hills wrote:
> We've often found it inconvenient that reads from Lustre mounts do not 
> correctly increment IO counts (/proc/<pid>/io).
> 
> Below is a patch which aims to fix this functionality.
> 
> The symptom is that writes are accounted for, but not reads. It seems that 
> the accounting it normally done in the kernels page writeback and 
> readahead functionality. Therefore as Lustre implements its own readahead, 
> it must also maintain its own accounting on reads (but not writes).
> 
> Is anyone able to confirm this rationale for the location of this 
> particular call, and consider the following patch? Thanks.

Mark,
It looks like this functionality was added to the kernel in Git commit hash 7c3ab7381e79dfc7db14a67c6f4f3285664e1ec2, which was between 2.6.19 and 2.6.20.  This call needs to be made conditional so that it doesn't break the client build on older kernels (it looks like it would break RHEL5 and SLES10 clients, which don't have this functionality AFAICS).

It looks like it may be possible to create a compatibility macro in lustre/include/linux/lustre_compat25.h so that it doesn't break for clients running on older kernels:

#ifdef CONFIG_TASK_IO_ACCOUNTING
#include <linux/task_io_accounting_ops.h>
#else
#define task_io_accounting_read(bytes) do {} while (0)
#endif


> lustre/llite/rw.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lustre/llite/rw.c b/lustre/llite/rw.c
> index ccd6a42..c7a84b7 100644
> --- a/lustre/llite/rw.c
> +++ b/lustre/llite/rw.c
> @@ -58,6 +58,7 @@
> #include <linux/mm.h>
> #include <linux/pagemap.h>
> #include <linux/smp_lock.h>
> +#include <linux/task_io_accounting_ops.h>
> 
> #define DEBUG_SUBSYSTEM S_LLITE
> 
> @@ -1311,6 +1312,8 @@ static int ll_issue_page_read(struct obd_export *exp,
>         if (rc) {
>                 LL_CDEBUG_PAGE(D_ERROR, page, "read queue failed: rc %d\n", rc);
>                 page_cache_release(page);
> +        } else {
> +                task_io_account_read(CFS_PAGE_SIZE);
>         }
>         RETURN(rc);
> }
> -- 
> 1.7.1.1
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
