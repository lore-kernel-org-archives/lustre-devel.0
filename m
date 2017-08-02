From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: llite: fix incorrect
 DCACHE_DISCONNECTED test
In-Reply-To: <150164273003.13199.7841976922211510658.stgit@noble>
References: <150164273003.13199.7841976922211510658.stgit@noble>
Message-ID: <150164317832.13199.6113390117004813683.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

It is almost always wrong to test DCACHE_DISCONNECTED, except in
"exportfs" code.
The flag tells us that this dentry *might* not be connected to the
root through a chain of d_parent links.  Following the d_parent
to an IS_ROOT() dentry *might* find one that is on the s_anon list
rather than s_root.

The code here needs to know if it is safe to call __d_drop(), and
the correct test is "!IS_ROOT(dentry)".
If an dentry IS_ROOT(), then it might be the filesystem root, or it
might be the root of a DCACHE_DISCONNECTED tree, and so be on
the s_anon list.  In these two cases it should not be __d_drop()ed.
If !IS_ROOT(), then the dentry is attached to its parent through
d_subdir, and can safely be unhashed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd3311abf999..4854985bf4d3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1299,7 +1299,7 @@ static inline void d_lustre_invalidate(struct dentry *dentry, int nested)
 	 * If we unhashed such a dentry, unmount would not be able to find
 	 * it and busy inodes would be reported.
 	 */
-	if (d_count(dentry) == 0 && !(dentry->d_flags & DCACHE_DISCONNECTED))
+	if (d_count(dentry) == 0 && !IS_ROOT(dentry))
 		__d_drop(dentry);
 	spin_unlock(&dentry->d_lock);
 }
