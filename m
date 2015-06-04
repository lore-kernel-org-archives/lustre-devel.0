From: Ned Bass <bass6@llnl.gov>
Date: Thu, 4 Jun 2015 10:37:26 -0700
Subject: [lustre-devel] Lustre and libreadline
In-Reply-To: <D1959036.F52DC%andreas.dilger@intel.com>
References: <556F4825.1050408@cray.com> <20150603185716.GA10033@llnl.gov>
	<556F6341.3070507@cray.com>
	<116ba3cddacd422ca0f9b597c691f5df@EXCHCS32.ornl.gov>
	<20150603224901.GB10033@llnl.gov>
	<D1959036.F52DC%andreas.dilger@intel.com>
Message-ID: <20150604173726.GC10033@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 04, 2015 at 11:21:09AM +0000, Dilger, Andreas wrote:
> This is handled by having a "command" named "--net" that runs the next
> command (e.g. "conn_list") so that it can be run from the command-line.
> That can definitely be replaced by getopt.  I don't think interactive mode
> is used very much anymore, so would probably be ok to remove from lctl.

Cool, thanks. The --net option isn't covered in the lctl man page, but
it is in the online help. We'll need to close all those documentation
gaps when we gut interactive mode.

Ned
