From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Thu, 4 Jun 2015 13:15:35 +0530
Subject: [lustre-devel] [PATCH v4 1/7] staging:lustre: move tcpip
	abstraction
In-Reply-To: <20150604073420.GA28762@mwanda>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-2-git-send-email-jsimmons@infradead.org>
	<20150604053554.GB6376@sudip-PC> <20150604073420.GA28762@mwanda>
Message-ID: <20150604074535.GA6781@sudip-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 04, 2015 at 10:34:20AM +0300, Dan Carpenter wrote:
> On Thu, Jun 04, 2015 at 11:05:54AM +0530, Sudip Mukherjee wrote:
> > On Wed, Jun 03, 2015 at 03:57:07PM -0400, James Simmons wrote:
> > > Rename libcfs/linux/linux-tcpip.c to lnet/lnet/lib-socket.c
> > looks like you have not just renamed the file, but there was also a change
> > in the #include which is not mentioned in the commit message.
> > 
> 
> That's obviously going to be part of moving the file.
yes. path changed for libcfs.h. so that was updated.
but there was also a new line
#include "../../include/linux/lnet/lib-lnet.h"

should that be part of moving the file also?

regards
sudip

> 
> 
