From: NeilBrown <neilb@suse.com>
Date: Thu, 26 Jul 2018 14:00:23 +1000
Subject: [lustre-devel] [PATCH 3/5] lustre: change
 lnet_ipaddr_enumerate() to use for_each_netdev()
In-Reply-To: <2D7F51A3-AE1F-4BBE-BF52-C3EFA99DF5B4@cray.com>
References: <153247352950.25051.3479450943810758169.stgit@noble>
 <153247363640.25051.8583622796462340468.stgit@noble>
 <2D7F51A3-AE1F-4BBE-BF52-C3EFA99DF5B4@cray.com>
Message-ID: <87fu06odd4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi Doug,
 thanks for your review to this patch and the others.
 Thanks particularly for noticing the FIXME :-)  I'll make that change.

Thanks,
NeilBrown

On Wed, Jul 25 2018, Doug Oucharek wrote:

> Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>
>
> Note:
> I did not think your changes would collide with Multi-Rail.  Unfortunately, it looks like this one does.  This config code was changed quite a bit by the Multi-Rail feature.  However, it is ok as landing this change now will prompt the Multi-Rail changes to utilize the better way of getting interface information.  Just a heads up to Multi-Rail porters.
>
> Doug
>
> On Jul 24, 2018, at 4:07 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:
>
> for_each_netdev() is a more direct interface than
> lnet_ipif_enumerate(), so use it instead.  Also get
> address and 'up' status directly from the device.
>
> This means we need to possible re-allocate the storage
> space if there are lots of IP addresses.
>
> However there is no need to resize the allocation down if we
> over-allocated.  This is only used once, and is freed soon
> after it is allocated, so that is a false optimization.
>
> Signed-off-by: NeilBrown <neilb at suse.com<mailto:neilb@suse.com>>
> ---
> drivers/staging/lustre/lnet/lnet/config.c |   78 +++++++++++++----------------
> 1 file changed, 35 insertions(+), 43 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 55ecc1998b7e..136905db2746 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -36,6 +36,7 @@
> #include <net/net_namespace.h>
> #include <linux/ctype.h>
> #include <linux/lnet/lib-lnet.h>
> +#include <linux/inetdevice.h>
>
> struct lnet_text_buf {    /* tmp struct for parsing routes */
> struct list_head ltb_list; /* stash on lists */
> @@ -1134,66 +1135,57 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
> static int
> lnet_ipaddr_enumerate(__u32 **ipaddrsp)
> {
> - int up;
> - __u32 netmask;
> + struct net_device *dev;
> __u32 *ipaddrs;
> - __u32 *ipaddrs2;
> + int nalloc = 64;
> int nip;
> - char **ifnames;
> - int nif = lnet_ipif_enumerate(&ifnames);
> - int i;
> - int rc;
>
> - if (nif <= 0)
> - return nif;
> -
> - ipaddrs = kcalloc(nif, sizeof(*ipaddrs), GFP_KERNEL);
> + ipaddrs = kcalloc(nalloc, sizeof(*ipaddrs), GFP_KERNEL);
> if (!ipaddrs) {
> - CERROR("Can't allocate ipaddrs[%d]\n", nif);
> - lnet_ipif_free_enumeration(ifnames, nif);
> + CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
> return -ENOMEM;
> }
>
> - for (i = nip = 0; i < nif; i++) {
> - if (!strcmp(ifnames[i], "lo"))
> + rtnl_lock();
> + for_each_netdev(&init_net, dev) {
> + struct in_device *in_dev;
> +
> + if (strcmp(dev->name, "lo") == 0)
> continue;
>
> - rc = lnet_ipif_query(ifnames[i], &up, &ipaddrs[nip], &netmask);
> - if (rc) {
> - CWARN("Can't query interface %s: %d\n",
> -      ifnames[i], rc);
> + if (!(dev_get_flags(dev) & IFF_UP)) {
> + CWARN("Ignoring interface %s: it's down\n", dev->name);
> continue;
> }
> -
> - if (!up) {
> - CWARN("Ignoring interface %s: it's down\n",
> -      ifnames[i]);
> + in_dev = __in_dev_get_rtnl(dev);
> + if (!in_dev) {
> + CWARN("Interface %s has no IPv4 status.\n", dev->name);
> continue;
> }
>
> - nip++;
> - }
> -
> - lnet_ipif_free_enumeration(ifnames, nif);
> -
> - if (nip == nif) {
> - *ipaddrsp = ipaddrs;
> - } else {
> - if (nip > 0) {
> - ipaddrs2 = kcalloc(nip, sizeof(*ipaddrs2),
> -   GFP_KERNEL);
> - if (!ipaddrs2) {
> - CERROR("Can't allocate ipaddrs[%d]\n", nip);
> - nip = -ENOMEM;
> - } else {
> - memcpy(ipaddrs2, ipaddrs,
> -       nip * sizeof(*ipaddrs));
> - *ipaddrsp = ipaddrs2;
> - rc = nip;
> + if (nip >= nalloc) {
> + __u32 *ipaddrs2;
> + nalloc += nalloc;
> + ipaddrs2 = krealloc(ipaddrs, nalloc * sizeof(*ipaddrs2),
> +    GFP_KERNEL);
> + if (ipaddrs2 == NULL) {
> + kfree(ipaddrs);
> + CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
> + return -ENOMEM;
> }
> + ipaddrs = ipaddrs2;
> }
> - kfree(ipaddrs);
> +
> + for_primary_ifa(in_dev)
> + if (strcmp(ifa->ifa_label, dev->name) == 0) {
> + ipaddrs[nip++] = ifa->ifa_local;
> + break;
> + }
> + endfor_ifa(in_dev);
> }
> + rtnl_unlock();
> +
> + *ipaddrsp = ipaddrs;
> return nip;
> }
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180726/b4ffb366/attachment.sig>
