From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Wed, 13 Oct 2010 00:06:09 -0400
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
	<5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
Message-ID: <AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Alexey for the reply.Thanks a lot.

I will try out the steps mentioned by you and see if I can add a new RPC for
the task which I am thinking of to implement in Lustre.

The RPC of which I am thinking of will not return the lock to the caller.Yes
that rpc will have special code to reconstruct in replay phase.

Just a last question from which release of Lustre can we make use of the new
API.Is their any documentation which lists the use of the new API.If yes can
you please point me to that ?

Thanks again.

Thanks,
Vilobh
*Graduate Research Associate*
***Department of Computer Science*
***The Ohio State University Columbus Ohio*

On Tue, Oct 12, 2010 at 11:46 PM, Alexey Lyashkov <
alexey.lyashkov@clusterstor.com> wrote:

> That is depend of rpc type - is that RPC want to be return lock to caller
> or not, and is that rpc want to have special code to reconstruct in replay
> phase.
> in general you need look to mdt/mdt_handler.c. mdt_get_info is good example
> of simple rpc processing - but it use new PtlRPC api.
> that is API hide of low level request structures and provide api to access
> to message buffer by identifier.
> to use that API you need define structure of own message in
> ptlrpc/layout.c, and own command in enum mds_cmd_t, adjust array with
> commands and write own handler.
>
>
> On Oct 13, 2010, at 01:17, Vilobh Meshram wrote:
>
> Thanks Alexey.It was helpful.
>
> I have one more question :-
>
> If we want to add a new RPC with a new opcode are there any guidlines to be
> followed in the Lustre File System.
>
> Also ,
> 1)How does the MDS process the ptlrpc_request i.e how does the MDS extract
> the buffer information from the ptlrpc_message.
> 2)For every new RPC is the message length which is to be sent on wire (
> including the fixed header size + the buffer size) dependent on the number
> of buffers in the lustre request message i.e the count field in the
> ptlrpc_prep_req() or the size of the size[] array.
>
>
> Thanks,
> Vilobh
> *Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio*
>
>
> On Tue, Oct 12, 2010 at 2:21 PM, Alexey Lyashkov <
> alexey.lyashkov at clusterstor.com> wrote:
>
>> Hi Vilobh,
>>
>> ldlm_cli_cancel_req is good example to use old PtlRPC API.
>> for first you need allocate request buffer via ptlrpc_prep_req
>> next is - allocate reply buffer via ptlrpc_req_set_repsize
>> next - call ptlrpc_queue_wait to send message and wait reply.
>>
>> osc_getattr_async good example for new PtlRPC API and async RPC
>> processing.
>>
>> if that isn't help you - please show a yours code to find a error.
>>
>> On Oct 12, 2010, at 20:55, Vilobh Meshram wrote:
>>
>> I want to understand the message encoding and decoding logic in lustre.I
>> am planning to send a request to the MDS and based on the reply from MDs
>> want to populate the
>>
>>    struct lustre_msg *rq_repbuf; /* client only, buf may be bigger than
>> msg */
>>    struct lustre_msg *rq_repmsg;
>>
>> I am trying this for a simple "Hello" message but not seeing the expected
>> output.Sometime I even see Kernel Crash.
>> If you can please give me some insight on the way the Lustre File system
>> encodes decodes the messages sent accross nodes it would be helpful.
>>
>> Thanks,
>> Vilobh
>> *Graduate Research Associate
>> Department of Computer Science
>> The Ohio State University Columbus Ohio*
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>>
>>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101013/45c860df/attachment.htm>
