From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 6 Nov 2015 14:08:50 -0800
Subject: [lustre-devel] Should we have fewer releases?
In-Reply-To: <7AE60ED4-FCA4-4263-887B-5DFC8A0866DA@intel.com>
References: <D25FA9D2.89BFF%spitzcor@cray.com> <563A6351.4080407@llnl.gov>
	<D25FC1DB.89C48%spitzcor@cray.com> <563BCDDE.9060103@llnl.gov>
	<7AE60ED4-FCA4-4263-887B-5DFC8A0866DA@intel.com>
Message-ID: <563D24F2.8050108@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/06/2015 06:39 AM, Drokin, Oleg wrote:
> Hello!
>
> On Nov 5, 2015, at 4:45 PM, Christopher J. Morrone wrote:
>> On the contrary, we need to go in the opposite direction to achieve those goals.  We need to shorten the release cycle and have more frequent releases.  I would recommend that we move to to a roughly three month release cycle.  Some of the benefits might be:
>>
>> * Less change and accumulate before the release
>> * The penalty for missing a release landing window is reduced when releases are more often
>> * Code reviewers have less pressure to land unfinished and/or insufficiently reviewed and tested code when the penalty is reduced
>> * Less change means less to test and fix at release time
>> * Bug authors are more likely to still remember what they did and participate in cleanup.
>> * Less time before bugs that slip through the cracks appear in a major release
>> * Reduces developer frustration with long freeze windows
>> * Encourages developers to rally more frequently around the landing windows instead of falling into a long period of silence and then trying to shove a bunch of code in just before freeze.  (They'll still try to ram things in just before freeze, but with more frequent landing windows the amount will be smaller and more manageable.)
>
> Bringing this to the logical extreme - we should just have one release per major feature.

It do not agree that it is logical to extend the argument to that 
extreme.  That is the "Appeal to Extremes" logical fallacy.

I also don't think it is appropriate to conflate major releases with 
major features.  When/if we move to a shorter release cycle, it would be 
entirely appropriate to put out a major release with no headline "major 
features".  It is totally acceptable to release the many changes that 
did make it in the landing window.  Even if none of the changes 
individually count as "major", they still collectively represent a major 
amount of work.

Right now we combine that major amount of work with seriously 
destabilizing new features that more than offset all the bug fixing that 
went on.  Why do we insist on making those destabilizing influences a 
requirement for a release?

Whether a major feature makes it into any particular release should be 
judge primarily on the quality and completeness of code, testing, and 
documentation for said feature.  Further, how many major features can be 
landed in a release would be gated on the amount of manpower we have for 
review and testing.  If 3 major features are truely complete and ready 
to land, but we can only fully vet 1 in the landing window, well, only 
one will land.  We'll have to make a judgement call as a community on 
the priority and work on that.

In summary: I think we should decouple the concept of major releases and 
major features.  Major releases do not need to be subject to major features.

> Sadly, I think the stabilization process is not likely to get any shorter.

Do not see a connection between the amount of change and the time it 
takes to stabilize that change?  Can you explain why you think that?

> Either that or interested parties would only jump into testing when enough of interesting features accumulate,
> after which point there'd be a bunch of bugreports for the current feature plus the backlocd that did not get any significant real-world testing before. We have seen this pattern
> to some degree already even with current releases.

The scary future you paint is no different than our present. 
Organizations like LLNL only move to new major releases every 18 months 
at the earliest, and we would really like to run the same version for 
more like three years in some cases.  We are too busy drowning in 
production Lustre issues half the time to get involved in testing except 
when it is something that is on our roadmap to put into production.  I 
don't think we're alone.  Even if it isn't Lustre issues, everyone has 
day jobs that keep us busy and time for testing things that don't look 
immediately relevant to upper management can be difficult to justify.

So I agree, many people already are skipping the testing of many 
releases and that will continue into the future.

Frankly, I think that relying on an open source community to do rigorous 
and systematic testing is foolhardy.  The only way that really works is 
if your user base is large in proportion to the size of your code size 
and complexity.  I would estimate the Lustre is low in that ratio, while 
something like ZFS is probably medium to large, and Linux is large.

The testing you get from an open source community is going to be a 
fairly random in terms of code coverage.  In order to the coverage to be 
reasonably complete, you need _alot_ of people testing.

If we rely on a voluntary, at-will community testing as out primary SQA 
enforcement method, we are not going to ever put out terribly quality 
code with something as complex and poorly documented as Lustre.

Lets not apply the Appeal to Extremes argument to this either.  I am not 
saying that we shouldn't have testing.  We absolutely should.  We should 
also strive to make the barriers to testing as low as possible,
and make the opportunities for testing as frequent as reasonble.

If we have release every three months on a _reliable_ schedule, that 
will give prospective testers the ability to plan their testing time 
ahead, increases the probability that each prospective tester will have 
spare time that aligns with one of our release testing windows.

All that said, I think you might also be wrong about no one testing the 
each releases.  ORNL has already demonstrated a commitment to try every 
version.  Cray is stepping up testing.  I would like to have my team at 
LLNL become more active on master in the future, and have our testing 
person worked into the Lustre development cycle.

> The releases that are ignored by community for one reason or another tend to be not very stable and then the follow-on release
> gets this "testing debt" baggage that is paid at release time once testing outside of Intel picks up the pace.

That is a challenge now, and I acknowledge that it will continue to be a 
challenge in the future.

Making the releases more frequently and on a reliable schedule is not 
magic; it will not fix everything about our development process on its 
own.  Nevertheless I do believe that it will be a key supporting element 
in improving our software development and SQA processes.

Chris
