From: James Simmons <jsimmons@infradead.org>
Date: Fri, 6 Jul 2018 16:57:00 +0100 (BST)
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <87o9fkyjqs.fsf@notabene.neil.brown.name>
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
 <02B7B718-E496-46CF-B55D-86EAB98381B6@cray.com>
 <87o9fkyjqs.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1807061650320.15728@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > When the CPT code was added to LNet back in 2012, it was to address
> > one primary case: a need for finer grained locking on metadata
> > servers.  LNet used to have global locks and metadata servers, which
> > do many small messages (high IOPS), much time in the worker threads
> > was spent in spinlocks.  So, CPT configuration was added so
> > locks/resources could be allocated per CPT.  This way, users have
> > control over how they want CPTs to be configured and how they want
> > resources/locks to be divided.  For example, users may want finer
> > grained locking on the metadata servers but not on clients.  Leaving
> > this to be automatically configured by Linux API calls would take this
> > flexibility away from the users who, for HPC, are very knowledgable
> > about what they want (i.e. we do not want to protect them from
> > themselves).
> >
> > The CPT support in LNet and LNDs has morphed to encompass more
> > traditional NUMA and core affinity performance improvements.  For
> > example, you can restrict a network interface to a socket (NUMA node)
> > which has better affinity to the PCIe lanes that interface is
> > connected to.  Rather than try to do this sort of thing automatically,
> > we have left it to the user to know what they are doing and configure
> > the CPTs accordingly.
> >
> > I think the many changes to the CPT code has realty clouded its
> > purpose.  In summary, the original purpose was finer grained locking
> > and that needs to be maintained as the IOPS requirements of metadata
> > servers is paramount.
> 
> Thanks for the explanation.
> I definitely get that fine-grained locking is a good thing.  Lustre is
> not alone in this of course.
> Even better than fine-grained locking is no locking.  That is not often
> possible, but this
>   https://github.com/neilbrown/linux/commit/ac3f8fd6e61b245fa9c14e3164203c1211c5ef6b
> 
> is an example of doing exactly that.
> 
> For the read/writer usage of CPT locks, RCU is a better approach if it
> can be made to work (usually it can) - and it scales even better.
> 
> When I was digging through the usage of locks I saw some hash tables.
> It seems that a lock protected a whole table.  It is usually sufficient
> for the lock to just protect a single chain (bit spin-locks can easily
> store one lock per chain) and then only for writes - RCU discipline can
> allow reads to proceed with only rcu_read_lock().
> Would we still need per-CPT tables once that was in place?  I don't know
> yet, though per-node seems likely to be sufficient when locking is per-chain.
> 
> I certainly wouldn't discard CPTs without replacing them with something
> better.  Near the top of my list for when I return from vacation
> (leaving in a couple of days) will be to look closely at the current
> fine-grained locking that you have helped me to see more clearly, and
> see if I can make it even better.

If RCU can provide better scaling then its best to replace CPT handling in
those cases. Lets land the Mult-Rail stuff first since it makes the most
heavy use of the CPT code. From there we can get a good idea of how to
move forward. I don't think we can easily abandon the CPT infrastructure
in general since we need it for partitioning to reduce noise. What would
be ideal is integrate the partitoning work to the general linux kernel.
While lustre attempts to reduce noise on nodes the rest of the kernel 
doesn't. If the linux kernel supported this it would be a big win for
HPC systems. The monster HPC systems today will be general hardware 5+
years down the road.
