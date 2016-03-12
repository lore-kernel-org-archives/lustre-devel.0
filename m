From: Joe Perches <joe@perches.com>
Date: Sat, 12 Mar 2016 10:23:25 -0800
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: Correct missing
 newline for CERROR call in sfw_handle_server_rpc
In-Reply-To: <1457805636-23859-2-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
	<1457805636-23859-2-git-send-email-jsimmons@infradead.org>
Message-ID: <1457807005.11972.9.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Nunez <james.a.nunez@intel.com>

On Sat, 2016-03-12 at 13:00 -0500, James Simmons wrote:
> From: James Nunez <james.a.nunez@intel.com>
> 
> This is one of the fixes broken out of patch 10000 that was
> missed in the merger. With this fix the CERROR called in
> sfw_handle_server_rpc will print out correctly.

Speaking of CERROR and logging, it it really useful
for each CERROR use to have 2 static structs?

In CERROR -> CDEBUG_LIMIT there is a:
	static struct cfs_debug_limit_state cdls;
	(12 or 16 bytes depending on 32/64 bit arch)

and in CDEBUG_LIMIT -> _CDEBUG
	static struct libcfs_debug_msg_data msgdata;
	(24 or 36 bytes depending on 32/64 bit arch)

That seems a largish bit of data and code to initialize
these structs for over a thousand call sites.

Wouldn't a single static suffice?
