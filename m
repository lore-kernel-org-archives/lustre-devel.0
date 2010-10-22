From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Thu, 21 Oct 2010 22:33:44 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
Message-ID: <AANLkTinvDP7yAF+L6WcREQ_kJr+ubxjupqOz9R_e0Eb=@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Andreas for the e-mail.

I am trying to modify the LDLM_ENQUEUE rpc to get the the reply in the form
of some buffer (say string "Hello World") filled in from MDS.I have
explained the use case in my last e-mail.Please refer my e-mail sent on
10/19.

I have attached the diff files. I am getting a kernel panic at the MDS end
when I try to make the attached changes.Can someone please suggest me where
I might be missing ?


Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*


On Wed, Oct 20, 2010 at 3:55 AM, Andreas Dilger
<andreas.dilger@oracle.com>wrote:

> On 2010-10-19, at 20:04, Vilobh Meshram wrote:
> > We are trying to do following things.Please let me know if things are not
> clear :-
> >
> > Say we have 2 client C1 and C2 and a MDS .Say C1 and C2 share a file.
> > 1) When a client C1 performs a open/create kind of request to the MDS we
> want to follow the normal path which Lustre performs.
> > 2) Now say C2 tries to open the same file which was opened by C1.
> > 3) At the MDS end we maintain some data structure to scan and see if the
> file was already opened by some Client(in this case C1 has opened this
> file).
> > 4) If MDS finds that some client(C1 here) has already opened the file
> then it send the new client(C2 here) with some information about the client
> which has initially opened the file.
>
> While I understand the basic concept, I don't really see how your proposal
> will actually improve performance.  If C2 already has to contact the MDS and
> get a reply from it, then wouldn't it be about the same to simply perform
> the open as is done today?  The number of MDS RPCs is the same, and in fact
> this would avoid further message overhead between C1 and C2.
>
> > 5) Once C2 gets the information its upto C2 to take further actions.
> > 6) By this process we can save the time spent in the locking mechanism
> for C2.Basically we aim to by-pass the locking scheme of Lustre for the
> files already opened by some client by maintaining some kind of data
> structure.
> >
> > Please let us know your thoughts on the above approach.Is this a feasible
> design moving ahead can we see any complications ?
>
> There is a separate proposal that has been underway in the Linux community
> for some time, to allow a user process to get a file handle (i.e. binary
> blob returned from a new name_to_handle() syscall) from the kernel for a
> given pathname, and then later use that file handle in another process to
> open a file descriptor without re-traversing the path.
>
> I've been thinking this would be very useful for Lustre (and MPI in
> general), and have tried to steer the Linux development in a direction that
> would allow this to happen.  Is this in line with what you are
> investigating?
>
> While this wouldn't eliminate the actual MDS open RPC (i.e. the
> LDLM_ENQUEUE you have been discussing), it could avoid the path traversal
> from each client, possibly saving {path_elements * num_clients} additional
> RPCs,
>
> > So considering the problem statement I need a way for C2 to extract the
> information from the data structure maintained at MDS.In order to do that ,
> C2 will send a request with intent = create|open which will be a
> LDLM_ENQUEUE RPC.I need to modify this RPC such that :-
> > 1) I can enclose some additional buffer whose size is known to me .
> > 2) When we pack the reply at the MDS side we should be able to include
> this buffer in the reply message .
> > 3) At the client side we should be able to extract the information from
> the reply message about the buffer.
> >
> > As of now , I need help in above three steps.
> >
> > Thanks,
> > Vilobh
> > Graduate Research Associate
> > Department of Computer Science
> > The Ohio State University Columbus Ohio
> >
> >
> > On Tue, Oct 19, 2010 at 6:53 PM, Andreas Dilger <
> andreas.dilger at oracle.com> wrote:
> > On 2010-10-19, at 14:28, Vilobh Meshram wrote:
> > > From my exploration it seems like for create/open kind of request
> LDLM_ENQUEUE is the RPC through which the client talks to MDS.Please confirm
> on this.
> > >
> > > Since I could figure out that LDLM_ENQUEUE is the only RPC to interface
> with MDS I am planning to send the LDLM_ENQUEUE RPC with some additonal
> buffer from the client to the MDS so that based on some specific condition
> the MDS can fill the information in the buffer sent from the client.
> >
> > This isn't correct.  LDLM_ENQUEUE is used for enqueueing locks.  It just
> happens that when Lustre wants to create a new file it enqueues a lock on
> the parent directory with the "intent" to create a new file.  The MDS
> currently always replies "you cannot have the lock for the directory, I
> created the requested file for you".  Similarly, when the client is getting
> attributes on a file, it needs a lock on that file in order to cache the
> attributes, and to save RPCs the attributes are returned with the lock.
> >
> > > I have made some modifications to the code for the LDLM_ENQUEUE RPC but
> I am getting kernel panics.Can someone please help me and suggest me what is
> a good way to tackle this problem.I am using Lustre 1.8.1.1 and I cannot
> upgrade to Lustre 2.0.
> >
> > It would REALLY be a lot easier to have this discussion with you if you
> actually told us what it is you are working on.  Not only could we focus on
> the higher-level issue that you are trying to solve (instead of possibly
> wasting a lot of time focussing in a small issue that may in fact be
> completely irrelevant), but with many ideas related to Lustre it has
> probably already been discussed at length by the Lustre developers sometime
> over the past 8 years that we've been working on it.  I suspect that the
> readership of this list could probably give you a lot of assistance with
> whatever you are working on, if you will only tell us what it actually is
> you are trying to do.
> >
> > > On Mon, Oct 18, 2010 at 7:33 PM, Vilobh Meshram <
> vilobh.meshram at gmail.com> wrote:
> > >> Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the
> most frequently used RPC to communicate between the client and the MDS.I
> have few queries regarding the same :-
> > >>
> > >> 1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind
> of request ; through which the client can interact with the MDS ?
> > >>
> > >> I tried couple of experiments and found out that LDLM_ENQUEUE comes
> into picture while mounting the FS as well as when we do a lookup,create or
> open a file.I was expecting the MDS_REINT RPC to get invoked in case of a
> CREATE/OPEN request via mdc_create() but it seems like Lustre invokes
> LDLM_ENQEUE even for CREATE/OPEN( by packing the intent related data).
> > >> Please correct me if I am wrong.
> > >>
> > >> 2) In which cases (which system calls) does the MDS_REINT RPC will get
> invoked ?
> >
> >
> > Cheers, Andreas
> > --
> > Andreas Dilger
> > Lustre Technical Lead
> > Oracle Corporation Canada Inc.
> >
> >
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101021/495a5f4a/attachment.htm>
-------------- next part --------------
*** ./lustre/ldlm/ldlm_lockd.c	2010-10-21 17:49:05.000000000 -0400
--- ../fresh/lustre/ldlm/ldlm_lockd.c	2010-10-15 15:37:02.000000000 -0400
*************** int ldlm_handle_enqueue(struct ptlrpc_re
*** 997,1017 ****
          struct obd_device *obddev = req->rq_export->exp_obd;
          struct ldlm_reply *dlm_rep;
          struct ldlm_request *dlm_req;
!         __u32 size[4] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep) };
          int rc = 0;
          __u32 flags;
          ldlm_error_t err = ELDLM_OK;
          struct ldlm_lock *lock = NULL;
          void *cookie = NULL;
-         int i;
-         char *str = "Hello World Sun";
-         char *str_target;
          ENTRY;
  
          LDLM_DEBUG_NOLOCK("server-side enqueue handler START");
!         printk("\n Inside function %s server-side enqueue handler START",__func__);
!         for(i=0;i<3;i++) printk("\n Inside function %s size[%d]:%d",__func__,i,size[i]);
          dlm_req = lustre_swab_reqbuf(req, DLM_LOCKREQ_OFF, sizeof(*dlm_req),
                                       lustre_swab_ldlm_request);
          if (dlm_req == NULL) {
--- 997,1013 ----
          struct obd_device *obddev = req->rq_export->exp_obd;
          struct ldlm_reply *dlm_rep;
          struct ldlm_request *dlm_req;
!         __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREPLY_OFF]   = sizeof(*dlm_rep) };
          int rc = 0;
          __u32 flags;
          ldlm_error_t err = ELDLM_OK;
          struct ldlm_lock *lock = NULL;
          void *cookie = NULL;
          ENTRY;
  
          LDLM_DEBUG_NOLOCK("server-side enqueue handler START");
! 
          dlm_req = lustre_swab_reqbuf(req, DLM_LOCKREQ_OFF, sizeof(*dlm_req),
                                       lustre_swab_ldlm_request);
          if (dlm_req == NULL) {
*************** existing_lock:
*** 1126,1148 ****
                  int buffers = 2;
  
                  lock_res_and_lock(lock);
-                 printk("\n Exsisting lock lock->l_resource->lr_lvb_len:%u",lock->l_resource->lr_lvb_len);
                  if (lock->l_resource->lr_lvb_len) {
-                         printk("\n Inside function %s , inside condition lock->l_resource->lr_lvb_len so buffers=3",__func__);
                          size[DLM_REPLY_REC_OFF] = lock->l_resource->lr_lvb_len;
                          buffers = 3;
                  }
-                 //size[DLM_REPLY_REC_OFF] = 16;
-                 //buffer = buffer + 1;
-                 if(lock->l_resource->lr_lvb_len == 0)
-                 {
-                      buffers++;
-                      size[DLM_REPLY_REC_OFF] = 0;
-                 }
-                 buffers++;
-                 size[DLM_REPLY_REC_OFF+1] = 16;
                  unlock_res_and_lock(lock);
!                 printk("\n Inside function %s , outside condition lock->l_resource->lr_lvb_len so buffers=2",__func__);
                  if (OBD_FAIL_CHECK_ONCE(OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR))
                          GOTO(out, rc = -ENOMEM);
  
--- 1122,1133 ----
                  int buffers = 2;
  
                  lock_res_and_lock(lock);
                  if (lock->l_resource->lr_lvb_len) {
                          size[DLM_REPLY_REC_OFF] = lock->l_resource->lr_lvb_len;
                          buffers = 3;
                  }
                  unlock_res_and_lock(lock);
! 
                  if (OBD_FAIL_CHECK_ONCE(OBD_FAIL_LDLM_ENQUEUE_EXTENT_ERR))
                          GOTO(out, rc = -ENOMEM);
  
*************** existing_lock:
*** 1156,1164 ****
          if (dlm_req->lock_desc.l_resource.lr_type == LDLM_EXTENT)
                  lock->l_req_extent = lock->l_policy_data.l_extent;
  
-         printk("%s: \twill do lock-enq...\n", __func__);
          err = ldlm_lock_enqueue(obddev->obd_namespace, &lock, cookie, (int *)&flags);
-         printk("%s: \tafter lock-enq...\n", __func__);
          if (err)
                  GOTO(out, err);
  
--- 1141,1147 ----
*************** existing_lock:
*** 1178,1185 ****
          dlm_rep->lock_flags |= dlm_req->lock_flags & LDLM_INHERIT_FLAGS;
          lock->l_flags |= dlm_req->lock_flags & LDLM_INHERIT_FLAGS;
  
-         str_target = lustre_msg_buf(req->rq_repmsg, DLM_REPLY_REC_OFF+1,16);
-         memcpy(str_target,str,16);
          /* Don't move a pending lock onto the export if it has already
           * been evicted.  Cancel it now instead. (bug 5683) */
          if (req->rq_export->exp_failed ||
--- 1161,1166 ----
*************** existing_lock:
*** 1232,1238 ****
  
          EXIT;
   out:
-         printk("\n [VM] Inside function %s got a hit at out",__func__);
          req->rq_status = rc ?: err;  /* return either error - bug 11190 */
          if (!req->rq_packed_final) {
                  err = lustre_pack_reply(req, 1, NULL, NULL);
--- 1213,1218 ----
*************** existing_lock:
*** 1248,1257 ****
  
                  if (rc == 0) {
                          lock_res_and_lock(lock);
-                         printk("\n Inside function %s , inside if condition rc=0 the place where we do a memcpy for offset = DLM_REPLY_REC_OFF",__func__);
                          size[DLM_REPLY_REC_OFF] = lock->l_resource->lr_lvb_len;
-                         printk("\n Inside function %s , size[DLM_REPLY_REC_OFF] : %u , lock->l_resource->lr_lvb_len :%u",__func__,size[DLM_REPLY_REC_OFF],lock->l_resource->lr_lvb_len);
-                         size[DLM_REPLY_REC_OFF+1]= 16;
                          if (size[DLM_REPLY_REC_OFF] > 0) {
                                  void *lvb = lustre_msg_buf(req->rq_repmsg,
                                                         DLM_REPLY_REC_OFF,
--- 1228,1234 ----
*************** existing_lock:
*** 1264,1270 ****
                          }
                          unlock_res_and_lock(lock);
                  } else {
-                         printk("\n Inside function %s , inside else condition rc=0 the place where we do a memcpy for offset = DLM_REPLY_REC_OFF",__func__);
                          lock_res_and_lock(lock);
                          ldlm_resource_unlink_lock(lock);
                          ldlm_lock_destroy_nolock(lock);
--- 1241,1246 ----
-------------- next part --------------
*** ./lustre/ldlm/ldlm_request.c	2010-10-21 22:26:28.000000000 -0400
--- ../fresh/lustre/ldlm/ldlm_request.c	2010-10-15 15:37:02.000000000 -0400
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 389,395 ****
          int cleanup_phase = 1;
          ENTRY;
  
-         printk("\n Inside function %s",__func__);
          lock = ldlm_handle2lock(lockh);
          /* ldlm_cli_enqueue is holding a reference on this lock. */
          if (!lock) {
--- 389,394 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 401,407 ****
                  LASSERT(!is_replay);
                  LDLM_DEBUG(lock, "client-side enqueue END (%s)",
                             rc == ELDLM_LOCK_ABORTED ? "ABORTED" : "FAILED");
-                 printk("\n Inside %s if client lock aborted or failed",__func__);
                  if (rc == ELDLM_LOCK_ABORTED) {
                          /* Before we return, swab the reply */
                          reply = lustre_swab_repbuf(req, DLM_LOCKREPLY_OFF,
--- 400,405 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 433,440 ****
                  GOTO(cleanup, rc = -EPROTO);
          }
  
-         printk("\n Inside function %s we have received a reply",__func__);
- 
          /* lock enqueued on the server */
          cleanup_phase = 0;
  
--- 431,436 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 463,469 ****
           * again. */
          if ((*flags) & LDLM_FL_LOCK_CHANGED) {
                  int newmode = reply->lock_desc.l_req_mode;
-                 printk("\n Inside function %s in condition (*flags) & LDLM_FL_LOCK_CHANGED)",__func__);
                  LASSERT(!is_replay);
                  if (newmode && newmode != lock->l_req_mode) {
                          LDLM_DEBUG(lock, "server returned different mode %s",
--- 459,464 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 504,510 ****
               * because it cannot handle asynchronous ASTs robustly (see
               * bug 7311). */
              (LIBLUSTRE_CLIENT && type == LDLM_EXTENT)) {
-                 printk("\n Inside function %s in condition ((*flags) & LDLM_FL_AST_SENT ||(LIBLUSTRE_CLIENT && type == LDLM_EXTENT))",__func__);
                  lock_res_and_lock(lock);
                  lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_BL_AST;
                  unlock_res_and_lock(lock);
--- 499,504 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 515,521 ****
           * clobber the LVB with an older one. */
          if (lvb_len && (lock->l_req_mode != lock->l_granted_mode)) {
                  void *tmplvb;
-                 printk("\n Inside function %s in condition lvb_len && (lock->l_req_mode != lock->l_granted_mode) , lvb_len:%d",__func__,lvb_len);
                  tmplvb = lustre_swab_repbuf(req, DLM_REPLY_REC_OFF, lvb_len,
                                              lvb_swabber);
                  if (tmplvb == NULL)
--- 509,514 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 524,530 ****
          }
  
          if (!is_replay) {
-                 printk("\n Inside function %s in condition !is_replay",__func__);
                  rc = ldlm_lock_enqueue(ns, &lock, NULL, flags);
                  if (lock->l_completion_ast != NULL) {
                          int err = lock->l_completion_ast(lock, *flags, NULL);
--- 517,522 ----
*************** int ldlm_cli_enqueue_fini(struct obd_exp
*** 536,542 ****
          }
  
          if (lvb_len && lvb != NULL) {
-                 printk("\n Inside function %s in condition lvb_len && lvb != NULL",__func__);
                  /* Copy the LVB here, and not earlier, because the completion
                   * AST (if any) can override what we got in the reply */
                  memcpy(lvb, lock->l_lvb_data, lvb_len);
--- 528,533 ----
*************** static inline int ldlm_req_handles_avail
*** 560,578 ****
                                           __u32 *size, int bufcount, int off)
  {
          int avail = min_t(int, LDLM_MAXREQSIZE, CFS_PAGE_SIZE - 512);
!         printk("\n Inside function %s",__func__);
!         printk("\n avail--before = %d",avail); 
          avail -= lustre_msg_size(class_exp2cliimp(exp)->imp_msg_magic,
                                   bufcount, size);
!         printk("\n avail--after  = %d",avail);
!         if (likely(avail >= 0)){
                  avail /= (int)sizeof(struct lustre_handle);
-                 printk("\n avail--likely = %d",avail);
-         }
          else
                  avail = 0;
          avail += LDLM_LOCKREQ_HANDLES - off;
!         printk("\n avail--lats = %d",avail);
          return avail;
  }
  
--- 551,565 ----
                                           __u32 *size, int bufcount, int off)
  {
          int avail = min_t(int, LDLM_MAXREQSIZE, CFS_PAGE_SIZE - 512);
! 
          avail -= lustre_msg_size(class_exp2cliimp(exp)->imp_msg_magic,
                                   bufcount, size);
!         if (likely(avail >= 0))
                  avail /= (int)sizeof(struct lustre_handle);
          else
                  avail = 0;
          avail += LDLM_LOCKREQ_HANDLES - off;
! 
          return avail;
  }
  
*************** struct ptlrpc_request *ldlm_prep_elc_req
*** 597,622 ****
          CFS_LIST_HEAD(head);
          ENTRY;
  
-         printk("\n Inside function %s, opc=%d",__func__, opc);
          if (cancels == NULL)
                  cancels = &head;
          if (exp_connect_cancelset(exp)) {
                  /* Estimate the amount of free space in the request. */
-                 printk("\n Inside exp_connect_cancelset(exp) in func %s",__func__);
                  LASSERT(bufoff < bufcount);
  
                  avail = ldlm_req_handles_avail(exp, size, bufcount, canceloff);
-                 printk("\n In function %s avail = %d",__func__,avail);
                  flags = ns_connect_lru_resize(ns) ?
                          LDLM_CANCEL_LRUR : LDLM_CANCEL_AGED;
-                 printk("\n In function %s ns_connect_lru_resize(ns) :%d",__func__,ns_connect_lru_resize(ns));
                  to_free = !ns_connect_lru_resize(ns) &&
                            opc == LDLM_ENQUEUE ? 1 : 0;
  
                  /* Cancel lru locks here _only_ if the server supports
                   * EARLY_CANCEL. Otherwise we have to send extra CANCEL
                   * rpc, what will make us slower. */
-                 printk("\n In function %s count = %d",__func__,count);
                  if (avail > count)
                          count += ldlm_cancel_lru_local(ns, cancels, to_free,
                                                         avail - count, 0, flags);
--- 584,604 ----
*************** struct ptlrpc_request *ldlm_prep_elc_req
*** 624,632 ****
                          pack = count;
                  else
                          pack = avail;
-                 printk("\n In function %s pack = %d",__func__,pack);
                  size[bufoff] = ldlm_request_bufsize(pack, opc);
-                 printk("\n In function %s , bufoff : %d , size[bufoff]= %u",__func__,bufoff,size[bufoff]);
          }
  
          req = ptlrpc_prep_req(class_exp2cliimp(exp), version,
--- 606,612 ----
*************** struct ptlrpc_request *ldlm_prep_enqueue
*** 657,663 ****
                                               struct list_head *cancels,
                                               int count)
  {
-         printk("\n Inside function %s \n",__func__);
          return ldlm_prep_elc_req(exp, LUSTRE_DLM_VERSION, LDLM_ENQUEUE,
                                   bufcount, size, DLM_LOCKREQ_OFF,
                                   LDLM_ENQUEUE_CANCEL_OFF, cancels, count);
--- 637,642 ----
*************** int ldlm_cli_enqueue(struct obd_export *
*** 679,697 ****
          struct ldlm_lock *lock;
          struct ldlm_request *body;
          struct ldlm_reply *reply;
!         __u32 size[4] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREQ_OFF]     = sizeof(*body),
                          [DLM_REPLY_REC_OFF]   = lvb_len ? lvb_len :
!                                                 sizeof(struct ost_lvb),
!                         [DLM_REPLY_REC_OFF+1] = 16};
          int is_replay = *flags & LDLM_FL_REPLAY;
          int req_passed_in = 1, rc, err;
          struct ptlrpc_request *req;
-         int i;
          ENTRY;
  
-         printk("\n Inside function %s \n",__func__);
-         for(i=0;i<4;i++) printk("\n size[%d] : %d",i,size[i]);
          LASSERT(exp != NULL);
  
          /* If we're replaying this lock, just check some invariants.
--- 658,672 ----
          struct ldlm_lock *lock;
          struct ldlm_request *body;
          struct ldlm_reply *reply;
!         __u32 size[3] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREQ_OFF]     = sizeof(*body),
                          [DLM_REPLY_REC_OFF]   = lvb_len ? lvb_len :
!                                                 sizeof(struct ost_lvb) };
          int is_replay = *flags & LDLM_FL_REPLAY;
          int req_passed_in = 1, rc, err;
          struct ptlrpc_request *req;
          ENTRY;
  
          LASSERT(exp != NULL);
  
          /* If we're replaying this lock, just check some invariants.
*************** int ldlm_cli_enqueue(struct obd_export *
*** 700,706 ****
                  lock = ldlm_handle2lock(lockh);
                  LASSERT(lock != NULL);
                  LDLM_DEBUG(lock, "client-side enqueue START");
-                 printk("\n Client-side enqueue START in %s",__func__);
                  LASSERT(exp == lock->l_conn_export);
          } else {
                  lock = ldlm_lock_create(ns, res_id, einfo->ei_type,
--- 675,680 ----
*************** int ldlm_cli_enqueue(struct obd_export *
*** 736,742 ****
          /* lock not sent to server yet */
  
          if (reqp == NULL || *reqp == NULL) {
!                 req = ldlm_prep_enqueue_req(exp,3, size, NULL, 0);
                  if (req == NULL) {
                          failed_lock_cleanup(ns, lock, lockh, einfo->ei_mode);
                          LDLM_LOCK_PUT(lock);
--- 710,716 ----
          /* lock not sent to server yet */
  
          if (reqp == NULL || *reqp == NULL) {
!                 req = ldlm_prep_enqueue_req(exp, 2, size, NULL, 0);
                  if (req == NULL) {
                          failed_lock_cleanup(ns, lock, lockh, einfo->ei_mode);
                          LDLM_LOCK_PUT(lock);
*************** int ldlm_cli_enqueue(struct obd_export *
*** 746,752 ****
                  if (reqp)
                          *reqp = req;
          } else {
-                 printk("\n [VM]got a hit at case where reqp is not NULL in %s",__func__);
                  req = *reqp;
                  LASSERTF(lustre_msg_buflen(req->rq_reqmsg, DLM_LOCKREQ_OFF) >=
                           sizeof(*body), "buflen[%d] = %d, not %d\n",
--- 720,725 ----
*************** int ldlm_cli_enqueue(struct obd_export *
*** 768,774 ****
          /* Continue as normal. */
          if (!req_passed_in) {
                  size[DLM_LOCKREPLY_OFF] = sizeof(*reply);
!                 ptlrpc_req_set_repsize(req, 4, size);
          }
  
          /*
--- 741,747 ----
          /* Continue as normal. */
          if (!req_passed_in) {
                  size[DLM_LOCKREPLY_OFF] = sizeof(*reply);
!                 ptlrpc_req_set_repsize(req, 3, size);
          }
  
          /*
*************** int ldlm_cli_enqueue(struct obd_export *
*** 784,793 ****
                  RETURN(0);
          }
  
-         printk("\n in --func-- %s SENDING REQUEST",__func__);
          LDLM_DEBUG(lock, "sending request");
          rc = ptlrpc_queue_wait(req);
-         printk("\n in --func-- %s REQUEST SENT after ptlrpc_queue_wait",__func__);
          err = ldlm_cli_enqueue_fini(exp, req, einfo->ei_type, policy ? 1 : 0,
                                      einfo->ei_mode, flags, lvb, lvb_len,
                                      lvb_swabber, lockh, rc);
--- 757,764 ----
-------------- next part --------------
*** ./lustre/mdc/mdc_locks.c	2010-10-20 20:58:51.000000000 -0400
--- ../fresh/lustre/mdc/mdc_locks.c	2010-10-15 15:37:15.000000000 -0400
*************** static struct ptlrpc_request *mdc_intent
*** 252,264 ****
          int repbufcount = 5;
          int mode;
          int rc;
-         int i;
          ENTRY;
  
-         printk("\n Inside function %s",__func__);
-         for(i=0;i<6;i++) printk("\n size[%d] : %d",i,size[i]);
-         for(i=0;i<5;i++) printk("\n repsize[%d] : %d",i,repsize[i]);
- 
          it->it_create_mode = (it->it_create_mode & ~S_IFMT) | S_IFREG;
          if (mdc_exp_is_2_0_server(exp)) {
                  size[DLM_INTENT_REC_OFF] = sizeof(struct mdt_rec_create);
--- 252,259 ----
*************** static struct ptlrpc_request *mdc_intent
*** 381,405 ****
          struct ptlrpc_request *req;
          struct ldlm_intent *lit;
          struct obd_device *obddev = class_exp2obd(exp);
!         __u32 size[] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request),
                          [DLM_INTENT_IT_OFF]   = sizeof(*lit),
                          [DLM_INTENT_REC_OFF]  = sizeof(struct mdt_body),
                          [DLM_INTENT_REC_OFF+1]= data->namelen + 1,
!                         [DLM_INTENT_REC_OFF+2]= 0,
!                         [DLM_INTENT_REC_OFF+3]= 16 };
!         __u32 repsize[] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                             [DLM_LOCKREPLY_OFF]   = sizeof(struct ldlm_reply),
                             [DLM_REPLY_REC_OFF]   = sizeof(struct mdt_body),
                             [DLM_REPLY_REC_OFF+1] = obddev->u.cli.
                                                          cl_max_mds_easize,
                             [DLM_REPLY_REC_OFF+2] = LUSTRE_POSIX_ACL_MAX_SIZE,
!                            [DLM_REPLY_REC_OFF+3] = 0,
!                            [DLM_REPLY_REC_OFF+4] = 16 };
          obd_valid valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE | OBD_MD_FLACL |
                            OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA;
!         int bufcount = 6;
!         int i=0;
          ENTRY;
  
          if (mdc_exp_is_2_0_server(exp)) {
--- 376,397 ----
          struct ptlrpc_request *req;
          struct ldlm_intent *lit;
          struct obd_device *obddev = class_exp2obd(exp);
!         __u32 size[6] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                          [DLM_LOCKREQ_OFF]     = sizeof(struct ldlm_request),
                          [DLM_INTENT_IT_OFF]   = sizeof(*lit),
                          [DLM_INTENT_REC_OFF]  = sizeof(struct mdt_body),
                          [DLM_INTENT_REC_OFF+1]= data->namelen + 1,
!                         [DLM_INTENT_REC_OFF+2]= 0 };
!         __u32 repsize[6] = { [MSG_PTLRPC_BODY_OFF] = sizeof(struct ptlrpc_body),
                             [DLM_LOCKREPLY_OFF]   = sizeof(struct ldlm_reply),
                             [DLM_REPLY_REC_OFF]   = sizeof(struct mdt_body),
                             [DLM_REPLY_REC_OFF+1] = obddev->u.cli.
                                                          cl_max_mds_easize,
                             [DLM_REPLY_REC_OFF+2] = LUSTRE_POSIX_ACL_MAX_SIZE,
!                            [DLM_REPLY_REC_OFF+3] = 0 };
          obd_valid valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE | OBD_MD_FLACL |
                            OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA;
!         int bufcount = 5;
          ENTRY;
  
          if (mdc_exp_is_2_0_server(exp)) {
*************** static struct ptlrpc_request *mdc_intent
*** 407,418 ****
                  size[DLM_INTENT_REC_OFF+2] = data->namelen + 1;
                  bufcount = 6;
          }
-        
-         printk("%s: prep-enq-req: bufcnt=%d\n", __func__, bufcount); 
-         for(i=0; i<bufcount; i++) {      
-                 printk("\tsize[%d]=%u\n", i,size[i] );
-                 printk("\trepsize[%d]=%u\n", i,repsize[i] );
-         }
          req = ldlm_prep_enqueue_req(exp, bufcount, size, NULL, 0);
          if (req) {
                  /* pack the intent */
--- 399,404 ----
*************** static int mdc_finish_enqueue(struct obd
*** 455,461 ****
          struct ldlm_reply *lockrep;
          ENTRY;
  
-         printk("\n Inside function %s",__func__);
          LASSERT(rc >= 0);
          /* Similarly, if we're going to replay this request, we don't want to
           * actually get a lock, just perform the intent. */
--- 441,446 ----
*************** static int mdc_finish_enqueue(struct obd
*** 517,523 ****
          /* We know what to expect, so we do any byte flipping required here */
          if (it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR)) {
                  struct mds_body *body;
!                 printk("\n Inside function %s inside condition IT_OPEN , IT_LOOKUP , IT_GETATTR",__func__);
                  body = lustre_swab_repbuf(req, DLM_REPLY_REC_OFF, sizeof(*body),
                                           lustre_swab_mds_body);
                  if (body == NULL) {
--- 502,508 ----
          /* We know what to expect, so we do any byte flipping required here */
          if (it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR)) {
                  struct mds_body *body;
! 
                  body = lustre_swab_repbuf(req, DLM_REPLY_REC_OFF, sizeof(*body),
                                           lustre_swab_mds_body);
                  if (body == NULL) {
*************** int mdc_enqueue(struct obd_export *exp, 
*** 587,593 ****
          int rc;
          ENTRY;
  
-         printk("\n Inside function %s \n",__func__);
          fid_build_reg_res_name((void *)&data->fid1, &res_id);
          LASSERTF(einfo->ei_type == LDLM_IBITS,"lock type %d\n", einfo->ei_type);
          if (it->it_op & (IT_UNLINK | IT_GETATTR | IT_READDIR))
--- 572,577 ----
*************** int mdc_intent_getattr_async(struct obd_
*** 924,933 ****
          int                      flags = LDLM_FL_HAS_INTENT;
          ENTRY;
  
-         printk("%s: name: %.*s in inode "LPU64", intent: %s flags %#o\n",__func__,
-                op_data->namelen, op_data->name, op_data->fid1.id,
-                ldlm_it2str(it->it_op), it->it_flags);
- 
          CDEBUG(D_DLMTRACE,"name: %.*s in inode "LPU64", intent: %s flags %#o\n",
                 op_data->namelen, op_data->name, op_data->fid1.id,
                 ldlm_it2str(it->it_op), it->it_flags);
--- 908,913 ----
