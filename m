From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 7 Dec 2016 22:22:37 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
 due to an assignment from kernel to user space
In-Reply-To: <46ee428d-016f-e532-9824-4ddbe8a0cc8b@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
	<306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
	<81821426-c32c-c45a-e9a3-82f9818fc986@gmail.com>
	<33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
	<20161207153317.GO8176@mwanda>
	<46ee428d-016f-e532-9824-4ddbe8a0cc8b@gmail.com>
Message-ID: <20161207192237.GP8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org

On Wed, Dec 07, 2016 at 04:42:30PM +0100, Quentin Lambert wrote:
> 
> 
> On 12/07/2016 04:33 PM, Dan Carpenter wrote:
> >Lustre is kind of a mess with regards to keeping user and kernel
> >pointers separate.  It's not going to be easy to fix.
> Fair enough.
> I am trying to make a contribution to drivers/staging using sparse.
> With that in mind, do you still fill I should keep clear of lustre?
> I feel that actually doing the work properly could be a meaningful
> learning experience.

It's just that you're the fifth person to look at lustre __user
annotations and it doesn't end well.  You need to be a lustre expert
who can test things.

But for other lustre things, feel free.

regards,
dan carpenter
