From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 12 Feb 2017 13:13:01 +0100
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: llite: root inode
 checking for migration
In-Reply-To: <1486833159-16251-3-git-send-email-jsimmons@infradead.org>
References: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
	<1486833159-16251-3-git-send-email-jsimmons@infradead.org>
Message-ID: <20170212121301.GA12048@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Feb 11, 2017 at 12:12:38PM -0500, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> Do not migrate root inode.

That says _what_ happens here, but you aren't giving any hint as to
_why_ this is needed.

I'll take this, but be more careful about your changelog comments in the
future...

thanks,

greg k-h
