From: Patrick Farrell <paf@cray.com>
Date: Wed, 6 May 2015 19:04:39 +0000
Subject: [lustre-devel] Lock ahead: LDLM_FL_LVB_READY & osc_lock_lvb_update
	questions
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614C42E9E@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Following on from my previous message.

In ldlm_lock_match, interestingly, the other threads do not (initially)
wait for the matched lock to be granted; instead, they first wait for
the LVB_READY flag to be set.  This flag is set only after a lock is granted,
so it's used as a proxy for the granted/waiting state of a lock.

However, getting this set correctly for async lock requests is a problem.
LDLM_FL_LVB_READY is only set (for extent locks) by osc_lock_lvb_update,
which is called from osc_lock_upcall/osc_lock_upcall_speculative (either directly
or via osc_lock_granted, but still from the upcall).

The problem that's happening is this:
The reply is received, putting the lock on the waiting list.
The lvb is filled in ldlm_cli_enqueue_fini, but when the upcall is called,
the lock is not granted, so osc_lock_lvb_update is not called,
and LDLM_FL_LVB_READY is not set.

This is a normal sequence of events for both synchronous and async lock requests.
However, for synchronous lock requests, the original enqueueing thread sleeps
(ldlm_cli_enqueue_fini-->l_completion_ast) waiting for the lock to be granted.
Then, once the lock is granted by a CP_CALLBACK (which fills the LVB again with updated data),
the original enqueueing thread wakes up and returns up to osc_enqueue_base,
which calls osc_enqueue_fini, which calls the upcall.
Now the lock is granted, so osc_lock_lvb_update is called & LDLM_FL_LVB_READY is set.

For asynchronous lock requests, no one is waiting.  So ldlm_handle_cp_callback fills
the LVB, then grants the lock, then is done.  And so, for async locks, osc_lock_lvb_update
is not called, and LDLM_FL_LVB_READY is not set.

To recap the sequence of events required:
1. Async lock request sent
2. Reply is received, lock is not granted (upcall is called, but
osc_lock_lvb_update cannot happen because the lock is not granted)
[Normally, at this point, a synchronous lock request would sleep waiting for
the lock to be granted]
3. CP_CALLBACK is received, granting the lock.  LVB is is filled.
--> osc_lock_lvb_update is never called & LDLM_FL_LVB_READY is never set.

I thought it might be possible to call osc_lock_lvb_update in the upcall even
when the lock is not granted, but the LVB is updated on a CP_CALLBACK, so we'd
fail to update with that newer information.  Presumably that's not OK.
(also, ldlm_lock_match checks LVB_READY before checking if the lock is granted,
so that would have to change too..  But that's fairly simple.)

I've been struggling to come up with a solution to this one.
Any thoughts?

The one thought I have is calling osc_lock_lvb_update in the CP callback handler,
but that feels like a layering violation.  We'd also need some method to ensure
we didn't call osc_lock_lvb_update more than once, but that could probably be done
by checking the LDLM_FL_LVB_READY flag...?

- Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150506/f75b8d1d/attachment-0001.htm>
