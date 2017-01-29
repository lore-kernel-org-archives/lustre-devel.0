From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:03 -0500
Subject: [lustre-devel] [PATCH 35/60] staging: lustre: lov: ld_target could
	be NULL
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

lov_device::ld_target[ost_idx] could be NULL if the OST target is
not filled in lov_device::ld_lov::lov_tgt_desc[ost_idx] yet.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8018
Reviewed-on: http://review.whamcloud.com/21411
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 9c4b5ab..977579c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -266,6 +266,13 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			if (result != 0)
 				goto out;
 
+			if (!dev->ld_target[ost_idx]) {
+				CERROR("%s: OST %04x is not initialized\n",
+				lov2obd(dev->ld_lov)->obd_name, ost_idx);
+				result = -EIO;
+				goto out;
+			}
+
 			subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
 			subconf->u.coc_oinfo = oinfo;
 			LASSERTF(subdev, "not init ost %d\n", ost_idx);
-- 
1.8.3.1
