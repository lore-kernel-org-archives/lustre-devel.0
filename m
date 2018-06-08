From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 15:45:35 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <C50F2EA9-AD25-480A-8A05-2541206BA17F@intel.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
 <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
 <87h8memg4k.fsf@notabene.neil.brown.name>
 <C50F2EA9-AD25-480A-8A05-2541206BA17F@intel.com>
Message-ID: <8736xxn85c.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 07 2018, Dilger, Andreas wrote:

> On Jun 7, 2018, at 15:38, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Thu, Jun 07 2018, Doug Oucharek wrote:
>> 
>>> What is the focus of landings in this tree?  There are two things needing to be done for an upstream Lustre:
>>> 
>>> 
>>>  *   Get the source code to meet the Linux guidelines so it is acceptable to be in mainline.
>>>  *   Get the binary product to have all the features and bug fixes that are in the Intel community tree so end users are interested in using the upstream version (users are unlikely to use a version of Lustre which is not current).
>>> 
>>> For the now-deleted staging area, we were supposed to be focusing on the first item but were submitting patches for the second item (syncing with Intel tree).  In my opinion, this is the core reason for never being able to get out of staging and getting deleted.
>> 
>> My (undoubtedly biased) perspective on the history of lustre in staging
>> goes like this:
>> There are two things needed for some out-of-tree code to get into
>> mainline Linux:  the code needs to be integrated and the community needs
>> to be integrated (or a new sub-community needs to form).
>> In the case of lustre, the code was never really integrated because the
>> community never really tried to integrate.
>
> One of the issues here was that the group (not Intel) that submitted the
> Lustre code to the staging tree promptly abandoned it for a couple of
> years after they submitted it upstream, after promising the community
> that they were in it for the long run.  That put the upstream integration
> behind the eight-ball from the start.

Yes, we have a lot of "technical debt" to recover from, or repay, or
what ever analogy works best.

>
>>  Integrating and becoming
>> part of the Linux community takes time and effort, and it is quite
>> possible that management for various developers didn't allocate enough
>> time over a long enough period.  Integrating also requires a change in
>> attitude and I don't see much evidence of that.  I see clear evidence of
>> an "us and them" attitude among (some) lustre developers - almost as
>> though upstream linux is hostile territory full of unfriendly developers
>
> Ah, but it *is* hostile territory, if you are not among the "in crowd".
> Christoph can get any change he wants to be accepted, but if someone else
> tries to push something similar it can be rejected outright or ignored
> for months or years.

Christoph is taken more seriously than others primarily because he is
more consistently right.  He has built up trust with other key people
over years.  You cannot expect to get the same returns without the same
investment.
If he has interests that overlap with your, then it is certainly worth
trying to understand his point of view, and worth trying to work with
him.  That can be a challenge as his style can be a bit abrasive, but
I'm sure it can yield good returns.

Christoph may seem like the enemy, but he is really just another
developer like you or me.  He has his priorities and his hang-ups and he
wants to get his work done and to keep Linux generally in a healthy
state.
If you think of him (or anyone else) as the enemy, it will poison your
relationship before you even start.
If you think of him as a future friend who speaks a different language
which it will take you a while to understand, I think you will make more
progress.
Importantly, if you appear to be trying to work together you will create
a good impression on others and start you build your social capital, and
start to earn trust.

>
>> who always reject our excellent code (even though they have lots of
>> horrible code themselves).  *We* need to see ourselves as part of the
>> Linux community, and we need to care about all of Linux as though it was
>> all ours (it *is* all ours, but *we* are a much larger group now).
>> 
>> Yes, the current code needs to be improved, bugs need to be fixed, and
>> features need to be added.  The order in which these is done is not the
>> most important things - if it were, Greg would have never accepted any
>> new features.  However he *did* accept them, but tried to remind the
>> lustre developers that there was other work to do.
>> 
>> Working together in one (single) community requires give-and-take.
>> Greg's behaviour as just described seems to be evidence of
>> give-and-take.  I think he kicked lustre out of staging because he
>> concluded that he was never going to get the matching give-and-take in
>> return.
>> 
>> So to answer your opening question, my focus for this tree is to train
>> any lustre developers who wish to engage about how to be part of the
>> Linux community.  As I've already said - I will accept features but I
>> prefer cleanups first.  I don't want to try to explain further than that
>> because it will be too hypothetical and unhelpful.  We - the Linux
>> community - don't work in hypotheticals.  We work with concrete objects
>> like patches.  So send me a patch and I will tell you what I think of
>> that specific patch.  It is up to you to generalise what I say to other
>> patches.  It might also be up to you to argue your case and tell me why
>> I'm wrong.  I'll be patient (because good upstream maintainers are) but
>> patience doesn't last forever (for Greg, it lasted about 5 years - I
>> hope mine won't be tried to that extent).
>
> Like I said in my other email, I think having another fork of the Lustre
> tree, especially one that is starting from two-year-old code is likely to
> fail, because there will be twice as much effort spent to maintain the two
> trees.  I'd rather see the cleanups and features go hand-in-hand into the
> same tree.  I'd be thrilled to have more reviews done on the features before
> they are landed, but we can't just stop all feature development for a year
> or two (or five) while the code is merged into the upstream kernel.

Where did this idea of stopping all feature development come from?  It
is a ridiculous idea.
Of course, getting the code into shape for upstream inclusion will
require effort and time and someone will have to do that.  While they
are doing it they won't be working on features.
That either means new developers will need to get involved (like me) or
current developers will need to dedicate some of their time to the
upstream work.
So feature development doesn't have to stop, but it might slow unless
extra developers are added.

There seem to be two options:
1/ code clean up and continuing feature development happen in the one
   tree.
2/ feature development happens in one tree while code cleanup and
   integration of newly developed feature happens in another tree.

There are two variation on option 2.
2a/ the code-cleanup tree is based on what is being removed from
    drivers/staging.
2b/ the code-cleanup tree is created as a new fork of the current
    devel tree.

Each of 2a and 2b would have costs and benefits that the other doesn't
have.
I like 2a because a lot of cleanup has already been done, and because
porting patches across from the devel tree will provide a good
opportunity to review those patches.  Reviewing a large body of existing code
is really hard.  Reviewing patches one at a time is easier as they tend
to be conceptually coherent.

I like 2a and have already made steps in that direction.  But the
decision needs to be made by the people who will be doing the work.
Hopefully that isn't just me.

So: who has time to commit to creating an upstream-able version of
  lustre?  If everyone who will be committing time could make a clear
  statement of how they would like to proceed, then I'm sure we can come
  to agreement.

>
>>> There are some very big (as in code size) features missing from
>>> upstream.  For example, Multi-Rail.  When should that be pushed
>>> relative to code cleanups?
>> 
>> Never add features to ugly code - fix the code first.
>> The doesn't mean you cannot add any feature to lustre until all of
>> lustre is beautiful.  But it does mean that if I can see in a patch some
>> ugly code and a new feature, then I won't be happy.  First clean up just
>> enough of the ugliness so that it won't be visible in the patch that
>> adds the feature.
>
> The issue is that we _can't_ just stop the development of new code/features
> for such a long time.  There are huge supercomputers being deployed or in
> planning that depend on these new features, or they wouldn't have been
> developed in the first place.
>
> Consider if the NFSv4 spec was written and the code was developed, and you
> were told you needed to go back to NFSv2 and start again?
>
>> But again, this is getting a bit too hypothetical.   If you care about a
>> feature, then post a patch.  We can take it from there.  The fact that
>> you care enough to post a patch cares significant weight - a lot more
>> weight than just asking about some feature.
>
> We definitely aren't at the point of "asking for some feature to be developed".
> At a minimum the starting point of the new upstream code needs to be the
> current release, or any resources that could possibly be put towards improving
> the Lustre code would be squandered on porting all of those patches to the
> upstream tree.  I'm fine with spending time to improve the code that exists
> today, but lets not start with a huge deficit from the outset.

We have a huge deficit either way.  One way we have a deficit of
functionality, the other way we have a deficit of quality.

But let's not spend too much time talking about the problems.  I'd much
rather hear what you are doing about it.  If other people are working,
I'll align with them.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/8b8fe4ad/attachment.sig>
