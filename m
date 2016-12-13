From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 13 Dec 2016 11:31:04 +0300
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
 proper byteorder functions in lustre_idl.h
In-Reply-To: <20161213003728.GA3052@kroah.com>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
	<20161210181649.GB8477@kroah.com>
	<alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
	<20161213003728.GA3052@kroah.com>
Message-ID: <20161213083104.GD8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

It used to be that great swathes of Lustre were used in both user space
and kernel space.  We had huge unused modules in the kernel that were
only used for user space.

regards,
dan carpenter
