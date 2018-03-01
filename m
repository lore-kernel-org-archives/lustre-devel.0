From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 12/17] staging: lustre: remove unused flag
 from ptlrpc_thread
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708545.7628.17939519532029157797.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

SVC_EVENT is no longer used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 5a4434e7c85a..108683c54127 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1259,7 +1259,6 @@ enum {
 	SVC_STOPPING    = 1 << 1,
 	SVC_STARTING    = 1 << 2,
 	SVC_RUNNING     = 1 << 3,
-	SVC_EVENT       = 1 << 4,
 };
 
 #define PTLRPC_THR_NAME_LEN		32
@@ -1302,11 +1301,6 @@ struct ptlrpc_thread {
 	char				t_name[PTLRPC_THR_NAME_LEN];
 };
 
-static inline int thread_is_init(struct ptlrpc_thread *thread)
-{
-	return thread->t_flags == 0;
-}
-
 static inline int thread_is_stopped(struct ptlrpc_thread *thread)
 {
 	return !!(thread->t_flags & SVC_STOPPED);
@@ -1327,11 +1321,6 @@ static inline int thread_is_running(struct ptlrpc_thread *thread)
 	return !!(thread->t_flags & SVC_RUNNING);
 }
 
-static inline int thread_is_event(struct ptlrpc_thread *thread)
-{
-	return !!(thread->t_flags & SVC_EVENT);
-}
-
 static inline void thread_clear_flags(struct ptlrpc_thread *thread, __u32 flags)
 {
 	thread->t_flags &= ~flags;
