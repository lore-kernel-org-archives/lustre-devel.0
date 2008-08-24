From: Andreas Dilger <adilger@sun.com>
Date: Sat, 23 Aug 2008 20:02:10 -0600
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <200808221945.57702.alexander.zarochentsev@sun.com>
References: <200808201523.36720.alexander.zarochentsev@sun.com>
	<C4D1B2E1.575A%peter.braam@sun.com>
	<20080820192922.GG3392@webber.adilger.int>
	<200808221945.57702.alexander.zarochentsev@sun.com>
Message-ID: <20080824020210.GY3392@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 22, 2008  19:45 +0400, Alexander Zarochentsev wrote:
> On 20 August 2008 23:29:22 Andreas Dilger wrote:
> > On Aug 20, 2008  11:39 -0600, Peter J. Braam wrote:
> > > If I remember correctly the flush is only there to try to reduce
> > > rollback. However, given that failover may happen on a system where
> > > the software is not fully responsive, one could question the wisdom
> > > of this reduction.  In any case having more replay due to more
> > > rollback is harmless.
> >
> > One major caveat is that with mountconf we ALWAYS mark the device as
> > "readonly" when it is being unmounted.
> > If we don't have the sync 
> > there I fear data loss after a clean server unmount, when all clients
> > are also being unmounted and cannot do replay.
> >
> > I'd be thrilled if this was fixed so a normal shutdown did not do a
> > "force" unmount and set the device read-only, because that would also
> > avoid leaving the journal needing recovery.
> 
> I think the proposed changes do not touch umount or mountconf.
> The affected procedures are:
> 
> 1. obd_fail_write calls lvfs_set_rdonly    
> 	-- IMO it might be better to not sync device there.
> 2. filter_iocontrol -> lvfs_set_rdonly  
> 	-- not changed, there is filter_sync() call right before
>            lvfs_set_readonly
> 3. mdt_iocontrol -> dt_ro/osd_ro -> __lvfs_set_rdonly
>         -- it is what I want to change
> 4. mdt_fail_write -> dt_ro/osd_ro -> __lvfs_set_rdonly
>         -- sync is needed?

I can't see the details now, but in the case of a "normal" unmount
of an MDT or OST it does the shutdown in "failover" mode, in order
to preserve the client state instead of evicting the clients.
Otherwise, an accidental unmount/shutdown would cause application
errors on the clients.

Nathan,
can you please look into this?  You know the twisty-turny mountconf
callbacks better than anyone.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
