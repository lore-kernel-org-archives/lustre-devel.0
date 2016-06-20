From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:39 -0400
Subject: [lustre-devel] [PATCH 24/28] staging/lustre/llite:
	ll_revalidate_dentry update
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <oleg.drokin@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <oleg.drokin@intel.com>

There are a couple of cases in ll_revalidate_dentry() where
we are pretty sure the dentry is valid, so check for them early
and save more expensive checks for later.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dcache.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index d964f4f..581a63a 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -302,6 +302,17 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 {
 	struct inode *dir = d_inode(dentry->d_parent);
 
+	/* If this is intermediate component path lookup and we were able to get
+	 * to this dentry, then its lock has not been revoked and the
+	 * path component is valid.
+	 */
+	if (lookup_flags & LOOKUP_PARENT)
+		return 1;
+
+	/* Symlink - always valid as long as the dentry was found */
+	if (dentry->d_inode && S_ISLNK(dentry->d_inode->i_mode))
+		return 1;
+
 	/*
 	 * if open&create is set, talk to MDS to make sure file is created if
 	 * necessary, because we can't do this in ->open() later since that's
-- 
2.7.4
