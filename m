From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jul 2018 09:07:16 +1000
Subject: [lustre-devel] [PATCH 0/5] lnet: reduce code in lib-socket
Message-ID: <153247352950.25051.3479450943810758169.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lib-socket contains code to iterate over network interfaces and
determine the IPv4 address of each.  It does this but using
socket-ioctls.
There are more direct interfaces within the kernel for
accessing this information, so change to use those directly.

---

NeilBrown (5):
      lustre: socklnd: use for_each_netdev() instead of lnet_ipif_enumerate()
      lustre: socklnd: use ksocknal_enumerate_interfaces for individual interfaces.
      lustre: change lnet_ipaddr_enumerate() to use for_each_netdev()
      lustre: o2iblnd: get IP address more directly.
      lustre: lnet: remove lnet_ipif_enumerate()


 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   48 +++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   96 ++++-----
 drivers/staging/lustre/lnet/lnet/config.c          |   78 +++----
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  211 --------------------
 5 files changed, 103 insertions(+), 333 deletions(-)

--
Signature
