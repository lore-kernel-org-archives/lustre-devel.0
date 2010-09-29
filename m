From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 28 Sep 2010 17:38:26 -0700
Subject: [Lustre-devel] git pull --rebase
Message-ID: <4CA28A82.9040406@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I've noticed that lustre developers may not be aware of the "git pull 
--rebase" option.

In the git history, there are frequently little forks and merges that 
can be avoided.  For instance, around many of the tags on master: one 
person will create the tag and push it to prime, meanwhile someone else 
has created a couple of commits on their local branch.  When they try to 
push to prime, they probably get a reject message because their local 
copy is out of date.  To resolve, they do "git pull", which results in a 
merge, then "git push".

This results in the little forks and "Merge branch 'master' of 
git.lustre.org:prime/lustre" commits" in the history.  At least I think 
that is how it happens.

This can be avoided by using "git pull --rebase" when you want to bring 
your local branch up to date with prime.  Where as "git pull" 
essentially does:

   git fetch
   git merge

"git pull --rebase" more-or-less does:

   git fetch
   git rebase

Its a little more complicated than that under the covers, but 
essentially it just temporarily removes your local commits, 
fast-forwards your local branch to catch up with the remote branch, and 
then replays the commits.

It is not a big deal, but using --rebase would keep the history a little 
cleaner.

Chris
