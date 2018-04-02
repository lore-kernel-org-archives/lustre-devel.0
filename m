From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Apr 2018 08:37:59 +1000
Subject: [lustre-devel] lustre and loopback device
In-Reply-To: <CABoqRjt5Ravrv2_937pDzSSAnSG0_oAUxMquSibh_JDt-M2NCQ@mail.gmail.com>
References: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
 <87d0zr668j.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1803302011110.9681@casper.infradead.org>
 <CABoqRjswwgQ5UH72FWKDdTJeaFDnKKe0+18FooZVPFM929B1HA@mail.gmail.com>
 <0A9CF639-958A-4548-AAEA-475129AA4393@intel.com>
 <CABoqRjt5Ravrv2_937pDzSSAnSG0_oAUxMquSibh_JDt-M2NCQ@mail.gmail.com>
Message-ID: <87h8ot1bg8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Apr 02 2018, Jinshan Xiong wrote:

> Hi Andreas,
>
> There are still some more work going on, like to apply the changes in
> LU-4198.
> The other improvement is to make 'lctl blockdev' attach a loop device to
> readonly by default, otherwise the virtual block device would be corrupted
> if there exist multiple writers.
>
> After that's done, I will be happy to push a patch for review.

If you just posted it now - even though it isn't perfect yet - I could
read it, understand what the problem is that it is trying to fix, and start
looking at how to improve drivers/block/loop.c so that your patch isn't
necessary.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180403/2cf5cf6e/attachment-0001.sig>
