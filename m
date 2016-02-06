From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sat,  6 Feb 2016 02:12:12 -0500
Subject: [lustre-devel] [PATCH] staging/lustre/lnet: Don't call
	roundup_pow_of_two on zero in LNetEQAlloc
Message-ID: <1454742732-2232567-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Pekka Enberg <penberg@kernel.org>

From: Oleg Drokin <green@linuxhacker.ru>

roundup_pow_of_two return when called on a zero argument is
undefined, so don't call it like that.

This fixes a problem introduced by commit 322489d9d551
("staging/lustre: Use roundup_pow_of_two() in LNetEQAlloc()")
since 0 is a valid count parameter for LNetEQAlloc. Also manifesting
itself as an annoying kernel warning:
LNet: 3486:0:(lib-eq.c:85:LNetEQAlloc()) EQ callback is guaranteed to get every event, do you still want to set eqcount 1 for polling event which will have locking overhead? Please contact with developer to confirm

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
CC: Pekka Enberg <penberg@kernel.org>
---
 drivers/staging/lustre/lnet/lnet/lib-eq.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 64f94a6..bfbc313 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -79,7 +79,8 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	 * overflow, they don't skip entries, so the queue has the same
 	 * apparent capacity at all times */
 
-	count = roundup_pow_of_two(count);
+	if (count)
+		count = roundup_pow_of_two(count);
 
 	if (callback != LNET_EQ_HANDLER_NONE && count != 0)
 		CWARN("EQ callback is guaranteed to get every event, do you still want to set eqcount %d for polling event which will have locking overhead? Please contact with developer to confirm\n", count);
-- 
2.1.0
