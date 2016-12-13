From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 13 Dec 2016 11:14:26 -0500
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
	proper byteorder functions in lustre_idl.h
In-Reply-To: <20161213083104.GD8176@mwanda>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
	<20161210181649.GB8477@kroah.com>
	<alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
	<20161213003728.GA3052@kroah.com> <20161213083104.GD8176@mwanda>
Message-ID: <DA71F36C-81EA-48FB-89F1-1E3438129601@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Dec 13, 2016, at 3:31 AM, Dan Carpenter wrote:

> It used to be that great swathes of Lustre were used in both user space
> and kernel space.  We had huge unused modules in the kernel that were
> only used for user space.

Huh?
There was nothing of the sort.
There were huge parts of code that were used by the server, but sue to no server
in staging client, ended up being unused, though.

There were also (much smaller) bits that were supporting userspace client
(that is, a library that was able to mount lustre servers completely from
userspace by hijacking libc calls), but that was mostly gone by the time
we got into staging anyway.
