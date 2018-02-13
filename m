From: Patrick Farrell <paf@cray.com>
Date: Tue, 13 Feb 2018 00:46:51 +0000
Subject: [lustre-devel] [PATCH 08/19] staging: lustre: simplify waiting
 in ldlm_completion_ast()
In-Reply-To: <87o9ktrbe5.fsf@notabene.neil.brown.name>
References: <151847037709.22826.16175867257667686132.stgit@noble>
 <151847055674.22826.12912356108048917428.stgit@noble>
 <4AC4BB93-85C5-4CA1-B062-1274833C51C6@cray.com>,
 <87o9ktrbe5.fsf@notabene.neil.brown.name>
Message-ID: <BN6PR1101MB2132A4E444F38C9BAF7FDC52CBF60@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas
 Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Yes, I assume it?s a comment about stack usage (or even more out of date and unrelated to the current code entirely. :p)  Like you, I can?t imagine what else it would be...

You?re probably right about the locking issue, I?m happy to defer.  (In any case, this timed out path should be very far from hot...)

Otherwise that fix looks good.  I?ll review the rest of these tomorrow.

________________________________
From: NeilBrown <neilb@suse.com>
Sent: Monday, February 12, 2018 6:17:22 PM
To: Patrick Farrell; Oleg Drokin; Andreas Dilger; James Simmons; Greg Kroah-Hartman
Cc: lkml; lustre
Subject: Re: [lustre-devel] [PATCH 08/19] staging: lustre: simplify waiting in ldlm_completion_ast()

On Mon, Feb 12 2018, Patrick Farrell wrote:

> Neil,
>
> I didn't get anything after 8/19 in this series.  Is this just me?  (I'd keep waiting, except I also found a few things in this patch.)

Not just you.  My fault.  They are appearing now.

>
> Minor:
> The line XXX ALLOCATE is out of date and could go.  (It refers to a
> mix of things you eliminated and things that were already gone.)

What does the line even mean?  Some comment about stack usage?
I think we have a look that looks for large stack frames.  I wonder how
to run it...

>
> Less minor:
> You remove use of the imp_lock when reading the connection count.  While that'll work on x86, it's probably wrong on some architecture to read that without taking the lock...?

It was my understanding that on all architectures which Linux support, a
32bit aligned read is atomic wrt any 32bit write.  I have trouble imagining how
it could be otherwise.

I probably should have highlighted the removal of the spinlock in the
patch description though - it was intentional.

>
> Bug:
> The existing code uses the imp_conn_cnt from *before* the wait, rather
> than after.  I think that's quite important.  So you'll want to read
> it out before the wait.  I think the main reason we'd hit the timeout
> is a disconnect, which should cause a reconnect, so it's very
> important to use the value from *before* the wait.  (See comment on
> ptlrpc_set_import_discon for more of an explanation.  Basically it's
> tracking a connection 'epoch', if it's changed, someone else already
> went through the reconnect code for this 'connection epoch' and we
> shouldn't start that process.)
>

That wasn't intentional though - thanks for catching!
Looking at  ptlrpc_set_import_discon(), which is where the number
eventually gets used, it is only used to compare with the new value of
imp->imp_conn_cnt.

This would fix both (assuming the locking issue needs fixing).

Thanks,
NeilBrown

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f1233d844bbd..c3c9186b74ce 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -103,7 +103,7 @@ static int ldlm_request_bufsize(int count, int type)
         return sizeof(struct ldlm_request) + avail;
 }

-static void ldlm_expired_completion_wait(struct ldlm_lock *lock, struct obd_import *imp2)
+static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
 {
         struct obd_import *imp;
         struct obd_device *obd;
@@ -129,7 +129,7 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, struct obd_impo

         obd = lock->l_conn_export->exp_obd;
         imp = obd->u.cli.cl_import;
-       ptlrpc_fail_import(imp, imp2 ? imp2->imp_conn_cnt : 0);
+       ptlrpc_fail_import(imp, conn_cnt);
         LDLM_ERROR(lock,
                    "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
                    (s64)lock->l_last_activity,
@@ -241,6 +241,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
         struct obd_device *obd;
         struct obd_import *imp = NULL;
         __u32 timeout;
+       __u32 conn_cnt = 0;
         int rc = 0;

         if (flags == LDLM_FL_WAIT_NOREPROC) {
@@ -268,6 +269,11 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)

         lock->l_last_activity = ktime_get_real_seconds();

+       if (imp) {
+               spin_lock(&imp->imp_lock);
+               conn_cnt = imp->imp_conn_cnt;
+               spin_unlock(&imp->imp_lock);
+       }
         if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
                                  OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
                 ldlm_set_fail_loc(lock);
@@ -280,7 +286,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
                                                      is_granted_or_cancelled(lock),
                                                      timeout * HZ);
                         if (rc == 0)
-                               ldlm_expired_completion_wait(lock, imp);
+                               ldlm_expired_completion_wait(lock, conn_cnt);
                 }
                 /* Now wait abortable */
                 if (rc == 0)
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180213/004b9baa/attachment.html>
