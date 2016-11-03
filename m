From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:51 -0400
Subject: [lustre-devel] [PATCH 01/14] staging/lustre/ldlm: Drop unused
	blocking_refs flock field
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

blocking_refs is only used on the server, so drop it on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 1c6b7b8..f770b86 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -550,8 +550,6 @@ struct ldlm_flock {
 	__u64 owner;
 	__u64 blocking_owner;
 	struct obd_export *blocking_export;
-	/* Protected by the hash lock */
-	__u32 blocking_refs;
 	__u32 pid;
 };
 
-- 
2.7.4
