From: Patrick Farrell <paf@cray.com>
Date: Wed, 6 May 2015 20:09:13 +0000
Subject: [lustre-devel] Lock ahead: ldlm_completion_ast questions
In-Reply-To: <ACD32058-E74D-4F14-B938-991AE9149AA7@intel.com>
References: <DB0C8A206669AC40B1C4E52A8584A6F614C42E2E@CFWEX01.americas.cray.com>
	<D69967CE-C0D2-4624-AD4C-7D63361C3359@intel.com>
	<DB0C8A206669AC40B1C4E52A8584A6F614C42E90@CFWEX01.americas.cray.com>,
	<ACD32058-E74D-4F14-B938-991AE9149AA7@intel.com>
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614C42EF2@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

OK - I believe I will need such an AST, then.  The problem is the first few write locks will be expanded (and passed back and forth between clients), so while the read lock will be cancelled, the lock ahead locks will most likely never get a chance to actually be granted on the file.

I'll work on writing that AST.  Thanks for your reply.  (I will probably re-use the name of ldm_completion_ast_async, since that name is perfect and it's no longer used after the CLIO simplification changes.)

- Patrick
________________________________________
From: Xiong, Jinshan [jinshan.xiong at intel.com]
Sent: Wednesday, May 06, 2015 3:04 PM
To: Patrick Farrell
Cc: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] Lock ahead: ldlm_completion_ast questions

> On May 6, 2015, at 11:55 AM, Patrick Farrell <paf@cray.com> wrote:
>
> Jinshan,
>
> I discussed that aspect with our MPIIO library developers, and they felt it was important to have the option to make the lock requests blocking (IE, have them revoke existing locks on conflict).  They pointed out that the library has no way to guarantee there aren't existing locks on the file, and in fact, a whole file read lock or something similar will be very common since the file may be created (and accessed) in any way number of ways before the library gets to it.

Patrick,

Actually the whole file read lock should have been revoked by the first few write locks(not lock-ahead locks) so that it should be fine. Lock-ahead locks should be best-effort basis and shouldn?t interfere with normal process.

Anyway, if you really like to go for that way, you?re going to write a customized completion_ast() for lock-ahead locks. Three cases will be handled in this customized completion_ast():
1. lock matching - sleep for lock to be available;
2. called by os_enqueue_interpret() - invoke ldlm_reprocess_all() and returns; and if lock has already granted, then continue to do case 3;
3. lock granted - grant lock and wake up processes.

Case 2 and 3 may happen simultaneously.

Jinshan

>
> So if lock ahead locks don't have the option of being blocking lock requests, they could only be used on newly created files.  (I'm currently controlling blocking/non-blocking with a flag passed in from userspace.)
>
> - Patrick
> ________________________________________
> From: Xiong, Jinshan [jinshan.xiong at intel.com]
> Sent: Wednesday, May 06, 2015 1:42 PM
> To: Patrick Farrell
> Cc: lustre-devel at lists.lustre.org; Dilger, Andreas
> Subject: Re: Lock ahead: ldlm_completion_ast questions
>
> On May 6, 2015, at 9:38 AM, Patrick Farrell <paf at cray.com<mailto:paf@cray.com>> wrote:
>
> Greetings,
>
> Trying the new list here, in the interest of having a bit more conversation and
> design in the open.
>
> I've been continuing work on lock ahead, and I've run in to a pair of related
> problems I wanted to ask about.  I'll do them in two separate mails.
>
> Basically, these center around ldlm_completion_ast/ldlm_completion_ast_async
> and the LVB ready flag.
>
> Here's the first one.
>
> Because the reply to an async request is handled by the PTLRPCD thread,
> async lock requests cannot use ldlm_completion_ast, because
> (as Oleg so memorably told us in Denver) we can't sleep in ptlrpcd threads.
>
> So I use ldlm_completion_ast_async for the lock ahead locks.
> The problem is, now, all of the users who attempt to use the lock will use that AST.
>
> That's a problem, because ldlm_completion_ast is where a thread that wants to
> use a lock on the waiting queue sleeps until that lock is granted.
> So if a lock ahead lock is on the waiting queue and another thread finds it in
> ldlm_lock_match, that thread calls ldlm_completion_ast_async, and does not sleep(!)
> waiting for the lock to be granted.
>
> My first thought for how to solve this is having a separate l_completion_ast_async
> pointer.  The only caller that needs (and should get) the async behavior is ptlrpcd
> via osc_enqueue_interpret, so it can call that instead of l_completion_ast.
>
> ptlrpcd uses osc_enqueue_interpret, which calls ldlm_cli_enqueue_fini, which then calls
> l_completion_ast.  I think it would be enough to add an "async" argument to
> ldlm_cli_enqueue_fini, and have osc_enqueue_interpret use that to make ldlm_cli_enqueue_fini
> call l_completion_ast_async instead.
>
> This would allow other users to wait correctly for lock ahead locks to be granted.
>
> Code implementing that will be going up shortly.  (I've tested it briefly and it seems to
> work.)
>
> Does that seem reasonable?  Is there another way it would be better to approach that one?
>
> I think this problem can be solved easily by not allowing lock-ahead locks to revoke conflicting locks at enqueue time. Therefore, the result of enqueueing a lock-ahead lock is either granted or aborted due to conflicting when osc_enqueue_interpret() is called, the locks? state is determined so the regular ldlm_completion_ast() in ptlrpcd thread context won?t be blocked.
>
> Jinshan
>
>
> Other question (which is a bit nastier) coming shortly.
>
> Thanks in advance,
> - Patrick Farrell
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
