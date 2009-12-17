From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Thu, 17 Dec 2009 14:12:04 +0200
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <999B10A5-95F8-47B5-8A87-17E1ED18F260@sun.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<3ed212d00912160924w5c823207h35378e814e0a6c23@mail.gmail.com>
	<999B10A5-95F8-47B5-8A87-17E1ED18F260@sun.com>
Message-ID: <3ed212d00912170412q793c9cfja032bc41a712f0df@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Dec 17, 2009 at 12:47 AM, Andreas Dilger <adilger@sun.com> wrote:

> On 2009-12-16, at 10:24, Yuriy Umanets wrote:
>
>> Andreas Dilger wrote:
>>
>>  Peter Braam wrote:
>>> > 2. We need MUCH more in the repository than Sun is putting into it.
>>> >
>>> > There are many development branches and sometimes abandoned projects
>>> > that still have a lot of value.  For example, there is a nearly
>>> > complete OS X client port - what if someone wanted to pick that up?
>>> > Similarly, there are projects like size on MDS or the network
>>> > request scheduler that may need help from the community to get
>>> > finished or re-prioritized.
>>>
>>> All of the Lustre history is still available in CVS, as it has always
>>> been.  As far as I know (I've never checked it out myself) even the OS/
>>> X client port is publicly available today, which was not true a few
>>> years ago.
>>>
>>
>> I would say, some time ago publicly available cvs repository "did not feel
>> well".
>>
>
> Was this from a checkout, or only via CVS scraping tools like cvs2git?


For example, git cvsimport. Additionally, cvs contained *.*,v files in wrong
format

>
>
>  I could not find cmd2 (seems to be not available todays too), gns or even
>> cmd3 code
>>
>
> Doing a "cvs log lustre/ChangeLog" shows that tags for all of those
> projects exist on that file.  I haven't tried to do a checkout of one of
> those tags, but I'd expect them to be there.  I know that ages ago some
> branches were deleted (in particular b_devel), but I don't think there is
> anything of interest there.
>

Cannot recall exactly, seems that I could not checkout specific
tags/branches while tags them selves were existing. Is it possible that I
happen to do that in the middle of some cvs migration process? I know there
were couple of them lastly.

>
>  and any attempt to convert it to git or do anything that requires "cvs
>> rlog" resulted in this:
>>
>> cvs [rlog aborted]: unexpected '\x0' reading revision number in RCS
>> file /lustre/lustre-core/demos/Attic/snaprest.sh,v
>> exit: 1
>>
>> Obviously demos/snaprest.sh,v contained garbage. Now it seems to be fixed.
>>
>
> This file was corrupted at some point in the past (binary zeros appended to
> the file), as was documented in bugs 17080 and 18564.  That was fixed this
> past summer when we started our own Git conversion process and noticed the
> same problem.
>
Sorry to contradict but it was not fixed at Sep 21, the date I tried it last
time.


>
> That was never a problem for checking out useful branches either internally
> or externally, because I don't think snaprest.sh was used since early 2000
> when Peter and I were working on snapfs, and it was deleted several years
> ago due to being completely obsolete.  It only was noticeable when trying to
> scrape the entire repository, including all of the history.

Yeah, unfortunately it was in "demos" directory which is one of first, so
that, it failed very quickly.

>
>
>  I think this is why Peter said it is "not clear" if all valuable branches
>> are available in public cvs.
>>
>
>
> It's unfortunate that incorrect conclusions were reached with incomplete
> data.
>
> The problem isn't whether all of the valuable branches are available in
> CVS, but rather which branches are the valuable ones?  I just checked, and
> there are 7638 tags in CVS, including 453 branches and 490 release tags.  If
> there are some useful bits in there that you are aware of, I'd be happy to
> see them extracted from the rest and brought back to life.

Sure I can name some of them but only those I participated or aware of.
Little % of those thousands tags:

mac os client, cobd + cmobd + mds on tmpfs, gns, cmd2, cmd3 branches, som,
crow (may be), hendrix project tests for cmd2 and cmd3

Thanks.


>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>


-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091217/d9bb45f8/attachment.htm>
