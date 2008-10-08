From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 08 Oct 2008 10:40:30 +0400
Subject: [Lustre-devel] COS performance issues
Message-ID: <200810081040.31363.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

the cos performance testing made discovered COS performance
problems in tests which were not supposed to be problematic.

The tests are: 
(3a) parallel file creation from several clients, each client creates files in own directory.
(3b) parallel file creation from several clients in one shared directory.

The test results published in Bugzilla bug 17235. The slowdown depends on hardware, for the test clusters
Washie1,3 it is enough big, the difference between COS=0 and COS=1 was about 20%
initially and PTLDEBUG=0 reduces the slowdown to 12-13% (COS patch adds debugging
stuff like ENTRY/EXIT to ptlrpc routines).

COS code finds no inter-client dependencies and adds no extra commits
during those tests, there are about 60 commits in each of 300 seconds tests
with COS=0 and COS=1, one ldiskfs commit in 5 seconds.

However, oprofile results are terrible for COS=1.

COS code profiling results:
== COS=1 ==

376924    4.5556  ptlrpc.ko                ptlrpc                   ptlrpc_server_handle_reply
288668    3.4889  vmlinux                  vmlinux                  .text.task_rq_lock
281528    3.4026  ptlrpc.ko                ptlrpc                   ldlm_resource_find
180107    2.1768  vmlinux                  vmlinux                  .text.__wake_up_common
173166    2.0929  obdclass.ko              obdclass                 htable_lookup
166829    2.0163  e1000e.ko                e1000e                   e1000_irq_enable
150765    1.8222  vmlinux                  vmlinux                  schedule
127059    1.5357  e1000e.ko                e1000e                   e1000_intr_msi
119343    1.4424  ptlrpc.ko                ptlrpc                   target_send_reply
118733    1.4350  lvfs.ko                  lvfs                     lprocfs_counter_add
99568     1.2034  vmlinux                  vmlinux                  __find_get_block
93356     1.1283  vmlinux                  vmlinux                  __switch_to
91259     1.1030  oprofiled                oprofiled                (no symbols)
91147     1.1016  vmlinux                  vmlinux                  try_to_wake_up
89665     1.0837  vmlinux                  vmlinux                  kfree
87774     1.0609  vmlinux                  vmlinux                  module_refcount
85149     1.0291  vmlinux                  vmlinux                  memset
84822     1.0252  vmlinux                  vmlinux                  mwait_idle
78850     0.9530  vmlinux                  vmlinux                  __kmalloc
70324     0.8500  ptlrpc.ko                ptlrpc                   ptlrpc_main
69333     0.8380  vmlinux                  vmlinux                  memmove

== COS=0 ==

237314    2.7642  e1000e.ko                e1000e                   e1000_irq_enable
211304    2.4613  obdclass.ko              obdclass                 htable_lookup
197515    2.3007  vmlinux                  vmlinux                  schedule
180431    2.1017  e1000e.ko                e1000e                   e1000_intr_msi
128113    1.4923  vmlinux                  vmlinux                  __switch_to
127683    1.4873  lvfs.ko                  lvfs                     lprocfs_counter_add
122777    1.4301  vmlinux                  vmlinux                  kfree
122584    1.4279  vmlinux                  vmlinux                  module_refcount
116800    1.3605  vmlinux                  vmlinux                  __find_get_block
110418    1.2862  vmlinux                  vmlinux                  mwait_idle
101909    1.1870  vmlinux                  vmlinux                  memset
101100    1.1776  oprofiled                oprofiled                (no symbols)
96397     1.1228  vmlinux                  vmlinux                  __kmalloc
91745     1.0686  ptlrpc.ko                ptlrpc                   ptlrpc_main
80605     0.9389  ksocklnd.ko              ksocklnd                 ksocknal_scheduler
79782     0.9293  vmlinux                  vmlinux                  kmem_cache_free
76968     0.8965  mds.ko                   mds                      mds_lov_dump_objids
75094     0.8747  vmlinux                  vmlinux                  .text.task_rq_lock
75087     0.8746  vmlinux                  vmlinux                  memmove
72627     0.8460  vmlinux                  vmlinux                  find_get_page
67242     0.7832  vmlinux                  vmlinux                  kmem_cache_alloc

== events distribution in ptlrpc_server_handle_reply, the most cpu consuming function ==

CPU: P4 / Xeon, speed 2800.2 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped)
with a unit mask of 0x01 (mandatory) count 100000

vma      samples  %        image name               app name                 symbol name
00000000000498f0 376924    4.5556  ptlrpc.ko                ptlrpc                   ptlrpc_server_handle_reply
  00000000000498f0 1        2.7e-04
  00000000000498f4 10        0.0027
  0000000000049905 3        8.0e-04
  0000000000049912 22        0.0058
  0000000000049972 1        2.7e-04
  0000000000049977 658       0.1746
  000000000004997e 24        0.0064
  0000000000049a23 5         0.0013
  0000000000049a35 21        0.0056
  0000000000049a80 1        2.7e-04
  0000000000049a85 4         0.0011
  0000000000049a92 2        5.3e-04
  0000000000049a99 22        0.0058
  0000000000049aa9 1        2.7e-04
  0000000000049ab5 371741   98.6249
  ...              ^^^^^^   spin_lock (&obd->obd_uncommitted_replies_lock);

I have a patch to avoid using of obd_uncommitted_replies_lock 
in ptlrpc_server_handle_reply but it has minimal effect, 
ptlrpc_server_handle_reply still the most cpu consuming function
because of svc->srv_lock contention.

I think the problem is that COS defers processing of replies to transaction commit time.
When commit happens, MDS has to process thousands of replies (about 14k replies per
commit in the test 3.a) in short period of time. I guess the mdt service threads 
all woken up and spin trying to get the service svr_lock. Processing of new requests may
also suffer of this.

I ran the tests with with CONFIG_DEBUG_SPINLOCK_SLEEP debugging compiled into a kernel, it found no
sleep under spinlock bugs.

Further optimization may include 
1. per-reply spin locks.
2. per-cpu structures and threads to process reply queues.

Any comments?

Thanks.

PS. the test results are much better when MDS server is sata20 machine with 4 cores
(the MDS from Washie1 has 2 cores), COS=0 and COS=1 have only %3 difference:

COS=1
Rate: 3101.77 creates/sec (total: 2 threads 930530 creates 300 secs)
Rate: 3096.94 creates/sec (total: 2 threads 929083 creates 300 secs)

COS=0
Rate: 3184.01 creates/sec (total: 2 threads 958388 creates 301 secs)
Rate: 3152.89 creates/sec (total: 2 threads 945868 creates 300 secs)

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
