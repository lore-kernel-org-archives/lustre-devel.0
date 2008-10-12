From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Sun, 12 Oct 2008 22:41:58 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <48EC9E22.2090403@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<48EC9E22.2090403@sun.com>
Message-ID: <200810122241.58982.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 8 October 2008 15:48:50 Alex Zhuravlev wrote:
> try to profile with single CPU? you'll probably get an idea how
> "per-cpu" approach can help.

I booted the MDS server with maxcpus=1 kernel parameter and here are the 
results:

cos=0
2039.31 creates/sec (total: 2 threads 611794 creates 300 secs)
2037.80 creates/sec (total: 2 threads 611341 creates 300 secs)
2076.21 creates/sec (total: 2 threads 622864 creates 300 secs)

cos=1
1874.93 creates/sec (total: 2 threads 564354 creates 301 secs)
1923.97 creates/sec (total: 2 threads 577191 creates 300 secs)
1892.61 creates/sec (total: 2 threads 567783 creates 300 secs)
1874.74 creates/sec (total: 2 threads 562421 creates 300 secs)

unfortunately profiling info isn't available yet, the results are done 
with SLES10 which can boot with maxcpus=1 but has no oprofile 
installed.

> Alexander Zarochentsev wrote:
> > I have a patch to avoid using of obd_uncommitted_replies_lock
> > in ptlrpc_server_handle_reply but it has minimal effect,
> > ptlrpc_server_handle_reply still the most cpu consuming function
> > because of svc->srv_lock contention.
> >
> > I think the problem is that COS defers processing of replies to
> > transaction commit time. When commit happens, MDS has to process
> > thousands of replies (about 14k replies per commit in the test 3.a)
> > in short period of time. I guess the mdt service threads all woken
> > up and spin trying to get the service svr_lock. Processing of new
> > requests may also suffer of this.
> >
> > I ran the tests with with CONFIG_DEBUG_SPINLOCK_SLEEP debugging
> > compiled into a kernel, it found no sleep under spinlock bugs.
> >
> > Further optimization may include
> > 1. per-reply spin locks.
> > 2. per-cpu structures and threads to process reply queues.
> >
> > Any comments?
> >
> > Thanks.
> >
> > PS. the test results are much better when MDS server is sata20
> > machine with 4 cores (the MDS from Washie1 has 2 cores), COS=0 and
> > COS=1 have only %3 difference:
> >
> > COS=1
> > Rate: 3101.77 creates/sec (total: 2 threads 930530 creates 300
> > secs) Rate: 3096.94 creates/sec (total: 2 threads 929083 creates
> > 300 secs)
> >
> > COS=0
> > Rate: 3184.01 creates/sec (total: 2 threads 958388 creates 301
> > secs) Rate: 3152.89 creates/sec (total: 2 threads 945868 creates
> > 300 secs)
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
