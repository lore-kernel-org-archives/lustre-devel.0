From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:29 -0700
Subject: [lustre-devel] [PATCH 2/6] Added fields to message for RLQOS support
In-Reply-To: <cover.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
Message-ID: <28c79a11bf7df97be1d3355b83c55a4ceea177bc.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Modified the request message to embed sent_time, which will be
returned from the server and used to calculate the exponentially
weighted moving average of sent_time gap in return messages. It is
used as a metric for rate-limiting quality of service.

Signed-off-by: Yan Li <yanli@ascar.io>
---
 lustre/include/lustre/lustre_idl.h | 4 ++++
 lustre/ptlrpc/pack_generic.c       | 5 +++++
 lustre/ptlrpc/wiretest.c           | 2 ++
 lustre/utils/wiretest.c            | 2 ++
 4 files changed, 13 insertions(+)

diff --git a/lustre/include/lustre/lustre_idl.h b/lustre/include/lustre/lustre_idl.h
index bf23a47..7a200d1 100644
--- a/lustre/include/lustre/lustre_idl.h
+++ b/lustre/include/lustre/lustre_idl.h
@@ -3336,8 +3336,12 @@ struct obdo {
 						 * each stripe.
 						 * brw: grant space consumed on
 						 * the client for the write */
+#ifdef ENABLE_RLQOS
+	struct timeval		o_sent_time;	/* timeval is 64x2 bits on Linux */
+#else
 	__u64			o_padding_4;
 	__u64			o_padding_5;
+#endif
 	__u64			o_padding_6;
 };
 
diff --git a/lustre/ptlrpc/pack_generic.c b/lustre/ptlrpc/pack_generic.c
index 8df8ea8..d0bc87a 100644
--- a/lustre/ptlrpc/pack_generic.c
+++ b/lustre/ptlrpc/pack_generic.c
@@ -1722,8 +1722,13 @@ void lustre_swab_obdo (struct obdo  *o)
         __swab32s (&o->o_uid_h);
         __swab32s (&o->o_gid_h);
         __swab64s (&o->o_data_version);
+#ifdef ENABLE_RLQOS
+        __swab64s ((__u64*)&o->o_sent_time.tv_sec);
+        __swab64s ((__u64*)&o->o_sent_time.tv_usec);
+#else
         CLASSERT(offsetof(typeof(*o), o_padding_4) != 0);
         CLASSERT(offsetof(typeof(*o), o_padding_5) != 0);
+#endif
         CLASSERT(offsetof(typeof(*o), o_padding_6) != 0);
 
 }
diff --git a/lustre/ptlrpc/wiretest.c b/lustre/ptlrpc/wiretest.c
index 070ef91..0c909a6 100644
--- a/lustre/ptlrpc/wiretest.c
+++ b/lustre/ptlrpc/wiretest.c
@@ -1314,6 +1314,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_data_version));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_data_version) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_data_version));
+#ifndef ENABLE_RLQOS
 	LASSERTF((int)offsetof(struct obdo, o_padding_4) == 184, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_4));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_4) == 8, "found %lld\n",
@@ -1322,6 +1323,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_padding_5));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_5) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_padding_5));
+#endif
 	LASSERTF((int)offsetof(struct obdo, o_padding_6) == 200, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_6));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_6) == 8, "found %lld\n",
diff --git a/lustre/utils/wiretest.c b/lustre/utils/wiretest.c
index 233d7d8..47fbbf0 100644
--- a/lustre/utils/wiretest.c
+++ b/lustre/utils/wiretest.c
@@ -1329,6 +1329,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_data_version));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_data_version) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_data_version));
+#ifndef ENABLE_RLQOS
 	LASSERTF((int)offsetof(struct obdo, o_padding_4) == 184, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_4));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_4) == 8, "found %lld\n",
@@ -1337,6 +1338,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_padding_5));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_5) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_padding_5));
+#endif
 	LASSERTF((int)offsetof(struct obdo, o_padding_6) == 200, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_6));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_6) == 8, "found %lld\n",
-- 
1.8.3.1
