From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 13 Oct 2010 19:28:45 -0500
Subject: [Lustre-devel] Query to understand the Lustre request/reply
 message
In-Reply-To: <AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
References: <AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
Message-ID: <20101014002844.GY1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 13, 2010 at 07:51:37PM -0400, Vilobh Meshram wrote:
> 1) Is it possible that without writing a new RPC in Lustre 1.8.1.1 I can
> append some string such as "Hello" to the exsisting message sent by the
> Client (with the buffer size set at client side by the count,size fields).I
> tried modifying the "size" of the request for one of the RPC in-built in
> Lustre

Yes, it's possible to add buffers to requests.  It's not possible to add
buffers to _replies_ to existing RPCs unless you know the client expects
those additional buffers -- existing clients expect a given maxsize for
each reply, and if your reply is bigger then it will get dropped.

>          __u32 size[2] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
> ptlrpc_body),
>                                     [DLM_LOCKREQ_OFF]     = sizeof(struct
> ldlm_request) };
> 
> ---->>
>      __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>                                   [DLM_LOCKREQ_OFF]     = sizeof(struct
> ldlm_request) ,
>                                   //how to add "char *str=Hello" ofcourse we
> will have sizeof(str) but how to choose the MACRO like DLM_LOCKREQ_OFF bcz
> for a specific kind of RPC there are limited number of such MACROS
>                                             };

Add a buffer.  Don't change the size of an existing buffer.

> The thing I want to know is how can I send a buffer from the client side by
> modifying the static structure "size" mentioned above.What all main places
> do I need to consider to make this work.

Add an element to the size[] array, then set it to the correct size when
you know the length of the string.  Look at the SET_INFO RPCs.

> If the above step i.e appending a buffer in the "size" array is not possible
> then I can move to write a new RPC.

The size[] array is just a convenient place to store the sizes of the
individual buffers while you construct them.

Nico
-- 
