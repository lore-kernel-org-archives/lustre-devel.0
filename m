From: Quentin Lambert <lambert.quentin@gmail.com>
Date: Tue, 6 Dec 2016 14:48:15 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
 due to an assignment from kernel to user space
In-Reply-To: <306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
	<306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
Message-ID: <81821426-c32c-c45a-e9a3-82f9818fc986@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org



On 12/05/2016 11:58 PM, Oleg Drokin wrote:
> I guess it's a false positive?
Yes, probably.

Thank you for the explanation though, I don't fully understand all this yet,
I am still learning.

Sorry for the noise.

Quentin
