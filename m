From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 05 Mar 2009 10:05:22 -0800
Subject: [Lustre-devel] Security configuration
In-Reply-To: <014901c9913f$94f0b560$bed22020$@com>
References: <014901c9913f$94f0b560$bed22020$@com>
Message-ID: <49B01462.1020001@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> Nathan,
>
> We'd like to be able to describe a set of nodes and say that
> as far as security is concerned, they are all equivalent - i.e. if
> an MDT authorizes eeb at node1 to perform a certain action, then
> eeb at nodex is implicitly authorized provided node1 and nodex are in
> the same set.
>
> Leaving aside for now, the question of how the sets are described
> (they could be whole LNETs or whole Kerberos realms, or NID lists),
> is the MGS the right place to stash this config?
>   
Yes, I think the MGS is the right place to stash any config.
FWIW we're pretty seriously thinking about removing all the distributed 
configuration we can (mkfs/tunefs.lustre settings and module parameters) 
and concentrating it all on the MGS node in a text-based config file.   
Exceptions would have to be made for the network setup, so that everyone 
could talk to the MGS -- so lnet networks and MGS nids would still have 
to be stored locally.
