From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Tue, 12 Oct 2010 18:39:16 -0400
Subject: [Lustre-devel] Adding a new RPC to Lustre
Message-ID: <AANLkTimTHKsfcBMHbTDymoSijMruB1w1gr3T0=d78VqT@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If we want to add a new RPC with a new opcode are there any guidlines to be
followed in the Lustre File System.

Also ,
1)How does the MDS process the ptlrpc_request i.e how does the MDS extract
the buffer information from the ptlrpc_message.
2)For every new RPC is the message length which is to be sent on wire (
including the fixed header size + the buffer size) dependent on the number
of buffers in the lustre request message i.e the count field in the
ptlrpc_prep_req() or the size of the size[] array.


Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101012/a78d2cc2/attachment.htm>
