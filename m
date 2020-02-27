From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:34 -0500
Subject: [lustre-devel] [PATCH 586/622] lnet: remove locking protection
 ln_testprotocompat
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-587-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

lnet_net_lock(LNET_LOCK_EX) is a heavy-weight lock that is not
necessary here.  The bits in this field are only set rarely - via an
ioctl - and the pattern for reading and clearing them exactly
matches test_and_clear_bit().  So change the field to "unsigned
long" (so test_and_clear_bit() can be used), and use
test_and_clear_bit(), discarding all other locking.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 624364420970 ("LU-12678 lnet: remove locking protection ln_testprotocompat")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36856
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h         |  2 +-
 net/lnet/klnds/socklnd/socklnd_proto.c | 17 ++++-------------
 net/lnet/lnet/acceptor.c               | 11 +++--------
 net/lnet/lnet/api-ni.c                 |  2 --
 4 files changed, 8 insertions(+), 24 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 99ed87a..9055da9 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1134,7 +1134,7 @@ struct lnet {
 	struct lnet_lnd			*ln_lnds[NUM_LNDS];
 
 	/* test protocol compatibility flags */
-	int				ln_testprotocompat;
+	unsigned long			ln_testprotocompat;
 
 	/*
 	 * 0 - load the NIs from the mod params
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 887ed2d..195c44f 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -484,16 +484,11 @@
 
 	if (the_lnet.ln_testprotocompat) {
 		/* single-shot proto check */
-		lnet_net_lock(LNET_LOCK_EX);
-		if (the_lnet.ln_testprotocompat & 1) {
+		if (test_and_clear_bit(0, &the_lnet.ln_testprotocompat))
 			hmv->version_major++;   /* just different! */
-			the_lnet.ln_testprotocompat &= ~1;
-		}
-		if (the_lnet.ln_testprotocompat & 2) {
+
+		if (test_and_clear_bit(1, &the_lnet.ln_testprotocompat))
 			hmv->magic = LNET_PROTO_MAGIC;
-			the_lnet.ln_testprotocompat &= ~2;
-		}
-		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
 	hdr->src_nid = cpu_to_le64(hello->kshm_src_nid);
@@ -541,12 +536,8 @@
 
 	if (the_lnet.ln_testprotocompat) {
 		/* single-shot proto check */
-		lnet_net_lock(LNET_LOCK_EX);
-		if (the_lnet.ln_testprotocompat & 1) {
+		if (test_and_clear_bit(0, &the_lnet.ln_testprotocompat))
 			hello->kshm_version++;   /* just different! */
-			the_lnet.ln_testprotocompat &= ~1;
-		}
-		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
 	rc = lnet_sock_write(sock, hello, offsetof(struct ksock_hello_msg, kshm_ips),
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index acd1d75..c6a1835 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -174,16 +174,11 @@
 
 		if (the_lnet.ln_testprotocompat) {
 			/* single-shot proto check */
-			lnet_net_lock(LNET_LOCK_EX);
-			if (the_lnet.ln_testprotocompat & 4) {
+			if (test_and_clear_bit(2, &the_lnet.ln_testprotocompat))
 				cr.acr_version++;
-				the_lnet.ln_testprotocompat &= ~4;
-			}
-			if (the_lnet.ln_testprotocompat & 8) {
+
+			if (test_and_clear_bit(3, &the_lnet.ln_testprotocompat))
 				cr.acr_magic = LNET_PROTO_MAGIC;
-				the_lnet.ln_testprotocompat &= ~8;
-			}
-			lnet_net_unlock(LNET_LOCK_EX);
 		}
 
 		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index cd95bdd..0ca8bef 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3842,9 +3842,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		return 0;
 
 	case IOC_LIBCFS_TESTPROTOCOMPAT:
-		lnet_net_lock(LNET_LOCK_EX);
 		the_lnet.ln_testprotocompat = data->ioc_flags;
-		lnet_net_unlock(LNET_LOCK_EX);
 		return 0;
 
 	case IOC_LIBCFS_LNET_FAULT:
-- 
1.8.3.1
