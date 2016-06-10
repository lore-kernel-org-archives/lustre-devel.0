From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 9 Jun 2016 18:28:52 -0700
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: lnet: optimize
 memory foot print for lnet_libmd
In-Reply-To: <1465512347-11650-4-git-send-email-jsimmons@infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
	<1465512347-11650-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20160610012852.GB6804@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Bruno Faccini <bruno.faccini@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 09, 2016 at 06:45:47PM -0400, James Simmons wrote:
> From: Bruno Faccini <bruno.faccini@intel.com>
> 
> The lnet_libmd struct fields have been re-ordered to optimize its
> memory foot-print.

This isn't a regression, so isn't ok for 4.7-rc releases, sorry.

greg k-h
