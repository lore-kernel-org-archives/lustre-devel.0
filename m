From: Peter Braam <peter_braam@xyratex.com>
Date: Tue, 27 Sep 2011 12:47:17 +0000
Subject: [Lustre-devel] question about failover
Message-ID: <CAO=bG7pWxqBX-U6Vp+cJV_jZMui2JbdEUaxVWvHLMqFn6Vv24w@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings -

The general question is how do router failures and server failover interact?

My suspicion is that is it necessary for the routing topology and server
topology to be such that server failures one wants to recover from always
leave working servers connected to the router, so that at least some traffic
makes it through that router, and it won't be declared failed also.  Is that
right?

As an example, point to point connections between two routers and a singe
failover pair are to be avoided, because it becomes impossible to
distinguish server and router failures.  Is that a rule that is generally
followed?

Thanks!

Peter

______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110927/2d0c1c24/attachment.htm>
