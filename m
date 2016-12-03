From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:18 -0500
Subject: [lustre-devel] [PATCH 11/22] staging: lustre: mdt: fail FMODE_WRITE
	open if the client is read only
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Dongyang <dongyang.li@anu.edu.au>, James Simmons <jsimmons@infradead.org>

From: Li Dongyang <dongyang.li@anu.edu.au>

O_WRONLY/O_RDWR open on a file will get EROFS on a read only client,
but the rpc gets sent to the mdt anyway.
mdt will increase the mot_write_count of the mdt object, blocking
subsequent FMODE_EXEC open to the same file.

This patch makes sure we fail the FMODE_WRITE open with EROFS on the
client straight away without sending the rpc to mdt.

Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7727
Reviewed-on: http://review.whamcloud.com/18242
Reviewed-by: Ian Costello <icostello@ddn.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index b07079c..9426759 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -572,6 +572,10 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		}
 	}
 
+	if (it->it_op & IT_OPEN && it->it_flags & FMODE_WRITE &&
+	    dentry->d_sb->s_flags & MS_RDONLY)
+		return ERR_PTR(-EROFS);
+
 	if (it->it_op & IT_CREAT)
 		opc = LUSTRE_OPC_CREATE;
 	else
-- 
1.7.1
