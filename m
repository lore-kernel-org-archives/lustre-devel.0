From: Chuck Fossen <chuckf@cray.com>
Date: Thu, 27 Sep 2012 22:35:56 +0000
Subject: [Lustre-devel] lnet eager receive path
Message-ID: <8396A2469279AB46BD407F36A461F14909F00976@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

LNET experts,

We are currently using the eager receive path to buffer rx messages removing them from the wire so as to not stall the network.
Is this necessary for the proper operation of LNET? I don't see that any of the other LNDs use the eager receive path.
Is there some history as to why the eager receive was added?

Thanks for any input.

Chuck Fossen
Cray Inc.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120927/6726fca9/attachment.htm>
