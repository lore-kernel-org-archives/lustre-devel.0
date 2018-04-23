From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 14:58:27 +0200
Subject: [lustre-devel] [PATCH 00/22] staging: lustre: llite: fix xattr
 handling
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20180423125827.GA32162@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:14:49AM -0400, James Simmons wrote:
> From: James Simmons <uja.ornl@yahoo.com>
> 
> Lustre utilities and user land APIs heavly depend on special xattr
> handling. Sadly much of the xattr handling for lustre client has
> been broken for awhile. This is all the fixes needed to make xattr
> handling work properly with the latest kernels.

Most of these now applied, please rebase and fix up the remaining ones
when resending.

thanks,

greg k-h
