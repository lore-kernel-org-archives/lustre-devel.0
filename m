From: Eric Barton <eeb@sun.com>
Date: Sat, 06 Feb 2010 12:28:45 +0000
Subject: [Lustre-devel] server-side resending & bulk transfer
In-Reply-To: <20100205202013.GN1061@Sun.COM>
References: <20100205163524.GW236@granier.hd.free.fr>
	<002d01caa686$72c40d40$584c27c0$@com> <20100205202013.GN1061@Sun.COM>
Message-ID: <008101caa727$ed16ad90$c74408b0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Nico,

> -----Original Message-----
> From: Nicolas Williams [mailto:Nicolas.Williams at Sun.COM]
> Sent: 05 February 2010 8:20 PM
> To: Eric Barton
> Cc: 'Johann Lombardi'; lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] server-side resending & bulk transfer

<snip>
 
> I agree that tying down a server thread on a long block is not a good
> thing.  If the LLNL proposal (resend the start bulk signal) is on the
> money, then the thing to do would be to create a queue and separate
> service thread(s) to handle such resends.

That's a dreadful layering violation - how LNET implements
GET and PUT is down to each LND in each network traversed.  The only
think you can do at the Lustre level is retry the GET or PUT on the
assumption that router failure caused the timeout, not the client's
death.
 
> > Roll on the health network! :)
> 
> Well, if the deadline here is on the order of 1s or thereabouts then the
> health network isn't likely to help much because we're not going to get
> sub-second dead node detection.  (Well, if we jack up the ping rate and
> reduce the time-to-declare-death low enough, and make sure that HN
> threads and messaging are suitably prioritized, then we might be able to
> get sub-second dead node detection, but my gut feeling is that any
> heuristic approach should wait for longer than 1s.)

The point is that the server can legitimately dedicate a thread retrying
communications with the client until it discovers the client is dead.  
Currently the bulk timeout is the sole, yet unreliable indication of
this.  A health network that provided reliable notification within 10s
of seconds would be a considerable improvement.

    Cheers,
              Eric
