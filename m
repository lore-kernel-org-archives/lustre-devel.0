From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 12 Jul 2012 14:25:15 -0600
Subject: [Lustre-devel] [cdwg] broader Lustre testing
In-Reply-To: <97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
References: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
	<97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
Message-ID: <9D94CDBC-4100-4087-8F9B-903E1D62D65C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-07-12, at 1:37 PM, Nathan Rutman wrote:
> On Jul 12, 2012, at 7:30 AM, John Carrier wrote:
>> A more strategic solution is to do more testing of a feature release
>> candidate _before_ it is released.  Even if a Community member has no
>> interest in using a feature release in production, early testing with
>> pre-release versions of feature releases will help identify
>> instabilities created by the new feature with their workloads and
>> hardware before the release is official. 
> 
> 
> Taking a few threads that have discussed recently, regarding the stability of certain releases vs others, what maintenance branches are, what testing was done, and "which branch should I use":
> 
> These questions, I think, should not need to be asked.  Which version of MacOS should I use?  The latest one, period.

Interesting...   I _don't_ run the latest version of MacOS, and I distinctly recall people having a variety of issues with 10.7.0 when it was released.  Does that mean the MacOS testing was insufficient?  Partly, but it is unrealistic to test every possible usage pattern, so testing has to be "optimized" to cover the most common use cases in order to be finished within both time and cost constraints.

> Why can't Lustre do the same thing?  The answer I think lies in testing, which becomes a chicken and egg problem.   I'm only going to use a "stable" release, which is the release which was tested with my applications.  I know acceptance-small was run, and passed, on Master, otherwise it wouldn't be released.  Hopefully it even ran on a big system like Hyperion.  (Do we learn anything more about running acc-sm on other big systems?  Probably not much.)

Right.  I don't think that acc-sm is the end-all in testing frameworks, and I freely admit that there is a lot more testing that could be done, both in scale and in the types of loads that are used.  The acceptance-small.sh script is intended to be an "optimized" test set that can run in a few hours to give some reasonable confidence in a particular change.

>  But it certainly wasn't tested with my application, because I didn't test it.  Because it wasn't released yet.  Chicken and egg.  Only after enough others make the leap am I willing to.

There are all kinds of other load/stress tests (including applications) that can/should be run after the "basic" tests have been run to find new defects.  When those defects are found they should be distilled down to a simple and specific test that gets added to the regular regression suite.  I think it is this kind of testing that is needed moving forward.

> So, it seems, we need to test pre-release versions of Lustre, aka Master, with my applications.

I would caveat this to say - only test on tags which we know to be at least reasonably stable, since a lot of testing time will be wasted otherwise.

> To that end, how willing are people to set aside a day, say once every two months, to be "filesystem beta day".  Scientists, run your codes, users, do your normal work, but bear in mind there may be filesystem instabilities on that day.  Make sure your data is backed up.  Make sure it's not in the middle of a critical week-long run.  Accept that you might have to re-run it tomorrow in the worst case.  Report any problems you have.

I'm not sure that users will be willing to do this, though some "friendly" users are known to make the leap onto new systems in order to get early/free CPU cycles on new clusters.

There are also "feature tests" that need to be run at scale to validate new features, to ensure they are functional at scale, don't impact performance, and experiencing the kids of race conditions that scale testing provides.

> What you get out of it is a much more stable Master, and an end to the question of "which version should I run".  When released, you have confidence that you can move up, get the great new features and performance, and it runs your applications.  More people are on the same release, so it sees even more testing. The maintenance branch is always the latest branch, you can pull in point releases with more bug fixes with ease. No more rolling your own Lustre with Frankenstein sets of patches.  Latest and greatest and most stable.
> 
> Pipe dream?

I hope not.  When I see users taking a specific release of Lustre, testing it, and then applying a patch series to their branch, the unfortunate result is more effort for the user (vendor/site, not end users) to maintain their patches, and more effort for support to determine if some _other_ bug is already fixed, or to debug a problem that appears only with a specific combination of patches applied, and then craft a different fix for that branch than the mainline.

A better use case would be for users to start testing _before_ a major release is made, find/fix bugs, and merge the fixes into mainline, so when it is released in a maintenance release it will already be quite stable.  This keeps the user patchset much smaller, and everyone will benefit from fixes from other testing before the release, and hopefully find fewer bugs in the field.  It also avoids the issue of each user testing some cross-product of patches, and not really leveraging each others testing.  Then, any bugs found in the field go into the maintenance branch and master, but there is much less of a need to "test" the maintenance branch, since the changes there should be relatively small.

I think this is a reasonable approach, given that we no longer land features on maintenance branches.  That means the risk of following maintenance releases is much smaller than it was in the 1.6 and 1.8 days (1.8.x only really entered "maintenance" mode with 1.8.6 or so).

We've been trying to follow this model with LLNL.  One issue is that 2.1.0 didn't really receive as much up-front testing as it could have, so it is getting more fixes than it should.  We are working hard to land all of the LLNL (and other) bugfix patches into master and the next 2.1.x release.

There is a parallel effort to test orion (2.4 development branch) so that by the time 2.4 rolls around (including features that are not in master or orion yet) it will be relatively stable and does not need its own "test effort".

Are we at this nirvana yet?  Not quite, but I think we are closer than ever before, and we have the chance to get there with a coordinated effort of the community.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
