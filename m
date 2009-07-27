From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 27 Jul 2009 08:55:15 -0500
Subject: [Lustre-devel] Kerb cross-site-forcing back clients to
	null/plain
In-Reply-To: <Pine.LNX.4.64.0907021313320.20445@pscuxa.psc.edu>
References: <Pine.LNX.4.64.0907021313320.20445@pscuxa.psc.edu>
Message-ID: <20090727135514.GW1020@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jul 02, 2009 at 01:21:34PM -0400, Josephine Palencia wrote:
> Is there/can there be a mechanism by which kerb auth on the 
> clients both from local & different kerb realm can be forced back to
> null/plain from krb5n/a/i/p if the remote site's kerb is not
> yet ready (properly configured)?
> 
> I'd rather the filesystem continues to be mounted on the client and 
> indicates it did so auto-reversing back to null/plain instead of just 
> hanging.

If a client could "force" a server to disable security features, then
there'd be no real security :)

If a server gives a client a choice then the client can pick from those
choices, but there's no "forcing" there.

So the answer would be "no".  And if the issue is that the cluster is
misconfigured, well, I'd say that the configuration should be fixed.

That said, we should support giving the client a choice of krb5* and
null, since that is helpful during deployment.  I'll look into that,
though it could well be that Lustre already supports that (I'm new to
Lustre).

Nico
-- 
