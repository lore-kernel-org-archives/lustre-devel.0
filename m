Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DEE84C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 673AC201112;
	Sun, 28 Nov 2021 15:28:17 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 73785200EC0
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:03 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C59EB26F;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BEE61C1ACE; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:52 -0500
Message-Id: <1638142074-5945-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/19] lustre: llite: mend the
 trunc_sem_up_write()
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

The original lli_trunc_sem replace change (commit ae9e437745) fixed a
lock scenario:

t1 (page fault)          t2 (dio read)              t3 (truncate)
|- vm_mmap_pgoff()       |- vvp_io_read_start()     |- vvp_io_setattr
|- down_write(mmap_sem)  |- down_read(trunc_sem)            _start()
|- do_map()              |- ll_direct_IO_impl()
|- vvp_io_fault_start    |- ll_get_user_pages()

                                                    |- down_write(
                         |- down_read(mmap_sem)        trunc_sem)
|- down_read(trunc_sem)

t1 waits for read semaphore of trunc_sem which is hindered by t3,
since t3 is waiting for the write semaphore while t2 take its read
semaphore,and t2 is waiting for mmap_sem which has been taken by t1,
and a deadlock ensues.

commit ae9e437745 changes the down_read(trunc_sem) to
trunc_sem_down_read_nowait() in page fault path, to make it ignore
that there is a down_write(trunc_sem) waiting, just takes the read
semaphore if no writer has taken the semaphore, and breaks the
deadlock.

But there is a delicacy in using wake_up_var(), wake_up_var()->
__wake_up_bit()->waitqueue_active() locklessly test for waiters on the
queue, and if it's called without explicit smp_mb() it's possible for
the waitqueue_active() to ge hoisted before the condition store such
that we'll observe an empty wait list and the waiter might not
observe the condition, and the waiter won't get woke up whereafter.

Fixes: ae9e437745 ("lustre: llite: replace lli_trunc_sem")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14713
Lustre-commit: 39745c8b5493159bb ("LU-14713 llite: mend the trunc_sem_up_write()")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43844
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 7768c99..ce7431f 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -365,6 +365,8 @@ static inline void trunc_sem_down_write(struct ll_trunc_sem *sem)
 static inline void trunc_sem_up_write(struct ll_trunc_sem *sem)
 {
 	atomic_set(&sem->ll_trunc_readers, 0);
+	/* match the smp_mb() in wait_var_event()->prepare_to_wait() */
+	smp_mb();
 	wake_up_var(&sem->ll_trunc_readers);
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
