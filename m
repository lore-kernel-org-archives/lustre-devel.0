From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 7 Jun 2018 23:06:23 +0000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <87h8memg4k.fsf@notabene.neil.brown.name>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
 <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
 <87h8memg4k.fsf@notabene.neil.brown.name>
Message-ID: <C50F2EA9-AD25-480A-8A05-2541206BA17F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 7, 2018, at 15:38, NeilBrown <neilb@suse.com> wrote:
> 
> On Thu, Jun 07 2018, Doug Oucharek wrote:
> 
>> What is the focus of landings in this tree?  There are two things needing to be done for an upstream Lustre:
>> 
>> 
>>  *   Get the source code to meet the Linux guidelines so it is acceptable to be in mainline.
>>  *   Get the binary product to have all the features and bug fixes that are in the Intel community tree so end users are interested in using the upstream version (users are unlikely to use a version of Lustre which is not current).
>> 
>> For the now-deleted staging area, we were supposed to be focusing on the first item but were submitting patches for the second item (syncing with Intel tree).  In my opinion, this is the core reason for never being able to get out of staging and getting deleted.
> 
> My (undoubtedly biased) perspective on the history of lustre in staging
> goes like this:
> There are two things needed for some out-of-tree code to get into
> mainline Linux:  the code needs to be integrated and the community needs
> to be integrated (or a new sub-community needs to form).
> In the case of lustre, the code was never really integrated because the
> community never really tried to integrate.

One of the issues here was that the group (not Intel) that submitted the
Lustre code to the staging tree promptly abandoned it for a couple of
years after they submitted it upstream, after promising the community
that they were in it for the long run.  That put the upstream integration
behind the eight-ball from the start.

>  Integrating and becoming
> part of the Linux community takes time and effort, and it is quite
> possible that management for various developers didn't allocate enough
> time over a long enough period.  Integrating also requires a change in
> attitude and I don't see much evidence of that.  I see clear evidence of
> an "us and them" attitude among (some) lustre developers - almost as
> though upstream linux is hostile territory full of unfriendly developers

Ah, but it *is* hostile territory, if you are not among the "in crowd".
Christoph can get any change he wants to be accepted, but if someone else
tries to push something similar it can be rejected outright or ignored
for months or years.

> who always reject our excellent code (even though they have lots of
> horrible code themselves).  *We* need to see ourselves as part of the
> Linux community, and we need to care about all of Linux as though it was
> all ours (it *is* all ours, but *we* are a much larger group now).
> 
> Yes, the current code needs to be improved, bugs need to be fixed, and
> features need to be added.  The order in which these is done is not the
> most important things - if it were, Greg would have never accepted any
> new features.  However he *did* accept them, but tried to remind the
> lustre developers that there was other work to do.
> 
> Working together in one (single) community requires give-and-take.
> Greg's behaviour as just described seems to be evidence of
> give-and-take.  I think he kicked lustre out of staging because he
> concluded that he was never going to get the matching give-and-take in
> return.
> 
> So to answer your opening question, my focus for this tree is to train
> any lustre developers who wish to engage about how to be part of the
> Linux community.  As I've already said - I will accept features but I
> prefer cleanups first.  I don't want to try to explain further than that
> because it will be too hypothetical and unhelpful.  We - the Linux
> community - don't work in hypotheticals.  We work with concrete objects
> like patches.  So send me a patch and I will tell you what I think of
> that specific patch.  It is up to you to generalise what I say to other
> patches.  It might also be up to you to argue your case and tell me why
> I'm wrong.  I'll be patient (because good upstream maintainers are) but
> patience doesn't last forever (for Greg, it lasted about 5 years - I
> hope mine won't be tried to that extent).

Like I said in my other email, I think having another fork of the Lustre
tree, especially one that is starting from two-year-old code is likely to
fail, because there will be twice as much effort spent to maintain the two
trees.  I'd rather see the cleanups and features go hand-in-hand into the
same tree.  I'd be thrilled to have more reviews done on the features before
they are landed, but we can't just stop all feature development for a year
or two (or five) while the code is merged into the upstream kernel.

>> There are some very big (as in code size) features missing from
>> upstream.  For example, Multi-Rail.  When should that be pushed
>> relative to code cleanups?
> 
> Never add features to ugly code - fix the code first.
> The doesn't mean you cannot add any feature to lustre until all of
> lustre is beautiful.  But it does mean that if I can see in a patch some
> ugly code and a new feature, then I won't be happy.  First clean up just
> enough of the ugliness so that it won't be visible in the patch that
> adds the feature.

The issue is that we _can't_ just stop the development of new code/features
for such a long time.  There are huge supercomputers being deployed or in
planning that depend on these new features, or they wouldn't have been
developed in the first place.

Consider if the NFSv4 spec was written and the code was developed, and you
were told you needed to go back to NFSv2 and start again?

> But again, this is getting a bit too hypothetical.   If you care about a
> feature, then post a patch.  We can take it from there.  The fact that
> you care enough to post a patch cares significant weight - a lot more
> weight than just asking about some feature.

We definitely aren't at the point of "asking for some feature to be developed".
At a minimum the starting point of the new upstream code needs to be the
current release, or any resources that could possibly be put towards improving
the Lustre code would be squandered on porting all of those patches to the
upstream tree.  I'm fine with spending time to improve the code that exists
today, but lets not start with a huge deficit from the outset.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
