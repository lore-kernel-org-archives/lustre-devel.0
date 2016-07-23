From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:08 -0400
Subject: [lustre-devel] [PATCH 11/15] staging/lustre: Always return EEXIST
	on mkdir for existing names
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-12-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

if the name already exists, but we don't have write permissions
in the parent, force talking to the MDS to determine what
more sensical error code to return.
This also happens to fix matlab and other such programs that
assume that EEXIST is the only valid error code for mkdir of
an existing directory.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/namei.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2c4dc69..d219d06 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -541,8 +541,12 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),flags=%u\n",
 	       dentry, PFID(ll_inode2fid(parent)), parent, flags);
 
-	/* Optimize away (CREATE && !OPEN). Let .create handle the race. */
-	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN))
+	/* Optimize away (CREATE && !OPEN). Let .create handle the race.
+	 * but only if we have write permissions there, otherwise we need
+	 * to proceed with lookup. LU-4185
+	 */
+	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN) &&
+	    (inode_permission(parent, MAY_WRITE | MAY_EXEC) == 0))
 		return NULL;
 
 	if (flags & (LOOKUP_PARENT|LOOKUP_OPEN|LOOKUP_CREATE))
-- 
2.7.4
