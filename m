From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Wed, 06 May 2009 14:24:52 +0800
Subject: [Lustre-devel] AT and ptlrpc SMP stuff
In-Reply-To: <015401c9cd77$6aaf5e90$400e1bb0$@com>
References: <49F88EB6.4070306@sun.com> <49F90286.6090108@sun.com>
	<49FA37FE.5010708@sun.com> <061001c9cc56$985b64f0$c9122ed0$@com>
	<49FEE495.6040001@sun.com> <015401c9cd77$6aaf5e90$400e1bb0$@com>
Message-ID: <4A012D34.8030205@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric,

Eric Barton wrote:
>> The only way I can find to resolve this problem is creating multiple
>> LNet networks between router and server, so both router and server can
>> have multiple peers & connections for remote side. Actually, I think
>> it's fair for router/server to take more credits, buffers, CPUs on
>> server/router then other clients. We have two options to get this:
>>    a)  static config by user, then we don't need change anything, but it
>> will increase complexity of network configuration, and some users may
>> feel confused.
>>    b) LNet can create sub-networks for network of  router&server (we can
>> make it tunable), requests will be balanced to different sub-networks.
>> We can make it almost transparent to user, it seems dorable to me but I
>> haven't estimated how much efforts we need.
>>     
>
> The more transparent, the better.  If _all_ configuration could be avoided,
> then so much the better.  Multiple connections to the same immediate
> physical peer at the LND level allow maximum SMP concurrency, but this is
> best detected/managed in the generic LNET code.  This seems to beg for
> adding explicit connection handling to the LND API and (as we've know since
> forever) would remove a lot of duplication between LNDs.
>   

I think we have two options here:
1. As you said, multiple connections the same physical peer at LND 
level, it's the ideal way but will take more efforts.
2. I have feeling that this issue could somehow be covered by channel 
bonding, which should be able to support bonding several LNet networks 
to one. So we can aggregate throughput of connections on the same 
physical NI(on different CPUs) as well as different physical NIs. 
Negativity I can think of is that it will take more preallocated memory 
resource at LND level for each network(i.e: preallocated TXs etc)

Isaac, do you have any thought about this?

Thanks
Liang


> However I think all we do right now is size the work and leave it pending.
> We _can_ achieve the same effect with explicit configuration and the most
> important use case right now is the MDS, which should be amply provisioned
> with routers where it matters.
>
>     Cheers,
>               Eric
>
>   
>> Any suggestion?
>>
>> Thanks
>> Liang
>>
>>
>> Eric Barton :
>>     
>>> Nathan,
>>>
>>> Please talk me through these issues.
>>>
>>>
>>>     Cheers,
>>>               Eric
>>>
>>>
>>>       
>>>> -----Original Message-----
>>>> From: Nathan.Rutman at Sun.COM [mailto:Nathan.Rutman at Sun.COM]
>>>> Sent: 01 May 2009 12:45 AM
>>>> To: Liang Zhen
>>>> Cc: Eric Barton; Robert Read
>>>> Subject: Re: AT and ptlrpc SMP stuff
>>>>
>>>> Liang Zhen wrote:
>>>>
>>>>         
>>>>> Nathan,
>>>>>
>>>>> Yes, I don't know whether eeb has sent you the patch or not, so I put
>>>>> it in attachment.
>>>>>
>>>>> Basically, I move some members from ptlrpc_service to per-cpu data,
>>>>> and make service threads  be cpu affinity by default, in order to get
>>>>> rid of any possible global lock contention on RPC handling path, i.e
>>>>> ptlrpc_service::srv_lock. As you know, ptlrpc_service::srv_at_estimate
>>>>> is global for each service, so I'm thinking to move it to per-cpu data
>>>>> for two reasons:
>>>>> 1) at_add(...) needs spinlock, if we keep it on ptlrpc_service, then
>>>>> it's a kind of global spin on hot path, now we are sure that any spin
>>>>> on hot path will be amplified a lot on fat cores machine like 16 or 32.
>>>>> 2. Requests from same client tend to be handled by same thread & CPU
>>>>> on server, so I think it's reasonable to have per-CPU AT estimate etc...
>>>>> I really know few about this because I just looked into it for few
>>>>> days, expecting for your advisement for AT or anything about the patch
>>>>> (it's still a rough prototype)
>>>>>
>>>>>           
>>>> I think there is no problem moving the at_estimate and at_lock to
>>>> per-cpu struct.  The server estimates might end up varying by cpu, but
>>>> since they are collected together by the clients from the RPC reply, the
>>>> clients will still continue to track the maximum estimate correctly.
>>>> They might see a little more "jitter" in the service estimate time, but
>>>> since they use a moving-maximum window (600sec by default), this jitter
>>>> will all get smoothed out.
>>>>
>>>> You will have to change ptlrpc_lprocfs_rd_timeouts to collect the
>>>> server-side service estimate from the per-cpu estimates, but I don't
>>>> think there's any need even here to do locking across the service
>>>> threads - just "max" each of the data points across the per-cpu values.
>>>> Hmm, actually a little trickiness comes in because we print the estimate
>>>> history (4 data points), but with per-cpu measurements the start time
>>>> (at_binstart) of the history values may vary.  IOW, the history is the
>>>> maximum estimate within a series of time slices (150s default), but
>>>> those slices may not line up between cpus.  So taking the max is not
>>>> truly the right thing to do, although it might not be worth much effort
>>>> to do any better.
>>>>
>>>>                  LCONSOLE_WARN("%s: This server is not able to keep up
>>>> with "
>>>> -                              "request traffic (cpu-bound).\n",
>>>> svc->srv_name);
>>>> +                              "request traffic (cpu-bound).\n",
>>>> +                              scd->scd_service->srv_name);
>>>> You could make this more fun:
>>>> (cpu bound on cpu #%d).\n", ...scd->scd_cpu_id
>>>>
>>>>         
>>>
>>>
>>>       
>
>
>   
