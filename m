From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 14 Oct 2010 18:45:35 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <AANLkTikHD_16NN_Ld6rXwmTERMPxfrbqYLWqwu_QwP1E@mail.gmail.com>
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
	<401C408D-C677-48EC-93FE-03333CCD9478@clusterstor.com>
	<AANLkTi=iXhG1rZ=Q+1Gv4abWvLFO6CS=ZLV26KEKWPwy@mail.gmail.com>
	<419E085D-61B9-4434-A172-1A1DAC99B070@clusterstor.com>
	<AANLkTikHD_16NN_Ld6rXwmTERMPxfrbqYLWqwu_QwP1E@mail.gmail.com>
Message-ID: <7E0BFE49-914F-44AC-9534-D0544F83878D@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Vilobh,

interop == interoperability between nodes with different version of software.

in general we have two ways to solve that - for requests with mdc_body - you can set flag in body and analyze that flag in server/client side.
if you want add new operation - better way add new flag into  connect_data  (look to OBD_CONNECT_* macroses handling)
that flag can checked via export->connect_flags on client or server side for remote side features.
as example 1.x and 2.0 have a different format for setattr requests :
int mdc_setattr
...
       if (mdc_exp_is_2_0_server(exp)) {                                                        
                size[REQ_REC_OFF] = sizeof(struct mdt_rec_setattr);                              
                size[REQ_REC_OFF + 1] = 0; /* capa */                                            
                size[REQ_REC_OFF + 2] = 0; //sizeof (struct mdt_epoch);                          
                size[REQ_REC_OFF + 3] = ealen;                                                   
                size[REQ_REC_OFF + 4] = ea2len;                                                  
                size[REQ_REC_OFF + 5] = sizeof(struct ldlm_request);                             
                offset = REQ_REC_OFF + 5;                                                        
                bufcount = 6;                                                                    
                replybufcount = 6;                                                               
        } else {                                                                                 
                bufcount = 4;                                                                    
        }                                                                                        
 
example of client features are checking version based recovery support for client 
mds_version_get_check
...
        if (inode == NULL || !exp_connect_vbr(req->rq_export))                                   


I hope that help you.


On Oct 14, 2010, at 18:29, Vilobh Meshram wrote:

> Hi Alexey,
> 
> Thanks again for the reply.
> 
> Can you briefly give me some pointers about this interop issue and in which kind of RPC should this issue arise ? How should we resolve this what kind of flag needs to be set in ?
> 
> I went through the bugzilla entry mentioned by you it seems like for RPCs dealing with LDLM may cause this issue.Please correct me if I am wrong.
> 
> Thanks,
> Vilobh
> Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio
> 
> 
> On Thu, Oct 14, 2010 at 11:10 AM, Alexey Lyashkov <alexey.lyashkov@clusterstor.com> wrote:
> Hi Vilobh,
> 
> as i see, you touched code related to locking. struct ldm_request used to lock enqueue process - that why i say about interop issue in ELC code, which solved with export flag.
> for common mdc requests you can resolve interop issue with flags in mdc_body (mdt_body), but that not possible for ldlm requests.
>  
> 
> On Oct 14, 2010, at 18:04, Vilobh Meshram wrote:
> 
>> Hi Alexey,
>> 
>> Thanks again for your reply.
>> 
>> I am trying to embed a buffer in the RPC which will get filled in with some values which MDS is aware of which the client calling the RPC is not aware of.It has nothing to do with locking.I just want to fill in the buffer which I embedd in the RPC with some suitable data from the MDS end and then do operations on that data at the client side.So I think the approach suggested by you and Nicholas of just including the sizeof(str) [the size of the expected information from the MDS] in the size[] array should be fine as done below :-
>> 
>> 
>> 
>> __u32 size[2] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>>                                     [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request) };
>> 
>> ---->> 
>>      __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>>                                   [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request) ,
>>                                   //how to add "char *str=Hello" ofcourse we will have sizeof(str) but how to choose the MACRO like DLM_LOCKREQ_OFF bcz for a specific kind of RPC there are limited number of such MACROS
>>  
>> 
>> Please correct me if I am wrong or please guide me if I need to consider few corner cases to handle this use case.
>> 
>> Thanks again.
>> 
>> Thanks,
>> Vilobh
>> Graduate Research Associate
>> Department of Computer Science
>> The Ohio State University Columbus Ohio
>> 
>> 
>> On Thu, Oct 14, 2010 at 10:40 AM, Alexey Lyashkov <alexey.lyashkov@clusterstor.com> wrote:
>> Andreas,
>> 
>> On Oct 14, 2010, at 17:31, Andreas Dilger wrote:
>> 
>> > On 2010-10-13, at 23:18, Nicolas Williams wrote:
>> >> On Thu, Oct 14, 2010 at 06:38:16AM +0300, Alexey Lyashkov wrote:
>> >>> On Oct 14, 2010, at 03:28, Nicolas Williams wrote:
>> >>>> Yes, it's possible to add buffers to requests.  It's not possible to add
>> >>>> buffers to _replies_ to existing RPCs unless you know the client expects
>> >>>> those additional buffers -- existing clients expect a given maxsize for
>> >>>> each reply, and if your reply is bigger then it will get dropped.
>> >>> It is wrong for last ~1year.
>> >>> ~1year ago i add code to ptlrpc layer which a adjust buffer for reply, and resend a request.
>> >>
>> >> Ah, I didn't know that was in 1.8.  Are there interop issues (with older
>> >> clients) though with sending larger replies than expected?
>> >
>> > Nico, it has always been possible in the past to increase the size of any buffer in a request, or in a reply (if the total reply size will fit into the pre-allocated reply buffer).  An older peer would just ignore the bytes beyond the known part of the buffer.
>> >
>> I think that question don't about rebalance buffers size in message,
>> i think that sending large reply in smaller reply buffer.
>> LNet don't able to put large reply to small buffer (without truncate flag, which is not exist in older ptlrpc version).
>> without that flag you will see messages
>> >>
>>                CERROR("Matching packet from %s, match "LPU64
>>                       " length %d too big: %d left, %d allowed\n",
>>                       libcfs_id2str(src), match_bits, rlength,
>>                       md->md_length - offset, mlength);
>> >>
>> and LNet will drop message without notify PtlRPC.
>> 
>> 
>> > Is that not true with the 2.x RPC handling?
>> >
>> 2.x able to rebalance space between buffers (but looks by hand), and able adjust reply buffer after truncated reply.
>> 
>> 
>> 
>> --------------------------------------
>> Alexey Lyashkov
>> alexey.lyashkov at clusterstor.com
>> 
>> 
>> 
>> 
>> 
> 
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101014/9e2aae97/attachment.htm>
