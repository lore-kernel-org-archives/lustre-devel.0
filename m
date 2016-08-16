From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:24 -0400
Subject: [lustre-devel] [PATCH 71/80] staging: lustre: llite: remove assert
	for acl refcount
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-72-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The purpose of this asssert to was to ensure lustre
was properly managing its posix_acl access. This test
is invalid due to the VFS layer also taking references
on the posix_acl. In reality their is no simple way to
detect this class of mistakes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index da00fbd..64c8a2b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1247,7 +1247,6 @@ void ll_clear_inode(struct inode *inode)
 
 #ifdef CONFIG_FS_POSIX_ACL
 	if (lli->lli_posix_acl) {
-		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
 	}
-- 
1.7.1
