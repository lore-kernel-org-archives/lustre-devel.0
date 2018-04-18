From: NeilBrown <neilb@suse.com>
Date: Thu, 19 Apr 2018 08:38:10 +1000
Subject: [lustre-devel] [cfs_trace_lock_tcd] BUG: KASAN: null-ptr-deref
 in cfs_trace_lock_tcd+0x25/0xeb
In-Reply-To: <CA+55aFz=VCq6w=kH5aYavOM0-h130HgzVhVc94JxeYSdbMWbxg@mail.gmail.com>
References: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
 <20180418134058.l3orjjxcpv7cxjfw@wfg-t540p.sh.intel.com>
 <CA+55aFz=VCq6w=kH5aYavOM0-h130HgzVhVc94JxeYSdbMWbxg@mail.gmail.com>
Message-ID: <87k1t4qgx9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Staging subsystem List <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Denis Petrovic <denis.petrovic@edu.ece.fr>, LKP <lkp@01.org>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Wed, Apr 18 2018, Linus Torvalds wrote:

> Ugh, that lustre code is disgusting.
>
> I thought we were getting rid of it.

Lots of people seem to get value out of it.  So we're trying to polish
the code to make it less disgusting.  This is just a little fall-out.
The smoking gun is

[    6.528851] LNetError: 1:0:(module.c:546:libcfs_init()) misc_register: error -16

lustre registers a misc char device with the same number as USERIO.
If they both try to register, one fails.
Until recently, lustre could only be built as a module so when lustre
failed to register the char dev, the module-load fails.
Now it can be built monolithic (makes my testing easier) and the failure
mode is different. The module that tried to register the chardev rewinds
some initialization, and a subsequent module assumes that init was done,
and explodes.

There are patches in Greg's inbox to change lustre to use a dynamically
allocated minor.  And it is on my todo list to get lustre to do less
initialization at module-init time (where, in a monolithic build, it is
hard to give up if some previous module failed), and more at mount time.

So this is a known bug (maybe a new manifestation) and a fix has been
posted.  There is certainly room for lots more cleanup and that is
slowly happening.  I'll make a note to look into the large stack frames
you observed.

Previous report of bug was
  Subject: [staging]  184ecc5ceb: BUG:unable_to_handle_kernel
  Message-ID: <20180319091931.gt6ijdw7ahkbtvrq@inn>


Thanks,
NeilBrown

>
> Anyway, I started looking at why the stack trace is such an incredible
> mess, with lots of stale entries.
>
> The reason (well, _one_ reason) seems to be "ksocknal_startup". It has
> a 500-byte stack frame for some incomprehensible reason. I assume due
> to excessive inlining, because the function itself doesn't seem to be
> that bad.
>
> Similarly, LNetNIInit has a 300-byte stack frame. So it gets pretty deep.
>
> I'm getting the feeling that KASAN is making things worse because
> probably it's disabling all the sane stack frame stuff (ie no merging
> of stack slot entries, perhaps?).
>
> Without KASAN (but also without a lot of other things, so I might be
> blaming KASAN incorrectly), the stack usage of ksocknal_startup() is
> just under 100 bytes, so if it is KASAN, it's really a big difference.
>
> Anyway, apart from the excessive elements, the report seems fine, but
> I'm adding Neil Brown to the cc, since he's the one that has been
> making most of the lustre/lnet changes this merge window.
>
> Also adding Andrey to check about the oddly large stack usage.
>
> Not including the whole email with the attachements - Neil, it's on
> lkml and lustre-devel if you hadn't seen it.
>
>                 Linus
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180419/e1f4d56a/attachment.sig>
