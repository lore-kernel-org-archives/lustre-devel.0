From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Mon, 30 Nov 2015 19:33:39 -0800
Subject: [lustre-devel] Should we have fewer releases?
In-Reply-To: <84F441B5-CB1E-4899-BCB1-4A3A25C94B19@intel.com>
References: <D25FA9D2.89BFF%spitzcor@cray.com> <563A6351.4080407@llnl.gov>
	<D25FC1DB.89C48%spitzcor@cray.com> <563BCDDE.9060103@llnl.gov>
	<7AE60ED4-FCA4-4263-887B-5DFC8A0866DA@intel.com>
	<563D24F2.8050108@llnl.gov>
	<84F441B5-CB1E-4899-BCB1-4A3A25C94B19@intel.com>
Message-ID: <565D1513.2060401@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/07/2015 12:36 AM, Drokin, Oleg wrote:
> Hello!
>
> On Nov 6, 2015, at 5:08 PM, Christopher J. Morrone wrote:
>
>> On 11/06/2015 06:39 AM, Drokin, Oleg wrote:
>>> Hello!
>>>
>>> On Nov 5, 2015, at 4:45 PM, Christopher J. Morrone wrote:
>>>> On the contrary, we need to go in the opposite direction to achieve those goals.  We need to shorten the release cycle and have more frequent releases.  I would recommend that we move to to a roughly three month release cycle.  Some of the benefits might be:
>>>>
>>>> * Less change and accumulate before the release
>>>> * The penalty for missing a release landing window is reduced when releases are more often
>>>> * Code reviewers have less pressure to land unfinished and/or insufficiently reviewed and tested code when the penalty is reduced
>>>> * Less change means less to test and fix at release time
>>>> * Bug authors are more likely to still remember what they did and participate in cleanup.
>>>> * Less time before bugs that slip through the cracks appear in a major release
>>>> * Reduces developer frustration with long freeze windows
>>>> * Encourages developers to rally more frequently around the landing windows instead of falling into a long period of silence and then trying to shove a bunch of code in just before freeze.  (They'll still try to ram things in just before freeze, but with more frequent landing windows the amount will be smaller and more manageable.)
>>>
>>> Bringing this to the logical extreme - we should just have one release per major feature.
>>
>> It do not agree that it is logical to extend the argument to that extreme.  That is the "Appeal to Extremes" logical fallacy.
>
> It probably is. But it's sometimes useful still.
>
>> I also don't think it is appropriate to conflate major releases with major features.  When/if we move to a shorter release cycle, it would be entirely appropriate to put out a major release with no headline "major features".  It is totally acceptable to release the many changes that did make it in the landing window.  Even if none of the changes individually count as "major", they still collectively represent a major amount of work.
>
> Yes, I agree there could be releases with no major new features, though attempts to make them in the past were not met with great enthusiasm.
>
>> Right now we combine that major amount of work with seriously destabilizing new features that more than offset all the bug fixing that went on.  Why do we insist on making those destabilizing influences a requirement for a release?
>
> That's what people want, apparently. Features are developed because there's a need for them.

Yes, people want everything.  While we want features, we want stability 
just as much.  So far stability has been playing second chair to 
features with Lustre.  We can't stop adding features, but we do need to 
shift the level of balance a bit.

>> Whether a major feature makes it into any particular release should be judge primarily on the quality and completeness of code, testing, and documentation for said feature.  Further, how many major features can be landed in a release would be gated on the amount of manpower we have for review and testing.  If 3 major features are truely complete and ready to land, but we can only fully vet 1 in the landing window, well, only one will land.  We'll have to make a judgement call as a community on the priority and work on that.
>
> I am skeptical this is going to work. If a feature is perceived to be ready, but is not accepted for whatever reason, those who feel they need it would just find some way of using it anyway.
> And it would lead to more fragmentation in the end.

If you really think about it, we already have that fragmentation today. 
  Hopefully the burden of constantly refreshing one's private major 
features to work with master will convince organizations that it is in 
their best effort to upstream their code.

I think that what causes people to be most annoyed and stop working with 
an upstream is when the upstream developers are uncommunicative and 
seemingly arbitrary.  We could use some work in that area, I think, if 
we are all honest.

I think that if we all discuss landing priority and some's feature is 
deemed too low to get into the current release, yes, that author will be 
disappointed.  But I think that the vast majority of developers would 
also be understanding.  They would especially be understanding if we 
explain that it will be at the top of the list for the next landing cycle.

Feedback and communication go a long way to keeping everyone content.

>> In summary: I think we should decouple the concept of major releases and major features.  Major releases do not need to be subject to major features.
>
> Should there be a period where no new features were developed into the "Ready to include" state, yes - I am all for it.
> I guess you think this is going to be easier to achieve by shortening time to next release. It's just right now we have such a backlog of features that that might not be a realistic assumption.

We have a backlog of stability and usability too.  I don't care how big 
the feature backlog is, we can't allow them in unless they are 
reasonably stable.

>>> Sadly, I think the stabilization process is not likely to get any shorter.
>> Do not see a connection between the amount of change and the time it takes to stabilize that change?  Can you explain why you think that?
>
> Testing (and vetting) takes a fixed time. For large scale community testing we also depend on large systems availability schedule. These do not change.

If you are right that test dates on large systems are unchangeable, then 
our current unpredicatble releases are completely incompatible with that 
model.

But, with all due respect, I think you are wrong about that.  Test dates 
on large machines _are_ changeable.  Those dates need to be scheduled in 
advance, but we _can_ change when those future testing windows will be.

Also, if we can't find ways to improve SQA other than small testing 
windows on large systems, then we may as well just give up on Lustre 
now.  That will never result in quality software.

Fortunately, I do not believe that is the case.  I think there are many 
ways that we can improve the development processes over time to result 
in higher quality software.  Testing won't catch enough on its own.

> Any problems found would require a retest once the fix is in place.
> Then there's a backlog of "deferred" bugs that are not deemed super critical, but as number of truly critical bugs goes down, I suspect those bugs from backlog would be viewed
> as more serious (and I don't think it's a bad thing).
>
> Of course I might be all wrong on this, but it's just my feeling. If we take any past Lustre release and add another X months of pure code freeze and stabilization,
> do you think that particular release would not have benefitted from that?
> I suspect same is true of (almost?) any other software project.

Not really.  We have already been adding X months of code freeze 
randomly as needed.  Once the easily found bugs are squashed the 
developers move on to adding new bugs^H^H^H^Hfeatures.  I don't think 
that testing alone is going to solve our quality problem.

[cut some things we agreed upon]
>> If we have release every three months on a _reliable_ schedule, that will give prospective testers the ability to plan their testing time ahead, increases the probability that each prospective tester will have spare time that aligns with one of our release testing windows.
>
> We need all the diverse testing we can get and then some. So there's no disagreement from me here.
> If you think just by doubling the number of releases gets us double the testing time from community, that alone might be worth it.

No, I don't think the testing will double.  I think a smaller overall 
improvement (10%? 20%? 30%?) might be reasonable.

I want this change not primarily for testing, but for the other 
advantages that it can provide to the development process.  Mainly it 
allows us to start getting control of the amount of change in each release.

Less change and shorter delay between landing and testing will tend to 
decrease the difficulty of removing the bugs that we find.

We are under less pressure to land unfinished features because the 
penalty for missing a release is lowered (only 3 months until the next 
release instead of the current 6-9 months).

Etc.

[cut]
>> Making the releases more frequently and on a reliable schedule is not magic; it will not fix everything about our development process on its own.  Nevertheless I do believe that it will be a key supporting element in improving our software development and SQA processes.
>
> We just need to ensure the rate at which bugs are introduced is a lot smaller than the rate at which bugs are fixed. ;)
> And we need to also achieve this without choking new features somehow.

I agree!

We haven't been too successful at introducing fewer bugs than we fix 
thus far with Lustre. :)

The painful truth is that feature progress probably needs to be slower 
if we want higher quality software in the future.  We shouldn't stop 
feature development, but we should take more care in their landing than 
we have in the past if we want stability to improve.

It is always a balancing game.

Chris
