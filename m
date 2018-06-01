From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:39:32 +0200
Subject: [lustre-devel] [PATCH v2 13/25] staging: lustre: libcfs: fix
 libcfs_cpu coding style
In-Reply-To: <1527603725-30560-14-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-14-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601083932.GF19242@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:53AM -0400, James Simmons wrote:
>  int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab,
> -			 int cpt, nodemask_t *mask);
> +			 int cpt, const nodemask_t *mask);

This is not a coding style change.  It is a semi-functional change.
Don't bury code changes in the middle of "cleanup code formatting"
patches, it makes maintainers very grumpy when we notice this as we then
feel like we might have missed other things being snuck by us in the
guise of these types of patches...

thanks,

greg k-h
