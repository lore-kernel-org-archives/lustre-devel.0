From: Patrick Farrell <paf@cray.com>
Date: Wed, 6 May 2015 16:38:42 +0000
Subject: [lustre-devel] Lock ahead: ldlm_completion_ast questions
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614C42E2E@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings,

Trying the new list here, in the interest of having a bit more conversation and
design in the open.

I've been continuing work on lock ahead, and I've run in to a pair of related
problems I wanted to ask about.  I'll do them in two separate mails.

Basically, these center around ldlm_completion_ast/ldlm_completion_ast_async
and the LVB ready flag.

Here's the first one.

Because the reply to an async request is handled by the PTLRPCD thread,
async lock requests cannot use ldlm_completion_ast, because
(as Oleg so memorably told us in Denver) we can't sleep in ptlrpcd threads.

So I use ldlm_completion_ast_async for the lock ahead locks.
The problem is, now, all of the users who attempt to use the lock will use that AST.

That's a problem, because ldlm_completion_ast is where a thread that wants to
use a lock on the waiting queue sleeps until that lock is granted.
So if a lock ahead lock is on the waiting queue and another thread finds it in
ldlm_lock_match, that thread calls ldlm_completion_ast_async, and does not sleep(!)
waiting for the lock to be granted.

My first thought for how to solve this is having a separate l_completion_ast_async
pointer.  The only caller that needs (and should get) the async behavior is ptlrpcd
via osc_enqueue_interpret, so it can call that instead of l_completion_ast.

ptlrpcd uses osc_enqueue_interpret, which calls ldlm_cli_enqueue_fini, which then calls
l_completion_ast.  I think it would be enough to add an "async" argument to
ldlm_cli_enqueue_fini, and have osc_enqueue_interpret use that to make ldlm_cli_enqueue_fini
call l_completion_ast_async instead.

This would allow other users to wait correctly for lock ahead locks to be granted.

Code implementing that will be going up shortly.  (I've tested it briefly and it seems to
work.)

Does that seem reasonable?  Is there another way it would be better to approach that one?

Other question (which is a bit nastier) coming shortly.

Thanks in advance,
- Patrick Farrell
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150506/0fa9fb3a/attachment-0001.htm>
