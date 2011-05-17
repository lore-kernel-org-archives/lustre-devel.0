From: Isaac Huang <isaac_huang@xyratex.com>
Date: Tue, 17 May 2011 16:53:24 -0600
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <4DCBF565.3060602@cray.com>
References: <4DCBF565.3060602@cray.com>
Message-ID: <20110517225324.GA2007@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, May 12, 2011 at 09:57:41AM -0500, Nic Henke wrote:
> ......
> Issues...
> 
> - lacks "proof" that peer nodes ptlrpc queues are moving forward,
> but not really sure that is all that important in terms of pinger
> evictions.
> 
> - LNet peer health is a bit "weird" in that it requires an upper
> layer sending a packet to trigger a node moving back to 'up'. We
> would need to address this for proper LNet peer health as it is.

The idea was that if upper layer has no interest sending him a message
LNet is not bothered whether he's become "up" again. But care must be
taken such that a message from upper layer must not be dropped if it's
destined to a peer that appears "dead" but LNet isn't so sure of it,
i.e. that death news was too old and we haven't tried to get some
update yet. All is so that unnecessary pings could be cut off.

This is also why router pinger can't be replaced by Peer Health -
there'd be no more message to a dead router without router pinger
being active.

As others have pointed out, Peer Health is not end-to-end.

Thanks,
Isaac
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
