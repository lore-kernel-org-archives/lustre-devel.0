From: Sebastien Buisson <sbuisson@ddn.com>
Date: Mon, 19 Oct 2020 06:01:51 +0000
Subject: [lustre-devel] sec: O_DIRECT for encrypted file crashes Linux
 client
In-Reply-To: <878sc3f3dh.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.2010190019040.21280@casper.infradead.org>
 <878sc3f3dh.fsf@notabene.neil.brown.name>
Message-ID: <1BC9DA4E-CD67-4F4C-878B-5121D33576B1@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Le 19 oct. 2020 ? 02:47, NeilBrown <neilb@suse.de> a ?crit :
> 
> On Mon, Oct 19 2020, James Simmons wrote:
> 
>> I have ported patch https://review.whamcloud.com/38967 which is 
>> "lustre: sec: O_DIRECT for encrypted file". The big difference is that for 
>> the Linux client we are using the native fscrypto layer. In my testing I'm 
>> seeing:
>> 
>> 2020-10-18 15:26:49 [ 4462.081809][T14012] Lustre: DEBUG MARKER: == sanity 
>> test 56w: check lfs_migrate -c stripe_count works 
>> ========================================== 15:26:49 (1603049209)
>> 2020-10-18 15:26:52 [ 4464.514691][T30281] BUG: kernel NULL pointer 
>> dereference, address: 0000000000000048
>> 2020-10-18 15:26:52 [ 4464.524282][T30281] #PF: supervisor read access in 
>> kernel mode
>> 2020-10-18 15:26:52 [ 4464.532011][T30281] #PF: error_code(0x0000) - 
>> not-present page
>> 2020-10-18 15:26:52 [ 4464.539709][T30281] PGD 80000007edcce067 P4D 
>> 80000007edcce067 PUD 7f1306067 PMD 0
>> 2020-10-18 15:26:52 [ 4464.549144][T30281] Oops: 0000 [#1] PREEMPT SMP PTI
>> 2020-10-18 15:26:52 [ 4464.555851][T30281] CPU: 0 PID: 30281 Comm: 
>> ptlrpcd_00_04 Tainted: G        W         5.7.0-rc7+ #1
>> 2020-10-18 15:26:52 [ 4464.566720][T30281] Hardware name: Supermicro Super 
>> Server/To be filled by O.E.M., BIOS 2.0b 08/12/2016
>> 2020-10-18 15:26:52 [ 4464.577932][T30281] RIP: 
>> 0010:mempool_free+0x12/0x80
>> 2020-10-18 15:26:52 [ 4464.584690][T30281] Code: 60 e8 ff cc cc cc cc cc 
>> 0f 1f 44 00 00 e9 86 a3 08 00 66 0f 1f 44 00 00 0f 1f 44 00 00 55 48 85 ff 
>> 48 89 fd 53 74 1a 48 89 f3 <8b> 46 48 39 46 4c 7c 12 48 8b 73 58 48 8b 43 
>> 68 48 89 ef 5b 5d ff
>> 2020-10-18 15:26:52 [ 4464.607734][T30281] RSP: 0018:ffffc9002414fcc0 
>> EFLAGS: 00010282
>> 2020-10-18 15:26:52 [ 4464.615423][T30281] RAX: ffff8887d44fb5e0 RBX: 
>> 0000000000000000 RCX: 0000000000000000
>> 2020-10-18 15:26:52 [ 4464.625013][T30281] RDX: ffff888845abb780 RSI: 
>> 0000000000000000 RDI: ffffea001f553340
>> 2020-10-18 15:26:52 [ 4464.634577][T30281] RBP: ffffea001f553340 R08: 
>> 0000000000000000 R09: 0000000000000000
>> 2020-10-18 15:26:52 [ 4464.644109][T30281] R10: 0000000000000000 R11: 
>> 000000000000000f R12: 0000000000000000
>> 2020-10-18 15:26:52 [ 4464.653614][T30281] R13: ffff8887d736c9f0 R14: 
>> 0000000000000010 R15: ffff888845abb780
>> 2020-10-18 15:26:52 [ 4464.663095][T30281] FS:  0000000000000000(0000) 
>> GS:ffff88885e600000(0000) knlGS:0000000000000000
>> 2020-10-18 15:26:52 [ 4464.673521][T30281] CS:  0010 DS: 0000 ES: 0000 
>> CR0: 0000000080050033
>> 2020-10-18 15:26:52 [ 4464.681579][T30281] CR2: 0000000000000048 CR3: 
>> 00000007cf9fa004 CR4: 00000000001606f0
>> 2020-10-18 15:26:52 [ 4464.691015][T30281] Call Trace:
>> 2020-10-18 15:26:52 [ 4464.695751][T30281]  brw_interpret+0xac/0xa60 [osc]
>> 2020-10-18 15:26:52 [ 4464.702190][T30281]  ? _raw_spin_unlock+0x29/0x50
>> 2020-10-18 15:26:52 [ 4464.708490][T30281]  ptlrpc_check_set+0x329/0x1790 
>> [ptlrpc]
>> 2020-10-18 15:26:52 [ 4464.715599][T30281]  ptlrpcd_check+0x411/0x460 
>> [ptlrpc]
>> 2020-10-18 15:26:52 [ 4464.722318][T30281]  ptlrpcd+0x278/0x300 [ptlrpc]
>> 2020-10-18 15:26:52 [ 4464.728463][T30281]  ? remove_wait_queue+0x60/0x60
>> 2020-10-18 15:26:52 [ 4464.734667][T30281]  kthread+0x12a/0x170
>> 2020-10-18 15:26:52 [ 4464.739993][T30281]  ? ptlrpcd_check+0x460/0x460 
>> [ptlrpc]
>> 2020-10-18 15:26:52 [ 4464.746745][T30281]  ? kthread_bind+0x10/0x10
>> 2020-10-18 15:26:52 [ 4464.752431][T30281]  ret_from_fork+0x24/0x30
>> 
>> Neil I suspect you might see this as well once this patch is ported to 
>> your tree. Any idea why this would break? I haven't dugged down into it 
>> yet.
> 
> Something has passed a NULL mempool to mempool_free().
> Possibly osc_release_bounce_pages -> fscrypt_finalize_bounce_page
>   -> fscrypt_free_bounce_page -> mempool_free

I agree this might be the call path leading to the stack above.

> The pool is initialized by fscrypt_initialize <-
> fscrypt_get_encryption_info.
> I don't know why that hasn't been called.

In fact, James hit this bug while running sanity test_56w. So I doubt it is using encryption.
I think the question is more ? why is this page considered a bounce page? ?.

Sebastien.
