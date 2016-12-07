From: James Simmons <jsimmons@infradead.org>
Date: Wed, 7 Dec 2016 19:13:17 +0000 (GMT)
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: obdclass: Create a
 header for obdo related functions
In-Reply-To: <20161206093635.GA11009@kroah.com>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-4-git-send-email-jsimmons@infradead.org>
	<20161206093635.GA11009@kroah.com>
Message-ID: <alpine.LFD.2.20.1612071912540.1427@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Ben Evans <bevans@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

> On Fri, Dec 02, 2016 at 02:40:47PM -0500, James Simmons wrote:
> > From: Ben Evans <bevans@cray.com>
> > 
> > Remove all obdo related functions from lustre_idl.h
> > Create lustre_odbo.h. Include where appropriate.
> > Make the functions lustre_get_wire_obdo and
> > lustre_set_wire_obdo to not be inlined functions.
> 
> Breaks the build, please test better.  I'm dropping this, and the rest
> of this series from my queue :(

Oops. Send a earlier verison of the patch by mistake.

> 
> greg k-h
> 
