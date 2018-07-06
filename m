From: Doug Oucharek <doucharek@cray.com>
Date: Fri, 6 Jul 2018 05:36:03 +0000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <87zhz5xdld.fsf@notabene.neil.brown.name>
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
 <AT5PR8401MB0900A5406BF0CB8C87B80EEC85410@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>
 <alpine.LFD.2.21.1807060052470.12665@casper.infradead.org>
 <87zhz5xdld.fsf@notabene.neil.brown.name>
Message-ID: <02B7B718-E496-46CF-B55D-86EAB98381B6@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When the CPT code was added to LNet back in 2012, it was to address one primary case: a need for finer grained locking on metadata servers.  LNet used to have global locks and metadata servers, which do many small messages (high IOPS), much time in the worker threads was spent in spinlocks.  So, CPT configuration was added so locks/resources could be allocated per CPT.  This way, users have control over how they want CPTs to be configured and how they want resources/locks to be divided.  For example, users may want finer grained locking on the metadata servers but not on clients.  Leaving this to be automatically configured by Linux API calls would take this flexibility away from the users who, for HPC, are very knowledgable about what they want (i.e. we do not want to protect them from themselves).

The CPT support in LNet and LNDs has morphed to encompass more traditional NUMA and core affinity performance improvements.  For example, you can restrict a network interface to a socket (NUMA node) which has better affinity to the PCIe lanes that interface is connected to.  Rather than try to do this sort of thing automatically, we have left it to the user to know what they are doing and configure the CPTs accordingly.

I think the many changes to the CPT code has realty clouded its purpose.  In summary, the original purpose was finer grained locking and that needs to be maintained as the IOPS requirements of metadata servers is paramount.

James: The Verbs RDMA interface has very poor support for NUMA/core affinity.  I was going to try to devise some patches to address that but have been too busy on other things.  Perhaps the RDMA maintainer could consider updating it?

Doug

On Jul 5, 2018, at 8:11 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

On Fri, Jul 06 2018, James Simmons wrote:

NeilBrown [mailto:neilb at suse.com] wrote:

To help contextualize things: the Lustre code can be decomposed into three parts:

1) The filesystem proper: Lustre.
2) The communication protocol it uses: LNet.
3) Supporting code used by Lustre and LNet: CFS.

Part of the supporting code is the CPT mechanism, which provides a way to
partition the CPUs of a system. These partitions are used to distribute queues,
locks, and threads across the system. It was originally introduced years ago, as
far as I can tell mainly to deal with certain hot locks: these were converted into
read/write locks with one spinlock per CPT.

As a general rule, CPT boundaries should respect node and socket boundaries,
but at the higher end, where CPUs have 20+ cores, it may make sense to split
a CPUs cores across several CPTs.

Thanks everyone for your patience in explaining things to me.
I'm beginning to understand what to look for and where to find it.

So the answers to Greg's questions:

 Where are you reading the host memory NUMA information from?

 And why would a filesystem care about this type of thing?  Are you
 going to now mirror what the scheduler does with regards to NUMA
 topology issues?  How are you going to handle things when the topology
 changes?  What systems did you test this on?  What performance
 improvements were seen?  What downsides are there with all of this?


Are:

 - NUMA info comes from ACPI or device-tree just like for every one
     else.  Lustre just uses node_distance().

Correct, the standard kernel interfaces for this information are used to
obtain it, so ultimately Lustre/LNet uses the same source of truth as
everyone else.

 - The filesystem cares about this because...  It has service
   thread that does part of the work of some filesystem operations
   (handling replies for example) and these are best handled "near"
   the CPU the initiated the request.  Lustre partitions
   all CPUs into "partitions" (cpt) each with a few cores.
   If the request thread and the reply thread are on different
   CPUs but in the same partition, then we get best throughput
   (is that close?)

At the filesystem level, it does indeed seem to help to have the service
threads that do work for requests run on a different core that is close to
the core that originated the request. So preferably on the same CPU, and
on certain multi-core CPUs there are also distance effects between cores.
That too is one of the things the CPT mechanism handles.

Their is another very important aspect to why Lustre has a CPU partition
layer. At least at the place I work at. While the Linux kernel manages all
the NUMA nodes and CPU cores Lustre adds the ability for us to specify a
subset of everything on the system. The reason is to limit the impact of
noise on the compute nodes. Noise has a heavy impact on large scale HP
work loads that can run days or even weeks at a time. Lets take an
example system:

              |-------------|     |-------------|
  |-------|   | NUMA  0     |     | NUMA  1     |   |-------|
  | eth0  | - |             | --- |             | - | eth1  |
  |_______|   | CPU0  CPU1  |     | CPU2  CPU3  |   |_______|
              |_____________|     |_____________|

In such a system it is possible with the right job schedular to start a
large parallel application on NUMA 0/ (CPU0 and CPU1). Normally such
large parallel applications will communicate between nodes using MPI,
such as openmpi, which can be configured to use eth0 only. Using the
CPT layer in lustre we can isolate lustre to NUMA 1 and use only eth1.
This greatly reducess the noise impact on the application running.

BTW this is one of the reasons ko2iblnd for lustre doesn't use the
generic RDMA api. The core IB layer doesn't support such isolation.
At least to my knowledge.

Thanks for that background (and for the separate explanation of how
jitter multiplies when jobs needs to synchronize periodically).

I can see that setting CPU affinity for lustre/lnet worker threads could
be important, and that it can be valuable to tie services to a
particular interface.  I cannot yet see why we need partitions for this,
rather that doing it at the CPU (or NODE) level.

Thanks,
NeilBrown

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180706/ba357d68/attachment-0001.html>
