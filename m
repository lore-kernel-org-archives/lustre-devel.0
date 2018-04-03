From: Jinshan Xiong <jinshan.xiong@gmail.com>
Date: Mon, 2 Apr 2018 17:03:53 -0700
Subject: [lustre-devel] lustre and loopback device
In-Reply-To: <87h8ot1bg8.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
 <87d0zr668j.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1803302011110.9681@casper.infradead.org>
 <CABoqRjswwgQ5UH72FWKDdTJeaFDnKKe0+18FooZVPFM929B1HA@mail.gmail.com>
 <0A9CF639-958A-4548-AAEA-475129AA4393@intel.com>
 <CABoqRjt5Ravrv2_937pDzSSAnSG0_oAUxMquSibh_JDt-M2NCQ@mail.gmail.com>
 <87h8ot1bg8.fsf@notabene.neil.brown.name>
Message-ID: <CABoqRjvH=eP41ynKmnx0VkeW-UUTWrFsSafRWO1-RN338stKbA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Neil,

Sure. Patches are attached for your reference.

The first patch is to bring llite_lloop driver back; the 2nd fixes some
bugs and the 3rd one adds async I/O. The patches are based on 2.7.21, but I
don't think it would be difficult to port them to master. Anyway, it's just
for your reference.

This is a piece of work in progress, please don't use it for production.

Thanks,
Jinshan





On Mon, Apr 2, 2018 at 3:37 PM, NeilBrown <neilb@suse.com> wrote:

> On Mon, Apr 02 2018, Jinshan Xiong wrote:
>
> > Hi Andreas,
> >
> > There are still some more work going on, like to apply the changes in
> > LU-4198.
> > The other improvement is to make 'lctl blockdev' attach a loop device to
> > readonly by default, otherwise the virtual block device would be
> corrupted
> > if there exist multiple writers.
> >
> > After that's done, I will be happy to push a patch for review.
>
> If you just posted it now - even though it isn't perfect yet - I could
> read it, understand what the problem is that it is trying to fix, and start
> looking at how to improve drivers/block/loop.c so that your patch isn't
> necessary.
>
> NeilBrown
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180402/6f56ab16/attachment-0001.html>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Revert-LU-8844-llite-delete-lloop.patch
Type: application/octet-stream
Size: 43945 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180402/6f56ab16/attachment-0003.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0002-cleanup-and-bugfix.patch
Type: application/octet-stream
Size: 21050 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180402/6f56ab16/attachment-0004.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0003-async-IO.patch
Type: application/octet-stream
Size: 14128 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180402/6f56ab16/attachment-0005.obj>
