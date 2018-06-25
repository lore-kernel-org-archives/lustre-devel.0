From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 23:57:25 +0100 (BST)
Subject: [lustre-devel] [PATCH v3 19/26] staging: lustre: libcfs: report
 NUMA node instead of just node
In-Reply-To: <87vaa78ybu.fsf@notabene.neil.brown.name>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-20-git-send-email-jsimmons@infradead.org>
 <87y3f38ye6.fsf@notabene.neil.brown.name>
 <87vaa78ybu.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806252354180.31196@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > On Sun, Jun 24 2018, James Simmons wrote:
> >
> >> From: Dmitry Eremin <dmitry.eremin@intel.com>
> >>
> >> Reporting "HW nodes" is too generic. It really is reporting
> >> "HW NUMA nodes". Update the debug message.
> >
> > I'm not happy with this patch description.....
> >
> >>
> >> Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> >> WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
> >> Reviewed-on: https://review.whamcloud.com/23306
> >> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> >> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> >> Reviewed-by: Patrick Farrell <paf@cray.com>
> >> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> >> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> >> Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> ---
> >>  drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h | 2 ++
> >>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c          | 2 +-
> >>  drivers/staging/lustre/lnet/lnet/lib-msg.c               | 2 ++
> >>  3 files changed, 5 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> >> index 2bb2140..29c5071 100644
> >> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> >> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> >> @@ -90,6 +90,8 @@ struct cfs_cpu_partition {
> >>  	unsigned int			*cpt_distance;
> >>  	/* spread rotor for NUMA allocator */
> >>  	int				cpt_spread_rotor;
> >> +	/* NUMA node if cpt_nodemask is empty */
> >> +	int				cpt_node;
> >>  };
> >
> > It doesn't give any reason why this (unused) field was added.
> > So I've removed it.
> 
> Ahhhh. this was meant to be in the previous patch too.
> I've moved it.

This is stupid NFS. So my test nodes are NFS root which will
contain the source tree. The test nodes don't have access to
the outside world so from another system I do my pulling and
pushing. What happens is that patches applied will not show
up right away before I push. By the time the next patch is
applied it shows up. Sorry about that.
