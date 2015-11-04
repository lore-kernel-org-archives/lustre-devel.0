From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Wed, 4 Nov 2015 17:11:35 +0530
Subject: [lustre-devel] [PATCH v2 1/7] staging: lustre: remove white
 space in libcfs_hash.h
In-Reply-To: <20151104034607.GA12870@kroah.com>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
	<1446484933-23571-2-git-send-email-jsimmons@infradead.org>
	<20151104034607.GA12870@kroah.com>
Message-ID: <20151104114135.GB7587@sudip-pc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Nov 03, 2015 at 07:46:07PM -0800, Greg Kroah-Hartman wrote:
> On Mon, Nov 02, 2015 at 12:22:07PM -0500, James Simmons wrote:
> > Cleanup all the unneeded white space in libcfs_hash.h.
> > 
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  .../lustre/include/linux/libcfs/libcfs_hash.h      |  135 ++++++++++----------
> >  1 files changed, 70 insertions(+), 65 deletions(-)
> 
> Doesn't apply, did I already queue up this series?

No. This did not apply because of:
c7fdf4a3959f ("staging: lustre: fix remaining checkpatch issues for libcfs_hash.h")

regards
sudip
