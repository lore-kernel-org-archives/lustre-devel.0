From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:37:54 +0200
Subject: [lustre-devel] [PATCH v2 08/25] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <1527603725-30560-9-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-9-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601083754.GE19242@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:48AM -0400, James Simmons wrote:
> From: Amir Shehata <amir.shehata@intel.com>
> 
> This patch adds NUMA node support.

Really?  It looks like you just added an empty data structure pointer
that doesn't really do anything at all.

Where are you reading the host memory NUMA information from?

And why would a filesystem care about this type of thing?  Are you
going to now mirror what the scheduler does with regards to NUMA
topology issues?  How are you going to handle things when the topology
changes?  What systems did you test this on?  What performance
improvements were seen?  What downsides are there with all of this?

I need a whole lot more information here...

> NUMA node information is stored
> in the CPT table. A NUMA node mask is maintained for the entire
> table as well as for each CPT to track the NUMA nodes related to
> each of the CPTs. Add new function cfs_cpt_of_node() which returns
> the CPT of a particular NUMA node.

This doesn't really seem to match up with the code changes from what I
can tell...

thanks,

greg k-h
