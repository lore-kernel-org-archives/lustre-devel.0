From: Greg Thelen <gthelen@google.com>
Date: Fri, 25 May 2018 17:32:52 -0700
Subject: [lustre-devel] [PATCH] IB: Revert "remove redundant INFINIBAND
 kconfig dependencies"
In-Reply-To: <20180525213123.2113748-1-arnd@arndb.de>
References: <20180525213123.2113748-1-arnd@arndb.de>
Message-ID: <CAHH2K0Ysgi30gHPN8EEdDa+PfSFJLo8=6j-aq=SYy=_h6K0kPg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, Steve French <sfrench@samba.org>, ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net, "David S. Miller" <davem@davemloft.net>, santosh.shilimkar@oracle.com, trond.myklebust@hammerspace.com, anna.schumaker@netapp.com, bfields@fieldses.org, jlayton@kernel.org, Bart Van Assche <bart.vanassche@wdc.com>, linux-rdma@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org

On Fri, May 25, 2018 at 2:32 PM Arnd Bergmann <arnd@arndb.de> wrote:

> Several subsystems depend on INFINIBAND_ADDR_TRANS, which in turn depends
> on INFINIBAND. However, when with CONFIG_INIFIBAND=m, this leads to a
> link error when another driver using it is built-in. The
> INFINIBAND_ADDR_TRANS dependency is insufficient here as this is
> a 'bool' symbol that does not force anything to be a module in turn.

> fs/cifs/smbdirect.o: In function `smbd_disconnect_rdma_work':
> smbdirect.c:(.text+0x1e4): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_request':
> trans_rdma.c:(.text+0x7bc): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_destroy_trans':
> trans_rdma.c:(.text+0x830): undefined reference to `ib_destroy_qp'
> trans_rdma.c:(.text+0x858): undefined reference to `ib_dealloc_pd'

> Fixes: 9533b292a7ac ("IB: remove redundant INFINIBAND kconfig
dependencies")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Greg Thelen <gthelen@google.com>

Sorry for the 9533b292a7ac problem.
At this point the in release cycle, I think Arnd's revert is best.

If there is interest, I've put a little thought into an alternative fix:
making INFINIBAND_ADDR_TRANS tristate.  But it's nontrivial.
So I prefer this simple revert for now.

Doug: do you need anything from me on this?

> ---
> The patch that introduced the problem has been queued in the
> rdma-fixes/for-rc tree. Please revert the patch before sending
> the branch to Linus.
> ---
>     drivers/infiniband/ulp/srpt/Kconfig | 2 +-
>     drivers/nvme/host/Kconfig           | 2 +-
>     drivers/nvme/target/Kconfig         | 2 +-
>     drivers/staging/lustre/lnet/Kconfig | 2 +-
>     fs/cifs/Kconfig                     | 2 +-
>     net/9p/Kconfig                      | 2 +-
>     net/rds/Kconfig                     | 2 +-
>     net/sunrpc/Kconfig                  | 2 +-
>     8 files changed, 8 insertions(+), 8 deletions(-)

> diff --git a/drivers/infiniband/ulp/srpt/Kconfig
b/drivers/infiniband/ulp/srpt/Kconfig
> index 25bf6955b6d0..fb8b7182f05e 100644
> --- a/drivers/infiniband/ulp/srpt/Kconfig
> +++ b/drivers/infiniband/ulp/srpt/Kconfig
> @@ -1,6 +1,6 @@
>     config INFINIBAND_SRPT
>            tristate "InfiniBand SCSI RDMA Protocol target support"
> -       depends on INFINIBAND_ADDR_TRANS && TARGET_CORE
> +       depends on INFINIBAND && INFINIBAND_ADDR_TRANS && TARGET_CORE
>            ---help---

>              Support for the SCSI RDMA Protocol (SRP) Target driver. The
> diff --git a/drivers/nvme/host/Kconfig b/drivers/nvme/host/Kconfig
> index dbb7464c018c..88a8b5916624 100644
> --- a/drivers/nvme/host/Kconfig
> +++ b/drivers/nvme/host/Kconfig
> @@ -27,7 +27,7 @@ config NVME_FABRICS

>     config NVME_RDMA
>            tristate "NVM Express over Fabrics RDMA host driver"
> -       depends on INFINIBAND_ADDR_TRANS && BLOCK
> +       depends on INFINIBAND && INFINIBAND_ADDR_TRANS && BLOCK
>            select NVME_CORE
>            select NVME_FABRICS
>            select SG_POOL
> diff --git a/drivers/nvme/target/Kconfig b/drivers/nvme/target/Kconfig
> index 7595664ee753..3c7b61ddb0d1 100644
> --- a/drivers/nvme/target/Kconfig
> +++ b/drivers/nvme/target/Kconfig
> @@ -27,7 +27,7 @@ config NVME_TARGET_LOOP

>     config NVME_TARGET_RDMA
>            tristate "NVMe over Fabrics RDMA target support"
> -       depends on INFINIBAND_ADDR_TRANS
> +       depends on INFINIBAND && INFINIBAND_ADDR_TRANS
>            depends on NVME_TARGET
>            select SGL_ALLOC
>            help
> diff --git a/drivers/staging/lustre/lnet/Kconfig
b/drivers/staging/lustre/lnet/Kconfig
> index f3b1ad4bd3dc..ad049e6f24e4 100644
> --- a/drivers/staging/lustre/lnet/Kconfig
> +++ b/drivers/staging/lustre/lnet/Kconfig
> @@ -34,7 +34,7 @@ config LNET_SELFTEST

>     config LNET_XPRT_IB
>            tristate "LNET infiniband support"
> -       depends on LNET && PCI && INFINIBAND_ADDR_TRANS
> +       depends on LNET && PCI && INFINIBAND && INFINIBAND_ADDR_TRANS
>            default LNET && INFINIBAND
>            help
>              This option allows the LNET users to use infiniband as an
> diff --git a/fs/cifs/Kconfig b/fs/cifs/Kconfig
> index d61e2de8d0eb..5f132d59dfc2 100644
> --- a/fs/cifs/Kconfig
> +++ b/fs/cifs/Kconfig
> @@ -197,7 +197,7 @@ config CIFS_SMB311

>     config CIFS_SMB_DIRECT
>            bool "SMB Direct support (Experimental)"
> -       depends on CIFS=m && INFINIBAND_ADDR_TRANS || CIFS=y &&
INFINIBAND_ADDR_TRANS=y
> +       depends on CIFS=m && INFINIBAND && INFINIBAND_ADDR_TRANS ||
CIFS=y && INFINIBAND=y && INFINIBAND_ADDR_TRANS=y
>            help
>              Enables SMB Direct experimental support for SMB 3.0, 3.02 and
3.1.1.
>              SMB Direct allows transferring SMB packets over RDMA. If
unsure,
> diff --git a/net/9p/Kconfig b/net/9p/Kconfig
> index 46c39f7da444..e6014e0e51f7 100644
> --- a/net/9p/Kconfig
> +++ b/net/9p/Kconfig
> @@ -32,7 +32,7 @@ config NET_9P_XEN


>     config NET_9P_RDMA
> -       depends on INET && INFINIBAND_ADDR_TRANS
> +       depends on INET && INFINIBAND && INFINIBAND_ADDR_TRANS
>            tristate "9P RDMA Transport (Experimental)"
>            help
>              This builds support for an RDMA transport.
> diff --git a/net/rds/Kconfig b/net/rds/Kconfig
> index 1a31502ee7db..bffde4b46c5d 100644
> --- a/net/rds/Kconfig
> +++ b/net/rds/Kconfig
> @@ -8,7 +8,7 @@ config RDS

>     config RDS_RDMA
>            tristate "RDS over Infiniband"
> -       depends on RDS && INFINIBAND_ADDR_TRANS
> +       depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
>            ---help---
>              Allow RDS to use Infiniband as a transport.
>              This transport supports RDMA operations.
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index 6358e5271070..ac09ca803296 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -50,7 +50,7 @@ config SUNRPC_DEBUG

>     config SUNRPC_XPRT_RDMA
>            tristate "RPC-over-RDMA transport"
> -       depends on SUNRPC && INFINIBAND_ADDR_TRANS
> +       depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
>            default SUNRPC && INFINIBAND
>            select SG_POOL
>            help
> --
> 2.9.0
