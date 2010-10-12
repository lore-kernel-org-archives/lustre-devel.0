From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Tue, 12 Oct 2010 21:21:05 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
Message-ID: <5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Vilobh,

ldlm_cli_cancel_req is good example to use old PtlRPC API.
for first you need allocate request buffer via ptlrpc_prep_req
next is - allocate reply buffer via ptlrpc_req_set_repsize
next - call ptlrpc_queue_wait to send message and wait reply.

osc_getattr_async good example for new PtlRPC API and async RPC processing.

if that isn't help you - please show a yours code to find a error.

On Oct 12, 2010, at 20:55, Vilobh Meshram wrote:

> I want to understand the message encoding and decoding logic in lustre.I am planning to send a request to the MDS and based on the reply from MDs want to populate the 
> 
>    struct lustre_msg *rq_repbuf; /* client only, buf may be bigger than msg */
>    struct lustre_msg *rq_repmsg;
> 
> I am trying this for a simple "Hello" message but not seeing the expected output.Sometime I even see Kernel Crash.
> If you can please give me some insight on the way the Lustre File system encodes decodes the messages sent accross nodes it would be helpful.
> 
> Thanks,
> Vilobh
> Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101012/299c21a8/attachment.htm>
