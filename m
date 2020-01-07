From: NeilBrown <neilb@suse.de>
Date: Tue, 07 Jan 2020 15:32:20 +1100
Subject: [lustre-devel] Lustre upstreaming status.
In-Reply-To: <8E3FD560-7730-49D7-B5F5-0EC2BD08E149@whamcloud.com>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87sglgg9ub.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
 <8E3FD560-7730-49D7-B5F5-0EC2BD08E149@whamcloud.com>
Message-ID: <87woa3dgyz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


(sorry for including the intel addresses in the original :-( )

On Tue, Jan 07 2020, Andreas Dilger wrote:

>
> I thought the goal was to stop at 2.12.x (following the b2_12 branch to get
> important fixes) and try to get that included upstream?  That gives a good
> point-in-time to track, and ensures that the upstream code is aligned with
> a relatively stable version of the code.  It also has the major benefit that
> 2.12 is an LTS branch and we will need to keep compatibility with that for
> a long time, which isn't always true of intermediate releases.

That was suggested at Houston, but I was against it.  I think I said I
would considered it going all the way to 'master' looked like too much
work - but it didn't.

Upstream Linux is not a place for old code.  It is a place for
developing new code.  If we don't submit the latest code to Linux,
people will want to know why.

Bug fixes will flow into the 'stable' releases with little or no effort
from the lustre team.  For the "community" face of lustre, this is
really all you need.

Compatability is import, but there should be no need to break it.  There
are feature flags (or similar) in the protocol, and a modest amount of
care with using them should avoid obvious breakage.

You don't need to test every single combination - you can assume that
people who care are doing that testing.  If someone reports a
compatability regression, we need to fix it.  But if no-one reports one,
then no fix is needed.

Obviously you will test the combinations that you support for your
customers - just as you do now.

We must have a long term goal of doing all (kernel) development against
upstream, and have it appear upstream first.  The lustre-release from
whamcloud will eventually contain no stand-alone kernel code.  Just
user-space code and a selection of backported patches (maybe).

So think of upstream-linux much the same way that you currently think
about "master".  My focus is to keep the two in-sync, so that thinking
this way will be natural.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200107/02bc058f/attachment.sig>
