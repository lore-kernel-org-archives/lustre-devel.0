From: Leon Romanovsky <leon@kernel.org>
Date: Thu, 12 Jan 2017 15:09:30 +0200
Subject: [lustre-devel] [PATCH 9/9] treewide: Inline ib_dma_map_*()
	functions
In-Reply-To: <20170111005648.14988-10-bart.vanassche@sandisk.com>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
	<20170111005648.14988-10-bart.vanassche@sandisk.com>
Message-ID: <20170112130930.GH20392@mtr-leonro.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Doug Ledford <dledford@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>, devel@driverdev.osuosl.org, linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, linux-rdma@vger.kernel.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org, Anna Schumaker <anna.schumaker@netapp.com>, Oleg Drokin <oleg.drokin@intel.com>, Eric Van Hensbergen <ericvh@gmail.com>, target-devel@vger.kernel.org, Ron Minnich <rminnich@sandia.gov>, James Simmons <jsimmons@infradead.org>, v9fs-developer@lists.sourceforge.net, rds-devel@oss.oracle.com, "David S . Miller" <davem@davemloft.net>, lustre-devel@lists.lustre.org

On Tue, Jan 10, 2017 at 04:56:48PM -0800, Bart Van Assche wrote:
> Almost all changes in this patch except the removal of local variables
> that became superfluous and the actual removal of the ib_dma_map_*()
> functions have been generated as follows:
>
> git grep -lE 'ib_(sg_|)dma_' |
>   xargs -d\\n \
>     sed -i -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\&\([^,]\+\),/\1dma_\2(\3.dma_device,/g' \
>            -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\([^,]\+\),/\1dma_\2(\3->dma_device,/g' \
> 	   -e 's/ib_sg_dma_\(len\|address\)(\([^,]\+\), /sg_dma_\1(/g'
>
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: Anna Schumaker <anna.schumaker@netapp.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Van Hensbergen <ericvh@gmail.com>
> Cc: James Simmons <jsimmons@infradead.org>
> Cc: Latchesar Ionkov <lucho@ionkov.net>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Ron Minnich <rminnich@sandia.gov>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: devel at driverdev.osuosl.org
> Cc: linux-nfs at vger.kernel.org
> Cc: linux-nvme at lists.infradead.org
> Cc: linux-rdma at vger.kernel.org
> Cc: lustre-devel at lists.lustre.org
> Cc: netdev at vger.kernel.org
> Cc: rds-devel at oss.oracle.com
> Cc: target-devel at vger.kernel.org
> Cc: v9fs-developer at lists.sourceforge.net
> ---
>  drivers/infiniband/core/mad.c                      |  28 +--
>  drivers/infiniband/core/rw.c                       |  30 ++-
>  drivers/infiniband/core/umem.c                     |   4 +-
>  drivers/infiniband/core/umem_odp.c                 |   6 +-
>  drivers/infiniband/hw/mlx4/cq.c                    |   2 +-
>  drivers/infiniband/hw/mlx4/mad.c                   |  28 +--
>  drivers/infiniband/hw/mlx4/mr.c                    |   4 +-
>  drivers/infiniband/hw/mlx4/qp.c                    |  10 +-
>  drivers/infiniband/hw/mlx5/mr.c                    |   4 +-

For mlx5 and mlx4 parts.
Acked-by: Leon Romanovsky <leonro@mellanox.com>

Thanks
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 833 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170112/7c2fc5e1/attachment.pgp>
