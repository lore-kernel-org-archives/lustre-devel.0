From: Jinshan Xiong <jinshan.xiong@gmail.com>
Date: Wed, 23 May 2018 14:08:22 -0700
Subject: [lustre-devel] lustre and loopback device
In-Reply-To: <87y3gbxo74.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
 <87d0zr668j.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1803302011110.9681@casper.infradead.org>
 <CABoqRjswwgQ5UH72FWKDdTJeaFDnKKe0+18FooZVPFM929B1HA@mail.gmail.com>
 <0A9CF639-958A-4548-AAEA-475129AA4393@intel.com>
 <CABoqRjt5Ravrv2_937pDzSSAnSG0_oAUxMquSibh_JDt-M2NCQ@mail.gmail.com>
 <87h8ot1bg8.fsf@notabene.neil.brown.name>
 <CABoqRjvH=eP41ynKmnx0VkeW-UUTWrFsSafRWO1-RN338stKbA@mail.gmail.com>
 <87y3gbxo74.fsf@notabene.neil.brown.name>
Message-ID: <CABoqRjvet8PayNSbodZRawYOmu7JOFs_1wXHe1w0JOsv-YTU=A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

See inserted.

On Tue, May 22, 2018 at 4:31 PM, NeilBrown <neilb@suse.com> wrote:

> On Mon, Apr 02 2018, Jinshan Xiong wrote:
>
> > Hi Neil,
> >
> > Sure. Patches are attached for your reference.
> >
> > The first patch is to bring llite_lloop driver back; the 2nd fixes some
> > bugs and the 3rd one adds async I/O. The patches are based on 2.7.21,
> but I
> > don't think it would be difficult to port them to master. Anyway, it's
> just
> > for your reference.
> >
> > This is a piece of work in progress, please don't use it for production.
>
> Thanks,
> just one quick comment at this stage:
>
>
> >  .PP
> > +.SS Virtual Block Device Operation
> > +Lustre is able to emulate a virtual block device upon regular file. It
> is necessary to be used when you are trying to setup a swap space via file.
>
> We should fix this properly.  Creating a loop device just to provide
> swap is not the best approach.
> The preferred approach for swapping to a networked filesystem can be
> seen by examining the swap_activate address_space_operation in nfs.
> If a file passed to swap_on has a swap_activate operation, it will be
> called and then ->readpage will be used to read from swap, and
> ->direct_IO will be used to write.
>
> swap_activate needs to ensure that the direct_IO calls will never block
> waiting for memory allocation.
> For NFS, all that it does is calls sk_set_memalloc() on all network
> sockets that might be used.  This allows TCP etc to use the reserve
> memory pools.
> Lustre might need to pre-allocate other things, or make use PF_MEMALLOC
> in other contexts, I don't know.
>

That was a major problem when I worked on loop back device initially.
Lustre allocates memory from too many places to write something to OSTs, so
it would take huge effort to reserve memory on the writeback path.

Jinshan


>
> Thanks,
> NeilBrown
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180523/83458448/attachment.html>
