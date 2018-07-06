From: Patrick Farrell <paf@cray.com>
Date: Fri, 6 Jul 2018 00:40:29 +0000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <alpine.LFD.2.21.1807060052470.12665@casper.infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-8-git-send-email-jsimmons@infradead.org>
 <877emnaed8.fsf@notabene.neil.brown.name>
 <A764DED1-A9A8-4FA5-A0F1-922C3E2D822A@cray.com>
 <87lgb16j8q.fsf@notabene.neil.brown.name>
 <DM3PR1101MB1213FD1001256E565FF011FFCB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <8736x77lrk.fsf@notabene.neil.brown.name>
 <9DE389AB-C7E1-4336-B7E8-604581EFD53E@cray.com>
 <CAAqp6i0uwmpdFYUJ7mCBz+MH+gVBa6S=P2t5Yn7wcFOtrTD-Fg@mail.gmail.com>
 <AT5PR8401MB0900C67FADDF0EF7ED1CDBC4854E0@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>
 <87va9vziay.fsf@notabene.neil.brown.name>
 <AT5PR8401MB0900A5406BF0CB8C87B80EEC85410@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>,
 <alpine.LFD.2.21.1807060052470.12665@casper.infradead.org>
Message-ID: <DM3PR1101MB1213C2A5A1CBC6631CB3FFCDCB470@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


A tiny bit more about noise for Neil, since it?s a bit subtle and I had never heard of it before working in HPC.  Sorry if this is old news.

Noise here means differences in execution time. A typical HPC Job consists of thousands of processes running across a large system.  The basic model is they all run a compute step, then they all communicate part of their results (generally to some neighboring subset of processes, not all-to-all).  The results which are communicated are then used as part of the input to the next compute step.  As you can see, effectively, everyone must finish each step before anyone can continue (or at least, continue very far).

So if everyone finishes every step in the same amount of time, great.  But if there?s jitter in the completion time for a step for a particular process - as can be introduced by a scheduler with ideas that don?t quite line up with your job priorities - it delays the completion of the step overall.  This is compounded at each step of the job and so can be quite serious.  (Job steps can be quite short - double digit microseconds is not unusual - so relatively small jitter can really add up.)

So HPC users are really fussy about affinity and placement control.  Which isn?t to say Lustre gets it all right, but it?s why we care so much.
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of James Simmons <jsimmons@infradead.org>
Sent: Thursday, July 5, 2018 7:20:37 PM
To: Weber, Olaf (HPC Data Management & Storage)
Cc: Lustre Development List
Subject: Re: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA support


> NeilBrown [mailto:neilb at suse.com] wrote:
>
> To help contextualize things: the Lustre code can be decomposed into three parts:
>
> 1) The filesystem proper: Lustre.
> 2) The communication protocol it uses: LNet.
> 3) Supporting code used by Lustre and LNet: CFS.
>
> Part of the supporting code is the CPT mechanism, which provides a way to
> partition the CPUs of a system. These partitions are used to distribute queues,
> locks, and threads across the system. It was originally introduced years ago, as
> far as I can tell mainly to deal with certain hot locks: these were converted into
> read/write locks with one spinlock per CPT.
>
> As a general rule, CPT boundaries should respect node and socket boundaries,
> but at the higher end, where CPUs have 20+ cores, it may make sense to split
> a CPUs cores across several CPTs.
>
> > Thanks everyone for your patience in explaining things to me.
> > I'm beginning to understand what to look for and where to find it.
> >
> > So the answers to Greg's questions:
> >
> >   Where are you reading the host memory NUMA information from?
> >
> >   And why would a filesystem care about this type of thing?  Are you
> >   going to now mirror what the scheduler does with regards to NUMA
> >   topology issues?  How are you going to handle things when the topology
> >   changes?  What systems did you test this on?  What performance
> >   improvements were seen?  What downsides are there with all of this?
> >
> >
> > Are:
>
> >   - NUMA info comes from ACPI or device-tree just like for every one
> >       else.  Lustre just uses node_distance().
>
> Correct, the standard kernel interfaces for this information are used to
> obtain it, so ultimately Lustre/LNet uses the same source of truth as
> everyone else.
>
> >   - The filesystem cares about this because...  It has service
> >     thread that does part of the work of some filesystem operations
> >     (handling replies for example) and these are best handled "near"
> >     the CPU the initiated the request.  Lustre partitions
> >     all CPUs into "partitions" (cpt) each with a few cores.
> >     If the request thread and the reply thread are on different
> >     CPUs but in the same partition, then we get best throughput
> >     (is that close?)
>
> At the filesystem level, it does indeed seem to help to have the service
> threads that do work for requests run on a different core that is close to
> the core that originated the request. So preferably on the same CPU, and
> on certain multi-core CPUs there are also distance effects between cores.
> That too is one of the things the CPT mechanism handles.

Their is another very important aspect to why Lustre has a CPU partition
layer. At least at the place I work at. While the Linux kernel manages all
the NUMA nodes and CPU cores Lustre adds the ability for us to specify a
subset of everything on the system. The reason is to limit the impact of
noise on the compute nodes. Noise has a heavy impact on large scale HP
work loads that can run days or even weeks at a time. Lets take an
example system:

               |-------------|      |-------------|
   |-------|   | NUMA  0     |     | NUMA  1      |   |-------|
   | eth0  | - |             | --- |              | - | eth1  |
   |_______|   | CPU0  CPU1  |     | CPU2  CPU3  |   |_______|
               |_____________|      |_____________|

In such a system it is possible with the right job schedular to start a
large parallel application on NUMA 0/ (CPU0 and CPU1). Normally such
large parallel applications will communicate between nodes using MPI,
such as openmpi, which can be configured to use eth0 only. Using the
CPT layer in lustre we can isolate lustre to NUMA 1 and use only eth1.
This greatly reducess the noise impact on the application running.

BTW this is one of the reasons ko2iblnd for lustre doesn't use the
generic RDMA api. The core IB layer doesn't support such isolation.
At least to my knowledge.

> >   - Not really mirroring the scheduler, maybe mirroring parts of the
> >     network layer(?)
>
> The LNet code, which is derived from Portals 3.x, is mostly an easier-to-use
> abstraction of RDMA interfaces provided by Infiniband and other similar
> hardware. It can also use TCP/IP, but that's not the primary use case.
>
> As a communication layer that builds on top of RDMA-capable hardware,
> LNet cares about such things as whether the CPU driving communication
> is close to the memory used, and also whether it is close to the interface
> used. Even in a 2-socket machine, there are measurable performance
> differences depending on whether the memory an interface connect
> to the same socket or to different sockets. On bigger hardware, like a
> 32-socket machine, the penalties are much more pronounced. At the
> time we found that the QPI links between sockets were a bottleneck
> and that performance cratered if they had to handle too much traffic.
>
> UPI, the successor to QPI is better -- has more bandwidth -- but with
> the CPUs having more and more cores I expect the scaling issues to
> remain similar.
>
> >   - We don't handle topology changes yet except in very minimal ways
> >     (cpts *can* become empty, and that can cause problems).
>
> Yes, this is a known deficiency.
>
> >   - This has been tested on .... great big things.
>
> The basic CPT mechanism predates my involvement with Lustre. I did
> work on making it more NUMA-aware. A 32-socket system was one of
> the primary test beds.
>
> >   - When multi-rails configurations are used (like ethernet-bonding,
> >     but for RDMA), we get ??? closer to theoretical bandwidth.
> >     Without these changes it scales poorly (??)
>
> The basic idea behind muti-rail configurations is that we use several
> Infiniband interfaces and LNet presents them as a single logical interface
> to Lustre. For each message, LNet picks the IB interface it should go across
> using several criteria, including NUMA distance of the interface and how
> busy it is.
>
> With these changes we could get pretty much linear scaling of LNet
> throughput by adding more interfaces.
>
> >   - The down-sides primarily are that we don't auto-configure
> >     perfectly.  This particularly affects hot-plug, but without
> >     hotplug the grouping of cpus and interfaces are focussed
> >     on .... avoiding worst case rather than achieving best case.
>
> Without hotplug the CPT grouping should be tuned to achieve a best
> case in a static configuration.
>
> Adding simple-minded hotplug tolerance (let's not call it support) would
> focus on avoiding truly pathological behaviour.
>
> > I've made up a lot of stuff there.  I'm happy not to pursue this further at the
> > moment, but if anyone would like to enhance my understanding by
> > correcting the worst errors in the above, I wouldn't object :-)
> >
> > Thanks,
> > NeilBrown
>
> PS: the NUMA effects I've mentioned above have been making the news
> lately under other names: they are part of the side channels used in various
> timing based attacks.
>
> Olaf
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180706/df9106cf/attachment-0001.html>
