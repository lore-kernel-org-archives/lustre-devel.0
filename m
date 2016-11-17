From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:48 -0500
Subject: [lustre-devel] [PATCH 10/19] staging: lustre: lnet: replace
	uninitialized_var
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Checkpatch for some reason doesn't like the way
libcfs_str2net_internal. Lets just replace it with
nf being set to NULL instead

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 63379f7..e1f1ca8 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -1156,7 +1156,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 static struct netstrfns *
 libcfs_str2net_internal(const char *str, __u32 *net)
 {
-	struct netstrfns *uninitialized_var(nf);
+	struct netstrfns *nf = NULL;
 	int nob;
 	unsigned int netnum;
 	int i;
-- 
1.7.1
