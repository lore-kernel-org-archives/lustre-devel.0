From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 6 Oct 2011 02:13:05 +0100
Subject: [Lustre-devel] question about failover
In-Reply-To: <CAO=bG7q_TAbkwX_S7j6nRQihgQVb-xDCFX5eDHedSK+oA1Yr2g@mail.gmail.com>
References: <CAO=bG7pWxqBX-U6Vp+cJV_jZMui2JbdEUaxVWvHLMqFn6Vv24w@mail.gmail.com>	<03d501cc8384$f39d3630$dad7a290$@com>
	<CAO=bG7q_TAbkwX_S7j6nRQihgQVb-xDCFX5eDHedSK+oA1Yr2g@mail.gmail.com>
Message-ID: <044a01cc83c5$1b0a5640$511f02c0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Peter,

 

LNETs are cliques, so in the example I gave, R1 and R2 both had connectivity to S1 and S2.

Redundant routers like this are required to ensure no single router failure "hides" a working
server from some of its clients.  More equivalent routers make partition less likely, but if it
occurs, affected targets that don't fail over to an accessible server will remain inaccessible
as you describe.

 

LNET is oblivious to the success or failure of the RPCs it transports - i.e. RPC failures cannot
change LNET's perception of peer router status.  LNET uses the success or failure of LND
communications with a given peer router to infer its status and upper levels don't even know
which router forwarded which messages.

 

Difficult cases occur when one of a router's networks fails or worse, when communications
between a router and one of its peers fails, but both the router and its peer are healthy.  Such
routers become a black hole for communications to their inaccessible peers.  They really need
to detect this (carefully) and absent themselves from all networks.  IIRC Isaac worked on
this and should know all about it.

 

Cheers,
                   Eric 

 

From: Peter Braam [mailto:peter_braam at xyratex.com] 
Sent: 05 October 2011 8:23 PM
To: Eric Barton
Subject: Re: [Lustre-devel] question about failover

 

Hi Eric -

On 5 October 2011 11:33, Eric Barton <eeb@whamcloud.com> wrote:

Peter,

 

I'm not sure I understand the situation you're trying to describe.

 

 

I'm trying to state that the following topology, as an example, is undesirable:

 

R1 has just one point to point connection with S1

R2 has just one point to point connection with S2

R3 has just one point to point connection with S2

S1, S2 form a failover pair, let's say with one target on S1, no target on S2 under normal operation.  Upon failover S2 takes over
this target.

 

Let's say there is one thread on one client sitting on some network connection to R1, R2 and R3.

 

The reason I think (but I want to verify) it is undesirable is that a client that finds a failure talking to S1 will go to S2,
through R2.  But S2 may not have started services yet to take over from S1, so the client may get no reply at all.  If this silence
leads the client to believe that R2 is not working, then we have a problem, because the client will go to R3 and possibly fail that
also as S2 may still not be ready.  Then no path to S2 remains when it finally boots up.

 

If routers, for example, ACK incoming packets then my suggestion is perhaps not correct.  

 

Please not that the formulation here is the contra-positive of the one I wrote earlier, when I describe how we would avoid this from
happening.

 

Thank you for thinking about it.

 

Peter

 

 

Consider 2 servers (S1, S2) connected to 2 routers (R1, R2) on 1 LNET (N1)

and clients connect to the routers via another LNET (N2).   Normally both R1

and R2 carry traffic between any/all clients on N2 and either server.  

 

If (say) R1 fails, clients on N2 will see communications failures when they

attempt to send to either of the servers via R1 and stop using it.  Similarly, both

servers will see communications failures when they attempt to send to any client

via R1 and they too will stop using it.  

 

Meanwhile, clients will time out RPCs that were affected by the failure of R1

and try to reconnect - first using the affected OST's current NID, then trying

the failover NID.  When they successfully reconnect, they will find that S1's

OSTs are still the "same ones" as before and therefore just resend the failed RPCs.

 

LNET running on both clients and servers will continue to avoid routing traffic

through R1, however they will try to ping R1 occasionally so that they notice

when it comes back and can start to reuse it.

 

If (say) S1 fails concurrently with R1, clients reconnecting after RPCs have

timed out will only reconnect successfully to the failover OST NIDs and

discover that they need to participate in recovery.

 

For all this to work smoothly, we require (a) multiple routers between N1 and N2

to ensure communications between clients and servers can continue in the face of

router failures.   We also need router failure to be detected relatively promptly to

minimize the number of reconnection attempts the clients make.

 

Cheers,
                   Eric 

 

 

 

From: lustre-devel-bounces@lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Peter Braam
Sent: 27 September 2011 1:47 PM
To: lustre-devel at lists.lustre.org
Subject: [Lustre-devel] question about failover

 

Greetings -

 

The general question is how do router failures and server failover interact?

 

My suspicion is that is it necessary for the routing topology and server topology to be such that server failures one wants to
recover from always leave working servers connected to the router, so that at least some traffic makes it through that router, and
it won't be declared failed also.  Is that right?

 

As an example, point to point connections between two routers and a singe failover pair are to be avoided, because it becomes
impossible to distinguish server and router failures.  Is that a rule that is generally followed?

 

Thanks!

 

Peter

______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by
Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message,
please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept
liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept
liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in
California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic
of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
 
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by
Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message,
please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept
liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept
liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in
California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic
of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
 

 

______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by
Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message,
please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept
liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept
liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in
California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic
of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111006/fc9d88d1/attachment.htm>
