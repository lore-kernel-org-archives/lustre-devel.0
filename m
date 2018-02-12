From: Patrick Farrell <paf@cray.com>
Date: Mon, 12 Feb 2018 22:08:56 +0000
Subject: [lustre-devel] [PATCH 08/19] staging: lustre: simplify waiting
 in ldlm_completion_ast()
In-Reply-To: <151847055674.22826.12912356108048917428.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
 <151847055674.22826.12912356108048917428.stgit@noble>
Message-ID: <4AC4BB93-85C5-4CA1-B062-1274833C51C6@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas
 Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Neil,

I didn't get anything after 8/19 in this series.  Is this just me?  (I'd keep waiting, except I also found a few things in this patch.)

Minor:
The line XXX ALLOCATE is out of date and could go.  (It refers to a mix of things you eliminated and things that were already gone.)

Less minor:
You remove use of the imp_lock when reading the connection count.  While that'll work on x86, it's probably wrong on some architecture to read that without taking the lock...?

Bug:
The existing code uses the imp_conn_cnt from *before* the wait, rather than after.  I think that's quite important.  So you'll want to read it out before the wait.  I think the main reason we'd hit the timeout is a disconnect, which should cause a reconnect, so it's very important to use the value from *before* the wait.  (See comment on ptlrpc_set_import_discon for more of an explanation.  Basically it's tracking a connection 'epoch', if it's changed, someone else already went through the reconnect code for this 'connection epoch' and we shouldn't start that process.)

- Patrick

?On 2/12/18, 3:24 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

    If a signal-callback (lwi_on_signal) is set without lwi_allow_intr, as
    is the case in ldlm_completion_ast(), the behavior depends on the
    timeout set.
    
    If a timeout is set, then signals are ignored.  If the timeout is
    reached, the timeout handler is called.  If the timeout handler
    return 0, which ldlm_expired_completion_wait() always does, the
    l_wait_event() switches to exactly the behavior if no timeout was set.
    
    If no timeout is set, then "fatal" signals are not ignored.  If one
    arrives the callback is run, but as the callback is empty in this
    case, that is not relevant.
    
    This can be simplified to:
     if a timeout is wanted
         wait_event_idle_timeout()
         if that timed out, call the timeout handler
     l_wait_event_abortable()
    
    i.e. the code always waits indefinitely.  Sometimes it performs a
    non-abortable wait first.  Sometimes it doesn't.  But it only
    aborts before the condition is true if it is signaled.
    This doesn't quite agree with the comments and debug messages.
    
    Reviewed-by: James Simmons <jsimmons@infradead.org>
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lustre/ldlm/ldlm_request.c |   55 +++++++--------------
     1 file changed, 18 insertions(+), 37 deletions(-)
    
    diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
    index a244fa717134..f1233d844bbd 100644
    --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
    +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
    @@ -72,15 +72,6 @@ MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
     /* in client side, whether the cached locks will be canceled before replay */
     unsigned int ldlm_cancel_unused_locks_before_replay = 1;
     
    -static void interrupted_completion_wait(void *data)
    -{
    -}
    -
    -struct lock_wait_data {
    -	struct ldlm_lock *lwd_lock;
    -	__u32	     lwd_conn_cnt;
    -};
    -
     struct ldlm_async_args {
     	struct lustre_handle lock_handle;
     };
    @@ -112,10 +103,8 @@ static int ldlm_request_bufsize(int count, int type)
     	return sizeof(struct ldlm_request) + avail;
     }
     
    -static int ldlm_expired_completion_wait(void *data)
    +static void ldlm_expired_completion_wait(struct ldlm_lock *lock, struct obd_import *imp2)
     {
    -	struct lock_wait_data *lwd = data;
    -	struct ldlm_lock *lock = lwd->lwd_lock;
     	struct obd_import *imp;
     	struct obd_device *obd;
     
    @@ -135,19 +124,17 @@ static int ldlm_expired_completion_wait(void *data)
     			if (last_dump == 0)
     				libcfs_debug_dumplog();
     		}
    -		return 0;
    +		return;
     	}
     
     	obd = lock->l_conn_export->exp_obd;
     	imp = obd->u.cli.cl_import;
    -	ptlrpc_fail_import(imp, lwd->lwd_conn_cnt);
    +	ptlrpc_fail_import(imp, imp2 ? imp2->imp_conn_cnt : 0);
     	LDLM_ERROR(lock,
     		   "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
     		   (s64)lock->l_last_activity,
     		   (s64)(ktime_get_real_seconds() - lock->l_last_activity),
     		   obd2cli_tgt(obd), imp->imp_connection->c_remote_uuid.uuid);
    -
    -	return 0;
     }
     
     /**
    @@ -251,10 +238,8 @@ EXPORT_SYMBOL(ldlm_completion_ast_async);
     int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
     {
     	/* XXX ALLOCATE - 160 bytes */
    -	struct lock_wait_data lwd;
     	struct obd_device *obd;
     	struct obd_import *imp = NULL;
    -	struct l_wait_info lwi;
     	__u32 timeout;
     	int rc = 0;
     
    @@ -281,32 +266,28 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
     
     	timeout = ldlm_cp_timeout(lock);
     
    -	lwd.lwd_lock = lock;
     	lock->l_last_activity = ktime_get_real_seconds();
     
    -	if (ldlm_is_no_timeout(lock)) {
    -		LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
    -		lwi = LWI_INTR(interrupted_completion_wait, &lwd);
    -	} else {
    -		lwi = LWI_TIMEOUT_INTR(timeout * HZ,
    -				       ldlm_expired_completion_wait,
    -				       interrupted_completion_wait, &lwd);
    -	}
    -
    -	if (imp) {
    -		spin_lock(&imp->imp_lock);
    -		lwd.lwd_conn_cnt = imp->imp_conn_cnt;
    -		spin_unlock(&imp->imp_lock);
    -	}
    -
     	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
     				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
     		ldlm_set_fail_loc(lock);
     		rc = -EINTR;
     	} else {
    -		/* Go to sleep until the lock is granted or cancelled. */
    -		rc = l_wait_event(lock->l_waitq,
    -				  is_granted_or_cancelled(lock), &lwi);
    +		/* Go to sleep until the lock is granted or canceled. */
    +		if (!ldlm_is_no_timeout(lock)) {
    +			/* Wait uninterruptible for a while first */
    +			rc = wait_event_idle_timeout(lock->l_waitq,
    +						     is_granted_or_cancelled(lock),
    +						     timeout * HZ);
    +			if (rc == 0)
    +				ldlm_expired_completion_wait(lock, imp);
    +		}
    +		/* Now wait abortable */
    +		if (rc == 0)
    +			rc = l_wait_event_abortable(lock->l_waitq,
    +						    is_granted_or_cancelled(lock));
    +		else
    +			rc = 0;
     	}
     
     	if (rc) {
    
    
    _______________________________________________
    lustre-devel mailing list
    lustre-devel at lists.lustre.org
    http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
    
