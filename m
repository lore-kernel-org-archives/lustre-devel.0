From: Cliff White <cliffw@whamcloud.com>
Date: Thu, 12 Jul 2012 13:25:00 -0700
Subject: [Lustre-devel] broader Lustre testing
In-Reply-To: <AF08BE7C-C729-4EF9-9432-BCDEC4FE28D1@xyratex.com>
References: <CC2476F2.5794%bruce_korb@xyratex.com>
	<AF08BE7C-C729-4EF9-9432-BCDEC4FE28D1@xyratex.com>
Message-ID: <CAGgoGxOxALv4WB-BLsxpP5Gq6jr9tcpDddQXn=EsS6m-dKRJhQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There are certainly examples of this working for other products, for
example (it's been a good number of years) at one time the main QA
benchmark for the Oracle database was a customer-furnished test (the
'Churchill' test) which exercised the database throughly.
It would also be useful to have data from those using standard IO tests
(IOR, iozone, etc) as we could easily expand the existing tests with
different parameter sets.
However, in the HPC space, i suspect obtaining/generating the data set
needed to replicate some customer situations would be a challenge.
cliffw


On Thu, Jul 12, 2012 at 1:07 PM, Nathan Rutman <nathan_rutman@xyratex.com>wrote:

>
> On Jul 12, 2012, at 12:48 PM, Bruce Korb wrote:
>
> Hi Nathan,
>
>
> On 2012-07-12, at 20:37, Nathan Rutman <nathan_rutman@xyratex.com> wrote:
>
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
>
> Taking a few threads that have discussed recently, regarding the stability
> of certain releases vs others, what maintenance branches are, what testing
> was done, and "which branch should I use":
> These questions, I think, should not need to be asked.  Which version of
> MacOS should I use?  The latest one, period.  Why can't Lustre do the same
> thing?  The answer I think lies in testing, which becomes a chicken and egg
> problem.   I'm only going to use a "stable" release, which is the release
> which was tested *with my applications*.  I know acceptance-small was
> run, and passed, on Master, otherwise it wouldn't be released.  Hopefully
> it even ran on a big system like Hyperion.  (Do we learn anything more
> about running acc-sm on other big systems?  Probably not much.)  But it
> certainly wasn't tested with my application, because I didn't test it.
>  Because it wasn't released yet.  Chicken and egg.  Only after enough
> others make the leap am I willing to.
> So, it seems, we need to test pre-release versions of Lustre, aka Master,
> *with my applications*.  To that end, how willing are people to set aside
> a day, say once every two months, to be "filesystem beta day".  Scientists,
> run your codes, users, do your normal work, but bear in mind there may be
> filesystem instabilities on that day.  Make sure your data is backed up.
>  Make sure it's not in the middle of a critical week-long run.  Accept that
> you might have to re-run it tomorrow in the worst case.  Report any
> problems you have.
> What you get out of it is a much more stable Master, and an end to the
> question of "which version should I run".  When released, you have
> confidence that you can move up, get the great new features and
> performance, and it runs your applications.  More people are on the same
> release, so it sees even more testing. The maintenance branch is always the
> latest branch, you can pull in point releases with more bug fixes with
> ease. No more rolling your own Lustre with Frankenstein sets of patches.
>  Latest and greatest and most stable.
>
> Pipe dream?
>
>
> On Jul 12, 2012, at 12:48 PM, Bruce Korb wrote:
>
>
> _I_ think so.  You might get a few customers to say, "yes" but
> never be able to find the appropriate round tuit.  A more fruitful
> approach might be to solicit customer acceptance tests.  Presumably,
> they've written them to hit the wrinkles that they tend to stub
> their toes on.  And there may be exceptions, too.  (e.g. Cray might
> well actually do some pre-testing -- they, too, have paying customers.)
>
>
> I have no aversion to customers writing and supplying their own acceptance
> tests, but I think that approach doesn't work for many of the cases:
> - acceptance tests may not exist; acceptance may simply be testing with
> large production codes
> - tests that run in a particular environment need to be significantly
> generalized
> - tests may not be sharable for various legal reasons
>
> This also doesn't have to be an all-or-nothing proposition -- interested
> parties will be able to use the latest features, and will help contribute
> to the stability of Master, and will help reduce the "spread" of deployed
> systems, in a positive feedback loop.
>
> Yes, absolutely, this is effort on the part of Lustre users.  But it can
> be balanced by the savings of efforts in roll-your-own, and risk reduction.
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>


-- 
cliffw
Support Guy
WhamCloud, Inc.
www.whamcloud.com
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120712/231a9543/attachment.htm>
