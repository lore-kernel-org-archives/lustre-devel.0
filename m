From: Andreas Dilger <adilger@sun.com>
Date: Thu, 14 May 2009 00:22:24 -0600
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
Message-ID: <20090514062224.GD3209@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 13, 2009  11:06 -0700, David Brown wrote:
> The file system created has the following characteristics
> 
> 1) 700Tb when df -h returns
> 2) 4600 OSTs (well within the max of 8192)
> 3) 2300 OSSs
> 
> We could have an alternate configuration where we break the raid
> arrays and go a bit wider, 18000 OSTs on 2300 OSSs. But this would
> require modifications to lustre source code to make that happen.

Hmm, even projecting out to the future I'm not certain we will get
to systems with 18000 OSTs.  The capacity of the disks is growing
contiuously, and with ZFS we can have very large individual OSTs
so even 2-3 years from now we're only looking at 1200 OSTs on 400 OSS
nodes (115 PB filesystem with 30x4TB disks/OST in RAID-6 8+2 = 96TB/OST).

> The bug above really hits us hard on this system, even on lustre
> 1.8.0. It took 5 hours just to get 4096 OSTs mounted.

Ouch.

> As this is going on everything is in a constant state of reconnect,
> since the mgs/mdt is busy handling new incoming OSTs. I'm glad to say
> that the reconnects keep up and everything goes through the recovery
> as expected.  When we've paused the mount process, the cluster settles
> back down and df -h returns about 5 minutes afterwards, which is very
> acceptable. However, there's a linear increase in the amount of
> reconnects and traffic associated with those reconnects as the number
> of OSTs increase during the mounting. This causes an increase in time
> for the next OSTs that has to mount. Keep in mind that this is on a
> brand new file system, not upgrading, not currently running. I would
> expect this behavior wouldn't happen (or would be slightly different)
> if the file system was already created.

Sounds unpleasant.  I wonder if this is driven by the fact that the
MGS clients (OSTs are also MGS clients) don't expect a huge amount of
change at any one time so they try to refetch the updated config in
an eager manner.  This probably increases the queue of requests on
the MGS linearly with the number of OSTs, and new OST connections are
getting backed up behind this.

I was going to say that getting some RPC stats from the MGS service
would be informative, but I can't see any MGS RPC stats file on my system...

I wonder if a longer-term solution is to have the MGS push the config
log changes to the clients, instead of having the clients pull them.

> Precreate mdt/mgs and ost images in a small form factor prior to
> production cluster time.
> 
> 1) pick a system and put lustre on it.
> 2) setup an mdt/mgs combo and mount it
> 3) create an ost and mount it
> 4) umount it save the image (should only be 10M or so not sure what
> the smallest size would be).

You only really need to mount the OST filesystem with "-t ldiksfs",
tar up the contents of the OST filesystem, and save the filesystem
label ({fsname}-OSTnnnn).

> 5) deactivate the new ost
> 6) go to step 3 with the same disk you used before
> 
> You'd end up with pre-created images of a lustre file system prior to
> deployment that you could dd onto all the drives in parallel quite
> fast.
> 
> You could then run resize2fs on the file systems to fill up the OST to
> the appropriate size for that device (not sure how long this would
> take).

If you only save the tar image, then you can just do a normal format
of the OST filesystem (using the mke2fs options as reported during
the mkfs.lustre run, with the proper label "-L {fsname}-OSTnnnn" for
that OST index, mount it with "-t ldiskfs" and then extract the
tarball into it.

> Then you would run tunefs.lustre to change where the mgsnode and
> fsname is for that file system.
> 
> Then all you'd have to do is mount and the bug may be averted, right?

Probably, yes.


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
