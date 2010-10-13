From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 13 Oct 2010 10:32:23 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <20101013071507.GE1635@oracle.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
	<5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<CCEF0646-8912-4D71-AA4B-C262D31EBC1B@clusterstor.com>
	<20101013071507.GE1635@oracle.com>
Message-ID: <4D7ECBDD-DA79-4DB4-AAE1-B1164802FF86@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

MDS code in 1.8 is more simple, because they don't have a parts of clustered metadata project aka CMD3 ;-)
same for client, they don't have many advantages - such as FID assignments on client side, or extra MD layer (LMV) and  don't have a CLIO.

so 1.8 is good start to learn :)

On Oct 13, 2010, at 10:15, Nicolas Williams wrote:

> On Wed, Oct 13, 2010 at 08:54:57AM +0300, Alexey Lyashkov wrote:
>> On Oct 13, 2010, at 08:42, Nicolas Williams wrote:
>>> On Wed, Oct 13, 2010 at 12:35:13AM -0400, Vilobh Meshram wrote:
>>>> Thanks a lot Alexey for the reply.The information will be really useful.
>>>> 
>>>> Since I am using 1.8.1.1 for my research project I will have to rely on the
>>>> old API.Since in the source tree prior to 2.0 we do not have a
>>>> mdt/mdt_handler.c and layout.c files will have to work with the low level
>>>> buffer management structures(ptlrpc_request,lustre_msg_v2,etc).Do you know a
>>>> place or a function which make use of the old API which I can use as a
>>>> reference to write the RPC for my task.
>>> 
>>> 
>>> Compared to the old thing, the new API is much closer to an IDL.  It's a
>>> good thing.  I strongly recommend that you use it,
>>> 
>> main problem - lustre 1.8.1 don't have the new API :)
> 
> You'll note that Vilobh did not provide any rationale for his/her choice
> of Lustre version.  Without having any other good reason for picking 1.8
> or 2.0, I strongly recommend 2.0.
> 
> Now, perhaps Vilobh has a need to interop with an installed base of 1.8.
> That would be a good reason to do this in 1.8.  But the work will have
> to be done for 2.0 as well.
> 
> Nico
> -- 



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
