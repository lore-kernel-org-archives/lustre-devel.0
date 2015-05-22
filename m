From: Michael Shuey <shuey@purdue.edu>
Date: Fri, 22 May 2015 18:48:26 -0400
Subject: [lustre-devel] [PATCH v4 00/13] staging: lustre: lnet: code
	cleanups
In-Reply-To: <20150522092142.GJ4150@mwanda>
References: <1432237849-53947-1-git-send-email-shuey@purdue.edu>
	<20150522092142.GJ4150@mwanda>
Message-ID: <CABqvwjsJXJYciMDHqy9vEdL6dGLhx3+Pi0_ro6192Z5SGR9Q_w@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I can definitely clean up the issues you (and others) have raised, and will
work on breaking up the larger changes into smaller, topic-based sets as
well.  I could use some instruction on how to proceed, though...

I presume in this case I should've flagged this series as an RFC, and
started to advertise a merge-able patch when most of the feedback was
resolved (and not added additional cleanups to the series already under
review).  What do I do with the cleanups in the present case - re-label
them as an RFC, repost all patches for comment (including the things added
in what I've labelled v4), and send a final patch series when all comments
are resolved?  Or break them up into the previous PATCH v3 set, which had
no comments, plus a second series tagged RFC (at least until I've got a
sense of appropriate cleanup and granularity)?

Also, in the future, at what point is it safe to assume a set of patches
will be merged?  And how do I indicate dependencies between series of
patches?  This last is fairly important to me, given the overlaps with some
of James' work; we're beginning to coordinate via email, but I'd like to
find out the general expectation here (and hopefully avoid this sort of
faux pas going forward).

Many thanks for your continued feedback and advice, Dan.

--
Mike Shuey

On Fri, May 22, 2015 at 5:21 AM, Dan Carpenter <dan.carpenter@oracle.com>
wrote:

> On Thu, May 21, 2015 at 03:50:23PM -0400, Mike Shuey wrote:
> > This patch series cleans up code in staging/lustre/lnet - mostly spacing
> > and dead function cleanup.  Should apply against linux-next 20150518.
>
> Why are you sending a v4 of this?  We don't actually enjoy reviewing the
> same patchset over and over...
>
> Update:  I have investigated and it is because you add a few new patches
> to this set which were not in the original.  Just assume that the
> original patchset will be merge and send the additional patches as a new
> set.
>
> Also since no one replied to the v3 patchset and Greg has a 5000 patches
> in between v3 and v4 he will not seen v4 until days after he has applied
> v3 so it causes confusion.
>
> Also you sent a v5 of this patchset but without a v5 label...
>
> regards,
> dan carpenter
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150522/6dcc1c28/attachment.htm>
