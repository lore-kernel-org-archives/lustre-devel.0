From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:45 -0400
Subject: [lustre-devel] [PATCH 06/42] lnet: use init_wait(),
 not init_waitqueue_entry()
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

    init_waitqueue_entry(foo, current)

is equivalent to

    init_wait(foo)

So use the shorter version - in lustre and libcfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: f6aa7a46d36b3 ("LU-6142 lustre: use init_wait(), not init_waitqueue_entry()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39300
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index f896321..14fcb2a 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -1167,7 +1167,7 @@ static int tracefiled(void *arg)
 				break;
 			}
 		}
-		init_waitqueue_entry(&__wait, current);
+		init_wait(&__wait);
 		add_wait_queue(&tctl->tctl_waitq, &__wait);
 		schedule_timeout_interruptible(HZ);
 		remove_wait_queue(&tctl->tctl_waitq, &__wait);
-- 
1.8.3.1
