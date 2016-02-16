From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:11 -0500
Subject: [lustre-devel] [PATCH 39/45] staging/lustre: Update cfs_cpu_notify
	switch statement with a comment
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-40-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

We do really mean to fall through to that default case statement from
all previous ones, so add a comment to unconfuse verious tools

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index 6c3e448..7318b77 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
@@ -939,6 +939,7 @@ cfs_cpu_notify(struct notifier_block *self, unsigned long action, void *hcpu)
 		spin_lock(&cpt_data.cpt_lock);
 		cpt_data.cpt_version++;
 		spin_unlock(&cpt_data.cpt_lock);
+		/* Fall through */
 	default:
 		if (action != CPU_DEAD && action != CPU_DEAD_FROZEN) {
 			CDEBUG(D_INFO, "CPU changed [cpu %u action %lx]\n",
-- 
2.1.0
