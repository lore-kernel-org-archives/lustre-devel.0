From: gregkh at linuxfoundation.org <gregkh@linuxfoundation.org>
Date: Mon, 17 Oct 2016 10:31:15 +0200
Subject: [lustre-devel]
 linux-4.9-rc1/drivers/staging/lustre/lustre/osc/osc_request.c:973: always
 false test ?
In-Reply-To: <VI1PR08MB1022232C214C9435587602379CD00@VI1PR08MB1022.eurprd08.prod.outlook.com>
References: <VI1PR08MB1022232C214C9435587602379CD00@VI1PR08MB1022.eurprd08.prod.outlook.com>
Message-ID: <20161017083115.GA28881@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Binderman <dcb314@hotmail.com>
Cc: "oleg.drokin@intel.com" <oleg.drokin@intel.com>, "andreas.dilger@intel.com" <andreas.dilger@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Oct 17, 2016 at 07:33:33AM +0000, David Binderman wrote:
> Hello there,
> 
> 
> 
> linux-4.9-rc1/drivers/staging/lustre/lustre/osc/osc_request.c:973]: (style) Checking if unsigned variable 'cli.cl_avail_grant' is less than zero.
> 
> 
> 
> Source code is
> 
> 
> 
> ?? if (cli->cl_avail_grant < 0) {
> 
> 
> 
> Suggest code rework.

Great!  Please send a patch.

thanks,

greg k-h
