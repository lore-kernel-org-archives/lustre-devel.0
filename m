From: Eric Barton <eeb@whamcloud.com>
Date: Wed, 5 Oct 2011 18:33:51 +0100
Subject: [Lustre-devel] question about failover
In-Reply-To: <CAO=bG7pWxqBX-U6Vp+cJV_jZMui2JbdEUaxVWvHLMqFn6Vv24w@mail.gmail.com>
References: <CAO=bG7pWxqBX-U6Vp+cJV_jZMui2JbdEUaxVWvHLMqFn6Vv24w@mail.gmail.com>
Message-ID: <03d501cc8384$f39d3630$dad7a290$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

 

I'm not sure I understand the situation you're trying to describe.

 

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
 
 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111005/df8826b6/attachment.htm>
