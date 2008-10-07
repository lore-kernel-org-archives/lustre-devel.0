From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 07 Oct 2008 13:13:08 +0400
Subject: [Lustre-devel] MDWBC and how much to trust clients
In-Reply-To: <18666.13572.686218.818001@gargle.gargle.HOWL>
References: <1FEDA9D966B34039AF0EC15DBD0E4BAA@eblap>
	<18666.13572.686218.818001@gargle.gargle.HOWL>
Message-ID: <18667.10276.857149.242018@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov writes:
 > Eric Barton writes:
 >  > Nikita,
 > 
 > Hello,

[...]

 > 
 > as Peter mentioned, we discussed this topic during the Moscow
 > meeting. If I am not mistaken, we converged to the idea that before
 > committing an epoch, every mdt composes some kind of a `summary',
 > containing enough information for verification of a global consistency,
 > and this summary is passed though every server as a ticket, with every

This can be simplified. Suppose total amount of `data', describing all
updates within given epoch is D, and there are N md servers in a cmd
cluster. Then total network traffic incurred by this algorithm is

             D   /* updates from client to all servers */ +
             D*N /* cycle summary through all servers */

that is, (N + 1)*D bytes, transferred in 2*N messages. So we won't
increase network traffic by broadcasting _all_ epoch updates to _every_
server (so that each server gets complete set of all updates within the
epoch). In this latter case, servers can prove that epoch is consistent
by

    - checking global consistency locally,

    - calculating md5 signature of all epoch updates, and

    - exchanging these signatures, to check that client sent the same
      set of updates to everybody.

This results in

             D*N /* broadcast epoch updates to all servers */ +
             e*N /* exchange signatures */

that is N*(D + e), for some small e, bytes transferred in 2*N
messages. Having complete set of updates on every server would probably
help in other places too.


 > server `approving' some bits in the summary accumulated so far, and

[...]

 >  > 
 >  > Thoughts?
 >  > 
 >  >     Cheers,
 >  >               Eric
 > 

Nikita.
