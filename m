From: Eric Barton <eeb@sun.com>
Date: Tue, 05 May 2009 12:48:32 +0100
Subject: [Lustre-devel] AT and ptlrpc SMP stuff
In-Reply-To: <49FEE495.6040001@sun.com>
References: <49F88EB6.4070306@sun.com> <49F90286.6090108@sun.com>
	<49FA37FE.5010708@sun.com> <061001c9cc56$985b64f0$c9122ed0$@com>
	<49FEE495.6040001@sun.com>
Message-ID: <015401c9cd77$6aaf5e90$400e1bb0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cc-ing Lustre-devel - this is of general interest.

> -----Original Message-----
> From: Zhen.Liang at Sun.COM [mailto:Zhen.Liang at Sun.COM]
> Sent: 04 May 2009 1:50 PM
> To: Eric Barton; Nathan.Rutman at Sun.COM
> Cc: 'Robert Read'
> Subject: Re: AT and ptlrpc SMP stuff
> 
> Nathan, Eric
> 
> I actually had a discussion with Eric last week, seems there could be
> some problems:
> 1. Stealing buffer or CPU load balance
>     a) Stealing buffer
>         New LNet always try to get buffer from current CPU to match
> request, but if all bufferes on current CPU are exhausted, then it will
> steal buffer from other CPUs, and it will wakeup service threads on
> other CPU to handle the request as well. So it's possible that RPCs from
> the same client are handled by different CPUs on the server.
>     b) CPU load balance
>         RPCs can be dispatched to other CPUs by current CPU, I don't
> know whether it's necessary to have this(we may benefit very few or
> nothing from bouncing RPCs between CPUs), if we have CPU load balance,
> then requests can be handled by any CPU.
> 
> 2. Client connected to a lot of routers
>     If client connected to more than one routers, then requests can be
> forwared by any one of these routers. On the server side, requests from
> different routers are very likely to be received by different LND
> threads, and wake up different ptlrpc service threads on different CPUs,
> so there is no bonding of CPU for clients in this case.
> 
> 3. The last one is more about LNet:
> Eric, we actually talked about this a bit in East Palo Alto. Based on
> current design, if there is only one router, then all requests will be
> received by the same LND thread and delivered to ptlrpc service threads
> on one CPU, so we will only use one or two CPUs on server, even worse on
> the router, all messages are serialized on the peer structure of server,
> we still have very high contention.

[For people reading on lustre-devel, this refers to the improved SMP
 scaling work Liang is doing]

The problem for a server "hiding" behind a single router centers on the
handling of traffic on the link between them - as you mention in another
mail, that's not a problem for the upper layers in the stack since they
can distribute the work over CPUs by hashing on the end-to-end peer NID.
But I agree that at the lower levels, we need multiple connections each
with separate CPU affinity to avoid contention and assure SMP scaling.

> The only way I can find to resolve this problem is creating multiple
> LNet networks between router and server, so both router and server can
> have multiple peers & connections for remote side. Actually, I think
> it's fair for router/server to take more credits, buffers, CPUs on
> server/router then other clients. We have two options to get this:
>    a)  static config by user, then we don't need change anything, but it
> will increase complexity of network configuration, and some users may
> feel confused.
>    b) LNet can create sub-networks for network of  router&server (we can
> make it tunable), requests will be balanced to different sub-networks.
> We can make it almost transparent to user, it seems dorable to me but I
> haven't estimated how much efforts we need.

The more transparent, the better.  If _all_ configuration could be avoided,
then so much the better.  Multiple connections to the same immediate
physical peer at the LND level allow maximum SMP concurrency, but this is
best detected/managed in the generic LNET code.  This seems to beg for
adding explicit connection handling to the LND API and (as we've know since
forever) would remove a lot of duplication between LNDs.

However I think all we do right now is size the work and leave it pending.
We _can_ achieve the same effect with explicit configuration and the most
important use case right now is the MDS, which should be amply provisioned
with routers where it matters.

    Cheers,
              Eric

> 
> Any suggestion?
> 
> Thanks
> Liang
> 
> 
> Eric Barton :
> > Nathan,
> >
> > Please talk me through these issues.
> >
> >
> >     Cheers,
> >               Eric
> >
> >
> >> -----Original Message-----
> >> From: Nathan.Rutman at Sun.COM [mailto:Nathan.Rutman at Sun.COM]
> >> Sent: 01 May 2009 12:45 AM
> >> To: Liang Zhen
> >> Cc: Eric Barton; Robert Read
> >> Subject: Re: AT and ptlrpc SMP stuff
> >>
> >> Liang Zhen wrote:
> >>
> >>> Nathan,
> >>>
> >>> Yes, I don't know whether eeb has sent you the patch or not, so I put
> >>> it in attachment.
> >>>
> >>> Basically, I move some members from ptlrpc_service to per-cpu data,
> >>> and make service threads  be cpu affinity by default, in order to get
> >>> rid of any possible global lock contention on RPC handling path, i.e
> >>> ptlrpc_service::srv_lock. As you know, ptlrpc_service::srv_at_estimate
> >>> is global for each service, so I'm thinking to move it to per-cpu data
> >>> for two reasons:
> >>> 1) at_add(...) needs spinlock, if we keep it on ptlrpc_service, then
> >>> it's a kind of global spin on hot path, now we are sure that any spin
> >>> on hot path will be amplified a lot on fat cores machine like 16 or 32.
> >>> 2. Requests from same client tend to be handled by same thread & CPU
> >>> on server, so I think it's reasonable to have per-CPU AT estimate etc...
> >>> I really know few about this because I just looked into it for few
> >>> days, expecting for your advisement for AT or anything about the patch
> >>> (it's still a rough prototype)
> >>>
> >> I think there is no problem moving the at_estimate and at_lock to
> >> per-cpu struct.  The server estimates might end up varying by cpu, but
> >> since they are collected together by the clients from the RPC reply, the
> >> clients will still continue to track the maximum estimate correctly.
> >> They might see a little more "jitter" in the service estimate time, but
> >> since they use a moving-maximum window (600sec by default), this jitter
> >> will all get smoothed out.
> >>
> >> You will have to change ptlrpc_lprocfs_rd_timeouts to collect the
> >> server-side service estimate from the per-cpu estimates, but I don't
> >> think there's any need even here to do locking across the service
> >> threads - just "max" each of the data points across the per-cpu values.
> >> Hmm, actually a little trickiness comes in because we print the estimate
> >> history (4 data points), but with per-cpu measurements the start time
> >> (at_binstart) of the history values may vary.  IOW, the history is the
> >> maximum estimate within a series of time slices (150s default), but
> >> those slices may not line up between cpus.  So taking the max is not
> >> truly the right thing to do, although it might not be worth much effort
> >> to do any better.
> >>
> >>                  LCONSOLE_WARN("%s: This server is not able to keep up
> >> with "
> >> -                              "request traffic (cpu-bound).\n",
> >> svc->srv_name);
> >> +                              "request traffic (cpu-bound).\n",
> >> +                              scd->scd_service->srv_name);
> >> You could make this more fun:
> >> (cpu bound on cpu #%d).\n", ...scd->scd_cpu_id
> >>
> >
> >
> >
> >
