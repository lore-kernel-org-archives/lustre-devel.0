From: James Simmons <jsimmons@infradead.org>
Date: Thu, 5 Jul 2018 23:11:51 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/10] lustre: libcfs: fix libcfs debugfs
 bugs
In-Reply-To: <87y3erzqvx.fsf@notabene.neil.brown.name>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
 <87y3erzqvx.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1807052305080.12665@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > The original port to sysfs / debugfs was done in haste without any
> > testing so many bugs were introduced. This patch set resolves the
> > bugs found in the libcfs code when it was reviewed.
> >
> > James Simmons (10):
> >   lustre: libcfs: rename lustre_*_debugfs to lnet_*_debugfs
> >   lustre: libcfs: rename *_debugmb to *_debug_mb
> >   lustre: libcfs: make lnet_debugfs_symlink_def fields const
> >   lustre: libcfs: fix module loading and sysfs setting race
> >   lustre: libcfs: fix wrong debugfs symlink name
> >   lustre: libcfs: don't assume sysfs mount point
> >   lustre: libcfs: properly initialize lnet_debugfs_symlink_def
> >   lustre: libcfs: test if table is NULL for lnet_insert_debugfs
> >   lustre: libcfs: return ssize_t for lnet_debugfs_*
> >   lustre: libcfs: small cleanups for debugfs code
> >
> >  .../staging/lustre/include/linux/libcfs/libcfs.h   |  2 +-
> >  drivers/staging/lustre/lnet/libcfs/debug.c         | 28 ++++----
> >  drivers/staging/lustre/lnet/libcfs/module.c        | 78 +++++++++++-----------
> >  drivers/staging/lustre/lnet/lnet/router_proc.c     |  2 +-
> >  4 files changed, 57 insertions(+), 53 deletions(-)
> >
> > -- 
> > 1.8.3.1
> 
> These all look good to me, so I've (provisionally) applied them.
> I didn't know about kernel_param_lock() before. I wonder if it
> would make sense to use that to protect updates to sbi->ll_flags???

Sadly no. The kernel_param_lock() takes a special mutex, param_lock to 
handle the racing between modules and sysfs. In the case of sbu->ll_flags
that is parsed from the mount string. You can see the flow in obd_mount.c
with lmd->lmd_opts being filled from the mount string and that ends up
being processed in llite_lib.c with the function ll_option(). Their it
translates to sbi->ll_flags.
