From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 17 Aug 2017 09:22:39 -0700
Subject: [lustre-devel] [PATCH 00/64] staging: lustre: uapi: normalize
	the lustre headers
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20170817162239.GA22674@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Aug 14, 2017 at 11:46:28AM -0400, James Simmons wrote:
> The headers for lustre/LNet for a long time lacked a clean separation in
> its internal headers which resulted in kernel specific data structures
> being exposed in user land code. This work unravels this mess and creates
> a clear separation between lustre kernel space and lustre user land.
> With this work done the include paths in the lustre kernel code can now
> be normalized.

Nice work, all now applied.

greg k-h
