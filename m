From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Thu, 09 Oct 2008 20:13:18 +0400
Subject: [Lustre-devel] MDWBC and how much to trust clients
In-Reply-To: <C5136B78.6085%peter.braam@sun.com>
References: <18667.10276.857149.242018@gargle.gargle.HOWL>
	<C5136B78.6085%peter.braam@sun.com>
Message-ID: <18670.11678.435196.734601@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > You'll need to limit this to the requests that have dependencies.  With the
 > algorithm below every server starts looking at every request - that probably
 > kills the scaling you want to achieve.

I agree that total amount of data can be reduced significantly, but
won't it be sometimes useful to have complete epoch state on all
servers? E.g., we can do server->server replay forward instead of a roll
back.

After all, additional requests are only `looked at' rather than actually
processed. Moreover, global consistency check can be done by one server
only (selected round-robin for each epoch), after which this server
sends md5 signature of total epoch state to other servers to verify.

 > 
 > Peter

Nikita.

 > 
 > 
 > On 10/7/08 3:13 AM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:
 > 
 > > Nikita Danilov writes:
 > >> Eric Barton writes:
 > >>> Nikita,
 > >> 
 > >> Hello,
 > > 
 > > [...]
 > > 
 > >> 
 > >> as Peter mentioned, we discussed this topic during the Moscow
 > >> meeting. If I am not mistaken, we converged to the idea that before
 > >> committing an epoch, every mdt composes some kind of a `summary',
 > >> containing enough information for verification of a global consistency,
 > >> and this summary is passed though every server as a ticket, with every
 > > 
 > > This can be simplified. Suppose total amount of `data', describing all
 > > updates within given epoch is D, and there are N md servers in a cmd
 > > cluster. Then total network traffic incurred by this algorithm is
 > > 
 > >              D   /* updates from client to all servers */ +
 > >              D*N /* cycle summary through all servers */
 > > 
 > > that is, (N + 1)*D bytes, transferred in 2*N messages. So we won't
 > > increase network traffic by broadcasting _all_ epoch updates to _every_
 > > server (so that each server gets complete set of all updates within the
 > > epoch). In this latter case, servers can prove that epoch is consistent
 > > by
 > > 
 > >     - checking global consistency locally,
 > > 
 > >     - calculating md5 signature of all epoch updates, and
 > > 
 > >     - exchanging these signatures, to check that client sent the same
 > >       set of updates to everybody.
 > > 
 > > This results in
 > > 
 > >              D*N /* broadcast epoch updates to all servers */ +
 > >              e*N /* exchange signatures */
 > > 
 > > that is N*(D + e), for some small e, bytes transferred in 2*N
 > > messages. Having complete set of updates on every server would probably
 > > help in other places too.
 > > 
 > > 
 > >> server `approving' some bits in the summary accumulated so far, and
 > > 
 > > [...]
 > > 
 > >>> 
 > >>> Thoughts?
 > >>> 
 > >>>     Cheers,
 > >>>               Eric
 > >> 
 > > 
 > > Nikita.
 > 
 > 
 > _______________________________________________
 > Lustre-devel mailing list
 > Lustre-devel at lists.lustre.org
 > http://lists.lustre.org/mailman/listinfo/lustre-devel
