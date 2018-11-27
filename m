From: Patrick Farrell <paf@cray.com>
Date: Tue, 27 Nov 2018 13:51:02 +0000
Subject: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel
 tasks framework
In-Reply-To: <7ED31E7C-2657-4FB8-B083-E451504EE62F@whamcloud.com>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
 <1543200508-6838-11-git-send-email-jsimmons@infradead.org>
 <87woozp2ws.fsf@notabene.neil.brown.name>,
 <7ED31E7C-2657-4FB8-B083-E451504EE62F@whamcloud.com>
Message-ID: <MWHPR11MB1488A82DFA620A251C2EEC70CBD00@MWHPR11MB1488.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Two notes coming, first about padata.

A major reason is actually the infrastructure itself - it?s inappropriate to our kinds of tasks.  I did a quick talk on it a while back, intending then to fix it, but never got the chance (and since had better ideas to improve write performance):

https://www.eofs.eu/_media/events/devsummit17/patrick_farrell_laddevsummit_pio.pdf

padata basically bakes in a set of assumptions that amount to ?functionally infinite amount of small work units and a dedicated machine?, which fit well with its role in packet encryption but don?t sit well for other kinds of paralelliziation.  (For example, all work is strictly and explicitly bound to a CPU.  No scheduler.  One more as a bonus - it distributes work across all allowed CPUs, but that means if you have a small number of work items (which splitting I/O tends to be because you have to make relatively big chunks) that effectively every work unit starts a worker thread for itself.)

The recent discussion of a new parallel inaction framework on LWN looked intriguing for future work.  it?s expected to fix a number of the limitations.
https://lwn.net/Articles/771169/

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Andreas Dilger <adilger@whamcloud.com>
Sent: Monday, November 26, 2018 11:08:45 PM
To: NeilBrown
Cc: Lustre Development List
Subject: Re: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel tasks framework

On Nov 26, 2018, at 21:20, NeilBrown <neilb@suse.com> wrote:
>
> On Sun, Nov 25 2018, James Simmons wrote:
>
>> From: Dmitry Eremin <dmitry.eremin@intel.com>
>>
>> In this patch new API for parallel tasks execution is introduced.
>> This API based on Linux kernel padata API which is used to perform
>> encryption and decryption on large numbers of packets without
>> reordering those packets.
>>
>> It was adopted for general use in Lustre for parallelization of
>> various functionality. The first place of its usage is parallel I/O
>> implementation.
>>
>> The first step in using it is to set up a cl_ptask structure to
>> control of how this task are to be run:
>>
>>    #include <cl_ptask.h>
>>
>>    int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc,
>>                      void *cbdata, unsigned int flags, int cpu);
>>
>> The cbfunc function with cbdata argument will be called in the process
>> of getting the task done. The cpu specifies which CPU will be used for
>> the final callback when the task is done.
>>
>> The submission of task is done with:
>>
>>    int cl_ptask_submit(struct cl_ptask *ptask,
>>                        struct cl_ptask_engine *engine);
>>
>> The task is submitted to the engine for execution.
>>
>> In order to wait for result of task execution you should call:
>>
>>   int cl_ptask_wait_for(struct cl_ptask *ptask);
>>
>> The tasks with flag PTF_ORDERED are executed in parallel but complete
>> into submission order. So, waiting for last ordered task you can be sure
>> that all previous tasks were done before this task complete.
>>
>> This patch differs from the OpenSFS tree by adding this functional
>> to the clio layer instead of libcfs.
>
> While you are right that it shouldn't be in libcfs, it actually
> shouldn't exist at all.
> cfs_ptask_init() is used precisely once in OpenSFS.  There is no point
> creating a generic API wrapper like this that is only used once.
>
> cl_oi needs to use padata API calls directly.

This infrastructure was also going to be used for parallel readahead, but the patch that implemented that was never landed because the expected performance gains didn't materialize.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181127/06cc8d7e/attachment-0001.html>
