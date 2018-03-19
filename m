From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 19 Mar 2018 17:16:18 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Enable
 Multiple OPA Endpoints between Nodes
In-Reply-To: <2253BE75-D4ED-4021-BBA1-BCBF2C6770CB@me.com>
References: <2253BE75-D4ED-4021-BBA1-BCBF2C6770CB@me.com>
Message-ID: <20180319161618.GA26103@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>
Cc: devel@driverdev.osuosl.org, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Mar 15, 2018 at 02:53:46PM -0700, Doug Oucharek wrote:
> OPA driver optimizations are based on the MPI model where it is
> expected to have multiple endpoints between two given nodes. To
> enable this optimization for Lustre, we need to make it possible,
> via an LND-specific tuneable, to create multiple endpoints and to
> balance the traffic over them.
> 
> Both sides of a connection must have this patch for it to work.
> Only the active side of the connection (usually the client)
> needs to have the new tuneable set > 1.
> 
> Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8943
> Reviewed-on: https://review.whamcloud.com/25168
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: Doug Oucharek <dougso@me.com>
> ---
> .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  3 ++-
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 17 ++++++++++++---
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 25 +++++++++++++++-------
> .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  9 ++++++++
> 4 files changed, 42 insertions(+), 12 deletions(-)

Does not apply to my tree at all :(
