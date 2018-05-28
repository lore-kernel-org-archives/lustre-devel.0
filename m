From: Greg Thelen <gthelen@google.com>
Date: Mon, 28 May 2018 11:02:40 -0700
Subject: [lustre-devel] [PATCH] IB: Revert "remove redundant INFINIBAND
 kconfig dependencies"
In-Reply-To: <20180528163949.GA17505@ziepe.ca>
References: <20180525213123.2113748-1-arnd@arndb.de>
 <CAHH2K0Ysgi30gHPN8EEdDa+PfSFJLo8=6j-aq=SYy=_h6K0kPg@mail.gmail.com>
 <20180528163949.GA17505@ziepe.ca>
Message-ID: <xr931sdv64lb.fsf@gthelen.svl.corp.google.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: arnd@arndb.de, Doug Ledford <dledford@redhat.com>, Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, Steve French <sfrench@samba.org>, ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net, "David S. Miller" <davem@davemloft.net>, santosh.shilimkar@oracle.com, trond.myklebust@hammerspace.com, anna.schumaker@netapp.com, bfields@fieldses.org, jlayton@kernel.org, Bart Van Assche <bart.vanassche@wdc.com>, linux-rdma@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, samba-techni

Jason Gunthorpe <jgg@ziepe.ca> wrote:

> On Fri, May 25, 2018 at 05:32:52PM -0700, Greg Thelen wrote:
>> On Fri, May 25, 2018 at 2:32 PM Arnd Bergmann <arnd@arndb.de> wrote:

>> > Several subsystems depend on INFINIBAND_ADDR_TRANS, which in turn  
>> depends
>> > on INFINIBAND. However, when with CONFIG_INIFIBAND=m, this leads to a
>> > link error when another driver using it is built-in. The
>> > INFINIBAND_ADDR_TRANS dependency is insufficient here as this is
>> > a 'bool' symbol that does not force anything to be a module in turn.

>> > fs/cifs/smbdirect.o: In function `smbd_disconnect_rdma_work':
>> > smbdirect.c:(.text+0x1e4): undefined reference to `rdma_disconnect'
>> > net/9p/trans_rdma.o: In function `rdma_request':
>> > trans_rdma.c:(.text+0x7bc): undefined reference to `rdma_disconnect'
>> > net/9p/trans_rdma.o: In function `rdma_destroy_trans':
>> > trans_rdma.c:(.text+0x830): undefined reference to `ib_destroy_qp'
>> > trans_rdma.c:(.text+0x858): undefined reference to `ib_dealloc_pd'

>> > Fixes: 9533b292a7ac ("IB: remove redundant INFINIBAND kconfig
>> dependencies")
>> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>

>> Acked-by: Greg Thelen <gthelen@google.com>

>> Sorry for the 9533b292a7ac problem.
>> At this point the in release cycle, I think Arnd's revert is best.

>> If there is interest, I've put a little thought into an alternative fix:
>> making INFINIBAND_ADDR_TRANS tristate.  But it's nontrivial.
>> So I prefer this simple revert for now.

> Is that a normal thing to do?

For me: no, it's not normal.  In my use case I merely want to disable
INFINIBAND_ADDR_TRANS while continuing to use INFINIBAND.  This is
supported with f7cb7b85be55 ("IB: make INFINIBAND_ADDR_TRANS
configurable").

During f7cb7b85be55 development https://lkml.org/lkml/2018/4/30/1073
suggested that we drop dependency on both INFINIBAND and
INFINIBAND_ADDR_TRANS.  Thus 9533b292a7ac ("IB: remove redundant
INFINIBAND kconfig dependencies").

But 9533b292a7ac led to the randconfig build errors reported and thus
("IB: Revert "remove redundant INFINIBAND kconfig dependencies"").

So I see no need to do anything more than apply ("IB: Revert "remove
redundant INFINIBAND kconfig dependencies"").

>> Doug: do you need anything from me on this?

> I can take the revert..

> Jason

Thanks.
