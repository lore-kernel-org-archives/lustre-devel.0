From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Sat, 31 May 2008 20:19:25 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1212247447.21348.70.camel@localhost>
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
Message-ID: <18497.31373.726995.583695@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:
 > Hi Nikita,

Hello,

(I reordered some of the comments below.)

 > Currently, the space reported by st_blocks is calculated from
 > dnode_phys_t->dn_used, which in recent SPA versions tracks the number of
 > allocated bytes (not blocks) of a DMU object, which is accurate up to
 > the last committed txg.
 > Is this what you mean by "space usage"?

I meant a counter of bytes or blocks that this object occupies for the
quota purposes. I specifically don't want to identify `space usage' with
st_blocks, because for the modern file systems there is no _the_ way to
define what to include into quota: users want quota to be consistent
with both df(1) and du(1) and in the presence of features like snapshots
this is not generally possible.

 > What do you mean by mount? Do you mean when starting an OST?

Yes, OST or MDT.

 > First of all, I think you would need to keep track of objects changed in
 > the last 2 synced transaction groups, not just the last one. The reason

Indeed, I omitted this for the sake of clarity.

 > group N+1 may already be quiescing. This presents a challenge because if
 > the machines crashes, you may lose data in 2 transaction groups, not
 > just 1, which I think would make things harder to recover..

Won't it be enough to record in the pending list object from two last
transaction groups, if necessary?

 > 
 > Another problem it this: let's say the DMU is syncing a transaction
 > group, and starts calling ->space_usage() for objects. Now the machine
 > crashes, and comes up again.
 > Now how do you distinguish between which objects were called
 > ->space_usage() in the transaction group that was syncing and which
 > weren't (or how would you differentiate between ->space_usage() calls of

But we don't have to, if we make ->space_usage() idempotent, i.e.,
taking an absolute space usage as a last argument, rather than delta. In
that case, DMU is free to call it multiple times, and client has to cope
with this. (Hmm... I am pretty sure this is what I was thinking about
when composing previous message, but confusing signed __s64 delta
somehow got in, sorry.)

 > >     - dmu internally updates space usage information in the context of
 > >       transaction being synced.
 > 
 > 
 > This is being done per-object already.

Aha, this simplifies the whole story significantly. If dmu already
maintains for every object a space usage counter that is suitable for
the quota, then `pending list' can be maintained by dmu client, without
any additional support from dmu:

    - when (as a part of open transaction), client does an operation
      that can potentially modify space usage it adds object identifier
      into pending list, implemented as a normal dmu object;

    - when disk space is actually allocated (transaction group is in
      sync mode), client gets ->space_usage() call-back as above;

    - on a `mount' client scans pending list object, fetches space usage
      from the dmu, updates client's internal data-structures, and
      prunes the pending list.

Of course, again, pending log has to keep track of objects modified in
the last 2 transaction groups.

With the help of commit call-back even ->space_usage() seems
unnecessary, because on a commit time client can scan pending list (in
memory). Heh, it seems that the quota can be implemented completely
outside of the dmu.

 > 
 > And furthermore, I think this kind of recovery could be better
 > implemented using commit callbacks, which is an abstraction already
 > designed for recovery purposes and which is backend-agnostic.

Sounds interesting, can you elaborate on this?

 > Perhaps I am making concentrating too much on correctness.. maybe going
 > over a quota is not too big of a deal, I remember some conversations
 > between Andreas and the ZFS team which implied that not having 100%
 > correctness is not too big of a problem. ???However, I am not so sure
 > about grants.. :/

It's my impression too that the agreement was to sacrifice some degree
of correctness to simplify implementation.

 > 
 > Regards,
 > Ricardo

Nikita.
