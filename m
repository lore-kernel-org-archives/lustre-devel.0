From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:09 -0700
Subject: [lustre-devel] [PATCH 11/12] time: Delete CURRENT_TIME_SEC and
	CURRENT_TIME
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-12-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: bfields@fieldses.org, clm@fb.com, linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net, tglx@linutronix.de, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, paul@paul-moore.com, y2038@lists.linaro.org, mingo@redhat.com, jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org, oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org, andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org, samba-technical@lists.samba.org, eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-audit@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, davem@davemloft.net, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

All uses of CURRENT_TIME_SEC and CURRENT_TIME macros have
been replaced by other time functions. These macros are
also not y2038 safe.
And, all their use cases can be fulfilled by y2038 safe
ktime_get_* variants.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Acked-by: John Stultz <john.stultz@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/time.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index 23f0f5c..c0543f5 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -151,9 +151,6 @@ static inline bool timespec_inject_offset_valid(const struct timespec *ts)
 	return true;
 }
 
-#define CURRENT_TIME		(current_kernel_time())
-#define CURRENT_TIME_SEC	((struct timespec) { get_seconds(), 0 })
-
 /* Some architectures do not supply their own clocksource.
  * This is mainly the case in architectures that get their
  * inter-tick times by reading the counter on their interval
-- 
2.7.4
