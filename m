From: NeilBrown <neilb@suse.com>
Date: Tue, 12 Jun 2018 11:16:26 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <alpine.LFD.2.21.1806120114020.15735@casper.infradead.org>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806120114020.15735@casper.infradead.org>
Message-ID: <87in6okdn9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 12 2018, James Simmons wrote:

>> >> lustre-testing:
>> >>    is based on 'lustre' and has most of my current lustre-related work.
>> >>    It includes assorted patches that are not specifically for lustre
>> >>    (rhashtables mostly at the moment).  Patches will move from here
>> >>    to 'lustre' or to mainline when they are ready.
>> >>    I plan to update this branch on most days that I work on Lustre,
>> >>    and expect it to rebase frequently.
>> >
>> > I had question about that. Some things in Lustre could in theory be merged
>> > into the linux kernel proper. Can that be done still?
>> 
>> What things?
>> 
>> If it measurably benefits the kernel proper, then I suspect it might be
>> worth submitting.  Things can go direct without going though staging -
>> they just have to be of good quality with good justification (and
>> sometimes lots of patience).
>
> One piece of work done for Lustre was the ability to submit "units" like
> K, M, G for sizes to sysfs files. This was developed before string helpers
> was created and the code for Lustre is well very ugly. So I rewrote it
> in the style of string helpers and it can be handly for other things as 
> well such as module parameters setting.

I cannot work out what we might need beyond string_helpers, and I cannot
find any code in lustre that might be what you are referring to.  But I
agree that making it easy to use unit in sysfs is probably a generally
good idea.

>                                         Lustre does have certain features
> in it debugging system that can applied to the linux kernel debugging
> system. That is more down the road. Their are few others like the crypto
> wrapper for alder. I don't see why that can't be mainstream.

I have wondered why crypto-adler isn't in the main crypto library.  I
understand that it is weak and deprecated, but I doubt that is a reason
to keep the code out.  Maybe we should just try to submit it.

>  
>> >  
>> >> I'm happy to review and, if acceptable, apply patches from other
>> >> developers.  I have fairly high standards, but if I don't accept your
>> >> patch I'll explain why and possible help fix it.
>> >
>> > Also long as you talk to me :-) I'm an easy person to work with. If I 
>> > refuse a patch with do the same. I might sometimes seem irrational 
>> > but I have valid reasons. Well at least in my head.
>> >
>> > We need to really layout the roadmap.
>> 
>> I have very little faith in road maps - I prefer to make steps.  Once we
>> have made all the steps, we can look back and see what the map looked
>> like in retrospect.
>
> I was looking to see what you plan to work on. I wanted to avoid 
> duplicating work. Some things I know of done already are listed under:

Providing that we regularly talk about what we are doing I think the
chance of duplication is fairly low, and I don't think the cost of
duplication is very high.  If we've both worked of doing X, then we
should each be able to review the work of the other quite quickly.

My current focus is cleaning up the build (reducing modules and
exports), renaming files (removing 'linux' from various names),
and removing unused cruft from include files (files named *compat.h are
next).
I then want to gain a more complete understanding of LNet.

>
> https://jira.hpdd.intel.com/browse/LU-9855

I had thought about attacking this, but it isn't on my current
shortlist.  I'll let you know if it gets near the top.

> https://jira.hpdd.intel.com/browse/LU-10257

I don't really know what this is about.  I think it is a much deeper
clean-up than the superficial stuff I've been focusing on.
If I read correctly, this has already been addressed in legacy-lustre.
In that case I probably would only get to it when I start going through
the git log locking for things to migrate to linux-lustre.

> https://jira.hpdd.intel.com/browse/LU-10994

This is even less on my radar than the above.

I suggest you feel free to do whatever seems suitable without worrying
if I'm already working there - but do report results and request review
often, even if you aren't completely happy yet.
If I ever find you working on something that I've started, I'll quietly
hide my work and just use the knowledge gained to provide insightful
review of you work.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180612/25c68dd0/attachment.sig>
