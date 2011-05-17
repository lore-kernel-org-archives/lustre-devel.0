From: Nic Henke <nic@cray.com>
Date: Tue, 17 May 2011 09:30:08 -0500
Subject: [Lustre-devel] replacing Lustre pings with LNet Peer Health
In-Reply-To: <4DCC1AEF.8020705@llnl.gov>
References: <4DCBF565.3060602@cray.com> <4DCC1AEF.8020705@llnl.gov>
Message-ID: <4DD28670.1090609@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/12/2011 12:37 PM, Christopher J. Morrone wrote:
> I think Eric's approach is the only sane way I've heard to reduce pings.
>
> Here are some issues that I see with this:
>
> 1)  For your solution to work, you require that the lnet layer take on
> pinging duties.  Usually the network, be it IB, TCP, whatever, will not
> provide any active notification of a peer failure.  To notice that a
> peer has died, the lnet LND must, you guessed it, ping.
>

Correct. I had assumed the LNDs would or could be doing the pinging. At 
worst it'd be done on a per-peer basis and not per-import, reducing the 
traffic somewhat. It'd also reduce the number of layers that need to be 
involved in the message RX, providing some CPU usage benefit.

> Usually the LNDs try to be smart.  They only generate their own pings if
> no traffic has been sent to the peer in a certain period of time.  So
> once you eliminate the higher-level pings, they will partly be replaced
> by lower-level pings.

Correct, and I thought that sufficient to provide reasonable notification.

Given the LNet router case, I think this idea is a bit DOA... unless I 
find some sort of non-gross magic :-)

Cheers,
Nic
