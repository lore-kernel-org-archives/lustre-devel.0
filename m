From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 26 Nov 2016 01:12:41 +0300
Subject: [lustre-devel] [PATCH v2] staging: lustre: osc: Performance
	tune for LRU
In-Reply-To: <1479942105-30220-1-git-send-email-jsimmons@infradead.org>
References: <1479942105-30220-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161125221241.GN6266@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Nov 23, 2016 at 06:01:45PM -0500, James Simmons wrote:
> From: Jinshan Xiong <jinshan.xiong@intel.com>
> 
> Early launch page LRU work in osc_io_rw_iter_init();
> Change the page LRU shrinking policy by OSC attributes;
> Delete the contented lock osc_object::oo_seatbelt
> 

The cli_name() stuff should be in a separate patch.  It's hard to review
this stuff (or possibly I just found the first deal breaker and gave
up).

Anyway, please review this again and break it up into separate patches.

regards,
dan carpenter

PS:  I glanced at the patch again and the very first line is changing
"lru" to "LRU" in a comment.  We'll get a million performance increases
from that I bet.  Don't mix random white space changes into it...
