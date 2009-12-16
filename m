From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 16 Dec 2009 15:01:23 -0800
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <9784AD2F-B1E4-4A48-BDB5-6B932437EBD9@sun.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<4B280B89.3010303@llnl.gov>
	<F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
	<4B283577.3070905@llnl.gov>
	<9784AD2F-B1E4-4A48-BDB5-6B932437EBD9@sun.com>
Message-ID: <4B2966C3.1050707@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:

> I know that Brian Behlendorf and Ricardo investigated a number of 
> different tools for managing patches, and topgit was the one they 
> chose.  Another tool in this vein is "guilt", which manages a patch 
> series in a way similar to "quilt".

Yes, I have discussed this at length with Brian.

The main problem with guilt is that seems to be designed with the single 
developer in mind, and not really well suited for sharing.  The major 
problem being that the patches and series information are not stored in 
git.  You need to come up with your own method of storing and keeping 
track of the patch set.

With topgit, anyone can simply clone our repo and checkout the "t18/top" 
branch of lustre, and have a tree that contains all of our patches. 
They don't really even need to use topgit.  And, in fact, I think Brian 
is the only person using topgit directly on the project that you are 
referring to.  The others usually just branch off one of his topgit 
branches and pass patches back to Brian.

> For developers that aren't keeping a huge number of patches, and 
> especially not a large number of dependent patches, "git rebase" is 
> probably sufficient. That will refresh the patches against changes in 
> the upstream repository.

Except that "git rebase" is a destructive operation, right?  It is fine 
for the single developer to do that, but you basically can't rebase a 
branch that you have published.  Here is the kind of comment that I see 
associate with git rebase over and over on the web:

"You should only use git rebase on your local-only branches. Its purpose 
is to keep your local, invisible changes up-to-date so that when you 
publish them they'll be more relevant and easy to understand for others."

So rebase is off limits to us when managing our published "llnl" branch. 
  (This is also why topgit uses "git merge" internally, not "git rebase".)

> As for tracking hidden semantic conflicts that do not have contextual 
> conflicts, that is of course more difficult.  I think one important way 
> to track this is that our own commit message policy will be to include 
> the bug number into the "short" (one line) patch description, and if you 
> do a "git rebase" against the updated repo and your patch for that bug 
> does not disappear due to the upstream commit for that bug, the patch 
> should be reviewed.

Yes, that might work.  I am hoping that it will work, but I am not 
entirely convinced yet.  If we were using git rebase, our history would 
be shorter and easer to follow.  But we can't use rebase.  So I'm not 
sure how easy it will be to track things using the log with repeated merges.

Maybe we just need to try it and see how it goes.

> I think that depends on how topgit is doing the updates against the 
> upstream repository.  If it is doing a "rebase" each time, then there 
> should only be a single git branch (each with a single commit) for each 
> patch that you have applied.  If it does this via a "merge" then there 
> will be new commits for each pull that you do from upstream that is 
> resolving conflicts, and the repo will become a mess.

It uses "git merge", because "git rebase" would basically make the whole 
thing unsharable.  Many of the merges turn into fast-forwards, but not 
all of them.

Chris
