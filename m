From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:23 -0500
Subject: [lustre-devel] [PATCH 16/22] staging: lustre: llite: Invoke
	file_update_time in page_mkwrite
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

Only update file times if page_mkwrite is not set. So we
need call file_update_time by ourselves.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1118
Reviewed-on: http://review.whamcloud.com/18683
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index f50b6c1..ee01f20 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -369,6 +369,7 @@ static int ll_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	bool retry;
 	int result;
 
+	file_update_time(vma->vm_file);
 	do {
 		retry = false;
 		result = ll_page_mkwrite0(vma, vmf->page, &retry);
-- 
1.7.1
