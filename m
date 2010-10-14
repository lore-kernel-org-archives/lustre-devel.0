From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 14 Oct 2010 11:44:57 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
References: <5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
Message-ID: <589D5419-E22E-4006-AEDA-22957F25290F@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 14, 2010, at 02:51, Vilobh Meshram wrote:
> 
> 
> 1) Is it possible that without writing a new RPC in Lustre 1.8.1.1 I can append some string such as "Hello" to the exsisting message sent by the Client (with the buffer size set at client side by the count,size fields).I tried modifying the "size" of the request for one of the RPC in-built in Lustre 
> 
>          __u32 size[2] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>                                     [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request) };
> 
> ---->> 
>      __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>                                   [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request) ,
>                                   //how to add "char *str=Hello" ofcourse we will have sizeof(str) but how to choose the MACRO like DLM_LOCKREQ_OFF bcz for a specific kind of RPC there are limited number of such MACROS
>              
should be better if you complete describe - what you want to do, because some requests can't changed easy without compatibility lost, - 
like ELC (early lock cancel) feature which add extra buffer in messages and have special connect flag, to check request format changes.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101014/cbd91c27/attachment.htm>
