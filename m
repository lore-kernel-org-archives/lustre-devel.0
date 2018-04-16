From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 16 Apr 2018 16:55:21 +0300
Subject: [lustre-devel] [PATCH 04/25] staging: lustre: libcfs: replace
 MAX_NUMNODES with nr_node_ids
In-Reply-To: <1523851807-16573-5-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-5-git-send-email-jsimmons@infradead.org>
Message-ID: <20180416135521.ipvwptbom36wrtlf@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:46AM -0400, James Simmons wrote:
> From: Amir Shehata <amir.shehata@intel.com>
> 
> Replace depricated MAX_NUMNODES with nr_node_ids.
> 

The changelog makes it sound like this is just a style change, but it's
actually a behavior change isn't it?

regards,
dan carpenter
