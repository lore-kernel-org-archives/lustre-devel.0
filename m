From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 7 Dec 2016 18:33:17 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
 due to an assignment from kernel to user space
In-Reply-To: <33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
	<306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
	<81821426-c32c-c45a-e9a3-82f9818fc986@gmail.com>
	<33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
Message-ID: <20161207153317.GO8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

Lustre is kind of a mess with regards to keeping user and kernel
pointers separate.  It's not going to be easy to fix.

regards,
dan carpenter
