From: Liang Zhen <liang@whamcloud.com>
Date: Tue, 5 Jul 2011 17:20:12 +0800
Subject: [Lustre-devel] NRS HLD
In-Reply-To: <8C4CE53E-8A87-43FE-B27F-F44B5E3D7550@us.xyratex.com>
References: <24C12A32-1D42-4327-8F8F-B9D30471B8C8@gmail.com>
	<1309448989.27038.5.camel@localhost.localdomain>
	<88C87A8C-8DB5-4602-863B-9B77FF93C0D1@whamcloud.com>
	<8C4CE53E-8A87-43FE-B27F-F44B5E3D7550@us.xyratex.com>
Message-ID: <61BD608D-C941-4741-8200-79752803AF5D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nathan,

We also have some ideas about infrastructure of NRS and would like to share
them at here for discussion:

- a common library to support inserting/removing prioritized requests, which 
  should be scalable even for millions of requests

- each policy only needs to provide:
  . private data ("heap", more details below)
  . a sorting callback to prioritize requests

By this way, most common code can be put into libcfs and ptlrpc modules,
instead of having a whole bunch of policy functions to sort requests in
each policy (like the patch on BZ 13634).

Here is the concept of "heap" mentioned above:

(it's quoted from the following link)
A heap is a specialized tree-based data structure that satisfies the heap
property: if B is a child node of A, then key(A) ? key(B). This implies that an
element with the greatest key is always in the root node, and so such a heap is
sometimes called a max-heap. Alternatively, if the comparison is reversed, the
smallest element is always in the root node, which results in a min-heap.

Please see more detail at:
http://en.wikipedia.org/wiki/Heap_%28data_structure%29

Heap can give (log N) for both inserting element and removing element with
greatest/lowest key, so it's very scalable, here are some sample heap APIs
from a simple prototype:

    /* create a heap, @compare is callback for sorting elements */
    cfs_binheap_t *cfs_binheap_create(cfs_binheap_cmp_t compare,
                                      unsigned int flags);

    /* destroy a heap */
    void cfs_binheap_destroy(cfs_binheap_t *h);

    /* insert @element into heap */
    int cfs_binheap_insert(cfs_binheap_t *h, void *elelment);

    /* pop root for the @heap, which has greatest/lowest key in @heap */
    void *cfs_binheap_pop_root(cfs_binheap_t *heap);

and an example of using "heap" to implement Client-Based Round Robin:

  - allocating a "heap" for the service which needs CBRR

  - the service also have a "global round-number" which is always incremental
    . GRN: Global Round Number
    . CRN: Client Round Number
    . RRN: Request Round Number

  Process of inserting a request
  - when there is new request:
    . if the incoming request is the first request for a client, assign
      the GRN to both the RRN of the request and CNR of the client

    . if the incoming request isn't the first request for a client,
      increase the CNR on the client then assign it to RRN of the request.

  - insert the request into the heap, the heap can sort requests based
    on callback like this:
    . primary key is RRN of request

    . secondary key is client ID (i.e: nid of client), secondary keys are
      compared only if primary keys are equal

  Process of dequeue a request:

  - pop the root element from the heap, which should always has the lowest RRN

  - if the RRN of the request is larger than GRN of the service,
    which means the service has already handled all requests with <= GRN and
    should set the GRN of service to the RRN of request

Again, this just an example to demonstrate how to use "heap" to implement CBRR
and show some preliminary ideas, it could be helpful to raise some discussion
at here and to see whether it's possible to improve and apply this to NRS and
make it to be a common library for future implementation of OBRR or any
policy needs to prioritize requests, or for QoS.

Thanks
Liang

On Jul 2, 2011,@11:39 PM, Nathan Rutman wrote:

> I think there is a whole slew of interesting possibilities to try out once an infrastructure for implementing different policies is in place. We're trying to get that infrastructure established first; we will be able to switch between policies dynamically to see their effects and optimize performance. People will be able to easily add new policies to test. 
> You raise a good point about the SMP scaling patches; we will have to take a close look to make sure we don't undo any of the work you've done there. 
> 
> On Jul 2, 2011, at 3:49 AM, "Liang Zhen" <liang@whamcloud.com> wrote:
> 
>> Hi Nikitas,
>> 
>> It's a very interesting document, thanks for sharing these great ideas.
>> May I ask whether there are any tests/numbers based on OBRR description
>> in HLD? We always want to see numbers from these algorithms, unfortunately
>> there is no reliable testing result from the patch on BZ 13634.
>> 
>> We are actually considering about NRS as well, although we don't have a
>> formal design document like this HLD, but we'd like to share a few
>> preliminary ideas for discussion:
>> 
>> - Target Based Round Robin (TBRR) probably is something worth to have
>> 
>> Briefly, it's just load balancing over OSTs to improve overall server
>> performance.
>> 
>> - Fairness for clients and resource control for jobs
>> 
>> I think they are similar to CBRR and UBRR described in your document
>> though I didn't see too much detail about them in the HLD.
>> Personally, I think they are important and we probably will do some tests
>> for CBRR survey very soon.
>> 
>> . Client-Based Round Robin (CBRR) can guarantee the server responses
>>   to all clients fairly, and get whole-cluster load balancing, improve
>>   concurrency of clients and jobs, and get better overall performance.
>> 
>> . resource control for jobs, some users complained that a busy job will
>>   hog all resources on servers, and make the cluster not usable for other
>>   control command or sysadmin. So it might be helpful to support job
>>   resource control inside NRS.
>> 
>> - Layering NRS polices
>> 
>> Of course, OBRR is very important policy for NRS, but it might be
>> helpful to have multiple polices working at the same time, i.e:
>> 
>> . bind OSTs on CPU partitions on NUMA system(please see more detail at
>>   http://jira.whamcloud.com/browse/LU-56)
>> 
>> . Service threads on each CPU partition can do TBRR for bound OSTs. If
>>   there is no CPU partition (like current Lustre) or OSTs are not bound
>>   on CPU partitions, service threads just do round robin over all OSTs.
>> 
>> . OBRR inside each OST
>> 
>> . of course, these layers should be tunable.
>> 
>> - Overhead of layerd polices
>> . there definitely will be some overhead for inserting/removing
>>   request from these queues (or whatever), so we want some very scalable
>>   algorithms to implement these polices.
>> 
>> Again, these are just some preliminary ideas, so we would appreciate any
>> comment and suggestion.
>> 
>> Thanks
>> Liang
>> 
>> 
>> On Jun 30, 2011, at 11:49 PM, Nikitas Angelinas wrote:
>> 
>>> Hi,
>>> 
>>> There is a slightly more up-to-date version of the HLD, which I am
>>> attaching.
>>> 
>>> 
>>> Thanks,
>>> Nikitas
>>> 
>>> On Wed, 2011-06-29 at 12:55 -0700, Nathan Rutman wrote:
>>>> Sharing with the community.  All comments welcome.
>>>> This HLD (high-level design) for a Network Request Scheduler is more
>>>> about infrastructure than algorithm.
>>>> 
>>>> 
>>>> 
>>>> 
>>>> We're actually in the DLD (detailed-level design) stage at the moment
>>>> (sorry it didn't occur to me to 
>>>> post this earlier).  I'll post the DLD after some minor revision.
>>>> _______________________________________________
>>>> Lustre-devel mailing list
>>>> Lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>> 
>>> 
>>> ______________________________________________________________________
>>> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
>>> 
>>> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
>>> 
>>> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>>> 
>>> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
>>> ______________________________________________________________________
>>> 
>>> 
>>> <HLD_of_Lustre_NRS.pdf>_______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
> 
> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
> 
> Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
> 
> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
> 
> 
