From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 09:25:38 +1000
Subject: [lustre-devel] [PATCH 21/24] lustre: move remainder of
 linux-tracefile.c to tracefile.c
In-Reply-To: <alpine.LFD.2.21.1806242125460.28698@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669084.10587.6920959206498193596.stgit@noble>
 <alpine.LFD.2.21.1806210236200.3886@casper.infradead.org>
 <87y3f7bj9w.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806242125460.28698@casper.infradead.org>
Message-ID: <87zhzjahsd.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

>> On Thu, Jun 21 2018, James Simmons wrote:
>> 
>> >> It's good to keep related code together.
>> >> 
>> >> Signed-off-by: NeilBrown <neilb@suse.com>
>> >
>> > Nak. For some reason this corrupts my dmesg output. Its really strange and
>> > I haven't figured it out yet.
>> 
>> This patch cannot possibly be the cause of any such behavioural change.
>> It purely moves code from one file to another, it doesn't change the
>> code at all.
>
> In a way you are correct. What this patch does is expose how badly messed
> up cfs_print_to_console() is. Originally it was a printk() call but some
> newbie changed it incorrectly into a pr_info() for all cases. This is 
> totally incorrect but it landed anyways :-( For some bizarre reason it
> works even with it being completely wrong.

I see the problem with cfs_print_to_console().  It chooses a message
type (KERN_EMERG, KERN_ERR, KERN_WARNING, KERN_INFO) then uses pr_info()
to print that, which adds another KERN_INFO.
However vprintk_emit() calls printk_get_level() repeatedly while it
succeeds, so the extra KERNE_INFO is ignored.

So while the code is strange and should use printk(), I don't see
how it could mess up your dmesg output.

>                                              I did fix this patch up
> and redid the later patches due the changes from the fix up.  Is it okay
> it I push the newer version of these patches with my changes?

I'm not really sure what you are asking here, but the answer is probably
"yes, it is okay".

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/5ef026fb/attachment.sig>
