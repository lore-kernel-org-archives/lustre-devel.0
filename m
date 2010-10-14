From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 14 Oct 2010 17:40:14 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <E95A1DEA-5447-4B6D-95B7-0BB8D96BDDDE@oracle.com>
References: <AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
	<20101014002844.GY1635@oracle.com>
	<FC5171E3-DC54-4FC2-B723-7787BE41BD80@clusterstor.com>
	<20101014051852.GZ1635@oracle.com>
	<E95A1DEA-5447-4B6D-95B7-0BB8D96BDDDE@oracle.com>
Message-ID: <401C408D-C677-48EC-93FE-03333CCD9478@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

On Oct 14, 2010, at 17:31, Andreas Dilger wrote:

> On 2010-10-13, at 23:18, Nicolas Williams wrote:
>> On Thu, Oct 14, 2010 at 06:38:16AM +0300, Alexey Lyashkov wrote:
>>> On Oct 14, 2010, at 03:28, Nicolas Williams wrote:
>>>> Yes, it's possible to add buffers to requests.  It's not possible to add
>>>> buffers to _replies_ to existing RPCs unless you know the client expects
>>>> those additional buffers -- existing clients expect a given maxsize for
>>>> each reply, and if your reply is bigger then it will get dropped.
>>> It is wrong for last ~1year.
>>> ~1year ago i add code to ptlrpc layer which a adjust buffer for reply, and resend a request.
>> 
>> Ah, I didn't know that was in 1.8.  Are there interop issues (with older
>> clients) though with sending larger replies than expected?
> 
> Nico, it has always been possible in the past to increase the size of any buffer in a request, or in a reply (if the total reply size will fit into the pre-allocated reply buffer).  An older peer would just ignore the bytes beyond the known part of the buffer.
> 
I think that question don't about rebalance buffers size in message,
i think that sending large reply in smaller reply buffer.
LNet don't able to put large reply to small buffer (without truncate flag, which is not exist in older ptlrpc version).
without that flag you will see messages 
>>
                CERROR("Matching packet from %s, match "LPU64
                       " length %d too big: %d left, %d allowed\n",
                       libcfs_id2str(src), match_bits, rlength,
                       md->md_length - offset, mlength);
>>
and LNet will drop message without notify PtlRPC.


> Is that not true with the 2.x RPC handling?
> 
2.x able to rebalance space between buffers (but looks by hand), and able adjust reply buffer after truncated reply.



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
