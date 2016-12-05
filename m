From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 23:55:37 +0300
Subject: [lustre-devel] [PATCH 04/22] staging: lustre: osc: handle osc
	eviction correctly
In-Reply-To: <1480726409-20350-5-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
	<1480726409-20350-5-git-send-email-jsimmons@infradead.org>
Message-ID: <20161205205537.GB31465@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 07:53:11PM -0500, James Simmons wrote:
> @@ -3183,8 +3182,10 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
>  	/* page is top page. */
>  	info->oti_next_index = osc_index(ops) + 1;
>  	if (cl_page_own(env, io, page) == 0) {
> -		KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
> -			      !PageDirty(cl_page_vmpage(page))));
> +		if (!ergo(page->cp_type == CPT_CACHEABLE,
> +			  !PageDirty(cl_page_vmpage(page))))
> +			CL_PAGE_DEBUG(D_ERROR, env, page,
> +				      "discard dirty page?\n");


I don't understand the point of the ergo macro.  There are way too many
double negatives (some of them hidden for my small brain).  How is that
simpler than just writing it out:

	if (page->cp_type == CPT_CACHEABLE &&
	    PageDirty(cl_page_vmpage(page))
		 CL_PAGE_DEBUG(D_ERROR, env, page, "discard dirty page?\n");

regards,
dan carpenter
