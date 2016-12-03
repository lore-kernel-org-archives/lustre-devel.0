From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:28 -0500
Subject: [lustre-devel] [PATCH 21/22] staging: lustre: remove set but unused
	variables
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

Remove set but unused variables in nidstring.c
and osc_request.c as reported by make W=1.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8378
Reviewed-on: http://review.whamcloud.com/23221
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c   |    2 --
 drivers/staging/lustre/lustre/osc/osc_request.c |    3 +--
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index e1f1ca8..a9fe3e6 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -247,10 +247,8 @@ struct addrrange {
 {
 	struct cfs_lstr addrrange;
 	struct cfs_lstr net;
-	struct cfs_lstr tmp;
 	struct nidrange *nr;
 
-	tmp = *src;
 	if (!cfs_gettok(src, '@', &addrrange))
 		goto failed;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0977127..0c50225 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -933,7 +933,6 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 	int i = 0;
 	struct cfs_crypto_hash_desc *hdesc;
 	unsigned int bufsize;
-	int err;
 	unsigned char cfs_alg = cksum_obd2cfs(cksum_type);
 
 	LASSERT(pg_count > 0);
@@ -975,7 +974,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 	}
 
 	bufsize = sizeof(cksum);
-	err = cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
+	cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
 
 	/* For sending we only compute the wrong checksum instead
 	 * of corrupting the data so it is still correct on a redo
-- 
1.7.1
