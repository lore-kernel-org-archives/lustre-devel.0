From: NeilBrown <neilb@suse.com>
Date: Wed, 18 Apr 2018 13:17:07 +1000
Subject: [lustre-devel] [PATCH 00/20] staging: lustre: convert to
 rhashtable
In-Reply-To: <alpine.LFD.2.21.1804170429300.14398@casper.infradead.org>
References: <152348312863.12394.11915752362061083241.stgit@noble>
 <alpine.LFD.2.21.1804170429300.14398@casper.infradead.org>
Message-ID: <87y3hlqk3w.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Apr 17 2018, James Simmons wrote:

>> libcfs in lustre has a resizeable hashtable.
>> Linux already has a resizeable hashtable, rhashtable, which is better
>> is most metrics. See https://lwn.net/Articles/751374/ in a few days
>> for an introduction to rhashtable.
>
> Thansk for starting this work. I was think about cleaning the libcfs
> hash but your port to rhashtables is way better. How did you gather
> metrics to see that rhashtable was better than libcfs hash?

Code inspection and reputation.  It is hard to beat inlined lockless
code for lookups.  And rhashtable is heavily used in the network
subsystem and they are very focused on latency there.  I'm not sure that
insertion is as fast as it can be (I have some thoughts on that) but I'm
sure lookup will be better.
I haven't done any performance testing myself, only correctness.

>  
>> This series converts lustre to use rhashtable.  This affects several
>> different tables, and each is different is various ways.
>> 
>> There are two outstanding issues.  One is that a bug in rhashtable
>> means that we cannot enable auto-shrinking in one of the tables.  That
>> is documented as appropriate and should be fixed soon.
>> 
>> The other is that rhashtable has an atomic_t which counts the elements
>> in a hash table.  At least one table in lustre went to some trouble to
>> avoid any table-wide atomics, so that could lead to a regression.
>> I'm hoping that rhashtable can be enhanced with the option of a
>> per-cpu counter, or similar.
>> 
>
> This doesn't sound quite ready to land just yet. This will have to do some
> soak testing and a larger scope of test to make sure no new regressions
> happen. Believe me I did work to make lustre work better on tickless 
> systems, which I'm preparing for the linux client, and small changes could 
> break things in interesting ways. I will port the rhashtable change to the 
> Intel developement branch and get people more familar with the hash code
> to look at it.

Whether it is "ready" or not probably depends on perspective and
priorities.  As I see it, getting lustre cleaned up and out of staging
is a fairly high priority, and it will require a lot of code change.
It is inevitable that regressions will slip in (some already have) and
it is important to keep testing (the test suite is of great benefit, but
is only part of the story of course).  But to test the code, it needs to
land.  Testing the code in Intel's devel branch and then porting it
across doesn't really prove much.  For testing to be meaningful, it
needs to be tested in a branch that up-to-date with mainline and on
track to be merged into mainline.

I have no particular desire to rush this in, but I don't see any
particular benefit in delaying it either.

I guess I see staging as implicitly a 'devel' branch.  You seem to be
treating it a bit like a 'stable' branch - is that right?

As mentioned, I think there is room for improvement in rhashtable.
- making the atomic counter optional
- replacing the separate spinlocks with bit-locks in the hash-chain head
  so that the lock and chain are in the same cache line
- for the common case of inserting in an empty chain, a single atomic
  cmpxchg() should be sufficient
I think we have a better chance of being heard if we have "skin in the
game" and have upstream code that would use this.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180418/55db7e31/attachment.sig>
