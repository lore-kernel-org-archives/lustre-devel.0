From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 12 Jul 2012 13:57:40 -0700
Subject: [Lustre-devel] [cdwg] broader Lustre testing
In-Reply-To: <97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
References: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
	<97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
Message-ID: <4FFF3A44.30106@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 07/12/2012 12:37 PM, Nathan Rutman wrote:
>
> On Jul 12, 2012, at 7:30 AM, John Carrier wrote:
>
> A more strategic solution is to do more testing of a feature release
> candidate _before_ it is released.  Even if a Community member has no
> interest in using a feature release in production, early testing with
> pre-release versions of feature releases will help identify
> instabilities created by the new feature with their workloads and
> hardware before the release is official.
>
>
> Taking a few threads that have discussed recently, regarding the stability of certain releases vs others, what maintenance branches are, what testing was done, and "which branch should I use":
> These questions, I think, should not need to be asked.  Which version of MacOS should I use?  The latest one, period.  Why can't Lustre do the same thing?

Because we're an open source project where all of our dirty laundry is 
in the public.  I'm sure that Apple has all kinds of internal deadlines 
and testing tags and things that we don't see on the outside world 
because it is a close-source proprietary product with vast resources to 
develop and test internally.

The every-six month cadence is a good thing in my opinion.  It forces us 
developers to regularly address the stability of the changes we are 
introducing.  It provides a clear, explicit time in the schedule for 
developers to stop writing new bugs, and focus their effort on fixing bugs.

I believe that the maintenance branch _is_ the place that you go when 
the question is "which version should I use"?  We just need to have a 
decent web page that says "Want Lustre? Here's the latest stable 
release!"  We need to increase exposure of the maintence releases, and 
hid the "feature" releases off on a developers page.

> The answer I think lies in testing, which becomes a chicken and egg problem.   I'm only going to use a "stable" release, which is the release which was tested with my applications.  I know acceptance-small was run, and passed, on Master, otherwise it wouldn't be released.  Hopefully it even ran on a big system like Hyperion.  (Do we learn anything more about running acc-sm on other big systems?  Probably not much.)  But it certainly wasn't tested with my application, because I didn't test it.  Because it wasn't released yet.  Chicken and egg.  Only after enough others make the leap am I willing to.
> So, it seems, we need to test pre-release versions of Lustre, aka Master, with my applications.  To that end, how willing are people to set aside a day, say once every two months, to be "filesystem beta day".  Scientists, run your codes, users, do your normal work, but bear in mind there may be filesystem instabilities on that day.  Make sure your data is backed up.  Make sure it's not in the middle of a critical week-long run.  Accept that you might have to re-run it tomorrow in the worst case.  Report any problems you have.
> What you get out of it is a much more stable Master, and an end to the question of "which version should I run".  When released, you have confidence that you can move up, get the great new features and performance, and it runs your applications.  More people are on the same release, so it sees even more testing. The maintenance branch is always the latest branch, you can pull in point releases with more bug fixes with ease. No more rolling your own Lustre with Frankenstein sets of patches.  Latest and greatest and most stable.

We can do a great deal more testing, and find a seriously large amount 
of bugs that we have been missing by getting more testing personnel 
allocated to Lustre.  I think that's the major gap in Lustre right now.

One day every two months is, I think, insufficient validating any 
software product, let alone something as complex as Lustre.  Not that I 
am opposed to the idea.  If you can arrange that, go for it!  But that 
isn't good enough by itself by a long shot.

We need full time personnel working on testing lustre.  I would think 
that all of the vendors out there selling products to customers would 
already have alot of experience testing hardware, and other software 
bits.  Lets apply some of that know-how to Lustre!

And I think these testing personnel need to be made known to the 
community, so they can talk to each other, so that developers can guide 
their efforts, so we know what our testing converage looks like, etc.

Testing needs to be a CONTINUAL process, not just something we do at the 
end for a specific release number.  By the time we tag 2.4, it should 
already have been tested so frequently all along the master development 
cycle that the final testing will start to look like a formality to us. 
  We should still do it, of course, but we should have confidence long 
before that happens.

LLNL is trying to do that with the master branch as it moves to 2.4. 
Our coverage is mainly on zfs backends for now, but as the rest of orion 
lands on master, and Sequoia goes into limited production use we'll have 
both zfs and ldiskfs filesystems in our testbed, and test regularly all 
the way up to, and beyond, 2.4.

The gaps in testing are NOT all an issue of insufficent scale testing, 
although there is admittedly a constant issue there.  We need much 
better testing at small scale as well.

And let me be really clear: when I say testing, I mean a real human 
being thinking up new tests all of the time.  Looking at logs all of the 
time (so even when the test app succeeded, we'll catch the timeouts and 
reconnections and things that should not be happening, and are symptoms 
of bugs).  Powering things off randomly.  Literally pulling cables out 
while an evil, pathologically bad IO workload is running.

We need real people to test all of the things that it is really easy for 
a human to do, and would take years for developers to automate with any 
reliability.

The automated regression suite that we use is great.  We should continue 
to improve that over time.  But I would content that it is not, and 
never will be, sufficient to tells us if Lustre is stable.

I would argue that the regressions tests are, in fact, a very low bar. 
And Lustre is just too complicated, networks are too complicated, we 
have too few developers, to ever come up with an automated suite with 
any thing but a relatively low confidence level in the stability of the 
software.

And human testers are given a very different set of goals then 
developers.  A developer's job is to make things work.  A tester's is to 
do whatever they can to break it.  And then create a good report of how 
they broke it so the developers can fix it.

I also agree that I don't want to continue in this mode of "we'll only 
run it when LLNL/ORNL runs it and says its good".  So we need more human 
testers.

And to get back to the topic of making every single release a "stable" 
release:  That ignores the fact that we have roughly a decade of 
seriously buggy, undocumented code that we're dealing with.  It just 
will not happen.  Period.  We have to accept that and move forward.

We can strive from this point on to make every release better than the 
last.  But developers are human.  Every time we add new features, we're 
going to add new bugs.  We'll also fix bugs.  But we're going to add new 
ones as well.

So we deal with that by having "maintenance" releases.  The maintenance 
release is maintained for a "long" period of time, but add NO new 
features.  No new support for new kernels.  No fantastic new performance 
improvements.  Just bug fixes.

The maintenance release is what vendors should build products upon, 
because that is where we'll land only bug fixes.  So it is far more 
likely to only improve with time, whereas "master" (and therefore the 
"feature" releases which are just tags on master every 6 months), will 
also introduce destabilizing new features.

We'll endevour to make the new features as stable as we are capable of 
doing, and we can do better if we have more testers, but we have to be 
pragmatic.

"Every tag should be completely stable" is impossible.  "Every tag on 
the maintenance branch should be more stable than the last" is an 
achievable goal.

Chris
