From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:31:40 +0200
Subject: [lustre-devel] [PATCH v2 v2 07/25] staging: lustre: libcfs:
 replace num_possible_cpus() with nr_cpu_ids
In-Reply-To: <1527603725-30560-8-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-8-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601083140.GC19242@kroah.com>
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

This says what you did, not _why_ you did it.  If these functions are
really identical, why do we have both of them?  :)

greg k-h
