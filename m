From: Nathan Rutman <nrutman@gmail.com>
Date: Thu, 26 May 2011 08:18:12 -0700
Subject: [Lustre-devel] LNET and IPv6?
Message-ID: <6EDF69A2-F4B6-49C0-A161-DE06A2529E92@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Does anyone have any ideas / plans for IPv6 support for Lustre / LNET?  Or does it remain an uninvestigated wishlist item?

This was part of the OpenSFS requirements gathering phase:
Support for IPv6 requires a change in the NID format to accommodate a 128bit IPv6 address in the address-within-network field. This affects all protocol levels: LNDs, LNET and Lustre.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/12c13276/attachment.htm>
