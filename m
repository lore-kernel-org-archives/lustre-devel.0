From: Andreas Dilger <adilger@sun.com>
Date: Wed, 16 Dec 2009 00:34:55 -0700
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <4B283577.3070905@llnl.gov>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<4B280B89.3010303@llnl.gov>
	<F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
	<4B283577.3070905@llnl.gov>
Message-ID: <9784AD2F-B1E4-4A48-BDB5-6B932437EBD9@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-15, at 18:18, Christopher J. Morrone wrote:
> Lets say that I DON'T use topgit, because it is just going to be  
> confusing for anyone else who tries to look at our repo.  And lets  
> say that I have a branch of lustre that has 50 "patches" against the  
> upstream code (our 1.6.6 branch had 175 patches! lets hope we don't  
> diverge that much again...)
>
> How do I keep track of the logical set of patches?  I am not worried  
> that I will lose them, I'm worried that cruft will accumulate, and  
> that their will be hidden conflicts.  I am worried that llnl will  
> fix the problem one way, and then Sun will fix it another, and now  
> we have two fixes that don't get along in our tree.  Its entirely  
> possible that there will be no contextual conflicts, even thought  
> the fixes don't work together.

I know that Brian Behlendorf and Ricardo investigated a number of  
different tools for managing patches, and topgit was the one they  
chose.  Another tool in this vein is "guilt", which manages a patch  
series in a way similar to "quilt".

For developers that aren't keeping a huge number of patches, and  
especially not a large number of dependent patches, "git rebase" is  
probably sufficient. That will refresh the patches against changes in  
the upstream repository.

As for tracking hidden semantic conflicts that do not have contextual  
conflicts, that is of course more difficult.  I think one important  
way to track this is that our own commit message policy will be to  
include the bug number into the "short" (one line) patch description,  
and if you do a "git rebase" against the updated repo and your patch  
for that bug does not disappear due to the upstream commit for that  
bug, the patch should be reviewed.

I believe there are scripts that can automatically generate "shortlog"  
summaries of git commits, and if LLNL's commit policy is also to  
include our bug number along with some LLNL-specific marker into the  
short description then a simple "sort" should make it fairly simple to  
detect automatically where there are LLNL-applied and Sun patches in  
your repo for the same bug.

> Also, if we commit all of our work to one tree, how do we keep track  
> of which commits belong to the same "bug"?

Via the commit message, as we are doing, is probably the easiest.

> Sun is never going to perform a full "pull" from the "llnl" branch.   
> And rightly so, that would just be too many disparate fixes to  
> digest.  So (at llnl) have two somewhat conflicting goals:
>
> 1) Keep every logical change separate (so we can interact with Sun  
> sanely)
> 2) Keep all changes together (so we can tag and install it :))
>
> Previously we solved the problem with quilt, and now we solve this  
> with topgit.  As long as we do not publish our repo, using topgit is  
> probably going to be fine.  But I am worried that if we publish our  
> repo, the history will just look like nonsense to other (because of  
> topgit), and not be terribly useful beyond those folks that just  
> want to blindly use our latest tag.

I think that depends on how topgit is doing the updates against the  
upstream repository.  If it is doing a "rebase" each time, then there  
should only be a single git branch (each with a single commit) for  
each patch that you have applied.  If it does this via a "merge" then  
there will be new commits for each pull that you do from upstream that  
is resolving conflicts, and the repo will become a mess.

Topgit is actually reasonably well suited to this, because it keeps  
every patch in a separate branch, and it would be possible (I think)  
to pull from just that branch, or possibly to make a clone and then  
delete all of the other branches, and then pull from that.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
