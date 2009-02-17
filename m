From: Eric Barton <eeb@sun.com>
Date: Tue, 17 Feb 2009 20:37:42 +0000
Subject: [Lustre-devel] Security configuration
Message-ID: <014901c9913f$94f0b560$bed22020$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan,

We'd like to be able to describe a set of nodes and say that
as far as security is concerned, they are all equivalent - i.e. if
an MDT authorizes eeb at node1 to perform a certain action, then
eeb at nodex is implicitly authorized provided node1 and nodex are in
the same set.

Leaving aside for now, the question of how the sets are described
(they could be whole LNETs or whole Kerberos realms, or NID lists),
is the MGS the right place to stash this config?


    Cheers,
              Eric
