From: NeilBrown <neilb@suse.com>
Date: Tue, 27 Nov 2018 15:20:19 +1100
Subject: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel
 tasks framework
In-Reply-To: <1543200508-6838-11-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
 <1543200508-6838-11-git-send-email-jsimmons@infradead.org>
Message-ID: <87woozp2ws.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Nov 25 2018, James Simmons wrote:

> From: Dmitry Eremin <dmitry.eremin@intel.com>
>
> In this patch new API for parallel tasks execution is introduced.
> This API based on Linux kernel padata API which is used to perform
> encryption and decryption on large numbers of packets without
> reordering those packets.
>
> It was adopted for general use in Lustre for parallelization of
> various functionality. The first place of its usage is parallel I/O
> implementation.
>
> The first step in using it is to set up a cl_ptask structure to
> control of how this task are to be run:
>
>     #include <cl_ptask.h>
>
>     int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc,
>                       void *cbdata, unsigned int flags, int cpu);
>
> The cbfunc function with cbdata argument will be called in the process
> of getting the task done. The cpu specifies which CPU will be used for
> the final callback when the task is done.
>
> The submission of task is done with:
>
>     int cl_ptask_submit(struct cl_ptask *ptask,
>                         struct cl_ptask_engine *engine);
>
> The task is submitted to the engine for execution.
>
> In order to wait for result of task execution you should call:
>
>    int cl_ptask_wait_for(struct cl_ptask *ptask);
>
> The tasks with flag PTF_ORDERED are executed in parallel but complete
> into submission order. So, waiting for last ordered task you can be sure
> that all previous tasks were done before this task complete.
>
> This patch differs from the OpenSFS tree by adding this functional
> to the clio layer instead of libcfs.

While you are right that it shouldn't be in libcfs, it actually
shouldn't exist at all.
cfs_ptask_init() is used precisely once in OpenSFS.  There is no point
creating a generic API wrapper like this that is only used once.

cl_oi needs to use padata API calls directly.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181127/94e4c201/attachment.sig>
