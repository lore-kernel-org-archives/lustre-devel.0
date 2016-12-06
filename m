From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 6 Dec 2016 10:59:58 +0100
Subject: [lustre-devel] [PATCH 14/22] staging: lustre: obd: add callback
 for llog_cat_process_or_fork
In-Reply-To: <1480726409-20350-15-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
	<1480726409-20350-15-git-send-email-jsimmons@infradead.org>
Message-ID: <20161206095958.GA9387@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Boyko <alexander.boyko@seagate.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 07:53:21PM -0500, James Simmons wrote:
> From: Alexander Boyko <alexander.boyko@seagate.com>
> 
> Currently llog_process_or_fork() is hard coded to
> always pass the function pointer llog_cat_process_cb().
> Change llog_cat_process_or_fork() to pass in any
> function pointer which will allow us more options
> for llog_cat callback routines in the future.

Don't change this until you have an actual user for this.  Adding
infrastructure that is not used is not ok for a staging driver, or
really any kernel driver at all.

sorry,

greg k-h
