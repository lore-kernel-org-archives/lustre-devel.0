From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 17 Oct 2016 09:19:04 +0200
Subject: [lustre-devel] [PATCH] staging/lustre/llite: Move
 unstable_stats from sysfs to debugfs
In-Reply-To: <1476638210-208994-1-git-send-email-green@linuxhacker.ru>
References: <1476638210-208994-1-git-send-email-green@linuxhacker.ru>
Message-ID: <20161017071904.GA11990@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Oct 16, 2016 at 01:16:50PM -0400, Oleg Drokin wrote:
> It's multiple values per file, so it has no business being in sysfs,
> besides it was assuming seqfile anyway.
> 
> Introduced by
> commit d806f30e639b ("staging: lustre: osc: revise unstable pages accounting")

In the future, the "correct" format for saying something like this is:

Fixes: d806f30e639b ("staging: lustre: osc: revise unstable pages accounting")

thanks,

greg k-h
