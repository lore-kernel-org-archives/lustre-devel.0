From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 11:22:44 +1000
Subject: [lustre-devel] Regression with delayed_work in sec_gc
In-Reply-To: <E4BBDF07-0165-4306-9846-382D2D0A9C3D@ddn.com>
References: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
 <87sh6s5zjy.fsf@notabene.neil.brown.name>
 <E4BBDF07-0165-4306-9846-382D2D0A9C3D@ddn.com>
Message-ID: <87r2m5ztsr.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, May 17 2018, Sebastien Buisson wrote:

>> Le 16 mai 2018 ? 00:22, NeilBrown <neilb@suse.com> a ?crit :
>> 
>> On Tue, May 15 2018, James Simmons wrote:
>> 
>>> Dmitry has backported your upstream commit
>>> 
>>> be3c64da248b1ada2bbcfc3855f07536d8087acb ( ptlrpc: use workqueue for
>>> pinger)
>>> 
>>> and Sebastien tried out the change which can be seen at
>>> https://review.whamcloud.com/#/c/31724. Sebastien is having issues with
>>> unloading osc, mdc, ost or mdt kernel modules. He writes that he activated
>>> Kerberos for my file system, did some IOs, then tried to unmount the
>>> client and the  targets. Unfortunately, on some occasions, while
>>> unmounting, the mdc module for instance has extra references (as shown by
>>> 'lsmod'), and cannot be unloaded. After a while, the extra references are
>>> dropped, and the  module can be unloaded. It also happens on occasions on
>>> server side, for the mdt or ost modules. I tried destroy_workqueue but
>>> that made things worst :-( Do you know what is going on?
>> 
>> My guess is that ptlrpc_pinger_main() is looping, so
>> cancel_delayed_work_sync() is waiting an unusually long time for it.
>> This patch might fix the problem - it certainly makes the usage
>> of "this_ping" closer to the original code.
>> 
>> Thanks,
>> NeilBrown
>> 
>> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>> index 89eef8ec7df4..131b201541e8 100644
>> --- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>> +++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>> @@ -222,12 +222,13 @@ static DECLARE_DELAYED_WORK(ping_work, ptlrpc_pinger_main);
>> 
>> static void ptlrpc_pinger_main(struct work_struct *ws)
>> {
>> -	unsigned long this_ping = jiffies;
>> 	long time_to_next_wake;
>> 	struct timeout_item *item;
>> 	struct obd_import *imp;
>> 
>> 	do {
>> +		unsigned long this_ping = jiffies;
>> +
>> 		mutex_lock(&pinger_mutex);
>> 		list_for_each_entry(item, &timeout_list, ti_chain) {
>> 			item->ti_cb(item, item->ti_cb_data);
>
> Still same problem when testing "ptlrpc: use delayed_work in sec_gc" with patch "ptlrpc: use workqueue for pinger" and modification as suggested above. Kernel module ptlrpc_gss holds extra references, and cannot be unloaded.
>
> However, patch "ptlrpc: use workqueue for pinger" alone does not have the issue.

Thanks for the clear explanation - helps a lot.  I see the problem - I think.

When (e.g.) ctx_release_kr() is called as part of shutting down a security
context, it calls sptlrpc_gc_add_ctx() which signals the gc-thread to
re-run.
None of this code is in mainline (why isn't the GSS code in
mainline????)
So I removed the SVC_SIGNAL flag as it was never being set.
So I didn't add matching functionality when porting to delayed-work.

To port  "ptlrpc: use delayed_work in sec_gc" to upstream lustre you
need to get sptlrpc_gc_add_ctx() to call
  	mod_delayed_work(system_wq, &sec_gc_work, 0);

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180521/a1104c70/attachment.sig>
