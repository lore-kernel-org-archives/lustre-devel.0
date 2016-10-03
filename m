From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 3 Oct 2016 00:31:04 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: ko2iblbd: handle
	ib_dereg_mr removal
In-Reply-To: <1475461351-21495-1-git-send-email-jsimmons@infradead.org>
References: <1475461351-21495-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161003073104.GA28412@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

Hell no.  If you had actually read the changelog you'd see that there
is a reason the functions went away, and simply calling the underlying
methods (which also will go away) will not fix it.

Please go back reading the changelogs, and while we're at it read some
basic introductions into the RDMA programming model.  As a little
shortcut: relying on any form of a global registration for the rkey
is inherently unsafe and only allowed as an option variant for
very trusted environments (thing single box appliances).  You'll need
to do a real memory registration here and not drag that old crap along.
