From: James Simmons <jsimmons@infradead.org>
Date: Sat, 20 Oct 2018 20:00:52 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/10] lustre: lnet: fixes for non-x86
 systems
In-Reply-To: <87va5zc12b.fsf@notabene.neil.brown.name>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
 <87va5zc12b.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810202000050.16676@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sun, Oct 14 2018, James Simmons wrote:
> 
> > These are the required patches to make LNet work with non-x86
> > platforms like ARM or Power8. The tunables map_on_demand and
> > concurrent_sends assumed pages were 4K in size which is not
> > correct. Massively reworked to basically defunct those tunables.
> > Also the size of the LNet packet was always 256 pages but when
> > the page size is 64K like some ARM or Power8 systems the maximum
> > LNet message sent was 16MB not 1MB which is what is expected.
> > Fixing up the RDMA handling in the ko2iblnd driver also resolved
> > some performance issues.
> 
> Thanks.
> I've applied this series, but I've still suspicious of that little
> section in patch 3.
> I hope that can be clarified, or fixed, before I feel the need to  move
> the series from 'lustre-testing' to 'lustre'.

Thank you. Yes as I pointed out that code in patch 3 is wrong. I pushed
a fix to the OpenSFS branch already. You can drop that change in patch 3.


> > Alexey Lyashkov (1):
> >   lustre: lnd: use less CQ entries for each connection
> >
> > Amir Shehata (6):
> >   lustre: lnd: set device capabilities
> >   lustre: o2iblnd: use IB_MR_TYPE_SG_GAPS
> >   lustre: lnd: rework map_on_demand behavior
> >   lustre: lnd: calculate qp max_send_wrs properly
> >   lustre: lnd: remove concurrent_sends tunable
> >   lustre: lnd: correct WR fast reg accounting
> >
> > Dmitry Eremin (1):
> >   lustre: o2iblnd: limit cap.max_send_wr for MLX5
> >
> > James Simmons (1):
> >   lustre: lnet: make LNET_MAX_IOV dependent on page size
> >
> > John L. Hammond (1):
> >   lustre: o2ib: use splice in kiblnd_peer_connect_failed()
> >
> >  .../staging/lustre/include/linux/lnet/lib-types.h  |  10 +-
> >  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   3 -
> >  drivers/staging/lustre/lnet/Kconfig                |  10 --
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 138 +++++++++++++++------
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  68 +++-------
> >  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 133 ++++++++++++++------
> >  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  85 ++++++-------
> >  drivers/staging/lustre/lustre/include/lustre_net.h |   1 +
> >  8 files changed, 256 insertions(+), 192 deletions(-)
> >
> > -- 
> > 1.8.3.1
> 
