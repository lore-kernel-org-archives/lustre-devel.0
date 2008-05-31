From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Sat, 31 May 2008 23:11:34 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1212254344.21348.116.camel@localhost>
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
	<1212247447.21348.70.camel@localhost>
	<18497.31373.726995.583695@gargle.gargle.HOWL>
	<1212254344.21348.116.camel@localhost>
Message-ID: <18497.41702.75481.956514@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:

 > I am assuming snapshots should not have any effect on quotas, right?

That's the problem: on the one hand, users want to use quota to control
actual disk usage, e.g., to not run out of disk space. For this, one
wants to include snapshots into quota. On the other hand, space in
snapshots is not easily reclaimable, which is not very convenient,
because user might be without a way to clean up space. Note that this
situation is possible without snapshots: other user can hard-link your
file from a directory to which you have no access.

 > 
 > Hmm.. I think so, but I think we should not rely on this always being 2,
 > I think we should allow the list to have an unbounded size, and let the
 > commit callbacks notify when an entry can be pruned from the list.

Right.

 > > But we don't have to, if we make ->space_usage() idempotent, i.e.,
 > > taking an absolute space usage as a last argument, rather than delta. In
 > > that case, DMU is free to call it multiple times, and client has to cope
 > > with this. (Hmm... I am pretty sure this is what I was thinking about
 > > when composing previous message, but confusing signed __s64 delta
 > > somehow got in, sorry.)
 > 
 > 
 > Ok, that clears my previous concern.
 > But in this case, how do you know how much you need to add or subtract
 > to a quota when an object changes size?
 > I am guessing that you'd need to at least write the previous object size
 > as part of the pending list, so that when you're recovering you'd know
 > the delta..

Yes, something similar to what data-bases do for redo logging, where the
same log entry can be replayed multiple times.

 > 
 > Cheers,
 > Ricardo
 > --

Nikita.
