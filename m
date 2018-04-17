From: Doug Oucharek <doucharek@cray.com>
Date: Tue, 17 Apr 2018 15:41:44 +0000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move stack-check
 macros to libcfs_debug.h
In-Reply-To: <A380CFB4-E33C-4D94-AA83-628A2A9F52C5@intel.com>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935730.23409.6748888065027051683.stgit@noble>
 <alpine.LFD.2.21.1804160438220.16188@casper.infradead.org>
 <6D3C7935-E7ED-4826-B459-0C4888D6048E@cray.com>
 <alpine.LFD.2.21.1804162336220.14398@casper.infradead.org>
 <44671B46-27F6-4CFA-8E3A-7AD62B4C597E@cray.com>
 <A380CFB4-E33C-4D94-AA83-628A2A9F52C5@intel.com>
Message-ID: <399C67D9-B90A-40D5-97DB-74EA257D650E@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre
 Development List <lustre-devel@lists.lustre.org>


On Apr 16, 2018, at 10:26 PM, Dilger, Andreas <andreas.dilger at intel.com<mailto:andreas.dilger@intel.com>> wrote:

On Apr 16, 2018, at 16:48, Doug Oucharek <doucharek at cray.com<mailto:doucharek@cray.com>> wrote:


On Apr 16, 2018, at 3:42 PM, James Simmons <jsimmons at infradead.org<mailto:jsimmons@infradead.org>> wrote:


James,

If I understand correctly, you're saying you want to be able to build without debug support...?  I'm not convinced that building a client without debug support is interesting or useful.  In fact, I think it would be harmful, and we shouldn't open up the possibility - this is switchable debug with very low overhead when not actually "on".  It would be really awful to get a problem on a running system and discover there's no debug support - that you can't even enable debug without a reinstall.

If I've understood you correctly, then I would want to see proof of a significant performance cost when debug is built but *off* before agreeing to even exposing this option.  (I know it's a choice they'd have to make, but if it's not really useful with a side order of potentially harmful, we shouldn't even give people the choice.)

I'm not saying add the option today but this is more for the long game.
While the Intel lustre developers deeply love lustre's debugging
infrastructure I see a future where something better will come along to
replace it. When that day comes we will have a period where both
debugging infrastructurs will exist and some deployers of lustre will
want to turn off the old debugging infrastructure and just use the new.
That is what I have in mind. A switch to flip between options.

Yes please!!  An option for users which says ?no, you do not have the right to panic my system via LASSERT whenever you like? would be a blessing.

Note that LASSERT() itself does not panic the system, unless you configure it
with panic_on_lbug=1.  Otherwise, it just blocks that thread (though this can
also have an impact on other threads if you are holding locks at that time).

That said, the LASSERT() should not be hit unless there is bad code, data
corruption, or the LASSERT() itself is incorrect (essentially bad code also).

I don?t know about the rest of Lustre, but LNet and LNDs use LASSERT() at the top of every function call to check parameters, reference counters, state variables, etc.  These do get hit in the field and do take down the nodes.  I have yet to see a case where the customer?s data was at risk of corruption.  These should all be converted to regular ?if? checks returning EINVAL.


So "whenever you like" is "whenever the system is about to corrupt your data",
and people are not very forgiving if a filesystem corrupts their data...

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180417/4a6a4024/attachment.html>
