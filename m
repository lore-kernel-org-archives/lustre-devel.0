From: Prakash Surya <surya1@llnl.gov>
Date: Tue, 7 Aug 2012 09:08:54 -0700
Subject: [Lustre-devel] merges to b2_<x>
In-Reply-To: <50209FD0.8000306@cray.com>
References: <50209FD0.8000306@cray.com>
Message-ID: <20120807160854.GL6857@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Looking at the man page for git-cherry-pick, I'm not sure the "-x"
option would entirely work:

    "Append the note only for cherry picks without conflicts."

How often do the backported patches apply without conflicts? With the
amount of code change taking place, my guess is conflicts are normal
operation. A developer enforced convention detailing the commit
backported and perhaps what and why changes were necessary to apply
cleanly would suffice. So long as it doesn't clutter the commit message.

Another way to do this would be to use the same Change-Id field for the
backported patch. One could grep for the Change-Id in the commit logs
relatively easily, although I'm not sure how the review system would
handle this.

-- 
Cheers, Prakash

On Mon, Aug 06, 2012 at 09:55:44PM -0700, Cory Spitz wrote:
> Hi.
> 
> We at Cray have been looking at b2_1 landings, and one thing that I 
> think would be nice is if we could identify the master commit that the 
> b2_1 commit is based on directly from the mod header.  Unless, of 
> course, there is an easy way to derive this information via git.  I hope 
> that this isn't a stupid question, but is there?  It seems to me that 
> since most b2_1 commits are cherry picked that we lose that bit.  It 
> seems that git cherry-pick -x might be useful here.  Is that all we need?
> 
> If there isn't an easy way for git to provide the lineage, would we be 
> able to add an additional commit tag or just advertise a convention to 
> follow at http://wiki.whamcloud.com/display/PUB/Commit+Comments?
> 
> Thanks,
> -Cory
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
