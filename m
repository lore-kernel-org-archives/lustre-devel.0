From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:29:57 +0200
Subject: [lustre-devel] [PATCH v2 v2 07/25] staging: lustre: libcfs:
 replace num_possible_cpus() with nr_cpu_ids
In-Reply-To: <1527603725-30560-8-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-8-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601082957.GB19242@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:47AM -0400, James Simmons wrote:
> From: Amir Shehata <amir.shehata@intel.com>
> 
> Move from num_possible_cpus() to nr_cpu_ids.

Nit, when doing a "v2" of a patch, in a series that is not all "v2", put
the moniker after the patch number.  Otherwise it does not sort properly
in anyone's email client and I have to manually edit it in order to get
it to apply in the correct order.

Remember, make things impossible for me to reject.  This is trivial for
me to reject on that issue alone, given that I deal with hundreds of
staging patches a week...

thanks,

greg k-h
