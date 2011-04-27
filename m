From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Apr 2011 10:43:45 -0600
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<5870C1C1-3775-4CC8-B619-C79B6799D6E5@whamcloud.com>
	<alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
Message-ID: <3059315E-A6DA-4AC1-BEB9-B3AF7E48AC36@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-04-27, at 5:23 AM, Mark Hills wrote:
> On Tue, 26 Apr 2011, Andreas Dilger wrote:
>> On 2011-04-26, at 10:06 AM, Mark Hills wrote:
>>> We've often found it inconvenient that reads from Lustre mounts do not 
>>> correctly increment IO counts (/proc/<pid>/io).
>>> 
>>> Below is a patch which aims to fix this functionality.
>>> 
>>> The symptom is that writes are accounted for, but not reads. It seems that 
>>> the accounting it normally done in the kernels page writeback and 
>>> readahead functionality. Therefore as Lustre implements its own readahead, 
>>> it must also maintain its own accounting on reads (but not writes).
>>> 
>>> Is anyone able to confirm this rationale for the location of this 
>>> particular call, and consider the following patch? Thanks.
>> 
>> Mark,
>> It looks like this functionality was added to the kernel in Git commit 
>> hash 7c3ab7381e79dfc7db14a67c6f4f3285664e1ec2, which was between 2.6.19 
>> and 2.6.20.  This call needs to be made conditional so that it doesn't 
>> break the client build on older kernels (it looks like it would break 
>> RHEL5 and SLES10 clients, which don't have this functionality AFAICS).
>> 
>> It looks like it may be possible to create a compatibility macro in 
>> lustre/include/linux/lustre_compat25.h so that it doesn't break for 
>> clients running on older kernels:
>> 
>> #ifdef CONFIG_TASK_IO_ACCOUNTING
>> #include <linux/task_io_accounting_ops.h>
>> #else
>> #define task_io_accounting_read(bytes) do {} while (0)
>> #endif
> 
> Newer kernels always define task_io_account_read() as a function, even if 
> it's a no-op. So to avoid redefining it it should check the kernel 
> version, not the CONFIG_ flag.

I don't think this is a real problem, because if CONFIG_TASK_IO_ACCOUNTING is not defined, then the compatibility functions in the task_io_accounting_ops.h file will not be included and there shouldn't be any problem.  I don't see task_io_accounting_ops.h included by any other headers in the kernel, only by fs/buffer.c and fs/direct-io.c, so my original proposal should be safe.

> A revised patch is below, which I tested with kernel 2.6.32.28. 
> Unfortunately I odn't have a pre-2.6.20 platform for testing.
> 
> Thanks Andreas,
> 
> -- 
> Mark
> 
> ---
> lustre/include/linux/lustre_compat25.h |    6 ++++++
> lustre/llite/rw.c                      |    2 ++
> 2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/lustre/include/linux/lustre_compat25.h b/lustre/include/linux/lustre_compat25.h
> index 81865d0..666374b 100644
> --- a/lustre/include/linux/lustre_compat25.h
> +++ b/lustre/include/linux/lustre_compat25.h
> @@ -143,6 +143,12 @@ void groups_free(struct group_info *ginfo);
> 
> #endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2,6,4) */
> 
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20)
> +#define task_io_account_read(bytes) do {} while (0)
> +#else
> +#include <linux/task_io_accounting_ops.h>
> +#endif
> +
> #ifndef page_private
> #define page_private(page) ((page)->private)
> #define set_page_private(page, v) ((page)->private = (v))
> diff --git a/lustre/llite/rw.c b/lustre/llite/rw.c
> index ccd6a42..1fddd5b 100644
> --- a/lustre/llite/rw.c
> +++ b/lustre/llite/rw.c
> @@ -1311,6 +1311,8 @@ static int ll_issue_page_read(struct obd_export *exp,
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


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
