From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Wed, 18 Feb 2009 17:19:00 -0600
Subject: [Lustre-devel] Security configuration
In-Reply-To: <014901c9913f$94f0b560$bed22020$@com>
References: <014901c9913f$94f0b560$bed22020$@com>
Message-ID: <20090218231900.GQ9992@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Feb 17, 2009 at 08:37:42PM +0000, Eric Barton wrote:
> We'd like to be able to describe a set of nodes and say that
> as far as security is concerned, they are all equivalent - i.e. if
> an MDT authorizes eeb at node1 to perform a certain action, then
> eeb at nodex is implicitly authorized provided node1 and nodex are in
> the same set.
> 
> Leaving aside for now, the question of how the sets are described
> (they could be whole LNETs or whole Kerberos realms, or NID lists),
> is the MGS the right place to stash this config?

As far as Kerberos V principal names go, then the name will be eeb at REALM
throughout.

As for what happens with identities on the wire (for GET/SETATTR), this
is where ID mapping comes in.  Here the configuration that matters will
be local to each client (what domain name to assert) and to the MDS
(what clients to trust).

Nico
-- 
