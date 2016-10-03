From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:17 -0400
Subject: [lustre-devel] [PATCH 21/41] staging: lustre: mdc: Removed unneeded
	NULL check
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Do not bother checking the return value of changelog_kuc_hdr()
against NULL since this value was dereferenced earlier.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4189
Reviewed-on: http://review.whamcloud.com/12919
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index d996326..206f5d0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1867,10 +1867,8 @@ static int mdc_changelog_send_thread(void *csdata)
 
 	/* Send EOF no matter what our result */
 	kuch = changelog_kuc_hdr(cs->cs_buf, sizeof(*kuch), cs->cs_flags);
-	if (kuch) {
-		kuch->kuc_msgtype = CL_EOF;
-		libcfs_kkuc_msg_put(cs->cs_fp, kuch);
-	}
+	kuch->kuc_msgtype = CL_EOF;
+	libcfs_kkuc_msg_put(cs->cs_fp, kuch);
 
 out:
 	fput(cs->cs_fp);
-- 
1.7.1
