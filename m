From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Fri, 13 Aug 2010 19:51:02 +0300
Subject: [Lustre-devel] [Lustre-discuss] Lustre Message
	Sending/Receiving Problems
In-Reply-To: <AANLkTi=HyT-QKEeQ5h_Jx8wb6t=ox7gmg9Lb13RhPtFY@mail.gmail.com>
References: <AANLkTi=HyT-QKEeQ5h_Jx8wb6t=ox7gmg9Lb13RhPtFY@mail.gmail.com>
Message-ID: <D7F3EE2D-0724-47DD-A936-F5CCD60A3888@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

i think you say about lustre 1.8 ptlrpc API ?
look into ldlm_cli_convert, that good example of using that API.
for first you must declare sending buffer via ptlrpc_prep_req,
second, you must declare reply buffer via ptlrpc_req_set_repsize,
if you want synchronous request processing you should use ptlrpc_queue_wait,
if you want async request processing, use should assing async completion callback and add into ptlrpcd processing queue via ptlrpcd_add_req.


On Aug 12, 2010, at 23:48, Vilobh Meshram wrote:

> 
> I want to understand the message encoding and decoding logic in Lustre.I am planning to send the lustre_msg (lustre_msg_v2) in the ptlrpc_request with some additional fields to the server (MDS). But when I add those fields I was not able to see their values at the Server end i.e MDS.For example say we now have 8 values + the variable size buffer which might be able to include the additional entries.So I want to add some additional entries to the variable part of the message.
> 
> If you can please give me some insight on the way the Lustre File system encodes decodes the messages sent accross nodes it would be helpful.I have traced down the following code path  and see that inorder to send the message we need only three steps :-
> ptlrpc_prep_req
> ptlrpc_req_set_repsize
> ptlrpc_queue_wait
> 
> Do I need to take into consideration any other things ?
> Any help in this regard will be highly useful.
> 
> Thanks,
> Vilobh
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100813/5b0b61a0/attachment.htm>
