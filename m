From: Joe Perches <joe@perches.com>
Date: Mon, 15 Aug 2016 12:33:23 -0700
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Add include path to
	Makefile
In-Reply-To: <cover.1471289489.git.joe@perches.com>
References: <cover.1471289489.git.joe@perches.com>
Message-ID: <5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Start to rationalize include paths in source code files.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/staging/lustre/Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/lustre/Makefile b/drivers/staging/lustre/Makefile
index 95ffe33..9d00237 100644
--- a/drivers/staging/lustre/Makefile
+++ b/drivers/staging/lustre/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include/
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
+
 obj-$(CONFIG_LNET)		+= lnet/
 obj-$(CONFIG_LUSTRE_FS)		+= lustre/
-- 
2.8.0.rc4.16.g56331f8
