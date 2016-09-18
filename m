From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 21:53:46 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: lmv: add missing
	function declaration
In-Reply-To: <2318806.4yLNEl44ta@wuerfel>
References: <1474198793-25108-1-git-send-email-baoyou.xie@linaro.org>
	<alpine.LFD.2.20.1609182035370.31599@casper.infradead.org>
	<2318806.4yLNEl44ta@wuerfel>
Message-ID: <alpine.LFD.2.20.1609182152220.31599@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Baoyou Xie <baoyou.xie@linaro.org>, oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, di.wang@intel.com, john.hammond@intel.com, fan.yong@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn


> On Sunday, September 18, 2016 8:43:18 PM CEST James Simmons wrote:
> > 
> > Nak. I'm not seeing this error with W=1. Also if you look
> > lmv_pack_md() is only used in lmv_obd.c and the function
> > appears early in the file before it is used, so no prototype
> > missing errors should happen. 
> 
> So it should be marked "static" and the EXPORT_SYMBOL() removed,
> right?

Already done. See patch

[PATCH 109/124] staging: lustre: misc: remove unnecessary EXPORT_SYMBOL

which is from Frank Zago which I just pushed to Greg.
