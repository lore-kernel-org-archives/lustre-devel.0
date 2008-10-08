From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 08 Oct 2008 15:48:50 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <200810081544.08292.alexander.zarochentsev@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
Message-ID: <48EC9E22.2090403@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

try to profile with single CPU? you'll probably get an idea how "per-cpu"
approach can help.

thanks, Alex

Alexander Zarochentsev wrote:
> I have a patch to avoid using of obd_uncommitted_replies_lock 
> in ptlrpc_server_handle_reply but it has minimal effect, 
> ptlrpc_server_handle_reply still the most cpu consuming function
> because of svc->srv_lock contention.
> 
> I think the problem is that COS defers processing of replies to transaction commit time.
> When commit happens, MDS has to process thousands of replies (about 14k replies per
> commit in the test 3.a) in short period of time. I guess the mdt service threads 
> all woken up and spin trying to get the service svr_lock. Processing of new requests may
> also suffer of this.
> 
> I ran the tests with with CONFIG_DEBUG_SPINLOCK_SLEEP debugging compiled into a kernel, it found no
> sleep under spinlock bugs.
> 
> Further optimization may include 
> 1. per-reply spin locks.
> 2. per-cpu structures and threads to process reply queues.
> 
> Any comments?
> 
> Thanks.
> 
> PS. the test results are much better when MDS server is sata20 machine with 4 cores
> (the MDS from Washie1 has 2 cores), COS=0 and COS=1 have only %3 difference:
> 
> COS=1
> Rate: 3101.77 creates/sec (total: 2 threads 930530 creates 300 secs)
> Rate: 3096.94 creates/sec (total: 2 threads 929083 creates 300 secs)
> 
> COS=0
> Rate: 3184.01 creates/sec (total: 2 threads 958388 creates 301 secs)
> Rate: 3152.89 creates/sec (total: 2 threads 945868 creates 300 secs)
> 
