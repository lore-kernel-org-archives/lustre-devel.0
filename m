From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 4 Apr 2017 12:38:52 +0300
Subject: [lustre-devel] [PATCH] drivers/staging/lustre:
 Coding-guideline: Missing a blank line after declarations
In-Reply-To: <1491297326-28973-1-git-send-email-pushkar.iit@gmail.com>
References: <1491297326-28973-1-git-send-email-pushkar.iit@gmail.com>
Message-ID: <20170404093851.GB4521@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Siyao <lai.siyao@intel.com>, James Nunez <james.a.nunez@intel.com>, Andrew Perepechko <andrew.perepechko@seagate.com>, wang di <di.wang@intel.com>, Bob Glossman <bob.glossman@intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Bobi Jam <bobijam@hotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Henri Doreau <henri.doreau@cea.fr>, Prakash Surya <surya1@llnl.gov>, Emoly Liu <emoly.liu@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Johann Lombardi <johann.lombardi@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, Apr 04, 2017 at 02:45:26PM +0530, Pushkar Jambhlekar wrote:
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> index cd9a40c..71fcc4c 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> @@ -482,6 +482,7 @@ void cl_page_disown0(const struct lu_env *env,
>  int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
>  {
>  	struct cl_io *top = cl_io_top((struct cl_io *)io);
> +
>  	LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
>  	return pg->cp_state == CPS_OWNED && pg->cp_owner == top;
>  }

This is not related to the patch but I don't understand CLOBINVRNT() and
LINVRNT().

# define LINVRNT(exp) LASSERT(exp)
# define LINVRNT(exp) ((void)sizeof !!(exp))

Why do we do the sizeof() instead of just an empty define?  The compiler
calculates the size at compile time and doesn't execute the expression
so it's the same as an empty define so far as I can tell.

regards,
dan carpenter
