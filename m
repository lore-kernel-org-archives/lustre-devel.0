From: NeilBrown <neilb@suse.com>
Date: Wed, 23 May 2018 08:55:35 +1000
Subject: [lustre-devel] lustre and loopback device
In-Reply-To: <CABoqRjswwgQ5UH72FWKDdTJeaFDnKKe0+18FooZVPFM929B1HA@mail.gmail.com>
References: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
 <87d0zr668j.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1803302011110.9681@casper.infradead.org>
 <CABoqRjswwgQ5UH72FWKDdTJeaFDnKKe0+18FooZVPFM929B1HA@mail.gmail.com>
Message-ID: <871se3z4ew.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Mar 30 2018, Jinshan Xiong wrote:

> + Andreas.
>
> A few problems:

Sorry that it has been 7 weeks, but I've finally scheduled time to
have a proper look at this.

> 1. Linux loop device won't work upon Lustre with direct IO mode because
> Lustre direct IO has to be pagesize aligned, and there seems no way of
> changing sector size to pagesize for Linux loop device;

The sector size for a loop device can be set with the --sector-size
argument to losetup (or the LOOP_SET_BLOCK_SIZE ioctl).  This is done
from user-space, not from in the  lustre module of course.
open(O_DIRECT) is documented as having size/alignment restrictions,
so I think a good case could be made to change the handling of
"losetup --raw" to imply a "--sector-size" setting, if we could
determine an appropriate size automatically.
The XFS_IOC_DIOINFO ioctl (see man xfsctl) can be used to ask a
filesystem about alignment requirements, but is currently only
supported for XFS.  If we added support to lustre, and asked util-linux
to use it to help configure a loop device, I suspect we could get
success.

There would probably be a request to hoist the ioctl out of xfs and add
it to VFS. I cannot predict how that would go, but I think it would be
good to pursue this approach.

You could try it in you own testing by using
  losetup -r --sector=size=4096 /dev/loopX  filename
to create a loop device.

> 2. 64KB is not an optimal RPC size for Lustre, so yes eventually we are
> going to see throughput issue if the RPC size is limited to 64KB;

So let's find out where the 64KB limit is imposed, and raise it.
Maybe it comes from
	lo->tag_set.queue_depth = 128;
combined with the default sector size of 512.
If so, then increasing the sector size to 4K should raise the RPC
size 512K.

> 3. It's hard to do I/O optimization more with Linux loop device. With
> direct I/O by default, it has to wait for the current I/O to complete
> before it can send the next one. This is not good. I have revised
> llite_lloop driver so that it can do async direct I/O. The performance
> boosts significantly by doing so.

This surprises me.  Looking at the code in loop.c, I see a field
->use_aio which is set when direct_io is used (->use_dio), except
for FLUSH DISCARD and WRITE_ZEROES.
->use_dio is disabled if the filesystem has a block device
(->i_sb->s_bdev != NULL) and alignment doesn't match, but that
wouldn't apply to lustre.
Linux gained aio in loop in Linux 4.4.  What kernel version were you
looking at?

>
> I tried to increase the sector size of Linux loop device and also
> max_{hw_}sectors_kb but it didn't work. Please let me know if there exists
> ways of doing that.

If --sector-size option to losetup doesn't work, we will have to make it
work.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180523/e13c4fbe/attachment.sig>
