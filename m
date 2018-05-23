From: NeilBrown <neilb@suse.com>
Date: Wed, 23 May 2018 10:57:05 +1000
Subject: [lustre-devel] Regression with delayed_work in sec_gc
In-Reply-To: <BN3PR1101MB120293F9E3AA076CA0B339CECB940@BN3PR1101MB1202.namprd11.prod.outlook.com>
References: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
 <87sh6s5zjy.fsf@notabene.neil.brown.name>
 <E4BBDF07-0165-4306-9846-382D2D0A9C3D@ddn.com>
 <87r2m5ztsr.fsf@notabene.neil.brown.name>
 <79108C6E-9FC1-44E8-9B3A-AB7FE3A4C5DE@intel.com>
 <874lizz6lq.fsf@notabene.neil.brown.name>
 <BN3PR1101MB120293F9E3AA076CA0B339CECB940@BN3PR1101MB1202.namprd11.prod.outlook.com>
Message-ID: <87vabfxk7y.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 22 2018, Patrick Farrell wrote:

> Neil, Andreas,
>
> A few thoughts I?d be curious to see one or both of you speak to.
>
> 1. Supporting multiple kernels has historically been important because
> Lustre is integrated in to various different HPC setups and they value
> being able to move distribution versions and Lustre versions
> independently.  Cray, for example, is less interested in upstream than
> we might be in part BECAUSE we use SLES as the base for our HPC distro
> and have a need for very recent versions of Lustre.  Long term, how
> would we square the desire to use enterprise distros and new versions
> of Lustre? 
>

We resolve this the same way that every enterprise distro handles every
other important filesystem and every major chunk of the kernel.
We develop upstream, and back-port to our enterprise kernels.  Sometimes
our partners help with the backport, sometimes we just do it ourselves.
For example, SLE12-SP3 currently has about 500 patches to btrfs, many
of which a backports, and a fair few of those were probably developed by
SUSE for SLE12 - submitted upstream and backported to SLE.
NFS and XFS have about 100 patches each.
Backporting well-written patches is not that hard.

This is pretty much was Peter Jones says in his reply.

> 2. The Lustre server code remains out of tree.  Until it?s in, it?s
> difficult for me to see development getting fully invested in
> upstream, since a key component - which is normally distributed as a
> unified whole, at least for source - is out of tree.  Thoughts on
> that? 

My main thought is that it is crazy that we have the client in Linux but
not the server.  However that ship obviously sailed long ago.  One of my
first priorities after getting lustre-client out of staging will be to
get lustre-server into staging. It makes zero sense to develop them
separately.

>
> 3. This is perhaps not so much a question for either of you, but it?s
> one I?m curious about anyway.  What?s the route out of staging and
> what happens after?  Provided we keep cleanliness high and duplication
> of existing functionality minimal, will the community accept a ton of
> feature drops?  If we have to dribble in existing features slowly,
> people will remain reluctant to use the upstream version for as long
> as that goes on.

The path out of staging is to remove all the warts we can find, address
all the issues that have been raised in the past, then say "please".
If people don't see things they hate, they'll probably just shrug.
If they do, we will respond to their concerns and have a productive
discussion.  "Established user base" carries a lot of weight with
Linus - not enough to suppress the gag-reflex, but enough to ignore the
whiners.  So if we had well-documented cases of people using the
code that is in Linux, and indications of interest from other
stake holders, that would be an important part of the sell.

Once it is out of staging, we need a small groups of maintainers who
will review patches and forward pull requests directly to Linus.  Linus
tends to be willing to trust people who have demonstrated competence -
until they betray his trust.  I don't know how much he will look at the
patches at first, but over time he is likely to do little more than
glance at them.  He is more likely to respond to valid complaints from
other maintainers, than to poor code from us.  We should minimize the
later to avoid the former.

I think the first priority would be to go through all the patches in
out-of-tree lustre that landed since it was forked into drivers/staging
and port all those that are relevant.  Nobody outside of the lustre
community will care much what features actually land as long as they
don't introduce horrible APIs or duplicate functionality - and they
might not even notice if they do.  If we simply maintain the same level
of quality as we achieved to get out of staging, there should be no
problem.


>
> Perhaps Greg?s suggestion of going temporarily out of tree, cleaning
> up, and coming back with everything would be better?  That?s radical,
> I know, but... 

I know I proposed this at one stage too, but I'm currently firmly
against the idea.  The benefits from staying in-tree include:

- protection against bit-rot.  If someone changes an interface that
  lustre uses, they will change lustre along with everything else that
  is in-tree.  If lustre is out-of-tree we have to do that ourselves
  and will have less expertise in the reason for the change, and less
  opportunity to disagree with it if it hurts lustre

- community credibility.  If we have an established history of working
  upstream, people both within and without the community will see that
  and take the in-tree version of lustre more seriously.

- extensive testing by static checkers and other automated tests.
  I know lustre has a jenkins which does good stuff, but the more
  automated testing that happens, the better.

Conversely, I don't see any value in moving out-of-tree.
All the barriers that you might see to in-tree development are there to
make the code better - we benefit from them.  I think it would send
entirely the wrong message to leave.
My concern, when I mentioned it, was that it seemed that no-one was
testing in-tree code: I was hits serious bugs very easily.
My concerns in that direction have been mostly allayed.   It seems
people really do use and test linux/lustre - I just got lucky with a
particular combination of test options :-)

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180523/b9e39d15/attachment.sig>
