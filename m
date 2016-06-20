From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:42 -0400
Subject: [lustre-devel] [PATCH 27/28] staging/lustre: Add documentation for
	unstable_stats in sysfs
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

commit ac5b14810952 ("staging: lustre: osc: Track and limit
"unstable" pages") added a new sysfs variable, but corresponding bit of
documentation was not forgotten.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/sysfs-fs-lustre | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/staging/lustre/sysfs-fs-lustre b/drivers/staging/lustre/sysfs-fs-lustre
index 873e2cf..20206ba 100644
--- a/drivers/staging/lustre/sysfs-fs-lustre
+++ b/drivers/staging/lustre/sysfs-fs-lustre
@@ -294,6 +294,14 @@ Description:
 		Controls extended attributes client-side cache.
 		1 to enable, 0 to disable.
 
+What:		/sys/fs/lustre/llite/<fsname>-<uuid>/unstable_stats
+Date:		Apr 2016
+Contact:	"Oleg Drokin" <oleg.drokin@intel.com>
+Description:
+		Shows number of pages that were sent and acknowledged by
+		server but were not yet committed and therefore still
+		pinned in client memory even though no longer dirty.
+
 What:		/sys/fs/lustre/ldlm/cancel_unused_locks_before_replay
 Date:		May 2015
 Contact:	"Oleg Drokin" <oleg.drokin@intel.com>
-- 
2.7.4
