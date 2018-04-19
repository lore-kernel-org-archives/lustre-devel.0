From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Thu, 19 Apr 2018 16:35:08 +0300
Subject: [lustre-devel] [cfs_trace_lock_tcd] BUG: KASAN: null-ptr-deref
 in cfs_trace_lock_tcd+0x25/0xeb
In-Reply-To: <CA+55aFz=VCq6w=kH5aYavOM0-h130HgzVhVc94JxeYSdbMWbxg@mail.gmail.com>
References: <20180418133831.uef7d77ejdyjtxgh@wfg-t540p.sh.intel.com>
 <20180418134058.l3orjjxcpv7cxjfw@wfg-t540p.sh.intel.com>
 <CA+55aFz=VCq6w=kH5aYavOM0-h130HgzVhVc94JxeYSdbMWbxg@mail.gmail.com>
Message-ID: <b66f6034-7631-7fbf-56aa-e8e136e8b636@virtuozzo.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, NeilBrown <neilb@suse.com>
Cc: Staging subsystem List <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Denis Petrovic <denis.petrovic@edu.ece.fr>, LKP <lkp@01.org>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org



On 04/18/2018 09:37 PM, Linus Torvalds wrote:
> Ugh, that lustre code is disgusting.
> 
> I thought we were getting rid of it.
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

AFAIR no merging of stack slots policy enabled only if -fsanitize-address-use-after-scope 
is on (which is CONFIG_KASAN_EXTRA). This feature does cause sometimes significant stack bloat,
but hasn't been proven to be very useful, so I wouldn't mind disabling it completely.

So far I know only about a single BUG - https://lkml.kernel.org/r/<151238865557.4852.10258661301122491354@mail.alporthouse.com>
it has found.
There are also a lot of other 


> Without KASAN (but also without a lot of other things, so I might be
> blaming KASAN incorrectly), the stack usage of ksocknal_startup() is
> just under 100 bytes, so if it is KASAN, it's really a big difference.
>

Yes, it's because of KASAN:
CONFIG_KASAN=n
socklnd.c:2795:1:ksocknal_startup       144     static

CONFIG_KASAN=y
CONFIG_KASAN_OUTLINE=y
CONFIG_KASAN_EXTRA=n
socklnd.c:2795:1:ksocknal_startup       552     static

CONFIG_KASAN=y
CONFIG_KASAN_OUTLINE=y
CONFIG_KASAN_EXTRA=y
socklnd.c:2795:1:ksocknal_startup       624     static

It's expected that KASAN may cause sometimes significant stack usage growth.
This is needed to catch out-of-bounds accesses to stack data.
When compiler can't proof that access to stack variable is valid (e.g. reference to
stack variable passed to some external function), it will create redzones around such
stack variable.

E.g. ksocknal_enumerate_interfaces() which is called only from ksocknal_startup(), thus probably
inlined into ksocknal_startup() does this:


	for (i = j = 0; i < n; i++) {
		int up;
		__u32 ip;
		__u32 mask;

		if (!strcmp(names[i], "lo")) /* skip the loopback IF */
			continue;

		rc = lnet_ipif_query(names[i], &up, &ip, &mask);


With KASAN stack might look something like this:
  [32-byte left redzone of the stack frame] [up (4 bytes)] [28-bytes redzone][ip (4 bytes)] [28-bytes redzone][mask (4 bytes)] [28-bytes redzone][32-byte right redzone of the stack frame]

GCC always use 32-bytes redzones. AFAIK clang is more smart about this, it has adaptive redzone policy - smaller redzones for small variables, and bigger for big.

In this particular case, the best way to reduce stack usage is to refactor the code.
1) Drop 'int *up' argument from lnet_ipif_query(). When interface is down lnet_ipif_query() sets up to zero and doesn't return error.
   But all callers treat up == 0 as error. So instead, lnet_ipif_query() should simply return error code, and 'up' won't be needed.
    This will simplify the code, and should drop the stack usage with KASAN and without KASAN.

2) Instead of using local ip, mask variables, pass pointers '&net->ksnn_interfaces[j].ksni_ipaddr', '&net->ksnn_interfaces[j].ksni_netmask'.
    As in 1) this should alst drop the stack usage both with KASAN and without KASAN
