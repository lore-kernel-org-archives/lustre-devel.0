From: Patrick Farrell <paf@cray.com>
Date: Tue, 27 Nov 2018 22:50:12 +0000
Subject: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel
 tasks framework
In-Reply-To: <87sgzmp35x.fsf@notabene.neil.brown.name>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
 <1543200508-6838-11-git-send-email-jsimmons@infradead.org>
 <87woozp2ws.fsf@notabene.neil.brown.name>
 <7ED31E7C-2657-4FB8-B083-E451504EE62F@whamcloud.com>
 <MWHPR11MB1488A82DFA620A251C2EEC70CBD00@MWHPR11MB1488.namprd11.prod.outlook.com>
 <MWHPR11MB148834CE6B90A81CE7D63D91CBD00@MWHPR11MB1488.namprd11.prod.outlook.com>
 <87sgzmp35x.fsf@notabene.neil.brown.name>
Message-ID: <5CFCC897-3F70-4925-B445-965189ED943D@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Starting from the top:
Yes, a simple work queue would probably work OK.  I had good luck with a simple kthread_run, actually (in a later pass at it).

But if you're thinking of improving it, there are a number of issues with it today, which are non-trivial to resolve.  Not sure which I mentioned in my presentation, but here's a quick attempt:
1. It only works on > 1 stripe files, which isn't ideal
2. It has no limit on the number of threads it will use to do I/O to one file.  In reality, 2-4 threads or so is the maximum which gets a benefit.  More than that actually hurts.
3. I believe it hurts read performance (or maybe it's off for reads even when on for writes?  Can't remember)
4. It has a deadlock with truncate which is not easy to fix.  My attempt to fix it creates a *different* lock inversion and since pio isn't (AFAIK) being used, I gave up.  No one has complained about the deadlock and it happens fairly easily with 'dd', so...

RE: Porting difficulties.  Sorry - Not the *ptask* part.  The changes in the CLIO stack to allow the actual parallel I/O use, which are in another patch.  I tend to run all the LU-8964 patches together in my mind.

This is the change I was suggesting you might not want to skip:

"commit db59ecb5d1d0284fb918def6348a11e0966d7767
Author: Dmitry Eremin <dmitry.eremin@intel.com>
Date:   Thu Mar 30 22:38:56 2017 +0300

    LU-8964 clio: Parallelize generic I/O

    Add parallel version of cl_io_loop() function which use information
    about stripes from LOV layer and process them in parallel.
    This feature is disabled by default. To enable it you should run
    "lctl set_param llite.*.pio=1" command."

" lustre/include/cl_object.h     |  49 ++++++---
 lustre/include/lustre_compat.h | 119 +++++++++++++++++++++
 lustre/include/obd_support.h   |   1 +
 lustre/llite/file.c            | 201 ++++++++++++++++++++++++++++-------
 lustre/llite/llite_internal.h  | 123 +--------------------
 lustre/llite/lproc_llite.c     |  39 ++++++-
 lustre/llite/rw26.c            |   4 +-
 lustre/llite/vvp_internal.h    |   9 +-
 lustre/llite/vvp_io.c          | 235 +++++++++++++++++++++--------------------
 lustre/lov/lov_io.c            |  91 ++++++++++------
 lustre/obdclass/cl_io.c        | 233 +++++++++++++++++++++++++++++++---------
 lustre/obdclass/cl_object.c    |  13 +++
 lustre/osc/osc_io.c            |   4 +-
 lustre/osc/osc_lock.c          |   6 +-
 lustre/tests/sanity.sh         |  11 ++"

It is, of course, up to you, and you are *really* good at porting code.  But as I assume you see, this one is significantly scarier.  The ptask patch itself is no big deal.

- Patrick


?On 11/27/18, 4:27 PM, "NeilBrown" <neilb@suse.com> wrote:

    On Tue, Nov 27 2018, Patrick Farrell wrote:
    
    > Second, about pio.
    >
    > I believe that long term it?s headed out of Lustre.  It only improves performance in a limited way in certain circumstances, and harms it in various others.  So it?s off by default, and, I suspect, remains completely unused.  A while back I noticed its test framework test didn?t activate it correctly, and once fixed, it sometimes deadlocks (race with truncate). There?s a patch to fix that, but a problem was found in it and it has since languished.
    >
    > I would still suggest you take it, Neil, as othewise you?ll complicate a bunch of potentially nasty porting working in the CLIO stack, as you apply the years of patches written with it there.  Instead, I?d suggest we pull it in the open sfs branch (Sorry!  It was a promising idea but it hasn?t panned out, and the current parallel readahead work isn?t going to use it.) and then eventually you could pick that up.
    
    Thanks so much for this background and context - really helpful.
    
    I looked though your slides and got the impression that a simple
    work-queue would probably be the best approach - no need to create your
    own pool of kthreads as I think you said you had trialed.
    
    As for the suggestion that I take it anyway, and then remove it later
    after it gets removed from OpenSFS, I remain unconvinced.
    You mention "years of patches written with it there"  but the first
    usage of the cfs_ptask_init only landed in March 2017 (less than 2 years
    ago).  libcfs_ptask is only use in lustre/obdclass/ lustre/llite/
    lustre/lov/ and the total patches in these directories since it was
    introduced in 319.  I suspect most of them aren't related to ptask.
    
    So I see no evidence that there will be much "nasty porting work".  I
    suspect there will be some, but porting code is what I spend a lot of my
    time doing, and doing it helps force me to understand the code.
    
    So what this isn't a "no way, never", it is "I'm not convinced".
    
    Thanks,
    NeilBrown
    
    
    >
    > Curious how folks feel about this.  I?d be willing to take a stab at writing a removal patch for 2.13.  It pains me a bit to suggest giving up on it, but Jinshan and I want to do write container type work to improve writes, and there?s the older/new again DDN parallel readahead work for reads.
    >
    > ________________________________
    > From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Patrick Farrell <paf@cray.com>
    > Sent: Tuesday, November 27, 2018 7:51:02 AM
    > To: Andreas Dilger; NeilBrown
    > Cc: Lustre Development List
    > Subject: Re: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel tasks framework
    >
    > Two notes coming, first about padata.
    >
    > A major reason is actually the infrastructure itself - it?s inappropriate to our kinds of tasks.  I did a quick talk on it a while back, intending then to fix it, but never got the chance (and since had better ideas to improve write performance):
    >
    > https://www.eofs.eu/_media/events/devsummit17/patrick_farrell_laddevsummit_pio.pdf
    >
    > padata basically bakes in a set of assumptions that amount to ?functionally infinite amount of small work units and a dedicated machine?, which fit well with its role in packet encryption but don?t sit well for other kinds of paralelliziation.  (For example, all work is strictly and explicitly bound to a CPU.  No scheduler.  One more as a bonus - it distributes work across all allowed CPUs, but that means if you have a small number of work items (which splitting I/O tends to be because you have to make relatively big chunks) that effectively every work unit starts a worker thread for itself.)
    >
    > The recent discussion of a new parallel inaction framework on LWN looked intriguing for future work.  it?s expected to fix a number of the limitations.
    > https://lwn.net/Articles/771169/
    >
    > ________________________________
    > From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Andreas Dilger <adilger@whamcloud.com>
    > Sent: Monday, November 26, 2018 11:08:45 PM
    > To: NeilBrown
    > Cc: Lustre Development List
    > Subject: Re: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel tasks framework
    >
    > On Nov 26, 2018, at 21:20, NeilBrown <neilb@suse.com> wrote:
    >>
    >> On Sun, Nov 25 2018, James Simmons wrote:
    >>
    >>> From: Dmitry Eremin <dmitry.eremin@intel.com>
    >>>
    >>> In this patch new API for parallel tasks execution is introduced.
    >>> This API based on Linux kernel padata API which is used to perform
    >>> encryption and decryption on large numbers of packets without
    >>> reordering those packets.
    >>>
    >>> It was adopted for general use in Lustre for parallelization of
    >>> various functionality. The first place of its usage is parallel I/O
    >>> implementation.
    >>>
    >>> The first step in using it is to set up a cl_ptask structure to
    >>> control of how this task are to be run:
    >>>
    >>>    #include <cl_ptask.h>
    >>>
    >>>    int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc,
    >>>                      void *cbdata, unsigned int flags, int cpu);
    >>>
    >>> The cbfunc function with cbdata argument will be called in the process
    >>> of getting the task done. The cpu specifies which CPU will be used for
    >>> the final callback when the task is done.
    >>>
    >>> The submission of task is done with:
    >>>
    >>>    int cl_ptask_submit(struct cl_ptask *ptask,
    >>>                        struct cl_ptask_engine *engine);
    >>>
    >>> The task is submitted to the engine for execution.
    >>>
    >>> In order to wait for result of task execution you should call:
    >>>
    >>>   int cl_ptask_wait_for(struct cl_ptask *ptask);
    >>>
    >>> The tasks with flag PTF_ORDERED are executed in parallel but complete
    >>> into submission order. So, waiting for last ordered task you can be sure
    >>> that all previous tasks were done before this task complete.
    >>>
    >>> This patch differs from the OpenSFS tree by adding this functional
    >>> to the clio layer instead of libcfs.
    >>
    >> While you are right that it shouldn't be in libcfs, it actually
    >> shouldn't exist at all.
    >> cfs_ptask_init() is used precisely once in OpenSFS.  There is no point
    >> creating a generic API wrapper like this that is only used once.
    >>
    >> cl_oi needs to use padata API calls directly.
    >
    > This infrastructure was also going to be used for parallel readahead, but the patch that implemented that was never landed because the expected performance gains didn't materialize.
    >
    > Cheers, Andreas
    > ---
    > Andreas Dilger
    > Principal Lustre Architect
    > Whamcloud
    >
    >
    >
    >
    >
    >
    >
    > _______________________________________________
    > lustre-devel mailing list
    > lustre-devel at lists.lustre.org
    > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
    
