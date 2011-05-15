From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Date: Sun, 15 May 2011 11:44:28 +0400
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <4DCC1AEF.8020705@llnl.gov>
References: <4DCBF565.3060602@cray.com> <4DCC1AEF.8020705@llnl.gov>
Message-ID: <020AA780-CB93-4FCD-98C4-4ECC5DE749A7@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

One problem.

LNet layer can report - node is live, but one or more ptlrpc services on that node is dead (due a LBUG hit by example).
But yes, generate a LNet event about node is dead is usefull to reduce time of detecting timeout of requests.


On May 12, 2011, at 21:37, Christopher J. Morrone wrote:

> I think Eric's approach is the only sane way I've heard to reduce pings.
> 
> Here are some issues that I see with this:
> 
> 1)  For your solution to work, you require that the lnet layer take on 
> pinging duties.  Usually the network, be it IB, TCP, whatever, will not 
> provide any active notification of a peer failure.  To notice that a 
> peer has died, the lnet LND must, you guessed it, ping.
> 
> Usually the LNDs try to be smart.  They only generate their own pings if 
> no traffic has been sent to the peer in a certain period of time.  So 
> once you eliminate the higher-level pings, they will partly be replaced 
> by lower-level pings.
> 
> 2)  Doesn't work in a routed environment.  Would need a health network 
> for clients behind routers to learn that a server has died, and vice versa.
> 
> On 05/12/2011 07:57 AM, Nic Henke wrote:
>> Just floating an idea... I'd much appreciate any feedback
>> 
>> Given bug 12471 where the ptlrpc pinger traffic on a large system can
>> approach the ridiculous (2.6M pings every 75s for 160 OSTs and 16K
>> clients), I'd like to consider getting rid of the pings entirely.
>> 
>> The idea would be to extend the idea in the attached patch where we add
>> an upper layer callback for lnet_notify() signaling a peer going down or
>> up. The ptlrpc pinger code would be then changed to record the 'down'
>> event for an import/export which would then start an eviction timer that
>> started when the LNet peer was last_alive. If the nodes comes 'up'
>> before the timer expires, no eviction. The eviction code would then only
>> operate on nodes with 'down' events and trusting that the rest are all
>> ok and functional.
>> 
>> Eric - I know this doesn't get us that far down the road toward your new
>> health network, but does solve a near term issue with pinger rates on
>> large systems.
>> 
>> Issues...
>> 
>> - lacks "proof" that peer nodes ptlrpc queues are moving forward, but
>> not really sure that is all that important in terms of pinger evictions.
>> 
>> - LNet peer health is a bit "weird" in that it requires an upper layer
>> sending a packet to trigger a node moving back to 'up'. We would need to
>> address this for proper LNet peer health as it is.
>> 
>> - Might need some beefing up of the standard LNDs to ensure we have good
>> peer health data.
>> 
>> Thoughts ?
>> 
>> Nic
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

--------------------------------------------
Alexey Lyashkov
alexey_lyashkov at xyratex.com




______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
