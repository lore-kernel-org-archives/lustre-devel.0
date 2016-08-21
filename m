From: Shawn Lin <shawn.lin@rock-chips.com>
Date: Sun, 21 Aug 2016 10:44:37 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: llite: don't clean in_data
	again
Message-ID: <1471747477-31654-1-git-send-email-shawn.lin@rock-chips.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Shawn Lin <shawn.lin@rock-chips.com>

We have got a zero buffer for in_data as we use
kzalloc here. So let's remove it anyway.

Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
---

 drivers/staging/lustre/lustre/llite/file.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 50938bd..ec6b7ce 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3251,7 +3251,6 @@ void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd)
 	if (!in_data)
 		return NULL;
 
-	memset(in_data, 0, sizeof(*in_data));
 	in_data->iocd_size = size;
 	in_data->iocd_cb = cb;
 	in_data->iocd_count = count;
-- 
2.3.7
