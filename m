From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Sat, 31 May 2008 18:19:04 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18497.31373.726995.583695@gargle.gargle.HOWL>
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
Message-ID: <1212254344.21348.116.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On S?b, 2008-05-31 at 20:19 +0400, Nikita Danilov wrote:

> I meant a counter of bytes or blocks that this object occupies for the
> quota purposes. I specifically don't want to identify `space usage' with
> st_blocks, because for the modern file systems there is no _the_ way to
> define what to include into quota: users want quota to be consistent
> with both df(1) and du(1) and in the presence of features like snapshots
> this is not generally possible.


I think dnode_phys_t->dn_used can be used for this, because AFAICS it
keeps track of allocated space referenced by the active filesystem (in
other words, it does not include space which is referenced only by
snapshots).

I am assuming snapshots should not have any effect on quotas, right?


>  > group N+1 may already be quiescing. This presents a challenge because if
>  > the machines crashes, you may lose data in 2 transaction groups, not
>  > just 1, which I think would make things harder to recover..
> 
> Won't it be enough to record in the pending list object from two last
> transaction groups, if necessary?


Hmm.. I think so, but I think we should not rely on this always being 2,
I think we should allow the list to have an unbounded size, and let the
commit callbacks notify when an entry can be pruned from the list.


> But we don't have to, if we make ->space_usage() idempotent, i.e.,
> taking an absolute space usage as a last argument, rather than delta. In
> that case, DMU is free to call it multiple times, and client has to cope
> with this. (Hmm... I am pretty sure this is what I was thinking about
> when composing previous message, but confusing signed __s64 delta
> somehow got in, sorry.)


Ok, that clears my previous concern.
But in this case, how do you know how much you need to add or subtract
to a quota when an object changes size?
I am guessing that you'd need to at least write the previous object size
as part of the pending list, so that when you're recovering you'd know
the delta..

Heh, to me this whole thing sounds quite complicated to get right, but I
think it could work (but of course, fine-grained hard quotas is another
matter altogether..)..


>  > And furthermore, I think this kind of recovery could be better
>  > implemented using commit callbacks, which is an abstraction already
>  > designed for recovery purposes and which is backend-agnostic.
> 
> Sounds interesting, can you elaborate on this?


I was thinking that commit callbacks could be used by the DMU consumer
to solve this problem instead of having an internal DMU list/log, and I
guess you've already figured out how that could be done :)

Cheers,
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/18819888/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080531/18819888/attachment.gif>
