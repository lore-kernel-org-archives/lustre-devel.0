From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 5 Mar 2016 11:52:56 -0800
Subject: [lustre-devel] [PATCH 00/10] Last batch of fixes for LNet
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160305195256.GA8126@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Mar 04, 2016 at 09:09:40PM -0500, James Simmons wrote:
> This batch merges the remaining LNet patches from the OpenSFS
> branch for the upstream client. Once merged the LNet code
> will be up to date with the latest production code. Only style
> issues are remaining. Still future patches being developed
> for LNet will be landed to the upstream client as soon as they
> are ready after extensive testing.

Please fix up the build issue, and figure out what went wrong with the
__user patch that you sent and resend this series after reworking them.

thanks,

greg k-h
