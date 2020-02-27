From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:22 -0500
Subject: [lustre-devel] [PATCH 514/622] lustre: llite: Don't clear d_fsdata
 in ll_release()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-515-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

The whole point of using rcu_free() is that some code might
still be accessing the dentry (e.g. lockless lookup) and so
the dentry cannot be freed until the end of the grace
period.

As lockless lookup can accesses d_fsdata -- ll_dcompare calls
d_lustre_invalid() -- we also mustn't clear d_fsdata before
the end of the grace period.
We don't need to clear it at all - by the time it is freed,
the inode will no longer be accessed.

Fixes: 7126bc2e8d60c ("lustre: switch to use of ->d_init()")

Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/llite/dcache.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 2dfe12a..3230d32 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -63,7 +63,6 @@ static void ll_release(struct dentry *de)
 		kfree(lld->lld_it);
 	}
 
-	de->d_fsdata = NULL;
 	call_rcu(&lld->lld_rcu_head, free_dentry_data);
 }
 
-- 
1.8.3.1
