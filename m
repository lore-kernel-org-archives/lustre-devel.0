From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:30 -0400
Subject: [lustre-devel] [PATCH 13/13] Add James Simmons as another Lustre
	maintainer
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

James Simmons is also spendign a lot of efforts on
cleaning up staging tree Lustre code and also
helps to sync up all the missing changes from the other tree.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index a306795..f277cfd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11154,6 +11154,7 @@ F:	drivers/staging/media/lirc/
 STAGING - LUSTRE PARALLEL FILESYSTEM
 M:	Oleg Drokin <oleg.drokin@intel.com>
 M:	Andreas Dilger <andreas.dilger@intel.com>
+M:	James Simmons <jsimmons@infradead.org>
 L:	lustre-devel at lists.lustre.org (moderated for non-subscribers)
 W:	http://wiki.lustre.org/
 S:	Maintained
-- 
2.7.4
