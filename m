From: James Simmons <jsimmons@infradead.org>
Date: Wed, 7 Dec 2016 23:16:44 +0000 (GMT)
Subject: [lustre-devel] [PATCH 04/22] staging: lustre: osc: handle osc
 eviction correctly
In-Reply-To: <A380972E-E5F6-44B5-B5B3-9446A6DA9FF5@intel.com>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
	<1480726409-20350-5-git-send-email-jsimmons@infradead.org>
	<20161205205537.GB31465@mwanda>
	<A380972E-E5F6-44B5-B5B3-9446A6DA9FF5@intel.com>
Message-ID: <alpine.LFD.2.20.1612072316200.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Dec 5, 2016, at 3:55 PM, Dan Carpenter wrote:
> 
> > On Fri, Dec 02, 2016 at 07:53:11PM -0500, James Simmons wrote:
> >> @@ -3183,8 +3182,10 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
> >> 	/* page is top page. */
> >> 	info->oti_next_index = osc_index(ops) + 1;
> >> 	if (cl_page_own(env, io, page) == 0) {
> >> -		KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
> >> -			      !PageDirty(cl_page_vmpage(page))));
> >> +		if (!ergo(page->cp_type == CPT_CACHEABLE,
> >> +			  !PageDirty(cl_page_vmpage(page))))
> >> +			CL_PAGE_DEBUG(D_ERROR, env, page,
> >> +				      "discard dirty page?\n");
> > 
> > 
> > I don't understand the point of the ergo macro.  There are way too many
> > double negatives (some of them hidden for my small brain).  How is that
> > simpler than just writing it out:
> > 
> > 	if (page->cp_type == CPT_CACHEABLE &&
> > 	    PageDirty(cl_page_vmpage(page))
> > 		 CL_PAGE_DEBUG(D_ERROR, env, page, "discard dirty page?\n");
> 
> I guess it makes it sound chic or something?
> I am not a huge fan of it either, esp. in a case like this, though
> it might be somewhat more convenient in assertions (where this is converted from).

Not a fan either. Resubmitted patch with ergo removed.
