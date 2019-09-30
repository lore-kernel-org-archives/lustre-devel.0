From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:21 -0400
Subject: [lustre-devel] [PATCH 002/151] lustre: fix signal handling in
 abortable waits.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Instead of blocking all but the fatal signals, we were
blocking just the fatal signals.  That wasn't what was
intended, but is easy to fix.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lib.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_lib.h b/fs/lustre/include/lustre_lib.h
index da86e46..64d2e91 100644
--- a/fs/lustre/include/lustre_lib.h
+++ b/fs/lustre/include/lustre_lib.h
@@ -93,7 +93,7 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 ({									\
 	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	siginitsetinv(&__new_blocked, LUSTRE_FATAL_SIGS);		\
 	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible(wq, condition);		\
 	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
@@ -104,7 +104,7 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 ({									\
 	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	siginitsetinv(&__new_blocked, LUSTRE_FATAL_SIGS);		\
 	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible_timeout(wq, condition, timeout);\
 	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
@@ -115,7 +115,7 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 ({									\
 	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	siginitsetinv(&__new_blocked, LUSTRE_FATAL_SIGS);		\
 	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible_exclusive(wq, condition);	\
 	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
-- 
1.8.3.1
