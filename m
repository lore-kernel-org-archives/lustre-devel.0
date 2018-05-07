From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 6 May 2018 18:35:55 -0700
Subject: [lustre-devel] [PATCH v2] staging: lustre: o2iblnd: Enable
 Multiple OPA Endpoints between Nodes
In-Reply-To: <1525361585-13775-1-git-send-email-dougso@me.com>
References: <1525361585-13775-1-git-send-email-dougso@me.com>
Message-ID: <20180507013555.GA29421@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Doug Oucharek <doug.s.oucharek@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, May 03, 2018 at 08:33:05AM -0700, Doug Oucharek wrote:
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
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  3 ++-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 17 ++++++++++++---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 25 +++++++++++++++-------
>  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  9 ++++++++
>  4 files changed, 42 insertions(+), 12 deletions(-)

Always put below the --- line what changed in each version.  I have no
idea what is different here from v1.

Please fix up and resend v3.

thanks,

greg k-h
