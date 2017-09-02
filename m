From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 2 Sep 2017 07:40:21 +0200
Subject: [lustre-devel] [PATCH] lustre: ptlrpc: kfree used instead of
	kvfree
In-Reply-To: <23708A03-C3C1-4270-AB59-8E1A17FB6EBA@intel.com>
References: <20170831225516.41922-1-namit@vmware.com>
	<23708A03-C3C1-4270-AB59-8E1A17FB6EBA@intel.com>
Message-ID: <20170902054021.GA22372@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Sep 01, 2017 at 08:13:18PM +0000, Dilger, Andreas wrote:
> On Aug 31, 2017, at 16:55, Nadav Amit <namit@vmware.com> wrote:
> > 
> > rq_reqbuf is allocated using kvmalloc() but released in one occasion
> > using kfree() instead of kvfree().
> > 
> > The issue was found using grep based on a similar bug.
> > 
> > Fixes: d7e09d0397e8 ("add Lustre file system client support")
> 
> It would appear that this bug was introduced by ee0ec1946ec2
> "lustre: ptlrpc: Replace uses of OBD_{ALLOC,FREE}_LARGE", but
> it looks like the problem predates this patch, since it was
> originally using OBD_FREE() instead of OBD_FREE_LARGE() here
> so the Coccinelle script wouldn't have caught the issue.
> 
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> 
> > 
> > Cc: Peng Tao <bergwolf@gmail.com>
> > Cc: Oleg Drokin <oleg.drokin@intel.com>
> > Cc: Andreas Dilger <andreas.dilger@intel.com>
> > Cc: James Simmons <jsimmons@infradead.org>
> > 
> > Signed-off-by: Nadav Amit <namit@vmware.com>
> > ---
> > drivers/staging/lustre/lustre/ptlrpc/sec.c | 2 +-
> > 1 file changed, 1 insertion(+), 1 deletion(-)

Can a lustre maintainer resend this in a format that I can apply it in?

thanks,

greg k-h
