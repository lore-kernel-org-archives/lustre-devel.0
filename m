From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 10 Dec 2016 19:16:49 +0100
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
 proper byteorder functions in lustre_idl.h
In-Reply-To: <1481393161-22623-6-git-send-email-jsimmons@infradead.org>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20161210181649.GB8477@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Dec 10, 2016 at 01:06:01PM -0500, James Simmons wrote:
> In order for lustre_idl.h to be usable for both user
> land and kernel space it has to use the proper
> byteorder functions.

Why would userspace need/want all of these inline functions?  A uapi
header file should just have a the structures that are passed
user/kernel and any needed ioctls.  Why would they ever care about
strange byte flip functions and a ton of inline functions?

I don't think this is needed, of if it is, I really don't want to see
your crazy userspace code...

thanks,

greg k-h
