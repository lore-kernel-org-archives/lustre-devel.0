From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:41 -0500
Subject: [lustre-devel] [PATCH 593/622] lnet: lnet response entries leak
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-594-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

LNetPut with ACK flag called, but LNetMDUnlink issued before ACK
arrives. It can due timeout or it is application call (ldiskfs commit
for difficult replies on MDT).
It freed an MD but rsp don't detached, as ACK don't hold an reference
to the MD between request sends and ACK arrives.
monitor thread detect it situation and RSP entry moved into the zombie
list, which don't freed as no msg processed due MD absence.

Let's remove a response tracking in case nobody want to have reply aka
LNetMDUnlink called.

Cray-bug-id: LUS-8188
WC-bug-id: https://jira.whamcloud.com/browse/LU-12991
Lustre-commit: b7035222bd64 ("LU-12991 lnet: lnet response entries leak")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/36896
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 2 ++
 net/lnet/lnet/lib-md.c        | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3b597e3..bf357b0 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -157,6 +157,8 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 {
 	unsigned int size;
 
+	LASSERTF(md->md_rspt_ptr == NULL, "md %p rsp %p\n", md, md->md_rspt_ptr);
+
 	if ((md->md_options & LNET_MD_KIOV) != 0)
 		size = offsetof(struct lnet_libmd, md_iov.kiov[md->md_niov]);
 	else
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 4a70c76..5ee43c2 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -548,6 +548,9 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		lnet_eq_enqueue_event(md->md_eq, &ev);
 	}
 
+	if (md->md_rspt_ptr)
+		lnet_detach_rsp_tracker(md, cpt);
+
 	lnet_md_unlink(md);
 
 	lnet_res_unlock(cpt);
-- 
1.8.3.1
