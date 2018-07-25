From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 25 Jul 2018 22:43:00 +0000
Subject: [lustre-devel] [PATCH 4/5] lustre: o2iblnd: get IP address more
 directly.
In-Reply-To: <153247363644.25051.16677553336215434742.stgit@noble>
References: <153247352950.25051.3479450943810758169.stgit@noble>
 <153247363644.25051.16677553336215434742.stgit@noble>
Message-ID: <9016B622-1E72-4A5A-9CC1-8D460AE7BA1E@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>

Doug

On Jul 24, 2018, at 4:07 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

Use dev_get_by_name() and for_primary_ifa() to
get IP address for a named device.  This is more
direct.

Signed-off-by: NeilBrown <neilb at suse.com<mailto:neilb@suse.com>>
---
.../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   48 +++++++++++++-------
1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 9f3fef5da38c..05835cc0f0a5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -38,6 +38,7 @@
#include <asm/div64.h>
#include <asm/page.h>
#include "o2iblnd.h"
+#include <linux/inetdevice.h>

static struct lnet_lnd the_o2iblnd;

@@ -2450,40 +2451,48 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
static struct kib_dev *kiblnd_create_dev(char *ifname)
{
struct net_device *netdev;
+ struct in_device *in_dev;
struct kib_dev *dev;
- __u32 netmask;
- __u32 ip;
- int up;
+ int flags;
int rc;

- rc = lnet_ipif_query(ifname, &up, &ip, &netmask);
- if (rc) {
- CERROR("Can't query IPoIB interface %s: %d\n",
-       ifname, rc);
- return NULL;
+ rtnl_lock();
+ netdev = dev_get_by_name(&init_net, ifname);
+ if (!netdev) {
+ CERROR("Can't find IPoIB interface %s\n",
+       ifname);
+ goto unlock;
}

- if (!up) {
+ flags = dev_get_flags(netdev);
+ if (!(flags & IFF_UP)) {
CERROR("Can't query IPoIB interface %s: it's down\n", ifname);
+ rtnl_unlock();
return NULL;
}

dev = kzalloc(sizeof(*dev), GFP_NOFS);
if (!dev)
- return NULL;
+ goto unlock;

- netdev = dev_get_by_name(&init_net, ifname);
- if (!netdev) {
- dev->ibd_can_failover = 0;
- } else {
- dev->ibd_can_failover = !!(netdev->flags & IFF_MASTER);
- dev_put(netdev);
- }
+ dev->ibd_can_failover = !!(flags & IFF_MASTER);

INIT_LIST_HEAD(&dev->ibd_nets);
INIT_LIST_HEAD(&dev->ibd_list); /* not yet in kib_devs */
INIT_LIST_HEAD(&dev->ibd_fail_list);
- dev->ibd_ifip = ip;
+ for_primary_ifa(in_dev)
+ if (strcmp(ifa->ifa_label, ifname) == 0) {
+ dev->ibd_ifip = ifa->ifa_local;
+ break;
+ }
+ endfor_ifa(in_dev);
+ rtnl_unlock();
+
+ if (dev->ibd_ifip == 0) {
+ CERROR("Can't initialize device: no IP address\n");
+ kfree(dev);
+ return NULL;
+ }
strcpy(&dev->ibd_ifname[0], ifname);

/* initialize the device */
@@ -2496,6 +2505,9 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)

list_add_tail(&dev->ibd_list, &kiblnd_data.kib_devs);
return dev;
+unlock:
+ rtnl_unlock();
+ return NULL;
}

static void kiblnd_base_shutdown(void)


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180725/618c236d/attachment.html>
