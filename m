From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 7 Nov 2015 08:36:45 +0000
Subject: [lustre-devel] Should we have fewer releases?
In-Reply-To: <563D24F2.8050108@llnl.gov>
References: <D25FA9D2.89BFF%spitzcor@cray.com> <563A6351.4080407@llnl.gov>
	<D25FC1DB.89C48%spitzcor@cray.com> <563BCDDE.9060103@llnl.gov>
	<7AE60ED4-FCA4-4263-887B-5DFC8A0866DA@intel.com>
	<563D24F2.8050108@llnl.gov>
Message-ID: <84F441B5-CB1E-4899-BCB1-4A3A25C94B19@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Nov 6, 2015, at 5:08 PM, Christopher J. Morrone wrote:

> On 11/06/2015 06:39 AM, Drokin, Oleg wrote:
>> Hello!
>> 
>> On Nov 5, 2015, at 4:45 PM, Christopher J. Morrone wrote:
>>> On the contrary, we need to go in the opposite direction to achieve those goals.  We need to shorten the release cycle and have more frequent releases.  I would recommend that we move to to a roughly three month release cycle.  Some of the benefits might be:
>>> 
>>> * Less change and accumulate before the release
>>> * The penalty for missing a release landing window is reduced when releases are more often
>>> * Code reviewers have less pressure to land unfinished and/or insufficiently reviewed and tested code when the penalty is reduced
>>> * Less change means less to test and fix at release time
>>> * Bug authors are more likely to still remember what they did and participate in cleanup.
>>> * Less time before bugs that slip through the cracks appear in a major release
>>> * Reduces developer frustration with long freeze windows
>>> * Encourages developers to rally more frequently around the landing windows instead of falling into a long period of silence and then trying to shove a bunch of code in just before freeze.  (They'll still try to ram things in just before freeze, but with more frequent landing windows the amount will be smaller and more manageable.)
>> 
>> Bringing this to the logical extreme - we should just have one release per major feature.
> 
> It do not agree that it is logical to extend the argument to that extreme.  That is the "Appeal to Extremes" logical fallacy.

It probably is. But it's sometimes useful still.

> I also don't think it is appropriate to conflate major releases with major features.  When/if we move to a shorter release cycle, it would be entirely appropriate to put out a major release with no headline "major features".  It is totally acceptable to release the many changes that did make it in the landing window.  Even if none of the changes individually count as "major", they still collectively represent a major amount of work.

Yes, I agree there could be releases with no major new features, though attempts to make them in the past were not met with great enthusiasm.

> Right now we combine that major amount of work with seriously destabilizing new features that more than offset all the bug fixing that went on.  Why do we insist on making those destabilizing influences a requirement for a release?

That's what people want, apparently. Features are developed because there's a need for them.

> Whether a major feature makes it into any particular release should be judge primarily on the quality and completeness of code, testing, and documentation for said feature.  Further, how many major features can be landed in a release would be gated on the amount of manpower we have for review and testing.  If 3 major features are truely complete and ready to land, but we can only fully vet 1 in the landing window, well, only one will land.  We'll have to make a judgement call as a community on the priority and work on that.

I am skeptical this is going to work. If a feature is perceived to be ready, but is not accepted for whatever reason, those who feel they need it would just find some way of using it anyway.
And it would lead to more fragmentation in the end.

> In summary: I think we should decouple the concept of major releases and major features.  Major releases do not need to be subject to major features.

Should there be a period where no new features were developed into the "Ready to include" state, yes - I am all for it.
I guess you think this is going to be easier to achieve by shortening time to next release. It's just right now we have such a backlog of features that that might not be a realistic assumption.

>> Sadly, I think the stabilization process is not likely to get any shorter.
> Do not see a connection between the amount of change and the time it takes to stabilize that change?  Can you explain why you think that?

Testing (and vetting) takes a fixed time. For large scale community testing we also depend on large systems availability schedule. These do not change.
Any problems found would require a retest once the fix is in place.
Then there's a backlog of "deferred" bugs that are not deemed super critical, but as number of truly critical bugs goes down, I suspect those bugs from backlog would be viewed
as more serious (and I don't think it's a bad thing).

Of course I might be all wrong on this, but it's just my feeling. If we take any past Lustre release and add another X months of pure code freeze and stabilization,
do you think that particular release would not have benefitted from that?
I suspect same is true of (almost?) any other software project.

>> Either that or interested parties would only jump into testing when enough of interesting features accumulate,
>> after which point there'd be a bunch of bugreports for the current feature plus the backlocd that did not get any significant real-world testing before. We have seen this pattern
>> to some degree already even with current releases.
> The scary future you paint is no different than our present. Organizations like LLNL only move to new major releases every 18 months at the earliest, and we would really like to run the same version for more like three years in some cases.  We are too busy drowning in production Lustre issues half the time to get involved in testing except when it is something that is on our roadmap to put into production.  I don't think we're alone.  Even if it isn't Lustre issues, everyone has day jobs that keep us busy and time for testing things that don't look immediately relevant to upper management can be difficult to justify.

Indeed. I am not painting any scare future, I am just making observations about today.

> So I agree, many people already are skipping the testing of many releases and that will continue into the future.
> 
> Frankly, I think that relying on an open source community to do rigorous and systematic testing is foolhardy.  The only way that really works is if your user base is large in proportion to the size of your code size and complexity.  I would estimate the Lustre is low in that ratio, while something like ZFS is probably medium to large, and Linux is large.
> 
> The testing you get from an open source community is going to be a fairly random in terms of code coverage.  In order to the coverage to be reasonably complete, you need _alot_ of people testing.

This is very true. We need many more unique environments to extend the coverage. That or finding some way of somehow forcing every possible code path to execute somehow in testing, which is
not really realistic.

> If we rely on a voluntary, at-will community testing as out primary SQA enforcement method, we are not going to ever put out terribly quality code with something as complex and poorly documented as Lustre.
> 
> Lets not apply the Appeal to Extremes argument to this either.  I am not saying that we shouldn't have testing.  We absolutely should.  We should also strive to make the barriers to testing as low as possible,
> and make the opportunities for testing as frequent as reasonble.
> 
> If we have release every three months on a _reliable_ schedule, that will give prospective testers the ability to plan their testing time ahead, increases the probability that each prospective tester will have spare time that aligns with one of our release testing windows.

We need all the diverse testing we can get and then some. So there's no disagreement from me here.
If you think just by doubling the number of releases gets us double the testing time from community, that alone might be worth it.

> All that said, I think you might also be wrong about no one testing the each releases.  ORNL has already demonstrated a commitment to try every version.  Cray is stepping up testing.  I would like to have my team at LLNL become more active on master in the future, and have our testing person worked into the Lustre development cycle.

There were releases in the past when this was true for various reasons.

>> The releases that are ignored by community for one reason or another tend to be not very stable and then the follow-on release
>> gets this "testing debt" baggage that is paid at release time once testing outside of Intel picks up the pace.
> 
> That is a challenge now, and I acknowledge that it will continue to be a challenge in the future.
> 
> Making the releases more frequently and on a reliable schedule is not magic; it will not fix everything about our development process on its own.  Nevertheless I do believe that it will be a key supporting element in improving our software development and SQA processes.

We just need to ensure the rate at which bugs are introduced is a lot smaller than the rate at which bugs are fixed. ;)
And we need to also achieve this without choking new features somehow.

Bye,
    Oleg
