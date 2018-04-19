From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Thu, 19 Apr 2018 16:55:28 +0300
Subject: [lustre-devel] [cfs_trace_lock_tcd] BUG: KASAN: null-ptr-deref
 in cfs_trace_lock_tcd+0x25/0xeb
In-Reply-To: <b66f6034-7631-7fbf-56aa-e8e136e8b636@virtuozzo.com>
References: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
 <20180418134058.l3orjjxcpv7cxjfw@wfg-t540p.sh.intel.com>
 <CA+55aFz=VCq6w=kH5aYavOM0-h130HgzVhVc94JxeYSdbMWbxg@mail.gmail.com>
 <b66f6034-7631-7fbf-56aa-e8e136e8b636@virtuozzo.com>
Message-ID: <dfa02f34-5ada-70fe-0fd7-c494d632f8e1@virtuozzo.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Denis Petrovic <denis.petrovic@edu.ece.fr>, lustre-devel@lists.lustre.org, Staging subsystem List <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>



On 04/19/2018 04:35 PM, Andrey Ryabinin wrote:
> 
> 
> On 04/18/2018 09:37 PM, Linus Torvalds wrote:
>> Ugh, that lustre code is disgusting.
>>
>> I thought we were getting rid of it.
>>
>> Anyway, I started looking at why the stack trace is such an incredible
>> mess, with lots of stale entries.
>>
>> The reason (well, _one_ reason) seems to be "ksocknal_startup". It has
>> a 500-byte stack frame for some incomprehensible reason. I assume due
>> to excessive inlining, because the function itself doesn't seem to be
>> that bad.
>>
>> Similarly, LNetNIInit has a 300-byte stack frame. So it gets pretty deep.
>>
>> I'm getting the feeling that KASAN is making things worse because
>> probably it's disabling all the sane stack frame stuff (ie no merging
>> of stack slot entries, perhaps?).
>>
> 
> AFAIR no merging of stack slots policy enabled only if -fsanitize-address-use-after-scope 
> is on (which is CONFIG_KASAN_EXTRA). This feature does cause sometimes significant stack bloat,
> but hasn't been proven to be very useful, so I wouldn't mind disabling it completely.
> 
> So far I know only about a single BUG - https://lkml.kernel.org/r/<151238865557.4852.10258661301122491354@mail.alporthouse.com>
> it has found.

Actually, there is one more - https://syzkaller.appspot.com/bug?id=6a929b72a32ca0b1a6985126fa1bc77c03c12304
so two bugs.

> There are also a lot of other 

I didn't finish this sentence:

There are also a lot of other reports about use-after-scope, but seem all of them are false positives
caused by STRUCTLEAK plugin.
