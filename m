From: Peter Braam <peter.braam@clusterstor.com>
Date: Sun, 13 Dec 2009 11:47:37 -0700
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
Message-ID: <2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian Reitz sent an email about GIT, that raises some questions, and I would
like to initiate some discussion here how we can reach the best
organization.

1. We need a public repository, where non Sun community members can commit.

a.  There are Lustre users than have their own branches.  LLNL has probably
the best tested branch among all users.  DDN's customers have a version of
Lustre that includes patches not yet in Sun's releases.  It would be very
valuable if these kind of releases could be collected in a publicly
accessible GIT repository.

I doubt that Sun will give commit rights to external entities (this is not
unreasonable, Sun needs to control what code enters its repositories).
 Hence I think that the community would be better served with a GIT
repository in a public place, like github, that can give such access.

My group at ClusterStor has reserved the "lustre" project at Github and we
will give keys to any and all organizations that wish to make serious
contributions to Lustre.  I was in particular hoping that LLNL would be
willing to commit their releases to that public place.

b.  Everyone is uncertain about what Sun will do with Lustre (proprietary
Solaris / ZFS server releases and discontinued support for Linux servers
have been mentioned to me several times now).  A public repository with the
open code will be valuable for the community and promote continued
development and access.


2. We need MUCH more in the repository than Sun is putting into it.

There are many development branches and sometimes abandoned projects that
still have a lot of value.  For example, there is a nearly complete OS X
client port - what if someone wanted to pick that up?  Similarly, there are
projects like size on MDS or the network request scheduler that may need
help from the community to get finished or re-prioritized.

It is unclear to me if these kind of branches can be found in the publicly
available CVS.  If they can, a collection of relevant branches, broadly
along the lines of what I mention above, should be placed in the public GIT
repository.

3. Brian's email message seems to indicate that Sun's git repository will be
used for Sun development.  In the past there were two CVS repositories - a
read-only one that was publicly accessible and when I last controlled the
group it was updated very frequently with all open source code (presently,
it seems to only contain releases, not the development stream of commits).
It is unclear how Sun can manage development with this git repository given
that parts of its work are proprietary (like the Windows port) or unreleased
(like the ZFS work).  Can we get more insight in what Brian is alluding to?


I am sure other community members have further suggestions, and I hope we
can discuss these here.  If there is support for github as a good location,
please let me know and we will give participants the keys.  In particular I
would like to publicly request that community members like LLNL that have
quite possibly the highest quality releases, place them in github or publish
another location where these can be found.

Thank you very much for your thoughts.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091213/e10f165a/attachment.htm>
