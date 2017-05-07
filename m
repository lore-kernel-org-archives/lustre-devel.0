From: Guru Das Srinagesh <gurooodas@gmail.com>
Date: Sun, 7 May 2017 16:59:46 -0700
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: Fix variable
 length array warning
In-Reply-To: <1494199491.31950.52.camel@perches.com>
References: <1494149009-2121-1-git-send-email-gurooodas@gmail.com>
	<1494199491.31950.52.camel@perches.com>
Message-ID: <20170507235946.GA2898@alpha>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Sun, May 07, 2017 at 04:24:51PM -0700, Joe Perches wrote:
> On Sun, 2017-05-07 at 02:23 -0700, Guru Das Srinagesh wrote:
> > Fix sparse warning "warning: Variable length array is used." by using
> > kmalloc_array to allocate the required amount of memory instead and
> > kfree to deallocate memory after use.
> []
> > diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> []
> > @@ -86,13 +86,17 @@ ll_xattr_set_common(const struct xattr_handler *handler,
> >  		    const char *name, const void *value, size_t size,
> >  		    int flags)
> >  {
> > -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> > +	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
> > +	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);
> 
> Are you sure about using GFP_KERNEL and that sleeping is
> allowed for this function allocation?
> 
I'm not sure about that. Would GFP_ATOMIC be a better flag to use?
