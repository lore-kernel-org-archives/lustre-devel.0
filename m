From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Mon, 14 Dec 2009 17:00:31 -0800
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
Message-ID: <4B26DFAF.2020906@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:

> My group at ClusterStor has reserved the "lustre" project at Github and we
> will give keys to any and all organizations that wish to make serious
> contributions to Lustre.  I was in particular hoping that LLNL would be
> willing to commit their releases to that public place.

First, I'd like to say thanks to Sun.  We are thrilled that they went 
through the effort of switching the repository over to git.

Yes, we at LLNL are happy to make our tree more public.  We have wanted 
to do this for a while, but hadn't spent the time to figure out a 
reasonable method of distribution.  Even with the move to git, it is not 
immediately clear how we should share our branch of Lustre given our 
current work flow.

For a long time, we used a script to create a tarball from Sun's CVS 
repo, and then imported that tree into a branch of our local Subversion 
repo.  All of our changes and maintained a quilt stack of patches.

For a number of reasons, when we started planning our 1.8.2-based 
release a couple of months ago, I transitioned us from Subversion to 
git.  We currently maintain all of our patches using topgit, which 
maintains each "patch" as a separate real "topic" branch in git.

topgit is nice in some ways, but one of its down sides is that it makes 
the git history pretty ugly, with dozens and dozens of merges.  topgit 
allows a DAG of topic branch dependencies, but I decided to keep it 
simple with a stack-like arrangement of patches.

But to make a long story short, I doubt that anyone wants to see our 
topgit noise in a public repo.  So how would we handle an llnl branch in 
a repo on github?

We are willing to change our workflow, and even give up using topgit, if 
someone can suggest a better way.  To some extent, we can try to improve 
our patch development process.  Instead of creating a new quilt 
patch/topgit branch, we could just:

  1) Create git temporary branch
  2) Develop fix, commit, commit, commit...
  3) Condense development branch into one clean commit on the llnl branch.

One issue will be that in parallel, we are going to be submitting this 
patch to Sun via bugzilla.  It is often a month or more before this 
patch is revised and landed upstream.  And if a different version IS 
landed upstream, merging later could be problematic.  At the very least, 
there will be conflicts, but those are easily dealt with.

More worrying is when Sun comes up with a better fix that touches other 
code that our fix.  When we merge from Sun, there is no obvious clue 
that we now have two fixes for the same bug, and while it may not have 
conflicted from git's point of view, the code is now probably broken.

So what is the best way for us to carry our long-term patches in git? 
Any suggestions?

Chris
