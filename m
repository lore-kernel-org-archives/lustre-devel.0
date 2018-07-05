From: NeilBrown <neilb@suse.com>
Date: Thu, 05 Jul 2018 11:57:32 +1000
Subject: [lustre-devel] [PATCH v3 07/26] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <AT5PR8401MB0900A5406BF0CB8C87B80EEC85410@AT5PR8401MB0900.NAMPRD84.PROD.OUTLOOK.COM>
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
Message-ID: <87k1qazboz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jul 04 2018, Weber, Olaf (HPC Data Management & Storage) wrote:

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

Thanks for this context.
Looking in the client code there are 2 per-cpt locks: ln_res_lock and
ln_net_lock.

ln_res_lock protects:
 lnet_res_container -> rec_lh_hash hash chains.

 the_lnet.ln_eq_container.rec_active list of lnet_eq

 lists of memory descriptors (rec_active)

 lists of match entries - one table per cpt.
     Some match entries follow cpu affinity, some are global and hashed
     to choose a table (I think).

  lib-move seems to use the lock to protect the md itself,
  rather than just the list of md.... not sure.

  ptl_mt_maps (??) (rather inefficient ordered-insertion in
  		lnet_ptl_enable_mt())

  proc_lnet_portal_rotor() uses lnet_res_lock(0) to protect
     portal_rotos[]. I wonder why.


ln_net_lock protects:

   ni->ni_refs counter (why not atomic_t I wonder)
   the_lnet.ln_testprotocompat - I guess we don't want that changing
          while a per-cpt lock is held?

   the_lnet.ln_counters - keep them stable while reading.
   the_lnet.ln_nis ??
   the_lnet.ln_nis_cpt list of lnet_ni... list of network interfaces I guess.
     Locking a per-cpt lock stops updates as all locks are needed to
     change.  These days RCU is often used for this sort of thing.

   lnet_ping_info
   ... and maybe lots more.


So ln_net_lock seems to be  "read/write locks with one spinlock per
CPT." that you described.  I wonder how much of that could be converted
to use RCU - with just a single spinlock to protect updates, and
rcu_read_lock() to make reads safe.

ln_res_lock is quite different - it protects a selection of different
resources that are distributed across multiple cpts.
I wonder why we don't have one lock per resource...
I also wonder how import having these things per-cpt is.
Lots of other code in the kernel has per-CPU lists etc, and
some have per-numa-node, but no other code seems to be need an
intermediate granularity.

I might try to drill down into some of this code a bit more and see what
I can find.  There is probably something I'm still missing.

Thanks,
NeilBrown

   

>
> As a general rule, CPT boundaries should respect node and socket boundaries,
> but at the higher end, where CPUs have 20+ cores, it may make sense to split
> a CPUs cores across several CPTs.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180705/d978b412/attachment.sig>
