From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Sat, 31 May 2008 16:31:19 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18496.11672.844774.815457@gargle.gargle.HOWL>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
	<18493.34513.370736.111492@gargle.gargle.HOWL>
	<1211994338.14599.24.camel@localhost>
	<18493.47971.504225.694251@gargle.gargle.HOWL>
	<1212008833.14599.84.camel@localhost>
	<18493.51834.832400.315440@gargle.gargle.HOWL>
	<1212010408.14599.105.camel@localhost>
	<18494.27609.986096.752687@gargle.gargle.HOWL>
	<18496.11672.844774.815457@gargle.gargle.HOWL>
Message-ID: <1212247880.21348.73.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nikita,

On Sex, 2008-05-30 at 20:38 +0400, Nikita Danilov wrote: 

> What about the following:
> 
>     - dmu tracks per-object `space usage', in addition to usual block
>       count as reported by st_blocks.


Currently, the space reported by st_blocks is calculated from
dnode_phys_t->dn_used, which in recent SPA versions tracks the number of
allocated bytes (not blocks) of a DMU object, which is accurate up to
the last committed txg.
Is this what you mean by "space usage"?


> - when space is actually allocated during transaction sync, dmu
>       notifies its user about changes in space usage by invoking some
> 
>           void (*space_usage)(objset_t *os, __u64 objid, __s64 delta);
> 
>       call-back, registered by user.


Ok. 



> - user updates its data-structures in the context of the currently
>       open transaction.


Ok.


> - dmu internally updates space usage information in the context of
>       transaction being synced.


This is being done per-object already.


> - it also records a list (let's call this "pending list") of all
>       object whose space allocation changed in the context of the same
>       transaction.



Ok, this is where I am starting not to like.. :) 



> - after a mount, dmu calls ->space_usage() against all objects in
>       the pending lists of last committed transaction group, to update
>       client's data-structures that are possibly stale due to the loss
> 
>       of next transaction group.


What do you mean by mount? Do you mean when starting an OST?


> Do you think that might work?


?If I understood correctly, the pending list you propose sounds like a
recovery mechanism (similar to a log) which I don't think is the right
way to implement this.

First of all, I think you would need to keep track of objects changed in
the last 2 synced transaction groups, not just the last one. The reason
is that when the DMU is syncing transaction group N, it is likely that
you can only be writing to transaction group N+2, because transaction
group N+1 may already be quiescing. This presents a challenge because if
the machines crashes, you may lose data in 2 transaction groups, not
just 1, which I think would make things harder to recover..

Another problem it this: let's say the DMU is syncing a transaction
group, and starts calling ->space_usage() for objects. Now the machine
crashes, and comes up again.
Now how do you distinguish between which objects were called
->space_usage() in the transaction group that was syncing and which
weren't (or how would you differentiate between ->space_usage() calls of
txg N and those of txg N+1)? At a minimum, you would need a txg
parameter in ->space_usage(), which again is leaking a bit internal
knowledge of how the DMU works outside the DMU (and which we may not
assume will always work the same way in future versions).

?Another thing that comes to mind is that the pending list is something
very problem-specific and that would only be useful for Lustre, not
other consumers, so the ZFS team may object to this..
For example, for implementing uid/gid quotas in ZFS, there is no need
for such a mechanism..

And furthermore, I think this kind of recovery could be better
implemented using commit callbacks, which is an abstraction already
designed for recovery purposes and which is backend-agnostic.

Ok, now stepping outside of the pending list (which I may have not
understood the purpose correctly at all :-), I think implementing quotas
in ZFS is harder that it may look at first sight.

For example, let's say you have 1 MB of quota left. How do you determine
how much data you can write before the quota runs out?
This may shock you, but depending on the pool configuration, filesystem
properties and object block size, writing 1 MB of file data can take
anywhere from exactly 0 bytes to 9.25 MB of allocated space (!!).

Now let's scale this up and imagine you have 1 GB of quota left, and you
write 1 GB of data (and you do this sufficiently fast enough). In the
worst case scenario, you could end up going 8.25 GB over the limit,
which goes against any possible wish of having fine-grained quotas.. :-)

BTW, this reminds me to that I am almost sure our uOSS grants code is
wrong (I have not been assigned as an inspector, so I can't say how bad
it is..).

Perhaps I am making concentrating too much on correctness.. maybe going
over a quota is not too big of a deal, I remember some conversations
between Andreas and the ZFS team which implied that not having 100%
correctness is not too big of a problem. ?However, I am not so sure
about grants.. :/

Regards,
Ricardo

--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/cd2f9f1f/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/cd2f9f1f/attachment.gif>
