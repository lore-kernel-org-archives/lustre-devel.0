From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 06/14] staging: lustre: Convert more
 LIBCFS_ALLOC allocation to direct GFP_KERNEL
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077837.9776.15653995287936476858.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

None of these need to be GFP_NOFS, so use GFP_KERNEL explicitly
with kmalloc(), kvmalloc(), or kvmalloc_array().
Change matching LIBCFS_FREE() to kfree() or kvfree()

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lnet/libcfs/linux/linux-module.c        |    4 +-
 drivers/staging/lustre/lnet/libcfs/module.c        |    9 ++---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   17 ++++------
 drivers/staging/lustre/lnet/lnet/config.c          |   34 ++++++++------------
 4 files changed, 26 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index b5746230ab31..ddf625669bff 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -146,7 +146,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 		return -EINVAL;
 	}
 
-	LIBCFS_ALLOC(*hdr_pp, hdr.ioc_len);
+	*hdr_pp = kvmalloc(hdr.ioc_len, GFP_KERNEL);
 	if (!*hdr_pp)
 		return -ENOMEM;
 
@@ -164,7 +164,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 	return 0;
 
 free:
-	LIBCFS_FREE(*hdr_pp, hdr.ioc_len);
+	kvfree(*hdr_pp);
 	return err;
 }
 
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index eb1a1dea723d..555f47651730 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -156,7 +156,7 @@ int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 		break; }
 	}
 out:
-	LIBCFS_FREE(hdr, hdr->ioc_len);
+	kvfree(hdr);
 	return err;
 }
 
@@ -302,7 +302,7 @@ static int __proc_cpt_table(void *data, int write,
 	LASSERT(cfs_cpt_table);
 
 	while (1) {
-		LIBCFS_ALLOC(buf, len);
+		buf = kzalloc(len, GFP_KERNEL);
 		if (!buf)
 			return -ENOMEM;
 
@@ -311,7 +311,7 @@ static int __proc_cpt_table(void *data, int write,
 			break;
 
 		if (rc == -EFBIG) {
-			LIBCFS_FREE(buf, len);
+			kfree(buf);
 			len <<= 1;
 			continue;
 		}
@@ -325,8 +325,7 @@ static int __proc_cpt_table(void *data, int write,
 
 	rc = cfs_trace_copyout_string(buffer, nob, buf + pos, NULL);
  out:
-	if (buf)
-		LIBCFS_FREE(buf, len);
+	kfree(buf);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e8f623190133..6a1fb0397604 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -108,7 +108,8 @@ lnet_create_remote_nets_table(void)
 
 	LASSERT(!the_lnet.ln_remote_nets_hash);
 	LASSERT(the_lnet.ln_remote_nets_hbits > 0);
-	LIBCFS_ALLOC(hash, LNET_REMOTE_NETS_HASH_SIZE * sizeof(*hash));
+	hash = kvmalloc_array(LNET_REMOTE_NETS_HASH_SIZE, sizeof(*hash),
+			      GFP_KERNEL);
 	if (!hash) {
 		CERROR("Failed to create remote nets hash table\n");
 		return -ENOMEM;
@@ -131,9 +132,7 @@ lnet_destroy_remote_nets_table(void)
 	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++)
 		LASSERT(list_empty(&the_lnet.ln_remote_nets_hash[i]));
 
-	LIBCFS_FREE(the_lnet.ln_remote_nets_hash,
-		    LNET_REMOTE_NETS_HASH_SIZE *
-		    sizeof(the_lnet.ln_remote_nets_hash[0]));
+	kvfree(the_lnet.ln_remote_nets_hash);
 	the_lnet.ln_remote_nets_hash = NULL;
 }
 
@@ -831,7 +830,7 @@ lnet_ping_info_create(int num_ni)
 	unsigned int infosz;
 
 	infosz = offsetof(struct lnet_ping_info, pi_ni[num_ni]);
-	LIBCFS_ALLOC(ping_info, infosz);
+	ping_info = kvzalloc(infosz, GFP_KERNEL);
 	if (!ping_info) {
 		CERROR("Can't allocate ping info[%d]\n", num_ni);
 		return NULL;
@@ -864,9 +863,7 @@ lnet_get_ni_count(void)
 static inline void
 lnet_ping_info_free(struct lnet_ping_info *pinfo)
 {
-	LIBCFS_FREE(pinfo,
-		    offsetof(struct lnet_ping_info,
-			     pi_ni[pinfo->pi_nnis]));
+	kvfree(pinfo);
 }
 
 static void
@@ -2160,7 +2157,7 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
-	LIBCFS_ALLOC(info, infosz);
+	info = kzalloc(infosz, GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
@@ -2310,6 +2307,6 @@ static int lnet_ping(struct lnet_process_id id, int timeout_ms,
 	LASSERT(!rc2);
 
  out_0:
-	LIBCFS_FREE(info, infosz);
+	kfree(info);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 4b24842e9b16..1516ac61108d 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -108,10 +108,8 @@ lnet_ni_free(struct lnet_ni *ni)
 
 	kfree(ni->ni_lnd_tunables);
 
-	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++) {
-		LIBCFS_FREE(ni->ni_interfaces[i],
-			    strlen(ni->ni_interfaces[i]) + 1);
-	}
+	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++)
+		kfree(ni->ni_interfaces[i]);
 
 	/* release reference to net namespace */
 	if (ni->ni_net_ns)
@@ -197,7 +195,6 @@ int
 lnet_parse_networks(struct list_head *nilist, char *networks)
 {
 	struct cfs_expr_list *el = NULL;
-	int tokensize;
 	char *tokens;
 	char *str;
 	char *tmp;
@@ -218,15 +215,12 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		return -EINVAL;
 	}
 
-	tokensize = strlen(networks) + 1;
-
-	LIBCFS_ALLOC(tokens, tokensize);
+	tokens = kstrdup(networks, GFP_KERNEL);
 	if (!tokens) {
 		CERROR("Can't allocate net tokens\n");
 		return -ENOMEM;
 	}
 
-	memcpy(tokens, networks, tokensize);
 	tmp = tokens;
 	str = tokens;
 
@@ -348,14 +342,11 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 			 * The newly allocated ni_interfaces[] can be
 			 * freed when freeing the NI
 			 */
-			LIBCFS_ALLOC(ni->ni_interfaces[niface],
-				     strlen(iface) + 1);
+			ni->ni_interfaces[niface] = kstrdup(iface, GFP_KERNEL);
 			if (!ni->ni_interfaces[niface]) {
 				CERROR("Can't allocate net interface name\n");
 				goto failed;
 			}
-			strncpy(ni->ni_interfaces[niface], iface,
-				strlen(iface));
 			niface++;
 			iface = comma;
 		} while (iface);
@@ -383,7 +374,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	list_for_each(temp_node, nilist)
 		nnets++;
 
-	LIBCFS_FREE(tokens, tokensize);
+	kfree(tokens);
 	return nnets;
 
  failed_syntax:
@@ -399,7 +390,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	if (el)
 		cfs_expr_list_free(el);
 
-	LIBCFS_FREE(tokens, tokensize);
+	kfree(tokens);
 
 	return -EINVAL;
 }
@@ -423,7 +414,7 @@ lnet_new_text_buf(int str_len)
 		return NULL;
 	}
 
-	LIBCFS_ALLOC(ltb, nob);
+	ltb = kzalloc(nob, GFP_KERNEL);
 	if (!ltb)
 		return NULL;
 
@@ -437,7 +428,7 @@ static void
 lnet_free_text_buf(struct lnet_text_buf *ltb)
 {
 	lnet_tbnob -= ltb->ltb_size;
-	LIBCFS_FREE(ltb, ltb->ltb_size);
+	kfree(ltb);
 }
 
 static void
@@ -1155,7 +1146,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 	if (nif <= 0)
 		return nif;
 
-	LIBCFS_ALLOC(ipaddrs, nif * sizeof(*ipaddrs));
+	ipaddrs = kzalloc(nif * sizeof(*ipaddrs), GFP_KERNEL);
 	if (!ipaddrs) {
 		CERROR("Can't allocate ipaddrs[%d]\n", nif);
 		lnet_ipif_free_enumeration(ifnames, nif);
@@ -1188,7 +1179,8 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 		*ipaddrsp = ipaddrs;
 	} else {
 		if (nip > 0) {
-			LIBCFS_ALLOC(ipaddrs2, nip * sizeof(*ipaddrs2));
+			ipaddrs2 = kzalloc(nip * sizeof(*ipaddrs2),
+					   GFP_KERNEL);
 			if (!ipaddrs2) {
 				CERROR("Can't allocate ipaddrs[%d]\n", nip);
 				nip = -ENOMEM;
@@ -1199,7 +1191,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 				rc = nip;
 			}
 		}
-		LIBCFS_FREE(ipaddrs, nip * sizeof(*ipaddrs));
+		kfree(ipaddrs);
 	}
 	return nip;
 }
@@ -1225,7 +1217,7 @@ lnet_parse_ip2nets(char **networksp, char *ip2nets)
 	}
 
 	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
-	LIBCFS_FREE(ipaddrs, nip * sizeof(*ipaddrs));
+	kfree(ipaddrs);
 
 	if (rc < 0) {
 		LCONSOLE_ERROR_MSG(0x119, "Error %d parsing ip2nets\n", rc);
