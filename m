From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 11 Apr 2016 21:03:06 -0700
Subject: [lustre-devel] [PATCH 00/24] staging: lustre: selftest: remove
	typedefs
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160412040306.GA28361@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Apr 06, 2016 at 03:25:26PM -0400, James Simmons wrote:
> The lnet selftest code is littered with typedefs. Convert these
> typedefs into their proper data types.

Not all of these applied, please fix up and resend the remaining ones.

thanks,

greg k-h
