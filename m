From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 24 Aug 2016 11:11:56 -0400
Subject: [lustre-devel] [PATCH v2 6/8] staging/lustre/llite: changes to
	avoid cache corruption
In-Reply-To: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
References: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1472051518-745466-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lokesh Nagappa Jaliminche <lokesh.jaliminche@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Lokesh Nagappa Jaliminche <lokesh.jaliminche@seagate.com>

ll_find_alias is responsible for getting alias for inode
which can be reused. Directories are assumed to have unique
alias, where in case of non-directories there can be multiple
aliases. In case of lustre there can be two type of aliases
i.e. discon_alias and invalid_alias. Usage of discon_alias in
case of non-directories may corrupt dcache and leads to kernel
crash. Changes made to avoid use of discon_alias in case of
non-directories.

Seagate-bug-id: MRP-2739, MRP-3601
Signed-off-by: Lokesh Nagappa Jaliminche <lokesh.jaliminche@seagate.com>
Reviewed-by: Ujjwal Lanjewar <ujjwal.lanjewar@seagate.com>
Reviewed-by: Ashish Purkar <ashish.purkar@seagate.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Tested-by: Parinay Vijayprakash Kondekar <parinay.kondekar@seagate.com>
Reviewed-on: http://review.whamcloud.com/17732
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7613
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 788a3f0..b7d448f 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -363,7 +363,8 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 		LASSERT(alias != dentry);
 
 		spin_lock(&alias->d_lock);
-		if (alias->d_flags & DCACHE_DISCONNECTED)
+		if ((alias->d_flags & DCACHE_DISCONNECTED) &&
+		    S_ISDIR(inode->i_mode))
 			/* LASSERT(last_discon == NULL); LU-405, bz 20055 */
 			discon_alias = alias;
 		else if (alias->d_parent == dentry->d_parent	     &&
-- 
2.7.4
