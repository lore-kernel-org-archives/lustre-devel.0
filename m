From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Fri, 17 Oct 2008 12:07:15 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <48F36393.9020406@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<200810131836.37447.alexander.zarochentsev@sun.com>
	<48F36393.9020406@sun.com>
Message-ID: <200810171207.16313.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 13 October 2008 19:04:51 Alex Zhuravlev wrote:
> cool! do you have profile with COS disabled? how is it different?
> I guess ldlm_resorce_find() is result of COS as now we've got 10K
> times more locks and resorces, but what about try_to_wake_up() and
> __wake_up_common() ?

What I got after number of performance optimizations:

332019    4.4010  ptlrpc.ko                ptlrpc                   ldlm_resource_find
190465    2.5247  obdclass.ko              obdclass                 htable_lookup
175260    2.3231  e1000.ko                 e1000                    e1000_irq_enable
146324    1.9396  vmlinux                  vmlinux                  schedule
139799    1.8531  e1000.ko                 e1000                    e1000_intr_msi
121729    1.6136  lvfs.ko                  lvfs                     lprocfs_counter_add
105164    1.3940  vmlinux                  vmlinux                  __find_get_block
102296    1.3560  vmlinux                  vmlinux                  memset
96728     1.2822  vmlinux                  vmlinux                  __switch_to
92123     1.2211  vmlinux                  vmlinux                  kfree
90847     1.2042  oprofiled                oprofiled                (no symbols)
84152     1.1155  vmlinux                  vmlinux                  mwait_idle
82378     1.0919  vmlinux                  vmlinux                  __kmalloc
80368     1.0653  vmlinux                  vmlinux                  try_to_wake_up
79110     1.0486  mds.ko                   mds                      mds_lov_dump_objids
71730     0.9508  vmlinux                  vmlinux                  memmove


The ptlrpc_server_handle_reply has gone due to per-reply spin lock implemented,
no try_to_wake_up due to dedicated reply handling threads,
there is only ldlm_resource_find and htable_lookup left, I hope to fix that with the next patch.

The massive create tests shows the following results:

COS=1
Rate: 2085.73 creates/sec (total: 2 threads 625719 creates 300 secs)
Rate: 2072.38 creates/sec (total: 2 threads 621713 creates 300 secs)
Rate: 2053.80 creates/sec (total: 2 threads 616141 creates 300 secs)

COS=0
Rate: 2128.22 creates/sec (total: 2 threads 638465 creates 300 secs)
Rate: 2151.05 creates/sec (total: 2 threads 645316 creates 300 secs)
Rate: 2169.91 creates/sec (total: 2 threads 650974 creates 300 secs)

Clean HEAD

Rate: 2199.67 creates/sec (total: 2 threads 659900 creates 300 secs)
Rate: 2213.95 creates/sec (total: 2 threads 664184 creates 300 secs)
Rate: 2186.74 creates/sec (total: 2 threads 658209 creates 301 secs)
Rate: 2206.10 creates/sec (total: 2 threads 661831 creates 300 secs)
Rate: 2217.49 creates/sec (total: 2 threads 665247 creates 300 secs)
Rate: 2230.86 creates/sec (total: 2 threads 669258 creates 300 secs)

WBR,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
