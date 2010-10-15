From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Fri, 15 Oct 2010 12:25:02 -0400
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <F6E7C0A5-B1E7-4792-A0C3-4A367DF8DEDF@clusterstor.com>
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
	<AANLkTik8gqaqEadz2w-0ZW4EvjE98SoZ8mYBqNF9on7d@mail.gmail.com>
	<F6E7C0A5-B1E7-4792-A0C3-4A367DF8DEDF@clusterstor.com>
Message-ID: <AANLkTi=f1v-09+Uo+mtNknQk+pJt71n=kpHnR1i35fxG@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Alexey,

I have attached the diff file .Please have a look at it and please let me
know your comments /suggestions.

Thanks again.

Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*


On Fri, Oct 15, 2010 at 3:39 AM, Alexey Lyashkov <
alexey.lyashkov@clusterstor.com> wrote:

> can you please attach diff file ?
>
> On Oct 15, 2010, at 03:58, Vilobh Meshram wrote:
>
> Hi Alexey/Nicholas,
>
> I modified the code in following way in the way Nicholas suggested
> yesterday in-order to get some information filled in a fixed sized buffer
> sent from client side.Here I am sending a buffer called "str" (whose size is
> 16) which will be updated at the MDS side by the string "hello"(whose size
> is 7 much less than original size of buffer "str" i.e 16).But I am not able
> to perform the operation successfully and I am getting an error
> "LustreError: 4209:0:(file.c:3143:ll_inode_revalidate_fini()) failure -14
> inode 31257"
>
> which seems to be related to  DLM_REPLY_REC_OFF since I have modified this
> offset in my code.Can you please review my code and suggest me if I am
> making any mistake.I will be done with my task if I can resolve this
> problem.
>
> Following are the modifications .The text in BOLD and Italics (blue color)
> are my modification at Client and MDS side for *Lustre 1.8.1.1*:-
>
> *At Client side :- lustre/ldlm/ldlm_lockd.c**
>
> * 655 int ldlm_cli_enqueue(.........)
>  665         __u32 size[] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
> ptlrpc_body),
>  666                         [DLM_LOCKREQ_OFF]     = sizeof(*body),
>  667                         [DLM_REPLY_REC_OFF]   = lvb_len ? lvb_len :
>  668                                                 sizeof(struct
> ost_lvb),
> * 669                                                 16};*
>
>  717         if (reqp == NULL || *reqp == NULL) {
>  *718                 req = ldlm_prep_enqueue_req(exp, 4, size, NULL, 0);
>                                                                |
>                                                               |
>                                                              v
>
>                       575 struct ptlrpc_request *ldlm_prep_elc_req(.......)
>                       584         void *str=NULL;
>                       585         char *bufs[4] = {NULL,NULL,NULL,str};
>                       616         req =
> ptlrpc_prep_req(class_exp2cliimp(exp), version,
>                       617                               opc, bufcount,
> size, bufs**);
>
>
> At MDS side :- lustre/ldlm/ldlm_lockd.c
>
>  992 int ldlm_handle_enqueue(.........)
>  996 {
> 1000         void *str;
>          __u32 size[4] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
> ptlrpc_body),
>                          [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep)
> 1009         char *org = "hello";
>
>
> *1119 existing_lock:
> 1120
> 1121         if (flags & LDLM_FL_HAS_INTENT) {
> 1122                 /* In this case, the reply buffer is allocated deep in
> 1123                  * local_lock_enqueue by the policy function. */
> 1124                 cookie = req;
> 1125         } else {
> *1126                 int buffers = 4;*
> 1127
> 1128                 lock_res_and_lock(lock);
> 1129                 if (lock->l_resource->lr_lvb_len) {
> *                       size[DLM_REPLY_REC_OFF] =
> lock->l_resource->lr_lvb_len;
>                        buffers = 4;*
> 1132                 }
> 1133                 unlock_res_and_lock(lock);
> 1134
> 1135                 if
> (OBD_FAIL_CHECK_ONCE(OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR))
> 1136                         GOTO(out, rc = -ENOMEM);
> *             str = lustre_msg_buf(req->rq_reqmsg, DLM_REPLY_REC_OFF+1,
> 1);
>              memcpy ( str , org , 7);
>              size[DLM_REPLY_REC_OFF + 1] = 16;
>
>
> *
>
> Thanks,
> Vilobh
> *Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio*
>
>
> On Thu, Oct 14, 2010 at 12:25 PM, Vilobh Meshram <vilobh.meshram@gmail.com
> > wrote:
>
>> Hi Alexey,
>>
>> That surely helps.Thanks for all the help till now.
>>
>> Thanks,
>> Vilobh
>> *Graduate Research Associate
>> Department of Computer Science
>> The Ohio State University Columbus Ohio*
>>
>>
>> On Thu, Oct 14, 2010 at 11:45 AM, Alexey Lyashkov <
>> alexey.lyashkov at clusterstor.com> wrote:
>>
>>> Hi Vilobh,
>>>
>>> interop == interoperability between nodes with different version of
>>> software.
>>>
>>> in general we have two ways to solve that - for requests with mdc_body -
>>> you can set flag in body and analyze that flag in server/client side.
>>> if you want add new operation - better way add new flag into
>>>  connect_data  (look to OBD_CONNECT_* macroses handling)
>>> that flag can checked via export->connect_flags on client or server side
>>> for remote side features.
>>> as example 1.x and 2.0 have a different format for setattr requests :
>>> int mdc_setattr
>>> ...
>>>        if (mdc_exp_is_2_0_server(exp)) {
>>>
>>>                 size[REQ_REC_OFF] = sizeof(struct mdt_rec_setattr);
>>>
>>>                 size[REQ_REC_OFF + 1] = 0; /* capa */
>>>
>>>                 size[REQ_REC_OFF + 2] = 0; //sizeof (struct mdt_epoch);
>>>
>>>                 size[REQ_REC_OFF + 3] = ealen;
>>>
>>>                 size[REQ_REC_OFF + 4] = ea2len;
>>>
>>>                 size[REQ_REC_OFF + 5] = sizeof(struct ldlm_request);
>>>
>>>                 offset = REQ_REC_OFF + 5;
>>>
>>>                 bufcount = 6;
>>>
>>>                 replybufcount = 6;
>>>
>>>         } else {
>>>
>>>                 bufcount = 4;
>>>
>>>         }
>>>
>>>
>>> example of client features are checking version based recovery support
>>> for client
>>> mds_version_get_check
>>> ...
>>>         if (inode == NULL || !exp_connect_vbr(req->rq_export))
>>>
>>>
>>>
>>> I hope that help you.
>>>
>>>
>>> On Oct 14, 2010, at 18:29, Vilobh Meshram wrote:
>>>
>>> Hi Alexey,
>>>
>>> Thanks again for the reply.
>>>
>>> Can you briefly give me some pointers about this interop issue and in
>>> which kind of RPC should this issue arise ? How should we resolve this what
>>> kind of flag needs to be set in ?
>>>
>>> I went through the bugzilla entry mentioned by you it seems like for RPCs
>>> dealing with LDLM may cause this issue.Please correct me if I am wrong.
>>>
>>> Thanks,
>>> Vilobh
>>> *Graduate Research Associate
>>> Department of Computer Science
>>> The Ohio State University Columbus Ohio*
>>>
>>>
>>> On Thu, Oct 14, 2010 at 11:10 AM, Alexey Lyashkov <
>>> alexey.lyashkov at clusterstor.com> wrote:
>>>
>>>> Hi Vilobh,
>>>>
>>>> as i see, you touched code related to locking. struct ldm_request used
>>>> to lock enqueue process - that why i say about interop issue in ELC code,
>>>> which solved with export flag.
>>>> for common mdc requests you can resolve interop issue with flags in
>>>> mdc_body (mdt_body), but that not possible for ldlm requests.
>>>>
>>>>
>>>> On Oct 14, 2010, at 18:04, Vilobh Meshram wrote:
>>>>
>>>> Hi Alexey,
>>>>
>>>> Thanks again for your reply.
>>>>
>>>> I am trying to embed a buffer in the RPC which will get filled in with
>>>> some values which MDS is aware of which the client calling the RPC is not
>>>> aware of.It has nothing to do with locking.I just want to fill in the
>>>> buffer which I embedd in the RPC with some suitable data from the MDS end
>>>> and then do operations on that data at the client side.So I think the
>>>> approach suggested by you and Nicholas of just including the sizeof(str)
>>>> [the size of the expected information from the MDS] in the size[] array
>>>> should be fine as done below :-
>>>>
>>>>
>>>>
>>>> __u32 size[2] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
>>>>                                     [DLM_LOCKREQ_OFF]     =
>>>> sizeof(struct ldlm_request) };
>>>>
>>>> ---->>
>>>>      __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct
>>>> ptlrpc_body),
>>>>                                   [DLM_LOCKREQ_OFF]     = sizeof(struct
>>>> ldlm_request) ,
>>>>                                   //how to add "char *str=Hello"
>>>> ofcourse we will have sizeof(str) but how to choose the MACRO like DLM_LOCKREQ_OFF
>>>> bcz for a specific kind of RPC there are limited number of such MACROS
>>>>
>>>>
>>>> *Please correct me if I am wrong or please guide me if I need to
>>>> consider few corner cases to handle this use case.
>>>>
>>>> *Thanks again.
>>>>
>>>> Thanks,
>>>> Vilobh
>>>> *Graduate Research Associate
>>>> Department of Computer Science
>>>> The Ohio State University Columbus Ohio*
>>>>
>>>>
>>>> On Thu, Oct 14, 2010 at 10:40 AM, Alexey Lyashkov <
>>>> alexey.lyashkov at clusterstor.com> wrote:
>>>>
>>>>> Andreas,
>>>>>
>>>>> On Oct 14, 2010, at 17:31, Andreas Dilger wrote:
>>>>>
>>>>> > On 2010-10-13, at 23:18, Nicolas Williams wrote:
>>>>> >> On Thu, Oct 14, 2010 at 06:38:16AM +0300, Alexey Lyashkov wrote:
>>>>> >>> On Oct 14, 2010, at 03:28, Nicolas Williams wrote:
>>>>> >>>> Yes, it's possible to add buffers to requests.  It's not possible
>>>>> to add
>>>>> >>>> buffers to _replies_ to existing RPCs unless you know the client
>>>>> expects
>>>>> >>>> those additional buffers -- existing clients expect a given
>>>>> maxsize for
>>>>> >>>> each reply, and if your reply is bigger then it will get dropped.
>>>>> >>> It is wrong for last ~1year.
>>>>> >>> ~1year ago i add code to ptlrpc layer which a adjust buffer for
>>>>> reply, and resend a request.
>>>>> >>
>>>>> >> Ah, I didn't know that was in 1.8.  Are there interop issues (with
>>>>> older
>>>>> >> clients) though with sending larger replies than expected?
>>>>> >
>>>>> > Nico, it has always been possible in the past to increase the size of
>>>>> any buffer in a request, or in a reply (if the total reply size will fit
>>>>> into the pre-allocated reply buffer).  An older peer would just ignore the
>>>>> bytes beyond the known part of the buffer.
>>>>> >
>>>>> I think that question don't about rebalance buffers size in message,
>>>>> i think that sending large reply in smaller reply buffer.
>>>>> LNet don't able to put large reply to small buffer (without truncate
>>>>> flag, which is not exist in older ptlrpc version).
>>>>> without that flag you will see messages
>>>>> >>
>>>>>                CERROR("Matching packet from %s, match "LPU64
>>>>>                       " length %d too big: %d left, %d allowed\n",
>>>>>                       libcfs_id2str(src), match_bits, rlength,
>>>>>                       md->md_length - offset, mlength);
>>>>> >>
>>>>> and LNet will drop message without notify PtlRPC.
>>>>>
>>>>>
>>>>> > Is that not true with the 2.x RPC handling?
>>>>> >
>>>>> 2.x able to rebalance space between buffers (but looks by hand), and
>>>>> able adjust reply buffer after truncated reply.
>>>>>
>>>>>
>>>>>
>>>>> --------------------------------------
>>>>> Alexey Lyashkov
>>>>> alexey.lyashkov at clusterstor.com
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101015/3b409614/attachment.htm>
-------------- next part --------------
Index: lustre.spec
===================================================================
--- lustre.spec	(revision 8279)
+++ lustre.spec	(working copy)
@@ -1,7 +1,7 @@
 # lustre.spec
 %{!?version: %define version 1.8.1.1}
-%{!?kversion: %define kversion }
-%{!?release: %define release }
+%{!?kversion: %define kversion 2.6.18-128.7.1.el5-lustre.1.8.1.1smp-cust}
+%{!?release: %define release 2.6.18_128.7.1.el5_lustre.1.8.1.1smp_cust_201010141227}
 %{!?lustre_name: %define lustre_name lustre}
 
 %define is_client %(bash -c "if [[ %{lustre_name} = *-client ]]; then echo -n '1'; else echo -n '0'; fi")
@@ -104,7 +104,7 @@
 
 # Set an explicit path to our Linux tree, if we can.
 cd $RPM_BUILD_DIR/lustre-%{version}
-./configure '--disable-modules' '--disable-utils' '--disable-liblustre' '--disable-tests' '--disable-doc' --with-lustre-hack --with-sockets %{?configure_flags:configure_flags} \
+./configure '--with-o2ib=/usr/local/ofed/src/ofa_kernel' '--with-linux=/lib/modules/2.6.18-128.7.1.el5-lustre.1.8.1.1smp-cust/build' --with-lustre-hack --with-sockets %{?configure_flags:configure_flags} \
 	--sysconfdir=%{_sysconfdir} \
 	--mandir=%{_mandir} \
 	--libdir=%{_libdir}
Index: lustre/mds/handler.c
===================================================================
--- lustre/mds/handler.c	(revision 8279)
+++ lustre/mds/handler.c	(working copy)
@@ -1687,7 +1687,7 @@
                                mds->mds_max_mdsize,
                                mds->mds_max_cookiesize };
                 int bufcount;
-
+                printk("Inside function %s a hit for case MDS_REINT",__func__);
                 /* NB only peek inside req now; mds_reint() will swab it */
                 if (opcp == NULL) {
                         CERROR ("Can't inspect opcode\n");
@@ -1704,15 +1704,18 @@
 
                 switch (opc) {
                 case REINT_CREATE:
+                        printk("Inside function %s a hit for case REINT_CREATE",__func__);
                         op = PTLRPC_LAST_CNTR + MDS_REINT_CREATE;
                         break;
                 case REINT_LINK:
                         op = PTLRPC_LAST_CNTR + MDS_REINT_LINK;
                         break;
                 case REINT_OPEN:
+                        printk("Inside function %s a hit for case REINT_OPEN",__func__);
                         op = PTLRPC_LAST_CNTR + MDS_REINT_OPEN;
                         break;
                 case REINT_SETATTR:
+                        printk("Inside function %s a hit for case REINT_SETATTR",__func__);
                         op = PTLRPC_LAST_CNTR + MDS_REINT_SETATTR;
                         break;
                 case REINT_RENAME:
@@ -1745,8 +1748,9 @@
                         if (opc == REINT_UNLINK || opc == REINT_RENAME)
                                 size[DLM_REPLY_REC_OFF + 1] = 0;
                 }
-
+                printk("Inside function %s in case MDS_REINT before calling lustre_pack_reply",__func__);
                 rc = lustre_pack_reply(req, bufcount, size, NULL);
+                printk("Inside function %s in case MDS_REINT after calling lustre_pack_reply",__func__);
                 if (rc)
                         break;
 
@@ -1756,6 +1760,7 @@
         }
 
         case MDS_CLOSE:
+                printk("Inside function %s in case MDS_CLOSE",__func__);
                 DEBUG_REQ(D_INODE, req, "close");
                 OBD_FAIL_RETURN(OBD_FAIL_MDS_CLOSE_NET, 0);
                 rc = mds_close(req, REQ_REC_OFF);
@@ -1798,6 +1803,7 @@
                 break;
 #endif
         case OBD_PING:
+                printk("Inside function %s got a hit at case OBD_PING",__func__);
                 DEBUG_REQ(D_INODE, req, "ping");
                 rc = target_handle_ping(req);
                 if (req->rq_export->exp_delayed)
@@ -1811,6 +1817,7 @@
                 break;
 
         case LDLM_ENQUEUE:
+                printk("\n Inside function %s got a hit at case LDLM_ENQUEUE",__func__);
                 DEBUG_REQ(D_INODE, req, "enqueue");
                 OBD_FAIL_RETURN(OBD_FAIL_LDLM_ENQUEUE, 0);
                 rc = ldlm_handle_enqueue(req, ldlm_server_completion_ast,
Index: lustre/ldlm/ldlm_request.c
===================================================================
--- lustre/ldlm/ldlm_request.c	(revision 8279)
+++ lustre/ldlm/ldlm_request.c	(working copy)
@@ -581,6 +581,8 @@
         int flags, avail, to_free, pack = 0;
         struct ldlm_request *dlm = NULL;
         struct ptlrpc_request *req;
+        void *str=NULL;
+        char *bufs[4] = {NULL,NULL,NULL,str};
         CFS_LIST_HEAD(head);
         ENTRY;
 
@@ -609,8 +611,10 @@
                 size[bufoff] = ldlm_request_bufsize(pack, opc);
         }
 
+        printk("\n Inside function %s before calling ptlrpc_prep_req",__func__);
+        printk("\n OPC for LDLM_ENQUEUE is %d",opc);
         req = ptlrpc_prep_req(class_exp2cliimp(exp), version,
-                              opc, bufcount, size, NULL);
+                              opc, bufcount, size, bufs);
         req->rq_export = class_export_get(exp);
         if (exp_connect_cancelset(exp) && req) {
                 if (canceloff) {
@@ -658,10 +662,11 @@
         struct ldlm_lock *lock;
         struct ldlm_request *body;
         struct ldlm_reply *reply;
-        __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
+        __u32 size[] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                         [DLM_LOCKREQ_OFF]     = sizeof(*body),
                         [DLM_REPLY_REC_OFF]   = lvb_len ? lvb_len :
-                                                sizeof(struct ost_lvb) };
+                                                sizeof(struct ost_lvb),
+                                                16};
         int is_replay = *flags & LDLM_FL_REPLAY;
         int req_passed_in = 1, rc, err;
         struct ptlrpc_request *req;
@@ -710,7 +715,7 @@
         /* lock not sent to server yet */
 
         if (reqp == NULL || *reqp == NULL) {
-                req = ldlm_prep_enqueue_req(exp, 2, size, NULL, 0);
+                req = ldlm_prep_enqueue_req(exp, 4, size, NULL, 0);
                 if (req == NULL) {
                         failed_lock_cleanup(ns, lock, lockh, einfo->ei_mode);
                         LDLM_LOCK_PUT(lock);
Index: lustre/ldlm/ldlm_lockd.c
===================================================================
--- lustre/ldlm/ldlm_lockd.c	(revision 8279)
+++ lustre/ldlm/ldlm_lockd.c	(working copy)
@@ -997,13 +997,17 @@
         struct obd_device *obddev = req->rq_export->exp_obd;
         struct ldlm_reply *dlm_rep;
         struct ldlm_request *dlm_req;
-        __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
-                        [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep) };
+        void *str;
+        __u32 size[4] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
+                        [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep)
+                                                 };
         int rc = 0;
         __u32 flags;
         ldlm_error_t err = ELDLM_OK;
         struct ldlm_lock *lock = NULL;
         void *cookie = NULL;
+        char *org = "hello";
+
         ENTRY;
 
         LDLM_DEBUG_NOLOCK("server-side enqueue handler START");
@@ -1119,19 +1123,24 @@
                  * local_lock_enqueue by the policy function. */
                 cookie = req;
         } else {
-                int buffers = 2;
+                int buffers = 4;
 
                 lock_res_and_lock(lock);
                 if (lock->l_resource->lr_lvb_len) {
                         size[DLM_REPLY_REC_OFF] = lock->l_resource->lr_lvb_len;
-                        buffers = 3;
+                        buffers = 4;
                 }
                 unlock_res_and_lock(lock);
 
                 if (OBD_FAIL_CHECK_ONCE(OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR))
                         GOTO(out, rc = -ENOMEM);
+                str = lustre_msg_buf(req->rq_reqmsg, DLM_REPLY_REC_OFF+1, 1);
+                memcpy ( str , org , 7);
+                size[DLM_REPLY_REC_OFF + 1] = 16;
 
+                printk("\n Inside function %s before calling 1.LUSTRE_PACK_REPLY",__func__);
                 rc = lustre_pack_reply(req, buffers, size, NULL);
+                printk("\n Inside function %s after calling 1.LUSTRE_PACK_REPLY",__func__);
                 if (rc)
                         GOTO(out, rc);
         }
@@ -1215,7 +1224,9 @@
  out:
         req->rq_status = rc ?: err;  /* return either error - bug 11190 */
         if (!req->rq_packed_final) {
+                printk("\n Inside function %s before calling 2.LUSTRE_PACK_REPLY",__func__);
                 err = lustre_pack_reply(req, 1, NULL, NULL);
+                printk("\n Inside function %s after calling 2.LUSTRE_PACK_REPLY",__func__);
                 if (rc == 0)
                         rc = err;
         }
