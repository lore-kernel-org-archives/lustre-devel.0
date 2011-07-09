From: Andreas Dilger <adilger@whamcloud.com>
Date: Sat, 9 Jul 2011 01:53:10 -0600
Subject: [Lustre-devel] NRS HLD
In-Reply-To: <06B2896D-1A6A-4738-96AD-95D9B04AE9A4@whamcloud.com>
References: <24C12A32-1D42-4327-8F8F-B9D30471B8C8@gmail.com>
	<1309448989.27038.5.camel@localhost.localdomain>
	<88C87A8C-8DB5-4602-863B-9B77FF93C0D1@whamcloud.com>
	<8C4CE53E-8A87-43FE-B27F-F44B5E3D7550@us.xyratex.com>
	<61BD608D-C941-4741-8200-79752803AF5D@whamcloud.com>
	<1310049242.2181.120.camel@localhost.localdomain>
	<06B2896D-1A6A-4738-96AD-95D9B04AE9A4@whamcloud.com>
Message-ID: <C9272EDA-83DB-4ACE-A1A9-CE9DB52AAF60@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think another policy type that is important to users is "minimum bandwidth" or "maximum bandwidth". Please ensure that any framework that is implemented can also be used in this manner. Ideally this would be part of the initial implementation. 

Cheers, Andreas

On 2011-07-08, at 9:34 PM, Liang Zhen <liang@whamcloud.com> wrote:

> Hi Nikitas,
> 
> As you can see, I've posted my prototype on our Jira, hope it can help on
> explaining how binheap can be used for NRS because it will be too complex
> for me to explain all things by English, :-)
> 
> http://jira.whamcloud.com/browse/LU-398
> http://jira.whamcloud.com/secure/attachment/10300/nrs_liang_v2.patch
> 
> I got this prototype a couple of weeks ago and we are looking for a chance
> to get some performance data with it.
> 
> It's not fully tested and not reviewed, so I posted it just for discussion
> and hope it can help us to understand things better and avoid rework.
> If I was wrong in the prototype or my points here, please just correct me
> either on Jira or at here.
> 
> the prototype contains:
> 
>  - implementation of binheap
> 
>  - a simple framework for NRS
> 
>  - client-round-robin implemented by binheap
> 
> Because it's just a prototype and I don't have any document (sorry...)
> so I'm going to give some introduction at here.
> 
>  A few concepts:
> 
>  - NRS policy
>    the algorithm of adding/sorting/removing requests
> 
>  - NRS policy head
>    . it's a list of NRS polices
> 
>    . a policy head must has a default-policy (i.e: FIFO), default-policy
>      should never fail and can't be disable
> 
>    . a policy-head can have one active-policy, or no active-policy at all.
>      If there is an active-policy, request should firstly be handled by it.
>      If the active-policy failed to handle request, the request will
>      be delivered to default-policy.
> 
>      If no active-policy, request will always be handled by default-policy.
> 
>      I think it's similar but a little different with your design(Please
>      correct me if I was wrong), the "secondary policy" in your design
>      is somehow like default-policy here, I'm wondering why we want to
>      specify secondary-policy for each policy, instead of just let all
>      polices share a default policy.
> 
>    . user can activate/deactivate poilicy at runtime
> 
>    . ptlrpc service should always poll over all polices to find pending
>      requests (even from inactive polices), so requests wouldn't be forgotten
>      forever when user deactivate policy at runtime.
> 
>  - NRS object
>    target object, i.e: it represents a client (or export) for
>    client-round-robin, or it represents an OST object for object-round-robin
> 
>  - NRS target
>    NRS-target is private data of NRS-policy, A NRS-target can contains
>    many NRS-objects, just like storage-target to storage-objects.
> 
>  - NRS request
>    NRS-request is a stub embedded in ptlrpc_request, each NRS-object can
>    have 1-N pending NRS-requests.
> 
>  Logic specifications
> 
>  - each service has two NRS-policy-heads, one for regular requests,
>    another for HP (high priority) requests
> 
>  - user can register/unregister a NRS-policy for a service, either for
>    for regular NRS-policy-heads, or for HP NRS-policy-heads
> 
>  - Two polices so far:
> 
>    . FIFO list, which is default
> 
>    . client-round-robin based on binheap
>      it's actually round-robin over exports for now, user can
>      activate/deactivate it by lprocfs.
>      We can change it to round-robin over client NIDs in the future,
>      or just add a new policy.
> 
>  - ptlrpc service threads call active/default NRS-policy to sort incoming
>    requests policy::nrs_ops::op_req_add()
> 
>    . requests can ben sorted by round & sequence number recorded on
>      NRS-target and NRS-object, buffer offset from request can also be
>      counted in as sorting key for using it as disk elevator in the future
> 
>  - ptlrpc service threads will poll request (round-robin) from all
>    NRS-polices on NRS-policy-head by calling policy::nrs_ops::op_req_first(),
>    which returns the request with the highest priority in the binheap or
>    just the first request if it's FIFO mode, the request can be removed from
>    NRS-target by calling policy::nrs_ops::op_req_del().
> 
>  - object-round-robin (not in the prototype)
> 
>    I agree cfs_hash can be used to find out object, also, I noticed the
>    patch on BZ 13634 is using list + rbtree to implement object-round-robin
>    and I'm not very clear about your sorting solution but I think binheap
>    could be an option. By using binheap,two data structures (list + rbtree,
>    or list+list) can be replaced by one (binheap), and all sorting operations
>    are invisible to user (user just needs to provide compare callback)
> 
>    The major difference between client-round-robin and object-round-robin is:
> 
>    . NRS-object of client-round-robin is a client, round-number on NRS-object
>      is unique for each request.
> 
>    . NRS-object of object-round-robin is an OST object, round-number on
>      NRS-object doesn't have to be unique, which means multiple NRS-requests
>      for one NRS-object can share the same round-number, and these requests
>      are sorted by buffer offset in binheap.
>      As you said, we can "consume" the round-number by counting grouped
>      RPCs or data size.
> 
> Anyway, these are just my preliminary ideas, any comment and suggestions
> would be great.
> 
> Some information about binheap:
> 
>  There are some changes for the binheap posted by Eric:
> 
>  - In the original version, user just needs address of element while
>    inserting it, users have no idea about where the element is and
>    can't remove element unless it's root of binheap.
>    In current version, user needs to provide a pointer of
>    cfs_binheap_node_t, which should be embedded in element structure.
> 
>    example:
>        struct foo_type {
>            cfs_binheap_node_t  node;
>        } foo;
>        cfs_binheap_insert(h, &foo.node);
> 
>    with this change, user can remove element at any position
> 
>    example:
>        cfs_binheap_remove(h, &foo.node);
> 
>  - there are two options if user wants to have atomically insert:
> 
>    . preallocate memory for binheap if caller can estimate heap size,
>      cfs_binheap_create(..., count);
> 
>    . use flag CBH_FLAG_ATOMIC_GROW
>      cfs_binheap_create(..., CBH_FLAG_ATOMIC_GROW, count);
> 
>  Here is the list of all APIs
> 
>    cfs_binheap_t *cfs_binheap_create(cfs_binheap_ops_t *ops,
>                                      unsigned int flags, unsigned count);
> 
>    void cfs_binheap_destroy(cfs_binheap_t *h);
> 
>    cfs_binheap_node_t *cfs_binheap_find(cfs_binheap_t *h, unsigned int idx);
> 
>    int cfs_binheap_insert(cfs_binheap_t *h, cfs_binheap_node_t *e);
> 
>    void cfs_binheap_remove(cfs_binheap_t *h, cfs_binheap_node_t *e);
> 
>  And some inline wrappers:
> 
>    int cfs_binheap_size(cfs_binheap_t *h)
> 
>    int cfs_binheap_is_empty(cfs_binheap_t *h)
> 
>    cfs_binheap_node_t *cfs_binheap_root(cfs_binheap_t *h)
> 
>    cfs_binheap_node_t *cfs_binheap_remove_root(cfs_binheap_t *h)
> 
> Anyway, hope these discussion can help us to understand the whole thing better
> so we can get agreement about how to move on this project.
> 
> Thanks
> Liang
> 
> 
> 
> On Jul 7, 2011, at 10:34 PM, Nikitas Angelinas wrote:
> 
>> Hi Liang,
>> 
>> 
>> Thank you for sharing these great ideas; I think the task lends itself
>> well to adding different schemes that performance can benefit from. To
>> answer an earlier question, we unfortunately don't have any numbers or
>> have performed any tests related to the NRS task. We'll obviously
>> publish any such data as soon as we get our first policy developed, and
>> under test.
>> 
>> Both Nathan and I think you raise a very good point by highlighting the
>> need for a scalable data structure that can sort elements in libcfs, as
>> different policies could probably make use of such a facility, and may
>> actually require it if they need to address scalability-related issues
>> (there's an older, related topic
>> http://lists.lustre.org/pipermail/lustre-devel/2008-January/002230.html
>> which I'm sure you're already aware of).
>> 
>> I think there are some holes in my understanding of the example you gave
>> on using the binary heap in conjunction with GRN/CRN/RRN to implement a
>> CBRR policy. Is the GRN incremented with every incoming request? And how
>> can two requests end up with the same RRN? I'm sure the logic makes
>> sense, this is probably me just being daft :-).
>> 
>> Can I ask if there is a binary heap implementation living in a branch
>> somewhere, or you plan on landing one on master at some point? There is
>> some code attached on the thread I have pasted above, but I have not had
>> a look through it; going through the thread posts, it seems to be in
>> working and well-performing state.
>> 
>> For the first policy we aim to develop ("obj_extents" in the HLD)
>> although OBRR-like, we are not looking at using any data structures that
>> are out of the norm, at present. The idea is that we 
>> pick up requests from the service in-queue and add requests in
>> number-limited (or perhaps size-limited) per-object groupings, sorted by
>> offset, which are either populated in-place in the normal service
>> request queue, or use the normal service request queue as an
>> intermediate queue (just to avoid much processing in what is now the
>> pre-processing stage for RPCs), before they are added to the sorted
>> queue, from where they are eventually dispatched. We are looking at
>> using a libcfs hash for resolving incoming requests to the appropriate
>> object grouping, much like the OBRR implementation in the prototype NRS
>> patch does; I think this method will naturally avoid any request
>> starvation issues, but I am not sure it will perform as well as an OBRR
>> implementation using a heap. Hope the description above makes some
>> sense; if you see any problems with it, then please do let us know.
>> 
>> The NRS architectural specification at
>> http://wiki.lustre.org/index.php/Architecture_-_Network_Request_Scheduler has references to additional aspects to the task. Are you looking at providing some form of POP capability, or reproducing offset stream ordering, at present? These both sound like features that perhaps the framework itself could benefit from, at least in part irrespective of policy, I think. We seem to have at least one use case where we could do with clients passing additional information with each RPC, in QoS, so it seems like resource control, and catering for offset stream consistency may add additional ones.
>> 
>> 
>> Regards,
>> Nikitas
>> 
>> 
>> 
>> 
>> 
>> 
>> On Tue, 2011-07-05 at 17:20 +0800, Liang Zhen wrote: 
>>> Hi Nathan,
>>> 
>>> We also have some ideas about infrastructure of NRS and would like to share
>>> them at here for discussion:
>>> 
>>> - a common library to support inserting/removing prioritized requests, which 
>>> should be scalable even for millions of requests
>>> 
>>> - each policy only needs to provide:
>>> . private data ("heap", more details below)
>>> . a sorting callback to prioritize requests
>>> 
>>> By this way, most common code can be put into libcfs and ptlrpc modules,
>>> instead of having a whole bunch of policy functions to sort requests in
>>> each policy (like the patch on BZ 13634).
>>> 
>>> Here is the concept of "heap" mentioned above:
>>> 
>>> (it's quoted from the following link)
>>> A heap is a specialized tree-based data structure that satisfies the heap
>>> property: if B is a child node of A, then key(A) ? key(B). This implies that an
>>> element with the greatest key is always in the root node, and so such a heap is
>>> sometimes called a max-heap. Alternatively, if the comparison is reversed, the
>>> smallest element is always in the root node, which results in a min-heap.
>>> 
>>> Please see more detail at:
>>> http://en.wikipedia.org/wiki/Heap_%28data_structure%29
>>> 
>>> Heap can give (log N) for both inserting element and removing element with
>>> greatest/lowest key, so it's very scalable, here are some sample heap APIs
>>> from a simple prototype:
>>> 
>>>   /* create a heap, @compare is callback for sorting elements */
>>>   cfs_binheap_t *cfs_binheap_create(cfs_binheap_cmp_t compare,
>>>                                     unsigned int flags);
>>> 
>>>   /* destroy a heap */
>>>   void cfs_binheap_destroy(cfs_binheap_t *h);
>>> 
>>>   /* insert @element into heap */
>>>   int cfs_binheap_insert(cfs_binheap_t *h, void *elelment);
>>> 
>>>   /* pop root for the @heap, which has greatest/lowest key in @heap */
>>>   void *cfs_binheap_pop_root(cfs_binheap_t *heap);
>>> 
>>> and an example of using "heap" to implement Client-Based Round Robin:
>>> 
>>> - allocating a "heap" for the service which needs CBRR
>>> 
>>> - the service also have a "global round-number" which is always incremental
>>>   . GRN: Global Round Number
>>>   . CRN: Client Round Number
>>>   . RRN: Request Round Number
>>> 
>>> Process of inserting a request
>>> - when there is new request:
>>>   . if the incoming request is the first request for a client, assign
>>>     the GRN to both the RRN of the request and CNR of the client
>>> 
>>>   . if the incoming request isn't the first request for a client,
>>>     increase the CNR on the client then assign it to RRN of the request.
>>> 
>>> - insert the request into the heap, the heap can sort requests based
>>>   on callback like this:
>>>   . primary key is RRN of request
>>> 
>>>   . secondary key is client ID (i.e: nid of client), secondary keys are
>>>     compared only if primary keys are equal
>>> 
>>> Process of dequeue a request:
>>> 
>>> - pop the root element from the heap, which should always has the lowest RRN
>>> 
>>> - if the RRN of the request is larger than GRN of the service,
>>>   which means the service has already handled all requests with <= GRN and
>>>   should set the GRN of service to the RRN of request
>>> 
>>> Again, this just an example to demonstrate how to use "heap" to implement CBRR
>>> and show some preliminary ideas, it could be helpful to raise some discussion
>>> at here and to see whether it's possible to improve and apply this to NRS and
>>> make it to be a common library for future implementation of OBRR or any
>>> policy needs to prioritize requests, or for QoS.
>>> 
>>> Thanks
>>> Liang
>>> 
>>> On Jul 2, 2011, at 11:39 PM, Nathan Rutman wrote:
>>> 
>>>> I think there is a whole slew of interesting possibilities to try out once an infrastructure for implementing different policies is in place. We're trying to get that infrastructure established first; we will be able to switch between policies dynamically to see their effects and optimize performance. People will be able to easily add new policies to test. 
>>>> You raise a good point about the SMP scaling patches; we will have to take a close look to make sure we don't undo any of the work you've done there. 
>>>> 
>>>> On Jul 2, 2011, at 3:49 AM, "Liang Zhen" <liang@whamcloud.com> wrote:
>>>> 
>>>>> Hi Nikitas,
>>>>> 
>>>>> It's a very interesting document, thanks for sharing these great ideas.
>>>>> May I ask whether there are any tests/numbers based on OBRR description
>>>>> in HLD? We always want to see numbers from these algorithms, unfortunately
>>>>> there is no reliable testing result from the patch on BZ 13634.
>>>>> 
>>>>> We are actually considering about NRS as well, although we don't have a
>>>>> formal design document like this HLD, but we'd like to share a few
>>>>> preliminary ideas for discussion:
>>>>> 
>>>>> - Target Based Round Robin (TBRR) probably is something worth to have
>>>>> 
>>>>> Briefly, it's just load balancing over OSTs to improve overall server
>>>>> performance.
>>>>> 
>>>>> - Fairness for clients and resource control for jobs
>>>>> 
>>>>> I think they are similar to CBRR and UBRR described in your document
>>>>> though I didn't see too much detail about them in the HLD.
>>>>> Personally, I think they are important and we probably will do some tests
>>>>> for CBRR survey very soon.
>>>>> 
>>>>> . Client-Based Round Robin (CBRR) can guarantee the server responses
>>>>> to all clients fairly, and get whole-cluster load balancing, improve
>>>>> concurrency of clients and jobs, and get better overall performance.
>>>>> 
>>>>> . resource control for jobs, some users complained that a busy job will
>>>>> hog all resources on servers, and make the cluster not usable for other
>>>>> control command or sysadmin. So it might be helpful to support job
>>>>> resource control inside NRS.
>>>>> 
>>>>> - Layering NRS polices
>>>>> 
>>>>> Of course, OBRR is very important policy for NRS, but it might be
>>>>> helpful to have multiple polices working at the same time, i.e:
>>>>> 
>>>>> . bind OSTs on CPU partitions on NUMA system(please see more detail at
>>>>> http://jira.whamcloud.com/browse/LU-56)
>>>>> 
>>>>> . Service threads on each CPU partition can do TBRR for bound OSTs. If
>>>>> there is no CPU partition (like current Lustre) or OSTs are not bound
>>>>> on CPU partitions, service threads just do round robin over all OSTs.
>>>>> 
>>>>> . OBRR inside each OST
>>>>> 
>>>>> . of course, these layers should be tunable.
>>>>> 
>>>>> - Overhead of layerd polices
>>>>> . there definitely will be some overhead for inserting/removing
>>>>> request from these queues (or whatever), so we want some very scalable
>>>>> algorithms to implement these polices.
>>>>> 
>>>>> Again, these are just some preliminary ideas, so we would appreciate any
>>>>> comment and suggestion.
>>>>> 
>>>>> Thanks
>>>>> Liang
>>>>> 
>>>>> 
>>>>> On Jun 30, 2011, at 11:49 PM, Nikitas Angelinas wrote:
>>>>> 
>>>>>> Hi,
>>>>>> 
>>>>>> There is a slightly more up-to-date version of the HLD, which I am
>>>>>> attaching.
>>>>>> 
>>>>>> 
>>>>>> Thanks,
>>>>>> Nikitas
>>>>>> 
>>>>>> On Wed, 2011-06-29 at 12:55 -0700, Nathan Rutman wrote:
>>>>>>> Sharing with the community.  All comments welcome.
>>>>>>> This HLD (high-level design) for a Network Request Scheduler is more
>>>>>>> about infrastructure than algorithm.
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> We're actually in the DLD (detailed-level design) stage at the moment
>>>>>>> (sorry it didn't occur to me to 
>>>>>>> post this earlier).  I'll post the DLD after some minor revision.
>>>>>>> _______________________________________________
>>>>>>> Lustre-devel mailing list
>>>>>>> Lustre-devel at lists.lustre.org
>>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>> 
>>>>>> 
>>>>>> ______________________________________________________________________
>>>>>> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
>>>>>> 
>>>>>> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
>>>>>> 
>>>>>> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>>>>>> 
>>>>>> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
>>>>>> ______________________________________________________________________
>>>>>> 
>>>>>> 
>>>>>> <HLD_of_Lustre_NRS.pdf>_______________________________________________
>>>>>> Lustre-devel mailing list
>>>>>> Lustre-devel at lists.lustre.org
>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>> 
>>>>> _______________________________________________
>>>>> Lustre-devel mailing list
>>>>> Lustre-devel at lists.lustre.org
>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>> ______________________________________________________________________
>>>> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
>>>> 
>>>> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
>>>> 
>>>> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>>>> 
>>>> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
>>>> ______________________________________________________________________
>>>> 
>>>> 
>>> 
>> 
>> 
>> ______________________________________________________________________
>> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
>> 
>> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
>> 
>> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>> 
>> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
>> ______________________________________________________________________
>> 
>> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
