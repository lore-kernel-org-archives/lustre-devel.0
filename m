From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 22 Aug 2016 06:04:08 -0400
Subject: [lustre-devel] [PATCH] staging/lustre: avoid zero buf for the
	first time
In-Reply-To: <1471855564-15962-1-git-send-email-shawn.lin@rock-chips.com>
References: <1471855564-15962-1-git-send-email-shawn.lin@rock-chips.com>
Message-ID: <20160822100408.GA11890@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shawn Lin <shawn.lin@rock-chips.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Aug 22, 2016 at 04:46:04PM +0800, Shawn Lin wrote:
> We only need to zero it when repeating in order to
> avoid old garbage. Let's improve it by moving this
> before we repeat the calculation to save some cpu
> cycle.
> 
> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>

Have you noticed a change with this in a benchmark?

If not, is it really worth it?

I need an ack from the lustre developers before taking patches like
this...

thanks,

greg k-h
