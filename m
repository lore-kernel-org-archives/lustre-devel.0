From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Sat, 18 Oct 2008 14:34:54 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <41338A16-5CFA-4979-BD68-35FE8D80455A@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<200810171207.16313.alexander.zarochentsev@sun.com>
	<41338A16-5CFA-4979-BD68-35FE8D80455A@sun.com>
Message-ID: <200810181434.54745.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 18 October 2008 00:55:03 Robert Read wrote:
> On Oct 17, 2008, at 01:07 , Alexander Zarochentsev wrote:
> > The massive create tests shows the following results:
> >
> > COS=1
> > Rate: 2085.73 creates/sec (total: 2 threads 625719 creates 300
> > secs) Rate: 2072.38 creates/sec (total: 2 threads 621713 creates
> > 300 secs) Rate: 2053.80 creates/sec (total: 2 threads 616141
> > creates 300 secs)
> >
> > COS=0
> > Rate: 2128.22 creates/sec (total: 2 threads 638465 creates 300
> > secs) Rate: 2151.05 creates/sec (total: 2 threads 645316 creates
> > 300 secs) Rate: 2169.91 creates/sec (total: 2 threads 650974
> > creates 300 secs)
> >
> > Clean HEAD
> >
> > Rate: 2199.67 creates/sec (total: 2 threads 659900 creates 300
> > secs) Rate: 2213.95 creates/sec (total: 2 threads 664184 creates
> > 300 secs) Rate: 2186.74 creates/sec (total: 2 threads 658209
> > creates 301 secs) Rate: 2206.10 creates/sec (total: 2 threads
> > 661831 creates 300 secs) Rate: 2217.49 creates/sec (total: 2
> > threads 665247 creates 300 secs) Rate: 2230.86 creates/sec (total:
> > 2 threads 669258 creates 300 secs)
>
> Any idea why COS=0 was consistently a bit slower than HEAD?

I only suspect the ENTRY/EXIT stuff I added to several ptlrpc functions.
next time I will try to build Lustre with CDEBUG_ENTRY_EXIT=0.

> robert

The latest results I got after increasing of ldlm resource
hashtable size are:

zam at lts-head:~$ zgrep Rate: m-ht-improved-WASHIE3.4-20081017.log

COS = 1
Rate: 1887.57 creates/sec (total: 2 threads 566271 creates 300 secs)
Rate: 1980.18 creates/sec (total: 2 threads 594053 creates 300 secs)
Rate: 1923.76 creates/sec (total: 2 threads 577129 creates 300 secs)

COS = 0
Rate: 1804.92 creates/sec (total: 2 threads 541475 creates 300 secs)
Rate: 1915.29 creates/sec (total: 2 threads 574587 creates 300 secs)
Rate: 2025.70 creates/sec (total: 2 threads 607711 creates 300 secs)


CLEAN HEAD:
zam at lts-head:~$ zgrep Rate: m-cleanhead-WASHIE3.4-20081017.log
Rate: 1986.13 creates/sec (total: 2 threads 595839 creates 300 secs)
Rate: 2009.84 creates/sec (total: 2 threads 602952 creates 300 secs)
Rate: 1887.05 creates/sec (total: 2 threads 566115 creates 300 secs)
Rate: 2060.59 creates/sec (total: 2 threads 618178 creates 300 secs)
Rate: 1868.89 creates/sec (total: 2 threads 560666 creates 300 secs)
Rate: 1976.95 creates/sec (total: 2 threads 594084 creates 301 secs)
zam at lts-head:~$

average values:

COS=1 : 1930.5
COS=0 : 1915.3
HEAD  : 1964.9

The results are done on another test cluster 
so they are not directly comparable with the previous ones.

The profiling chart for COS=1, there is no ldlm_resource_find anymore in top20:

198152    2.9052  e1000.ko                 e1000                    e1000_irq_enable
158535    2.3243  e1000.ko                 e1000                    e1000_intr_msi
152375    2.2340  vmlinux                  vmlinux                  schedule
148709    2.1803  obdclass.ko              obdclass                 htable_lookup
109440    1.6045  lvfs.ko                  lvfs                     lprocfs_counter_add
102773    1.5068  vmlinux                  vmlinux                  __switch_to
95607     1.4017  vmlinux                  vmlinux                  __find_get_block
90447     1.3261  vmlinux                  vmlinux                  kfree
88713     1.3006  vmlinux                  vmlinux                  mwait_idle
84511     1.2390  vmlinux                  vmlinux                  try_to_wake_up
83801     1.2286  vmlinux                  vmlinux                  memset
79735     1.1690  vmlinux                  vmlinux                  __kmalloc
78594     1.1523  oprofiled                oprofiled                (no symbols)
71184     1.0437  ksocklnd.ko              ksocklnd                 ksocknal_scheduler
65613     0.9620  vmlinux                  vmlinux                  kmem_cache_free
64525     0.9460  mds.ko                   mds                      mds_lov_dump_objids
64208     0.9414  ptlrpc.ko                ptlrpc                   ptlrpc_main
63260     0.9275  vmlinux                  vmlinux                  memmove
56148     0.8232  vmlinux                  vmlinux                  find_get_page
55011     0.8065  vmlinux                  vmlinux                  kmem_cache_alloc

I attached all performance enhancement patches 
(except the latest patch of ldlm resource hash table size increase) 
to the COS bug (Bug 15393).

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
