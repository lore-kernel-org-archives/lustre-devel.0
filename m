From: James Simmons <jsimmons@infradead.org>
Date: Wed, 7 Dec 2016 19:18:36 +0000 (GMT)
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: obdclass: Create a
 header for obdo related functions
In-Reply-To: <20161205220647.GD8244@mwanda>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-4-git-send-email-jsimmons@infradead.org>
	<20161205205005.GA31243@mwanda>
	<2394CAB0-41C1-4F3B-AF94-03D302F6ABF5@intel.com>
	<20161205220647.GD8244@mwanda>
Message-ID: <alpine.LFD.2.20.1612071917050.1427@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> Sorry, I was unclear.  I have no problem with white space changes on
> their own or when they are on the same line as something else you're
> changing.
> 
> What I meant is that when you're just moving functions around then don't
> mix unrelated white space changes into that patch.  I have automated
> scripts for reviewing moving code around but slight changes mean that I
> have to review it manually line by line to spot the difference.  I can
> review a one liner cleanup in about 10 seconds but it's finding the line
> which changed that's the problem in this case.
> 
> And I'm also fine with this patch since I already reviewed it, but in
> the future, please avoid the temptation to do cleanups until after.

Okay, I can do that. I was just trying to create checkpatch clean patches.
