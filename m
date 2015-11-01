From: Michael Shuey <shuey@purdue.edu>
Date: Sun, 1 Nov 2015 18:24:18 -0500
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: checkpatch cleanups
 for nidstring.c
In-Reply-To: <229dae23c2f34950a21db4bd6dbdcfba@EXCHCS32.ornl.gov>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
	<1446161303-798-2-git-send-email-jsimmons@infradead.org>
	<20151030230148.GB2920@kroah.com>
	<229dae23c2f34950a21db4bd6dbdcfba@EXCHCS32.ornl.gov>
Message-ID: <CABqvwjtkS-uQH5e0zbCKFq3pkZSGrj6wo80SDa6PLgtKFVgUTA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I suspect you're over-thinking it.  The maintainers appear to be
reacting to the different types of style changes - "checkpatch
cleanups" is an awfully broad commit message.  I'd suggest breaking
this patch (and any others like it) into two pieces; one with
whitespace cleanups, and one with the "== NULL" fixes (and mentioning
both by kind in the commit message, rather than just attributing to
checkpatch).  Then issue a v2 of the series, and see where you land.

Of course, YMMV. :-)

--
Mike Shuey


On Sun, Nov 1, 2015 at 6:07 PM, Simmons, James A. <simmonsja@ornl.gov> wrote:
>>On Thu, Oct 29, 2015 at 07:28:21PM -0400, James Simmons wrote:
>>> With nidstring now having the latest fixes we can
>>> now clean up all the remaining checkpatch errors
>>> for nidstring.c.
>>
>>Please be specific as to exactly what you changed, and break it up into
>>one-patch-per-thing.  And no, "fix all checkpatch errors" is not "one
>>thing"
>
> Hmm. This makes me think I might be going about this wrong.  Instead of
> doing style changes per file I should be doing one style change per subsystem
> instead. Unless you prefer doing these style changes on per file base. Perhaps
> for now I should focus on pushing the fixes that have cumulated and once
> caught up then finished off the style issues.
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
