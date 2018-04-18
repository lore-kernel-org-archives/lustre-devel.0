From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 18 Apr 2018 21:56:44 +0000
Subject: [lustre-devel] [PATCH 00/20] staging: lustre: convert to
 rhashtable
In-Reply-To: <87y3hlqk3w.fsf@notabene.neil.brown.name>
References: <152348312863.12394.11915752362061083241.stgit@noble>
 <alpine.LFD.2.21.1804170429300.14398@casper.infradead.org>,
 <87y3hlqk3w.fsf@notabene.neil.brown.name>
Message-ID: <1524088604572.29145@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


>>> libcfs in lustre has a resizeable hashtable.
>>> Linux already has a resizeable hashtable, rhashtable, which is better
>>> is most metrics. See https://lwn.net/Articles/751374/ in a few days
>>> for an introduction to rhashtable.
>>
>> Thansk for starting this work. I was think about cleaning the libcfs
>> hash but your port to rhashtables is way better. How did you gather
>> metrics to see that rhashtable was better than libcfs hash?
>
>Code inspection and reputation.  It is hard to beat inlined lockless
>code for lookups.  And rhashtable is heavily used in the network
>subsystem and they are very focused on latency there.  I'm not sure that
>insertion is as fast as it can be (I have some thoughts on that) but I'm
>sure lookup will be better.
>I haven't done any performance testing myself, only correctness.

Sorry this email never reached my infradead account so I'm replying
from my work account.  I was just wondering if numbers were gathered.
I'm curious how well this would scale on some HPC cluster. In any case
I can do a comparison with and without the patches on one of my test
clusters and share the numbers with you using real world work loads.

>>> This series converts lustre to use rhashtable.  This affects several
>>> different tables, and each is different is various ways.
>>>
>>> There are two outstanding issues.  One is that a bug in rhashtable
>>> means that we cannot enable auto-shrinking in one of the tables.  That
>>> is documented as appropriate and should be fixed soon.
>>>
>>> The other is that rhashtable has an atomic_t which counts the elements
>>> in a hash table.  At least one table in lustre went to some trouble to
>>> avoid any table-wide atomics, so that could lead to a regression.
>>> I'm hoping that rhashtable can be enhanced with the option of a
>>> per-cpu counter, or similar.
>>>
>>
>> This doesn't sound quite ready to land just yet. This will have to do some
>> soak testing and a larger scope of test to make sure no new regressions
>> happen. Believe me I did work to make lustre work better on tickless
>> systems, which I'm preparing for the linux client, and small changes could
>> break things in interesting ways. I will port the rhashtable change to the
>> Intel developement branch and get people more familar with the hash code
>> to look at it.
>
>Whether it is "ready" or not probably depends on perspective and
>priorities.  As I see it, getting lustre cleaned up and out of staging
>is a fairly high priority, and it will require a lot of code change.
>It is inevitable that regressions will slip in (some already have) and
>it is important to keep testing (the test suite is of great benefit, but
>is only part of the story of course).  But to test the code, it needs to
>land.  Testing the code in Intel's devel branch and then porting it
>across doesn't really prove much.  For testing to be meaningful, it
>needs to be tested in a branch that up-to-date with mainline and on
>track to be merged into mainline.
>
>I have no particular desire to rush this in, but I don't see any
>particular benefit in delaying it either.
>
>I guess I see staging as implicitly a 'devel' branch.  You seem to be
>treating it a bit like a 'stable' branch - is that right?

So two years ago no one would touch the linux Lustre client due to it
being so broken. Then after about a year of work the client got into 
sort of working state. Even to the point actual sites are using it. 
It still is  broken and guess who gets notified of the brokenness :-)  
The good news is that people do actually test it but if it regress to much
we will lose our testing audience. Sadly its a chicken and egg problem. Yes I
want to see it leave staging but I like the Lustre client to be in good working
order. If it leaves staging still broken and no one uses it then their is not
much point. 

So to understand why I work with the Intel development branch and linux 
kernel version I need to explain my test setup.  So I test at different levels.

At level one I have my generic x86 nodes and x86 server back ends. Pretty
vanilla and the scale is pretty small. 3 servers nodes and a couple of clients.
In the environment I can easily test the upstream client. This is not VMs but
real hardware and real storage back end.

Besides x86 client nodes for level one testing I also have Power9 ppc nodes.
Also its possible for me to test the upstream client directly. In case you want to
know nope lustre doesn't work out of the box for Power9. The IB stack needs
fixing and we need to handle 64K pages at the LNet layer. I have work that
resolves those issues. The fixes need to be pushed upstream.

Next I have an ARM client cluster to test with which runs a newer kernel that 
is "offical".  When we first got the cluster I stomped all over it but discovered
I had to share it and the other parties involved were not to happy with my 
experimenting. The ARM system had the same issues as the Power9 so
now it works. Once the upstream client is in better shape I think I could
subject the other users of the system to try it out. I have been told the ARM
vendor has a strong interest in the linux lustre client as well.

Once I'm done with that testing I moved to my personal Cray test cluster.
Sadly Cray has unique hardware so if I use the latest vanilla upstream kernel
that unique hardware no longer works which makes the test bed pretty much
useless. Since I have to work with an older kernel I back port the linux kernel
client work and run test to make sure to works. On that cluster I can run real
HPC work loads.  

Lastly if the work shows itself stable at this point I see if I can put it on a Cray
development system that users at my workplace test on. If the user scream
things are broken then I find out how they break it. General users are very
creative at find ways to break things that we wouldn't think of. 

>I think we have a better chance of being heard if we have "skin in the
>game" and have upstream code that would use this.

I agree. I just want a working base line that users can  work with :-) For me 
landing the rhashtable work is only the beginning. Its behavior at very large scales
needs to be examined to find any potential bottlenecks. 

Which bring me to the next point since this is cross posting to the lustre-devel list.
For me the largest test cluster I can get my hands on is 80 nodes. Would anyone 
be willing to donate test time on their test bed clusters to help out in this work. It would
be really awesome to test on a many thousand node system. I will be at the Lustre
User Group Conference next week so if you want to meet up with me to discuss details
I would love to help you set up your test cluster so we really can exercise these changes.
