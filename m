From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 13 Dec 2016 20:21:40 +0300
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
 proper byteorder functions in lustre_idl.h
In-Reply-To: <DA71F36C-81EA-48FB-89F1-1E3438129601@intel.com>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
	<20161210181649.GB8477@kroah.com>
	<alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
	<20161213003728.GA3052@kroah.com> <20161213083104.GD8176@mwanda>
	<DA71F36C-81EA-48FB-89F1-1E3438129601@intel.com>
Message-ID: <20161213172140.GG8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Dec 13, 2016 at 11:14:26AM -0500, Oleg Drokin wrote:
> 
> On Dec 13, 2016, at 3:31 AM, Dan Carpenter wrote:
> 
> > It used to be that great swathes of Lustre were used in both user space
> > and kernel space.  We had huge unused modules in the kernel that were
> > only used for user space.
> 
> Huh?
> There was nothing of the sort.
> There were huge parts of code that were used by the server, but sue to no server
> in staging client, ended up being unused, though.
> 

Oh.  Right,  that's it.

regards,
dan carpenter
