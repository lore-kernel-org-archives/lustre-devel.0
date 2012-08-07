From: Cory Spitz <spitzcor@cray.com>
Date: Mon, 6 Aug 2012 23:55:44 -0500
Subject: [Lustre-devel] merges to b2_<x>
Message-ID: <50209FD0.8000306@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi.

We at Cray have been looking at b2_1 landings, and one thing that I 
think would be nice is if we could identify the master commit that the 
b2_1 commit is based on directly from the mod header.  Unless, of 
course, there is an easy way to derive this information via git.  I hope 
that this isn't a stupid question, but is there?  It seems to me that 
since most b2_1 commits are cherry picked that we lose that bit.  It 
seems that git cherry-pick -x might be useful here.  Is that all we need?

If there isn't an easy way for git to provide the lineage, would we be 
able to add an additional commit tag or just advertise a convention to 
follow at http://wiki.whamcloud.com/display/PUB/Commit+Comments?

Thanks,
-Cory
