From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:56 -0500
Subject: [lustre-devel] [PATCH 18/19] staging: lustre: lnet: use BIT macro
	in LNet selftest
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Some of the defines for lnet selftest can use the BIT
macros.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/timer.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index a4b723b..2fe692d 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -46,9 +46,9 @@
  * to cover a time period of 1024 seconds into the future before wrapping.
  */
 #define STTIMER_MINPOLL        3	/* log2 min poll interval (8 s) */
-#define STTIMER_SLOTTIME       (1 << STTIMER_MINPOLL)
+#define STTIMER_SLOTTIME	BIT(STTIMER_MINPOLL)
 #define STTIMER_SLOTTIMEMASK   (~(STTIMER_SLOTTIME - 1))
-#define STTIMER_NSLOTS	       (1 << 7)
+#define STTIMER_NSLOTS		BIT(7)
 #define STTIMER_SLOT(t)	       (&stt_data.stt_hash[(((t) >> STTIMER_MINPOLL) & \
 						    (STTIMER_NSLOTS - 1))])
 
-- 
1.7.1
