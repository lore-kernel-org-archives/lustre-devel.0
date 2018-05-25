From: Leon Romanovsky <leon@kernel.org>
Date: Sat, 26 May 2018 00:38:53 +0300
Subject: [lustre-devel] [PATCH] IB: Revert "remove redundant INFINIBAND
 kconfig dependencies"
In-Reply-To: <20180525213123.2113748-1-arnd@arndb.de>
References: <20180525213123.2113748-1-arnd@arndb.de>
Message-ID: <20180525213853.GF22686@mtr-leonro.mtl.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Steve French <sfrench@samba.org>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, "David S. Miller" <davem@davemloft.net>, Santosh Shilimkar <santosh.shilimkar@oracle.com>, Trond Myklebust <trond.myklebust@hammerspace.com>, Anna Schumaker <anna.schumaker@netapp.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayto>

On Fri, May 25, 2018 at 11:29:59PM +0200, Arnd Bergmann wrote:
> Several subsystems depend on INFINIBAND_ADDR_TRANS, which in turn depends
> on INFINIBAND. However, when with CONFIG_INIFIBAND=m, this leads to a
> link error when another driver using it is built-in. The
> INFINIBAND_ADDR_TRANS dependency is insufficient here as this is
> a 'bool' symbol that does not force anything to be a module in turn.
>
> fs/cifs/smbdirect.o: In function `smbd_disconnect_rdma_work':
> smbdirect.c:(.text+0x1e4): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_request':
> trans_rdma.c:(.text+0x7bc): undefined reference to `rdma_disconnect'
> net/9p/trans_rdma.o: In function `rdma_destroy_trans':
> trans_rdma.c:(.text+0x830): undefined reference to `ib_destroy_qp'
> trans_rdma.c:(.text+0x858): undefined reference to `ib_dealloc_pd'
>
> Fixes: 9533b292a7ac ("IB: remove redundant INFINIBAND kconfig dependencies")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> The patch that introduced the problem has been queued in the
> rdma-fixes/for-rc tree. Please revert the patch before sending
> the branch to Linus.
> ---

It was already sent to Linus.

https://marc.info/?l=linux-rdma&m=152719509803047&w=2

Thanks
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 801 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180526/7111b8aa/attachment.sig>
