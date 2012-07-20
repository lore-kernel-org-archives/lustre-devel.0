From: Nathan Rutman <nathan_rutman@xyratex.com>
Date: Fri, 20 Jul 2012 11:20:54 -0700
Subject: [Lustre-devel] [cdwg] broader Lustre testing
In-Reply-To: <1342793622.7484.6.camel@bohr.ornl.gov>
References: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
	<97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
	<1342793622.7484.6.camel@bohr.ornl.gov>
Message-ID: <EEC07D6B-AAC0-442B-9660-58D28B200D07@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 20, 2012, at 7:13 AM, James A Simmons wrote:

> On Thu, 2012-07-12 at 15:37 -0400, Nathan Rutman wrote:
>> 
>> On Jul 12, 2012, at 7:30 AM, John Carrier wrote:
>> 
>>> A more strategic solution is to do more testing of a feature release
>>> candidate _before_ it is released.  Even if a Community member has
>>> no
>>> interest in using a feature release in production, early testing
>>> with
>>> pre-release versions of feature releases will help identify
>>> instabilities created by the new feature with their workloads and
>>> hardware before the release is official. 
> 
> ...
>> So, it seems, we need to test pre-release versions of Lustre, aka
>> Master, with my applications.  To that end, how willing are people to
>> set aside a day, say once every two months, to be "filesystem beta
>> day".  Scientists, run your codes, users, do your normal work, but
>> bear in mind there may be filesystem instabilities on that day.  Make
>> sure your data is backed up.  Make sure it's not in the middle of a
>> critical week-long run.  Accept that you might have to re-run it
>> tomorrow in the worst case.  Report any problems you have.
>> What you get out of it is a much more stable Master, and an end to the
>> question of "which version should I run".  When released, you have
>> confidence that you can move up, get the great new features and
>> performance, and it runs your applications.  More people are on the
>> same release, so it sees even more testing. The maintenance branch is
>> always the latest branch, you can pull in point releases with more bug
>> fixes with ease. No more rolling your own Lustre with Frankenstein
>> sets of patches.  Latest and greatest and most stable.
>> 
>> 
>> Pipe dream?
> 
> Since people are now moving to help test out the current master branch
> for whamcloud I like to purpose posting a general summary of testing
> results people are seeing. I personally have finished a first run at
> testing 2.2.91 this last week and would galdly share the results. Anyone
> else can to share :-)
> 
> 

I started a page on the OpenSFS Wiki for everyone to share their test results in a free-form format.  Note that the Wiki itself is still in it's infancy - I call on the community to help populate it.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120720/18bf46fe/attachment.htm>
