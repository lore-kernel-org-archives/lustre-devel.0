From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Mon, 13 Oct 2008 18:36:36 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <48F24C0A.9070301@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<200810122241.58982.alexander.zarochentsev@sun.com>
	<48F24C0A.9070301@sun.com>
Message-ID: <200810131836.37447.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 12 October 2008 23:12:10 Alex Zhuravlev wrote:
> would be good to look at profiles as the next one was
> ldlm_resource_get()

Alex, look, ptlrpc_server_handle_reply has gone:

CPU: P4 / Xeon, speed 2800.25 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped
with a unit mask of 0x01 (mandatory) count
 100000
samples  %        image name               app name                 symbol name
312318    4.7857  vmlinux                  vmlinux                  try_to_wake_up
259690    3.9792  ptlrpc.ko                ptlrpc                   ldlm_resource_find
175916    2.6956  vmlinux                  vmlinux                  __wake_up_common
160912    2.4657  e1000.ko                 e1000                    e1000_irq_enable
157031    2.4062  obdclass.ko              obdclass                 htable_lookup
134309    2.0580  e1000.ko                 e1000                    e1000_intr_msi
121261    1.8581  lvfs.ko                  lvfs                     lprocfs_counter_add
87613     1.3425  vmlinux                  vmlinux                  __find_get_block
87562     1.3417  oprofiled                oprofiled                (no symbols)
77926     1.1941  vmlinux                  vmlinux                  memset
74561     1.1425  vmlinux                  vmlinux                  __kmalloc
70952     1.0872  vmlinux                  vmlinux                  __switch_to
67288     1.0311  mds.ko                   mds                      mds_lov_dump_objids
67085     1.0279  vmlinux                  vmlinux                  memmove
66521     1.0193  vmlinux                  vmlinux                  kfree
55112     0.8445  ptlrpc.ko                ptlrpc                   ptlrpc_main
54357     0.8329  vmlinux                  vmlinux                  schedule
53501     0.8198  vmlinux                  vmlinux                  find_get_page

> thanks, Alex
>
> Alexander Zarochentsev wrote:
> > On 8 October 2008 15:48:50 Alex Zhuravlev wrote:
> >> try to profile with single CPU? you'll probably get an idea how
> >> "per-cpu" approach can help.
> >
> > I booted the MDS server with maxcpus=1 kernel parameter and here
> > are the results:
> >
> > cos=0
> > 2039.31 creates/sec (total: 2 threads 611794 creates 300 secs)
> > 2037.80 creates/sec (total: 2 threads 611341 creates 300 secs)
> > 2076.21 creates/sec (total: 2 threads 622864 creates 300 secs)
> >
> > cos=1
> > 1874.93 creates/sec (total: 2 threads 564354 creates 301 secs)
> > 1923.97 creates/sec (total: 2 threads 577191 creates 300 secs)
> > 1892.61 creates/sec (total: 2 threads 567783 creates 300 secs)
> > 1874.74 creates/sec (total: 2 threads 562421 creates 300 secs)
> >
> > unfortunately profiling info isn't available yet, the results are
> > done with SLES10 which can boot with maxcpus=1 but has no oprofile
> > installed.
> >
> >> Alexander Zarochentsev wrote:
> >>> I have a patch to avoid using of obd_uncommitted_replies_lock
> >>> in ptlrpc_server_handle_reply but it has minimal effect,
> >>> ptlrpc_server_handle_reply still the most cpu consuming function
> >>> because of svc->srv_lock contention.
> >>>
> >>> I think the problem is that COS defers processing of replies to
> >>> transaction commit time. When commit happens, MDS has to process
> >>> thousands of replies (about 14k replies per commit in the test
> >>> 3.a) in short period of time. I guess the mdt service threads all
> >>> woken up and spin trying to get the service svr_lock. Processing
> >>> of new requests may also suffer of this.
> >>>
> >>> I ran the tests with with CONFIG_DEBUG_SPINLOCK_SLEEP debugging
> >>> compiled into a kernel, it found no sleep under spinlock bugs.
> >>>
> >>> Further optimization may include
> >>> 1. per-reply spin locks.
> >>> 2. per-cpu structures and threads to process reply queues.
> >>>
> >>> Any comments?
> >>>
> >>> Thanks.
> >>>
> >>> PS. the test results are much better when MDS server is sata20
> >>> machine with 4 cores (the MDS from Washie1 has 2 cores), COS=0
> >>> and COS=1 have only %3 difference:
> >>>
> >>> COS=1
> >>> Rate: 3101.77 creates/sec (total: 2 threads 930530 creates 300
> >>> secs) Rate: 3096.94 creates/sec (total: 2 threads 929083 creates
> >>> 300 secs)
> >>>
> >>> COS=0
> >>> Rate: 3184.01 creates/sec (total: 2 threads 958388 creates 301
> >>> secs) Rate: 3152.89 creates/sec (total: 2 threads 945868 creates
> >>> 300 secs)
> >>
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
