From: Hammond, John <john.hammond@intel.com>
Date: Wed, 5 Apr 2017 13:41:47 +0000
Subject: [lustre-devel] [PATCH] drivers/staging/lustre:
 Coding-guideline: Missing a blank line after declarations
In-Reply-To: <20170404093851.GB4521@mwanda>
References: <1491297326-28973-1-git-send-email-pushkar.iit@gmail.com>
	<20170404093851.GB4521@mwanda>
Message-ID: <C6D48C5819337145905EDC9DB164E6972DC4E55F@fmsmsx120.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>, Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Siyao, Lai" <lai.siyao@intel.com>, "Nunez, James A" <james.a.nunez@intel.com>, Andrew Perepechko <andrew.perepechko@seagate.com>, "Wang, Di" <di.wang@intel.com>, "Glossman, Bob" <bob.glossman@intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, "Xiong, Jinshan" <jinshan.xiong@intel.com>, Bobi Jam <bobijam@hotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Henri Doreau <henri.doreau@cea.fr>, Prakash Surya <surya1@llnl.gov>, "Liu, Emoly" <emoly.liu@intel.com>, "Eremin, Dmitry" <dmitry.eremin@intel.com>, "Lombardi, Johann" <johann.lombardi@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

> On Tue, Apr 04, 2017 at 02:45:26PM +0530, Pushkar Jambhlekar wrote:
> > diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> > b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> > index cd9a40c..71fcc4c 100644
> > --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> > +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> > @@ -482,6 +482,7 @@ void cl_page_disown0(const struct lu_env *env,
> > int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
> > {
> >  	struct cl_io *top = cl_io_top((struct cl_io *)io);
> > +
> >  	LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
> >  	return pg->cp_state == CPS_OWNED && pg->cp_owner == top;  }
> 
> This is not related to the patch but I don't understand CLOBINVRNT() and
> LINVRNT().
> 
> # define LINVRNT(exp) LASSERT(exp)
> # define LINVRNT(exp) ((void)sizeof !!(exp))
> 
> Why do we do the sizeof() instead of just an empty define?  The compiler
> calculates the size at compile time and doesn't execute the expression so it's the
> same as an empty define so far as I can tell.

This is someone's attempt to avoid the unused variable warnings which would occur
in some places when LINVRNT(exp) is defined as ((void)0).
