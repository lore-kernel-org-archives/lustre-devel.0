From: Eric Barton <eeb@whamcloud.com>
Date: Wed, 24 Nov 2010 13:31:50 -0000
Subject: [Lustre-devel] OST pool administration (was RE: Stripe offset
	default)
In-Reply-To: <4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
	<4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
Message-ID: <01b501cb8bdb$f3ff3ac0$dbfdb040$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

> The  proposal for acl / Group / users violates Posix, and may lead
> to results users don't expect.  Sgid directories and inheritance
> on ACLs are safer I think.

This should probably be in a separate thread since I was trying to make
a case for improving the administration storage pools (the classic
gold/silver/bronze scenarios) which is really different from the default
file layout issue.

If the default layout in a directory creates files in the "gold" OST
pool but the user has no permissions for that pool, then returning
EPERM on file creation would potentially be inconsistent with the
permissions on the directory itself.  Is this what you meant by being
inconsistent with Posix?  If so, I'm afraid I don't follow the point
about sgid.

I guess using per-pool quotas rather than permissions might be more
natural.  I'd be interested to hear people's opinions...

          Cheers,
                   Eric
