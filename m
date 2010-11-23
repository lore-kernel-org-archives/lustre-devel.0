From: Eric Barton <eeb@whamcloud.com>
Date: Tue, 23 Nov 2010 17:20:58 -0000
Subject: [Lustre-devel] Stripe offset default
Message-ID: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Nick Cardo at NERSC mentioned at the LUG, and again when I chatted
with him at SC10, that setting the default stripe offset is positively
dangerous.  I think he has a point.

Setting file layout precisely can be essential for applications that
know precisely what they're doing and want to control how aggregate
OST load is balanced.  But the default file layout is another matter
entirely.  Setting the default to a fixed layout, or even just a fixed
starting OST has got to be the most direct path to achieving OST load
imbalance.

I believe, now that lfs setstripe uses options rather than positional
parameters, that the risk of unintentional errors is much less.  But
that still leaves the filesystem vulnerable to na?ve or malicious
users.  So I propose that we should continue to check permissions
normally when setting the default stripe _count_, but restrict the
ability to set a specific default stripe _offset_ to the superuser.

Thoughts?

P.S. Do people also agree that setting user/group/ACL permissions on
OST pools would be a Good Thing?

          Cheers,
                   Eric

Eric Barton
CTO Whamcloud, Inc.
