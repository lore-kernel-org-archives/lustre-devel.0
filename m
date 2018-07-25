From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 25 Jul 2018 22:17:15 +0000
Subject: [lustre-devel] [PATCH 1/5] lustre: socklnd: use
 for_each_netdev() instead of lnet_ipif_enumerate()
In-Reply-To: <153247363628.25051.7385338424046780220.stgit@noble>
References: <153247352950.25051.3479450943810758169.stgit@noble>
 <153247363628.25051.7385338424046780220.stgit@noble>
Message-ID: <39FF8C8A-A60E-428A-ADC2-4AEC6443F67C@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <
dougso at me.com<mailto:dougso@me.com>
>

On Jul 24, 2018, at 4:07 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

for_each_netdev() is a more direct interface and doesn't require
library support.

Also get the ip address directly from the net_device, rather than
using lnet_ipif_query().

Signed-off-by: NeilBrown <neilb at suse.com<mailto:neilb@suse.com>>
---
.../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   63 +++++++++-----------
1 file changed, 28 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index c6e74ee01d27..895f744bb959 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -39,6 +39,7 @@
 */

#include "socklnd.h"
+#include <linux/inetdevice.h>

static struct lnet_lnd the_ksocklnd;
struct ksock_nal_data ksocknal_data;
@@ -2614,53 +2615,45 @@ ksocknal_shutdown(struct lnet_ni *ni)
static int
ksocknal_enumerate_interfaces(struct ksock_net *net)
{
- char **names;
- int i;
- int j;
- int rc;
- int n;
-
- n = lnet_ipif_enumerate(&names);
- if (n <= 0) {
- CERROR("Can't enumerate interfaces: %d\n", n);
- return n;
- }
+ int j = 0;
+ struct net_device *dev;

- for (i = j = 0; i < n; i++) {
- int up;
- __u32 ip;
- __u32 mask;
+ rtnl_lock();
+ for_each_netdev(&init_net, dev) {
+ const char *name = dev->name;
+ struct in_device *in_dev;
+ struct ksock_interface *ksi = &net->ksnn_interfaces[j];

- if (!strcmp(names[i], "lo")) /* skip the loopback IF */
+ if (strcmp(name, "lo") == 0) /* skip the loopback IF */
continue;

- rc = lnet_ipif_query(names[i], &up, &ip, &mask);
- if (rc) {
- CWARN("Can't get interface %s info: %d\n",
-      names[i], rc);
- continue;
- }
-
- if (!up) {
- CWARN("Ignoring interface %s (down)\n",
-      names[i]);
+ if (!(dev_get_flags(dev) & IFF_UP)) {
+ CWARN("Ignoring interface %s (down)\n", name);
continue;
}

if (j == LNET_MAX_INTERFACES) {
CWARN("Ignoring interface %s (too many interfaces)\n",
-      names[i]);
+      name);
continue;
}
-
- net->ksnn_interfaces[j].ksni_ipaddr = ip;
- net->ksnn_interfaces[j].ksni_netmask = mask;
- strlcpy(net->ksnn_interfaces[j].ksni_name,
- names[i], sizeof(net->ksnn_interfaces[j].ksni_name));
- j++;
+ in_dev = __in_dev_get_rtnl(dev);
+ if (!in_dev) {
+ CWARN("Interface %s has no IPv4 status.\n", name);
+ continue;
+ }
+ for_primary_ifa(in_dev)
+ if (strcmp(ifa->ifa_label, name) == 0) {
+ ksi->ksni_ipaddr = ifa->ifa_local;
+ ksi->ksni_netmask = ifa->ifa_mask;
+ strlcpy(ksi->ksni_name,
+ name, sizeof(ksi->ksni_name));
+ j++;
+ break;
+ }
+ endfor_ifa(in_dev);
}
-
- lnet_ipif_free_enumeration(names, n);
+ rtnl_unlock();

if (!j)
CERROR("Can't find any usable interfaces\n");


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180725/59bb2f7c/attachment.html>
