From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Thu, 14 Oct 2010 20:58:02 -0400
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <AANLkTikyGYF=atFyZXr99RdJ5JMc6ef4wgXXWA7pEzmV@mail.gmail.com>
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
	<7E0BFE49-914F-44AC-9534-D0544F83878D@clusterstor.com>
	<AANLkTikyGYF=atFyZXr99RdJ5JMc6ef4wgXXWA7pEzmV@mail.gmail.com>
Message-ID: <AANLkTik8gqaqEadz2w-0ZW4EvjE98SoZ8mYBqNF9on7d@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Alexey/Nicholas,

I modified the code in following way in the way Nicholas suggested yesterday
in-order to get some information filled in a fixed sized buffer sent from
client side.Here I am sending a buffer called "str" (whose size is 16) which
will be updated at the MDS side by the string "hello"(whose size is 7 much
less than original size of buffer "str" i.e 16).But I am not able to perform
the operation successfully and I am getting an error
"LustreError: 4209:0:(file.c:3143:ll_inode_revalidate_fini()) failure -14
inode 31257"

which seems to be related to  DLM_REPLY_REC_OFF since I have modified this
offset in my code.Can you please review my code and suggest me if I am
making any mistake.I will be done with my task if I can resolve this
problem.

Following are the modifications .The text in BOLD and Italics (blue color)
are my modification at Client and MDS side for *Lustre 1.8.1.1*:-

*At Client side :- lustre/ldlm/ldlm_lockd.c**

* 655 int ldlm_cli_enqueue(.........)
 665         __u32 size[] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
ptlrpc_body),
 666                         [DLM_LOCKREQ_OFF]     = sizeof(*body),
 667                         [DLM_REPLY_REC_OFF]   = lvb_len ? lvb_len :
 668                                                 sizeof(struct ost_lvb),
* 669                                                 16};*

 717         if (reqp == NULL || *reqp == NULL) {
 *718                 req = ldlm_prep_enqueue_req(exp, 4, size, NULL, 0);
                                                               |
                                                              |
                                                             v

                      575 struct ptlrpc_request *ldlm_prep_elc_req(.......)
                      584         void *str=NULL;
                      585         char *bufs[4] = {NULL,NULL,NULL,str};
                      616         req =
ptlrpc_prep_req(class_exp2cliimp(exp), version,
                      617                               opc, bufcount, size,
bufs**);


At MDS side :- lustre/ldlm/ldlm_lockd.c

 992 int ldlm_handle_enqueue(.........)
 996 {
1000         void *str;
         __u32 size[4] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
ptlrpc_body),
                         [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep)
1009         char *org = "hello";


*1119 existing_lock:
1120
1121         if (flags & LDLM_FL_HAS_INTENT) {
1122                 /* In this case, the reply buffer is allocated deep in
1123                  * local_lock_enqueue by the policy function. */
1124                 cookie = req;
1125         } else {
*1126                 int buffers = 4;*
1127
1128                 lock_res_and_lock(lock);
1129                 if (lock->l_resource->lr_lvb_len) {
*                       size[DLM_REPLY_REC_OFF] =
lock->l_resource->lr_lvb_len;
                       buffers = 4;*
1132                 }
1133                 unlock_res_and_lock(lock);
1134
1135                 if
(OBD_FAIL_CHECK_ONCE(OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR))
1136                         GOTO(out, rc = -ENOMEM);
*             str = lustre_msg_buf(req->rq_reqmsg, DLM_REPLY_REC_OFF+1, 1);
             memcpy ( str , org , 7);
             size[DLM_REPLY_REC_OFF + 1] = 16;


*

Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*


On Thu, Oct 14, 2010 at 12:25 PM, Vilobh Meshram
<vilobh.meshram@gmail.com>wrote:

> Hi Alexey,
>
> That surely helps.Thanks for all the help till now.
>
> Thanks,
> Vilobh
> *Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio*
>
>
> On Thu, Oct 14, 2010 at 11:45 AM, Alexey Lyashkov <
> alexey.lyashkov at clusterstor.com> wrote:
>
>> Hi Vilobh,
>>
>> interop == interoperability between nodes with different version of
>> software.
>>
>> in general we have two ways to solve that - for requests with mdc_body -
>> you can set flag in body and analyze that flag in server/client side.
>> if you want add new operation - better way add new flag into  connect_data
>>  (look to OBD_CONNECT_* macroses handling)
>> that flag can checked via export->connect_flags on client or server side
>> for remote side features.
>> as example 1.x and 2.0 have a different format for setattr requests :
>> int mdc_setattr
>> ...
>>        if (mdc_exp_is_2_0_server(exp)) {
>>
>>                 size[REQ_REC_OFF] = sizeof(struct mdt_rec_setattr);
>>
>>                 size[REQ_REC_OFF + 1] = 0; /* capa */
>>
>>                 size[REQ_REC_OFF + 2] = 0; //sizeof (struct mdt_epoch);
>>
>>                 size[REQ_REC_OFF + 3] = ealen;
>>
>>                 size[REQ_REC_OFF + 4] = ea2len;
>>
>>                 size[REQ_REC_OFF + 5] = sizeof(struct ldlm_request);
>>
>>                 offset = REQ_REC_OFF + 5;
>>
>>                 bufcount = 6;
>>
>>                 replybufcount = 6;
>>
>>         } else {
>>
>>                 bufcount = 4;
>>
>>         }
>>
>>
>> example of client features are checking version based recovery support for
>> client
>> mds_version_get_check
>> ...
>>         if (inode == NULL || !exp_connect_vbr(req->rq_export))
>>
>>
>>
>> I hope that help you.
>>
>>
>> On Oct 14, 2010, at 18:29, Vilobh Meshram wrote:
>>
>> Hi Alexey,
>>
>> Thanks again for the reply.
>>
>> Can you briefly give me some pointers about this interop issue and in
>> which kind of RPC should this issue arise ? How should we resolve this what
>> kind of flag needs to be set in ?
>>
>> I went through the bugzilla entry mentioned by you it seems like for RPCs
>> dealing with LDLM may cause this issue.Please correct me if I am wrong.
>>
>> Thanks,
>> Vilobh
>> *Graduate Research Associate
>> Department of Computer Science
>> The Ohio State University Columbus Ohio*
>>
>>
>> On Thu, Oct 14, 2010 at 11:10 AM, Alexey Lyashkov <
>> alexey.lyashkov at clusterstor.com> wrote:
>>
>>> Hi Vilobh,
>>>
>>> as i see, you touched code related to locking. struct ldm_request used to
>>> lock enqueue process - that why i say about interop issue in ELC code, which
>>> solved with export flag.
>>> for common mdc requests you can resolve interop issue with flags in
>>> mdc_body (mdt_body), but that not possible for ldlm requests.
>>>
>>>
>>> On Oct 14, 2010, at 18:04, Vilobh Meshram wrote:
>>>
>>> Hi Alexey,
>>>
>>> Thanks again for your reply.
>>>
>>> I am trying to embed a buffer in the RPC which will get filled in with
>>> some values which MDS is aware of which the client calling the RPC is not
>>> aware of.It has nothing to do with locking.I just want to fill in the
>>> buffer which I embedd in the RPC with some suitable data from the MDS end
>>> and then do operations on that data at the client side.So I think the
>>> approach suggested by you and Nicholas of just including the sizeof(str)
>>> [the size of the expected information from the MDS] in the size[] array
>>> should be fine as done below :-
>>>
>>>
>>>
>>> __u32 size[2] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>>>                                     [DLM_LOCKREQ_OFF]     = sizeof(struct
>>> ldlm_request) };
>>>
>>> ---->>
>>>      __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
>>> ptlrpc_body),
>>>                                   [DLM_LOCKREQ_OFF]     = sizeof(struct
>>> ldlm_request) ,
>>>                                   //how to add "char *str=Hello" ofcourse
>>> we will have sizeof(str) but how to choose the MACRO like DLM_LOCKREQ_OFF
>>> bcz for a specific kind of RPC there are limited number of such MACROS
>>>
>>>
>>> *Please correct me if I am wrong or please guide me if I need to
>>> consider few corner cases to handle this use case.
>>>
>>> *Thanks again.
>>>
>>> Thanks,
>>> Vilobh
>>> *Graduate Research Associate
>>> Department of Computer Science
>>> The Ohio State University Columbus Ohio*
>>>
>>>
>>> On Thu, Oct 14, 2010 at 10:40 AM, Alexey Lyashkov <
>>> alexey.lyashkov at clusterstor.com> wrote:
>>>
>>>> Andreas,
>>>>
>>>> On Oct 14, 2010, at 17:31, Andreas Dilger wrote:
>>>>
>>>> > On 2010-10-13, at 23:18, Nicolas Williams wrote:
>>>> >> On Thu, Oct 14, 2010 at 06:38:16AM +0300, Alexey Lyashkov wrote:
>>>> >>> On Oct 14, 2010, at 03:28, Nicolas Williams wrote:
>>>> >>>> Yes, it's possible to add buffers to requests.  It's not possible
>>>> to add
>>>> >>>> buffers to _replies_ to existing RPCs unless you know the client
>>>> expects
>>>> >>>> those additional buffers -- existing clients expect a given maxsize
>>>> for
>>>> >>>> each reply, and if your reply is bigger then it will get dropped.
>>>> >>> It is wrong for last ~1year.
>>>> >>> ~1year ago i add code to ptlrpc layer which a adjust buffer for
>>>> reply, and resend a request.
>>>> >>
>>>> >> Ah, I didn't know that was in 1.8.  Are there interop issues (with
>>>> older
>>>> >> clients) though with sending larger replies than expected?
>>>> >
>>>> > Nico, it has always been possible in the past to increase the size of
>>>> any buffer in a request, or in a reply (if the total reply size will fit
>>>> into the pre-allocated reply buffer).  An older peer would just ignore the
>>>> bytes beyond the known part of the buffer.
>>>> >
>>>> I think that question don't about rebalance buffers size in message,
>>>> i think that sending large reply in smaller reply buffer.
>>>> LNet don't able to put large reply to small buffer (without truncate
>>>> flag, which is not exist in older ptlrpc version).
>>>> without that flag you will see messages
>>>> >>
>>>>                CERROR("Matching packet from %s, match "LPU64
>>>>                       " length %d too big: %d left, %d allowed\n",
>>>>                       libcfs_id2str(src), match_bits, rlength,
>>>>                       md->md_length - offset, mlength);
>>>> >>
>>>> and LNet will drop message without notify PtlRPC.
>>>>
>>>>
>>>> > Is that not true with the 2.x RPC handling?
>>>> >
>>>> 2.x able to rebalance space between buffers (but looks by hand), and
>>>> able adjust reply buffer after truncated reply.
>>>>
>>>>
>>>>
>>>> --------------------------------------
>>>> Alexey Lyashkov
>>>> alexey.lyashkov at clusterstor.com
>>>>
>>>>
>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101014/302f016d/attachment.htm>
