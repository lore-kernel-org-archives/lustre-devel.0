From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 24 Aug 2016 11:11:57 -0400
Subject: [lustre-devel] [PATCH v2 7/8] staging/lustre: release MGC device if
	connect fails
In-Reply-To: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
References: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1472051518-745466-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

In lustre_fill_super() if lustre_start_mgc() fails then call
lustre_common_put_super() to release a reference on the MGC device
attached to the LSI.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/20851
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8297
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index ae702ce..0273768 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1144,7 +1144,7 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 		} else {
 			rc = lustre_start_mgc(sb);
 			if (rc) {
-				lustre_put_lsi(sb);
+				lustre_common_put_super(sb);
 				goto out;
 			}
 			/* Connect and start */
-- 
2.7.4
