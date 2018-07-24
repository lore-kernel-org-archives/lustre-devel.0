From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jul 2018 09:07:16 +1000
Subject: [lustre-devel] [PATCH 5/5] lustre: lnet: remove
 lnet_ipif_enumerate()
In-Reply-To: <153247352950.25051.3479450943810758169.stgit@noble>
References: <153247352950.25051.3479450943810758169.stgit@noble>
Message-ID: <153247363648.25051.9690425452792746820.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Also remove lnet_ipif_query() and related functions.

There are no longer any users of these functions, so remove them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  211 --------------------
 2 files changed, 214 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 8ff8139e04fe..0fecf0d32c58 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -594,9 +594,6 @@ int lnet_acceptor_port(void);
 int lnet_acceptor_start(void);
 void lnet_acceptor_stop(void);
 
-int lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask);
-int lnet_ipif_enumerate(char ***names);
-void lnet_ipif_free_enumeration(char **names, int n);
 int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int lnet_sock_getaddr(struct socket *socket, bool remote, __u32 *ip, int *port);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 9b61260155f2..6758090d4165 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -43,217 +43,6 @@
 
 #include <linux/lnet/lib-lnet.h>
 
-static int
-kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
-{
-	mm_segment_t oldfs = get_fs();
-	int err;
-
-	set_fs(KERNEL_DS);
-	err = filp->f_op->unlocked_ioctl(filp, cmd, arg);
-	set_fs(oldfs);
-
-	return err;
-}
-
-static int
-lnet_sock_ioctl(int cmd, unsigned long arg)
-{
-	struct file *sock_filp;
-	struct socket *sock;
-	int rc;
-
-	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
-	if (rc) {
-		CERROR("Can't create socket: %d\n", rc);
-		return rc;
-	}
-
-	sock_filp = sock_alloc_file(sock, 0, NULL);
-	if (IS_ERR(sock_filp))
-		return PTR_ERR(sock_filp);
-
-	rc = kernel_sock_unlocked_ioctl(sock_filp, cmd, arg);
-
-	fput(sock_filp);
-	return rc;
-}
-
-int
-lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
-{
-	struct ifreq ifr;
-	int nob;
-	int rc;
-	__be32 val;
-
-	nob = strnlen(name, IFNAMSIZ);
-	if (nob == IFNAMSIZ) {
-		CERROR("Interface name %s too long\n", name);
-		return -EINVAL;
-	}
-
-	BUILD_BUG_ON(sizeof(ifr.ifr_name) < IFNAMSIZ);
-
-	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
-		return -E2BIG;
-	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
-
-	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
-	if (rc) {
-		CERROR("Can't get flags for interface %s\n", name);
-		return rc;
-	}
-
-	if (!(ifr.ifr_flags & IFF_UP)) {
-		CDEBUG(D_NET, "Interface %s down\n", name);
-		*up = 0;
-		*ip = *mask = 0;
-		return 0;
-	}
-	*up = 1;
-
-	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
-		return -E2BIG;
-	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
-
-	ifr.ifr_addr.sa_family = AF_INET;
-	rc = lnet_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
-	if (rc) {
-		CERROR("Can't get IP address for interface %s\n", name);
-		return rc;
-	}
-
-	val = ((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr.s_addr;
-	*ip = ntohl(val);
-
-	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
-		return -E2BIG;
-	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
-
-	ifr.ifr_addr.sa_family = AF_INET;
-	rc = lnet_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
-	if (rc) {
-		CERROR("Can't get netmask for interface %s\n", name);
-		return rc;
-	}
-
-	val = ((struct sockaddr_in *)&ifr.ifr_netmask)->sin_addr.s_addr;
-	*mask = ntohl(val);
-
-	return 0;
-}
-EXPORT_SYMBOL(lnet_ipif_query);
-
-int
-lnet_ipif_enumerate(char ***namesp)
-{
-	/* Allocate and fill in 'names', returning # interfaces/error */
-	char **names;
-	int toobig;
-	int nalloc;
-	int nfound;
-	struct ifreq *ifr;
-	struct ifconf ifc;
-	int rc;
-	int nob;
-	int i;
-
-	nalloc = 16;	/* first guess at max interfaces */
-	toobig = 0;
-	for (;;) {
-		if (nalloc * sizeof(*ifr) > PAGE_SIZE) {
-			toobig = 1;
-			nalloc = PAGE_SIZE / sizeof(*ifr);
-			CWARN("Too many interfaces: only enumerating first %d\n",
-			      nalloc);
-		}
-
-		ifr = kzalloc(nalloc * sizeof(*ifr), GFP_KERNEL);
-		if (!ifr) {
-			CERROR("ENOMEM enumerating up to %d interfaces\n",
-			       nalloc);
-			rc = -ENOMEM;
-			goto out0;
-		}
-
-		ifc.ifc_buf = (char *)ifr;
-		ifc.ifc_len = nalloc * sizeof(*ifr);
-
-		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
-		if (rc < 0) {
-			CERROR("Error %d enumerating interfaces\n", rc);
-			goto out1;
-		}
-
-		LASSERT(!rc);
-
-		nfound = ifc.ifc_len / sizeof(*ifr);
-		LASSERT(nfound <= nalloc);
-
-		if (nfound < nalloc || toobig)
-			break;
-
-		kfree(ifr);
-		nalloc *= 2;
-	}
-
-	if (!nfound)
-		goto out1;
-
-	names = kzalloc(nfound * sizeof(*names), GFP_KERNEL);
-	if (!names) {
-		rc = -ENOMEM;
-		goto out1;
-	}
-
-	for (i = 0; i < nfound; i++) {
-		nob = strnlen(ifr[i].ifr_name, IFNAMSIZ);
-		if (nob == IFNAMSIZ) {
-			/* no space for terminating NULL */
-			CERROR("interface name %.*s too long (%d max)\n",
-			       nob, ifr[i].ifr_name, IFNAMSIZ);
-			rc = -ENAMETOOLONG;
-			goto out2;
-		}
-
-		names[i] = kmalloc(IFNAMSIZ, GFP_KERNEL);
-		if (!names[i]) {
-			rc = -ENOMEM;
-			goto out2;
-		}
-
-		memcpy(names[i], ifr[i].ifr_name, nob);
-		names[i][nob] = 0;
-	}
-
-	*namesp = names;
-	rc = nfound;
-
-out2:
-	if (rc < 0)
-		lnet_ipif_free_enumeration(names, nfound);
-out1:
-	kfree(ifr);
-out0:
-	return rc;
-}
-EXPORT_SYMBOL(lnet_ipif_enumerate);
-
-void
-lnet_ipif_free_enumeration(char **names, int n)
-{
-	int i;
-
-	LASSERT(n > 0);
-
-	for (i = 0; i < n && names[i]; i++)
-		kfree(names[i]);
-
-	kfree(names);
-}
-EXPORT_SYMBOL(lnet_ipif_free_enumeration);
-
 int
 lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 {
