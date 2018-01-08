From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 8 Jan 2018 15:51:57 +0100
Subject: [lustre-devel] [PATCH 03/15] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <151355799030.6200.8100283223734974485.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
 <151355799030.6200.8100283223734974485.stgit@noble>
Message-ID: <20180108145157.GA32570@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Mon, Dec 18, 2017 at 11:46:30AM +1100, NeilBrown wrote:
> All usages of the form
>   LIBCFS_ALLOC(variable, sizeof(variable))
> or
>   LIBCFS_ALLOC(variable, sizeof(variable's-type))
> 
> are changed to
>   variable = kzalloc(sizeof(...), GFP_NOFS);
> 
> Similarly, all
>    LIBCFS_FREE(variable, sizeof(variable))
> become
>    kfree(variable);
> 
> None of these need the vmalloc option, or any of the other minor
> benefits of LIBCFS_ALLOC().
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

As this broke the kbuild system, I'll stop here in this patch series.
Can you please fix it up, rebase and resend the remaining ones in this
series?

thanks,

greg k-h
