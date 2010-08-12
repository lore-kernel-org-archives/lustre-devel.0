From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Thu, 12 Aug 2010 16:48:27 -0400
Subject: [Lustre-devel] Lustre Message Sending/Receiving Problems
Message-ID: <AANLkTi=HyT-QKEeQ5h_Jx8wb6t=ox7gmg9Lb13RhPtFY@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I want to understand the message encoding and decoding logic in Lustre.I am
planning to send the lustre_msg (lustre_msg_v2) in the ptlrpc_request with
some additional fields to the server (MDS). But when I add those fields I
was not able to see their values at the Server end i.e MDS.For example say
we now have 8 values + the variable size buffer which might be able to
include the additional entries.So I want to add some additional entries to
the variable part of the message.

If you can please give me some insight on the way the Lustre File system
encodes decodes the messages sent accross nodes it would be helpful.I have
traced down the following code path  and see that inorder to send the
message we need only three steps :-
ptlrpc_prep_req
ptlrpc_req_set_repsize
ptlrpc_queue_wait

Do I need to take into consideration any other things ?
Any help in this regard will be highly useful.

Thanks,
Vilobh
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100812/faa31e96/attachment.htm>
