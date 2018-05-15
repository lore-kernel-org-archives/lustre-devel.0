From: NeilBrown <neilb@suse.com>
Date: Wed, 16 May 2018 08:22:57 +1000
Subject: [lustre-devel] Regression with delayed_work in sec_gc
In-Reply-To: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
References: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
Message-ID: <87sh6s5zjy.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 15 2018, James Simmons wrote:

> Dmitry has backported your upstream commit 
>
> be3c64da248b1ada2bbcfc3855f07536d8087acb ( ptlrpc: use workqueue for 
> pinger)
>
> and Sebastien tried out the change which can be seen at 
> https://review.whamcloud.com/#/c/31724. Sebastien is having issues with 
> unloading osc, mdc, ost or mdt kernel modules. He writes that he activated 
> Kerberos for my file system, did some IOs, then tried to unmount the 
> client and the  targets. Unfortunately, on some occasions, while 
> unmounting, the mdc module for instance has extra references (as shown by 
> 'lsmod'), and cannot be unloaded. After a while, the extra references are 
> dropped, and the  module can be unloaded. It also happens on occasions on 
> server side, for the mdt or ost modules. I tried destroy_workqueue but
> that made things worst :-( Do you know what is going on?

My guess is that ptlrpc_pinger_main() is looping, so
cancel_delayed_work_sync() is waiting an unusually long time for it.
This patch might fix the problem - it certainly makes the usage
of "this_ping" closer to the original code.

Thanks,
NeilBrown

diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 89eef8ec7df4..131b201541e8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -222,12 +222,13 @@ static DECLARE_DELAYED_WORK(ping_work, ptlrpc_pinger_main);
 
 static void ptlrpc_pinger_main(struct work_struct *ws)
 {
-	unsigned long this_ping = jiffies;
 	long time_to_next_wake;
 	struct timeout_item *item;
 	struct obd_import *imp;
 
 	do {
+		unsigned long this_ping = jiffies;
+
 		mutex_lock(&pinger_mutex);
 		list_for_each_entry(item, &timeout_list, ti_chain) {
 			item->ti_cb(item, item->ti_cb_data);
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180516/4e6c8c37/attachment.sig>
