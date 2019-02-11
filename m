From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 14:08:46 +1100
Subject: [lustre-devel] [PATCH 05/21] lustre: use list_first_entry() in
 lustre subdirectory.
In-Reply-To: <alpine.LFD.2.21.1902110132500.24975@casper.infradead.org>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781279.10620.5804477141390456723.stgit@noble.brown>
 <alpine.LFD.2.21.1902110132500.24975@casper.infradead.org>
Message-ID: <875ztrggxt.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Feb 11 2019, James Simmons wrote:

>> Convert
>>   list_entry(foo->next .....)
>> to
>>   list_first_entry(foo, ....)
>> 
>> in 'lustre'
>> 
>> In several cases the call is combined with
>> a list_empty() test and list_first_entry_or_null() is used
>
> Nak. One of the changes below breaks things.
>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/include/cl_object.h  |    2 -
>>  drivers/staging/lustre/lustre/llite/statahead.c    |   23 ++++----
>>  drivers/staging/lustre/lustre/lov/lov_io.c         |    9 +--
>>  drivers/staging/lustre/lustre/obdclass/cl_page.c   |    9 +--
>>  drivers/staging/lustre/lustre/obdclass/genops.c    |   22 ++++---
>>  .../staging/lustre/lustre/obdclass/lustre_peer.c   |    5 +-
>>  drivers/staging/lustre/lustre/osc/osc_cache.c      |   17 +++---
>>  drivers/staging/lustre/lustre/osc/osc_lock.c       |    5 +-
>>  drivers/staging/lustre/lustre/osc/osc_page.c       |   17 +++---
>>  drivers/staging/lustre/lustre/osc/osc_request.c    |    8 +--
>>  drivers/staging/lustre/lustre/ptlrpc/client.c      |    8 +--
>>  drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    6 +-
>>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 +
>>  drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    6 +-
>>  drivers/staging/lustre/lustre/ptlrpc/service.c     |   59 ++++++++++----------
>>  15 files changed, 101 insertions(+), 99 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
>> index 13d79810dd39..53fd8d469e55 100644
>> --- a/drivers/staging/lustre/lustre/include/cl_object.h
>> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
>> @@ -2335,7 +2335,7 @@ static inline struct cl_page *cl_page_list_last(struct cl_page_list *plist)
>>  static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
>>  {
>>  	LASSERT(plist->pl_nr > 0);
>> -	return list_entry(plist->pl_pages.next, struct cl_page, cp_batch);
>> +	return list_first_entry(&plist->pl_pages, struct cl_page, cp_batch);
>>  }
>>  
>>  /**
>
> ...
>
>> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
>> index 5b97f2a1fea1..a69736dfe8b7 100644
>> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
>> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
>> @@ -299,9 +299,9 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
>>  			return posted;
>>  		}
>>  
>> -		rqbd = list_entry(svcpt->scp_rqbd_idle.next,
>> -				  struct ptlrpc_request_buffer_desc,
>> -				  rqbd_list);
>> +		rqbd = list_first_entry(&svcpt->scp_rqbd_idle,
>> +					struct ptlrpc_request_buffer_desc,
>> +					rqbd_list);
>>  		list_del(&rqbd->rqbd_list);
>>  
>>  		/* assume we will post successfully */
>> @@ -769,9 +769,9 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
>>  		 * I expect only about 1 or 2 rqbds need to be recycled here
>>  		 */
>>  		while (svcpt->scp_hist_nrqbds > svc->srv_hist_nrqbds_cpt_max) {
>> -			rqbd = list_entry(svcpt->scp_hist_rqbds.next,
>> -					  struct ptlrpc_request_buffer_desc,
>> -					  rqbd_list);
>> +			rqbd = list_first_entry(&svcpt->scp_hist_rqbds,
>> +						struct ptlrpc_request_buffer_desc,
>> +						rqbd_list);
>>  
>>  			list_del(&rqbd->rqbd_list);
>>  			svcpt->scp_hist_nrqbds--;
>> @@ -1240,9 +1240,9 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
>>  	/* we took additional refcount so entries can't be deleted from list, no
>>  	 * locking is needed
>>  	 */
>> -	while (!list_empty(&work_list)) {
>> -		rq = list_entry(work_list.next, struct ptlrpc_request,
>> -				rq_timed_list);
>> +	while ((rq = list_first_entry_or_null(&work_list,
>> +					      struct ptlrpc_request,
>> +					      rq_timed_list)) != NULL) {
>>  		list_del_init(&rq->rq_timed_list);
>>  
>>  		if (ptlrpc_at_send_early_reply(rq) == 0)
>> @@ -1485,8 +1485,8 @@ ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
>>  		return 0;
>>  	}
>>  
>> -	req = list_entry(svcpt->scp_req_incoming.next,
>> -			 struct ptlrpc_request, rq_list);
>> +	req = list_first_entry(&svcpt->scp_req_incoming,
>> +			       struct ptlrpc_request, rq_list);
>>  	list_del_init(&req->rq_list);
>>  	svcpt->scp_nreqs_incoming--;
>>  	/* Consider this still a "queued" request as far as stats are
>> @@ -2345,9 +2345,9 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
>>  
>>  	wake_up_all(&svcpt->scp_waitq);
>>  
>> -	while (!list_empty(&svcpt->scp_threads)) {
>> -		thread = list_entry(svcpt->scp_threads.next,
>> -				    struct ptlrpc_thread, t_link);
>> +	while ((thread = list_first_entry_or_null(&svcpt->scp_threads,
>> +						  struct ptlrpc_thread,
>> +						  t_link)) != NULL) {
>>  		if (thread_is_stopped(thread)) {
>>  			list_del(&thread->t_link);
>>  			list_add(&thread->t_link, &zombie);
>> @@ -2365,9 +2365,9 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
>>  
>>  	spin_unlock(&svcpt->scp_lock);
>>  
>> -	while (!list_empty(&zombie)) {
>> -		thread = list_entry(zombie.next,
>> -				    struct ptlrpc_thread, t_link);
>> +	while ((thread = list_first_entry(&zombie,
>> +					  struct ptlrpc_thread,
>> +					  t_link)) != NULL) {
>>  		list_del(&thread->t_link);
>>  		kfree(thread);
>>  	}
>
> The above change causes sanity tests 77j: client only supporting ADLER32
> to fail with:
>
> 2019-02-07 18:38:26 [ 4346.464550] Lustre: Unmounted lustre-client
> 2019-02-07 18:38:26 [ 4346.471990] BUG: unable to handle kernel paging 
> request at ffffeb02001c89c8
> 2019-02-07 18:38:26 [ 4346.480489] #PF error: [normal kernel read fault]
> 2019-02-07 18:38:26 [ 4346.486719] PGD 0 P4D 0
> 2019-02-07 18:38:26 [ 4346.490758] Oops: 0000 [#1] PREEMPT SMP PTI
> 2019-02-07 18:38:26 [ 4346.496420] CPU: 0 PID: 2478 Comm: kworker/0:1 
> Tainted: G        WC        5.0.0-rc4+ #1
> 2019-02-07 18:38:26 [ 4346.505976] Hardware name: Supermicro 
> SYS-6028TR-HTFR/X10DRT-HIBF, BIOS 2.0b 08/12/2016
> 2019-02-07 18:38:26 [ 4346.515461] Workqueue: obd_zombid 
> obd_zombie_imp_cull [obdclass]
> 2019-02-07 18:38:26 [ 4346.522917] RIP: 0010:kfree+0x52/0x1b0
>

Thanks so much for testing and finding this.
The above should, of course, be

>> +	while ((thread = list_first_entry_or_null(&zombie,
>> +					  struct ptlrpc_thread,
>> +					  t_link)) != NULL) {

(with _or_null).  I've fixed it in my tree.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/423431a2/attachment-0001.sig>
