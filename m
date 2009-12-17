From: David Dillow <dillowda@ornl.gov>
Date: Wed, 16 Dec 2009 21:53:13 -0500
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <4B2966C3.1050707@llnl.gov>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<4B280B89.3010303@llnl.gov>
	<F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
	<4B283577.3070905@llnl.gov>
	<9784AD2F-B1E4-4A48-BDB5-6B932437EBD9@sun.com>
	<4B2966C3.1050707@llnl.gov>
Message-ID: <1261018393.30644.53.camel@obelisk.thedillows.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-12-16 at 15:01 -0800, Christopher J. Morrone wrote:
> Andreas Dilger wrote:
> > For developers that aren't keeping a huge number of patches, and 
> > especially not a large number of dependent patches, "git rebase" is 
> > probably sufficient. That will refresh the patches against changes in 
> > the upstream repository.
> 
> Except that "git rebase" is a destructive operation, right?  It is fine 
> for the single developer to do that, but you basically can't rebase a 
> branch that you have published.  Here is the kind of comment that I see 
> associate with git rebase over and over on the web:
> 
> "You should only use git rebase on your local-only branches. Its purpose 
> is to keep your local, invisible changes up-to-date so that when you 
> publish them they'll be more relevant and easy to understand for others."
> 
> So rebase is off limits to us when managing our published "llnl" branch. 
>   (This is also why topgit uses "git merge" internally, not "git rebase".)

It's not a rule written in stone. If you have branches on which you
expect others to base their work, rebasing is painful for them as they
have to keep rebasing their work on top of the ones you do. But, this
can be OK if this is communicated to those that would follow your work.
Dave Miller used to rebase often with the net-2.6 tree, but stopped due
to the pain it was causing people working with him; it does occasionally
get rebased (and an email sent to netdev) if there is a problem that
would result in intolerable ugliness in the history.

linux-next is essentially rebased every day, but keeps tags to the
previous heads so that they don't get lost. Ie, if one wants to develop
against linux-next, they should use a tag such as next-20091216 to get a
stable base as master gets rewound daily. Similarly, the "pu" branch of
git is often rewound, and this fact is well advertised.

Certainly, if your changes are to go upstream via git pull and not via
an email patch series, then I think rebasing -- at least before the send
-- is a good idea, just to keep the history clean of distracting commits
like "Oops, forgot to add this file."

-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
