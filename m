From: NeilBrown <neilb@suse.com>
Date: Wed, 18 Apr 2018 12:29:08 +1000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move stack-check
 macros to libcfs_debug.h
In-Reply-To: <alpine.LFD.2.21.1804162336220.14398@casper.infradead.org>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935730.23409.6748888065027051683.stgit@noble>
 <alpine.LFD.2.21.1804160438220.16188@casper.infradead.org>
 <6D3C7935-E7ED-4826-B459-0C4888D6048E@cray.com>
 <alpine.LFD.2.21.1804162336220.14398@casper.infradead.org>
Message-ID: <877ep5s0wb.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Patrick Farrell <paf@cray.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16 2018, James Simmons wrote:

>> James,
>> 
>> If I understand correctly, you're saying you want to be able to build without debug support...?  I'm not convinced that building a client without debug support is interesting or useful.  In fact, I think it would be harmful, and we shouldn't open up the possibility - this is switchable debug with very low overhead when not actually "on".  It would be really awful to get a problem on a running system and discover there's no debug support - that you can't even enable debug without a reinstall.
>> 
>> If I've understood you correctly, then I would want to see proof of a significant performance cost when debug is built but *off* before agreeing to even exposing this option.  (I know it's a choice they'd have to make, but if it's not really useful with a side order of potentially harmful, we shouldn't even give people the choice.)
>
> I'm not saying add the option today but this is more for the long game.
> While the Intel lustre developers deeply love lustre's debugging 
> infrastructure I see a future where something better will come along to
> replace it. When that day comes we will have a period where both
> debugging infrastructurs will exist and some deployers of lustre will
> want to turn off the old debugging infrastructure and just use the new.
> That is what I have in mind. A switch to flip between options.

My position on this is that lustre's debugging infrastructure (in
mainline) *will* be changed to use something that the rest of the kernel
can and does use.  Quite possibly that "something" will first be
enhanced so that it is as powerful and useful as what lustre has.
I suspect this will partly be pr_debug(), partly WARN_ON(), partly trace
points.  But I'm not very familiar with tracepoints or with lustre
debugging yet so this is far from certain.
pr_debug() and tracepoints can be compiled out, but only kernel-wide.
There is no reason for lustre to be special there.  WARN_ON() and
BUG_ON() cannot be compiled out, but BUG_ON() must only be used when
proceeding is unarguably worse than crashing the machine.  In recent
years a lot of BUG_ON()s have been removed or changed to warnings.  We
need to maintain that attitude.

I don't like the idea of have two parallel debuging infrastructures that
you can choose between - it encourages confusion and brings no benefits.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180418/1e20da11/attachment.sig>
