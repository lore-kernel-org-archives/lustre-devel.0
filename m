From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 23:50:05 +0300
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: obdclass: Create a
 header for obdo related functions
In-Reply-To: <1480707650-24089-4-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20161205205005.GA31243@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Ben Evans <bevans@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 02:40:47PM -0500, James Simmons wrote:
> -	__u32 local_flags = 0;
> +	u32 local_flags = 0;

> -	if (local_flags != 0) {
> +	if (local_flags) {

Please avoid these unrelated white space changes.

regards,
dan carpenter
