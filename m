From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 15 May 2018 09:30:09 +0200
Subject: [lustre-devel] [PATCH v2 1/5] staging: lustre: llite: add
 support set_acl method in inode operations
In-Reply-To: <878t8l7ext.fsf@notabene.neil.brown.name>
References: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
 <1526350623-4616-2-git-send-email-jsimmons@infradead.org>
 <878t8l7ext.fsf@notabene.neil.brown.name>
Message-ID: <20180515073009.GB13000@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@yahoo.com>

On Tue, May 15, 2018 at 01:53:02PM +1000, NeilBrown wrote:
> On Mon, May 14 2018, James Simmons wrote:
> 
> > From: Dmitry Eremin <dmitry.eremin@intel.com>
> >
> > Linux kernel v3.14 adds set_acl method to inode operations.
> > This patch adds support to Lustre for proper acl management.
> >
> > Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Signed-off-by: John L. Hammond <john.hammond@intel.com>
> > Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
> > Reviewed-on: https://review.whamcloud.com/25965
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10541
> > Reviewed-on: https://review.whamcloud.com/31588
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10926
> > Reviewed-on: https://review.whamcloud.com/32045
> > Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> > Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> > Changelog:
> >
> > v1) Initial patch ported to staging tree
> > v2) Fixed up goto handling and avoid BUG() when calling
> >     forget_cached_acl()with invalid type as pointed out by Dan Carpenter
> >
> >  drivers/staging/lustre/lustre/llite/file.c         | 62 ++++++++++++++++++++++
> >  .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
> >  drivers/staging/lustre/lustre/llite/namei.c        | 10 +++-
> >  3 files changed, 74 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> > index 0026fde..64a5698 100644
> > --- a/drivers/staging/lustre/lustre/llite/file.c
> > +++ b/drivers/staging/lustre/lustre/llite/file.c
> > @@ -3030,6 +3030,7 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
> >  	return rc;
> >  }
> >  
> > +#ifdef CONFIG_FS_POSIX_ACL
> 
> Using #ifdef in  .c files is generally discouraged.
> The "standard" approach here is:
> - put the acl code in a separate file (acl.c)
> - optionally include it via the Make file
>      lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
> 
> - in the header where ll_get_acl and ll_set_acl are declared have
>  #ifdef CONFIG_FS_POSIX_ACL
>    declare the functions
>  #else
>  #define ll_get_acl NULL
>  #define ll_set_acl NULL
>  #endif
> 
> Now as this is staging and that is (presumably) an upstream patch
> lightly improved it is probably fine to include the patch as-is,
> but in that case we will probably want to fix it up later.

Let's get it right the first time if at all possible please.

I'll drop this series from my queue and wait for the next version of it.

thanks,

greg k-h
