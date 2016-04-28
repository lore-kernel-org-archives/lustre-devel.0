From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:17 -0400
Subject: [lustre-devel] [PATCH 08/12] staging: lustre: llite: debugging for
	ll_file_open LASSERT
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Add debugging for LASSERTF(it_disposition(it, DISP_ENQ_OPEN_REF)
in ll_file_open(), since this is a rarely hit failure under racer,
and it would be useful to get more information if this is hit
again.  Print the full intent disposition, as well as the status,
in case Oleg's earlier comment about bailing out on any error is
actually the case here.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1993
Reviewed-on: http://review.whamcloud.com/6250
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a8de10e..f47f2ac 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -679,7 +679,9 @@ restart:
 		if (rc)
 			goto out_och_free;
 
-		LASSERT(it_disposition(it, DISP_ENQ_OPEN_REF));
+		LASSERTF(it_disposition(it, DISP_ENQ_OPEN_REF),
+			 "inode %p: disposition %x, status %d\n", inode,
+			 it_disposition(it, ~0), it->d.lustre.it_status);
 
 		rc = ll_local_open(file, it, fd, *och_p);
 		if (rc)
-- 
2.7.4
