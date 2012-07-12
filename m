From: Nathan Rutman <nathan_rutman@xyratex.com>
Date: Thu, 12 Jul 2012 12:37:14 -0700
Subject: [Lustre-devel] broader Lustre testing
In-Reply-To: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
References: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
Message-ID: <97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 12, 2012, at 7:30 AM, John Carrier wrote:

> A more strategic solution is to do more testing of a feature release
> candidate _before_ it is released.  Even if a Community member has no
> interest in using a feature release in production, early testing with
> pre-release versions of feature releases will help identify
> instabilities created by the new feature with their workloads and
> hardware before the release is official. 


Taking a few threads that have discussed recently, regarding the stability of certain releases vs others, what maintenance branches are, what testing was done, and "which branch should I use":
These questions, I think, should not need to be asked.  Which version of MacOS should I use?  The latest one, period.  Why can't Lustre do the same thing?  The answer I think lies in testing, which becomes a chicken and egg problem.   I'm only going to use a "stable" release, which is the release which was tested with my applications.  I know acceptance-small was run, and passed, on Master, otherwise it wouldn't be released.  Hopefully it even ran on a big system like Hyperion.  (Do we learn anything more about running acc-sm on other big systems?  Probably not much.)  But it certainly wasn't tested with my application, because I didn't test it.  Because it wasn't released yet.  Chicken and egg.  Only after enough others make the leap am I willing to.
So, it seems, we need to test pre-release versions of Lustre, aka Master, with my applications.  To that end, how willing are people to set aside a day, say once every two months, to be "filesystem beta day".  Scientists, run your codes, users, do your normal work, but bear in mind there may be filesystem instabilities on that day.  Make sure your data is backed up.  Make sure it's not in the middle of a critical week-long run.  Accept that you might have to re-run it tomorrow in the worst case.  Report any problems you have.
What you get out of it is a much more stable Master, and an end to the question of "which version should I run".  When released, you have confidence that you can move up, get the great new features and performance, and it runs your applications.  More people are on the same release, so it sees even more testing. The maintenance branch is always the latest branch, you can pull in point releases with more bug fixes with ease. No more rolling your own Lustre with Frankenstein sets of patches.  Latest and greatest and most stable.

Pipe dream?

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120712/2fed6c1d/attachment.htm>
