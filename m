From: Barton, Eric <eric.barton@intel.com>
Date: Wed, 3 Oct 2012 23:35:11 +0000
Subject: [Lustre-devel] lnet eager receive path
In-Reply-To: <8396A2469279AB46BD407F36A461F14909F00976@CFWEX01.americas.cray.com>
References: <8396A2469279AB46BD407F36A461F14909F00976@CFWEX01.americas.cray.com>
Message-ID: <FAC87753BCAFAD47A698DC08956169330A530D8B@FMSMSX104.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Aaaarrrggghhh - this is a bit of a hack I'm afraid to compensate for a feature (currently) only of the ptllnd.

The issue stems from the fact that LNDs _must_ keep sufficient numbers of buffers posted at all times to ensure they remain responsive to their peers and play their part in the buffer credits protocol.  All other LNDs have buffer size == message size - i.e. they post 1 buffer for every buffer credit their peers have, but the ptllnd posts large buffers that are expected to receive many messages.   This means that a failure to handle  messages eagerly by upper levels could  leave a whole ptllnd buffer of 'n' messages pinned and therefore out of service.  This would violate the credit protocol and lead to deadlock.  So the ptllnd has an 'eager receive' method to copy messages that can't be handled immediately into a temporary buffer to avoid this problem.

IIRC, we had to use this feature in the ptllnd because if we'd posted 1 buffer for every message we could receive at any time, we'd have run out of portals MDs.  Allowing multiple incoming messages to share a single buffer has some obvious benefits (LNET does this too!), but IMHO it can be a bit of a two-edged sword with some non-obvious consequences.  For example, buffers must be considered full when there isn't enough space left to receive the longest message a peer might send.  If you have considerable variation in message length and buffers are only sized large enough for 1 maximum message, you end up with significant buffer underutilisation.  I believe this was the root cause of recent network hangs at scale on Blue Waters after the maximum MDS request size was increased significantly to permit wide striping.

Cheers,
                  Eric

From: lustre-devel-bounces@lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Chuck Fossen
Sent: Thursday, September 27, 2012 11:36 PM
To: lustre-devel at lists.lustre.org
Subject: [Lustre-devel] lnet eager receive path

LNET experts,

We are currently using the eager receive path to buffer rx messages removing them from the wire so as to not stall the network.
Is this necessary for the proper operation of LNET? I don't see that any of the other LNDs use the eager receive path.
Is there some history as to why the eager receive was added?

Thanks for any input.

Chuck Fossen
Cray Inc.
---------------------------------------------------------------------
Intel Corporation (UK) Limited
Registered No. 1134945 (England)
Registered Office: Pipers Way, Swindon SN3 1RJ
VAT No: 860 2173 47

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121003/bf8b7b64/attachment.htm>
