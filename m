From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Fri, 13 Nov 2015 10:44:20 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: cl_lock: Remove
 cl_lock_lockdep_init wrapper
In-Reply-To: <D26A8399.11A59C%andreas.dilger@intel.com>
References: <1447237306-46901-1-git-send-email-shivanib134@gmail.com>
	<201511111859.mIw4mICa%fengguang.wu@intel.com>
	<CAKHNQQHLwsfv6OKOci4g4405_vcFgy7GNcUAWX0aDAS+GFU6gw@mail.gmail.com>
	<D26A8399.11A59C%andreas.dilger@intel.com>
Message-ID: <CAKHNQQHLLDwd4X7kRhBt3Pc-bvfEW-g+MsTt0qnB_xHP7PNDYg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 13, 2015 at 6:29 AM, Dilger, Andreas <andreas.dilger@intel.com>
wrote:

> On 2015/11/11, 10:21, "lustre-devel on behalf of Shivani Bhardwaj"
> <lustre-devel-bounces at lists.lustre.org on behalf of shivanib134@gmail.com>
> wrote:
>
> >On Wed, Nov 11, 2015 at 4:24 PM, kbuild test robot <lkp@intel.com> wrote:
> >> Hi Shivani,
> >>
> >> [auto build test ERROR on staging/staging-testing]
> >> [also build test ERROR on v4.3 next-20151111]
> >>
> >> url:
> >>
> https://github.com/0day-ci/linux/commits/Shivani-Bhardwaj/staging-lustre-
> >>cl_lock-Remove-cl_lock_lockdep_init-wrapper/20151111-182452
> >> config: m68k-allyesconfig (attached as .config)
> >> reproduce:
> >>         wget
> >>
> https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin
> >>/make.cross -O ~/bin/make.cross
> >>         chmod +x ~/bin/make.cross
> >>         # save the attached .config to linux build tree
> >>         make.cross ARCH=m68k
> >>
> >> All errors (new ones prefixed by >>):
> >>
> >>    In file included from include/linux/spinlock_types.h:18:0,
> >>                     from include/linux/spinlock.h:81,
> >>                     from include/linux/mmzone.h:7,
> >>                     from include/linux/gfp.h:5,
> >>                     from include/linux/slab.h:14,
> >>                     from
> >>drivers/staging/lustre/lustre/obdclass/../include/obd_support.h:40,
> >>                     from
> >>drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:39,
> >>                     from
> >>drivers/staging/lustre/lustre/obdclass/cl_lock.c:43:
> >>    drivers/staging/lustre/lustre/obdclass/cl_lock.c: In function
> >>'cl_lock_alloc':
> >>>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:379:37: error:
> >>>>'cl_lock_key' undeclared (first use in this function)
> >>       lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
> >>                                         ^
> >>    include/linux/lockdep.h:401:15: note: in definition of macro
> >>'lockdep_set_class_and_name'
> >>       do { (void)(key); (void)(name); } while (0)
> >>                   ^
> >>    drivers/staging/lustre/lustre/obdclass/cl_lock.c:379:37: note: each
> >>undeclared identifier is reported only once for each function it appears
> >>in
> >>       lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
> >>                                         ^
> >>    include/linux/lockdep.h:401:15: note: in definition of macro
> >>'lockdep_set_class_and_name'
> >>       do { (void)(key); (void)(name); } while (0)
> >>                   ^
> >>    drivers/staging/lustre/lustre/obdclass/cl_lock.c: At top level:
> >>    drivers/staging/lustre/lustre/obdclass/cl_lock.c:166:13: warning:
> >>'cl_lock_lockdep_init' defined but not used [-Wunused-function]
> >>     static void cl_lock_lockdep_init(struct cl_lock *lock)
> >>                 ^
> >>
> >> vim +/cl_lock_key +379 drivers/staging/lustre/lustre/obdclass/cl_lock.c
> >>
> >>    373                  lockdep_set_class(&lock->cll_guard,
> >>&cl_lock_guard_class);
> >>    374                  init_waitqueue_head(&lock->cll_wq);
> >>    375                  head = obj->co_lu.lo_header;
> >>    376                  CS_LOCKSTATE_INC(obj, CLS_NEW);
> >>    377                  CS_LOCK_INC(obj, total);
> >>    378                  CS_LOCK_INC(obj, create);
> >>  > 379                  lockdep_set_class_and_name(lock, &cl_lock_key,
> >>"EXT");
> >>    380                  list_for_each_entry(obj, &head->loh_layers,
> >>    381                                          co_lu.lo_linkage) {
> >>    382                          int err;
> >>
> >> ---
> >> 0-DAY kernel test infrastructure                Open Source Technology
> >>Center
> >> https://lists.01.org/pipermail/kbuild-all                   Intel
> >>Corporation
> >
> >Hi all,
> >
> >I'm not getting any of these errors at compilation. I've checked
> >thrice. Could you please tell what am I doing wrong so that I can
> >avoid introducing errors in future patches?
>
> You need to have CONFIG_LOCKDEP_SUPPORT=y in your kernel .config file.
>
>
Thanks Andreas
It is already set to 'y'. I still do not get any errors. Can there be any
other cause?


> Cheers, Andreas
> --
> Andreas Dilger
>
> Lustre Principal Engineer
> Intel High Performance Data Division
>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151113/d646fb13/attachment.htm>
