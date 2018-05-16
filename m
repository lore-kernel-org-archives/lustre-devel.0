From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 19:34:45 +0200
Subject: [lustre-devel] [PATCH 14/14] mm: turn on vm_fault_t type
 checking
In-Reply-To: <20180516150829.GA4904@magnolia>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-15-hch@lst.de> <20180516150829.GA4904@magnolia>
Message-ID: <20180516173445.GA6088@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-btrfs@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, ocfs2-devel@oss.oracle.com, Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, Christoph Hellwig <hch@lst.de>, devel@lists.orangefs.org, lustre-devel@lists.lustre.org

On Wed, May 16, 2018 at 08:08:29AM -0700, Darrick J. Wong wrote:
> Uh, we're changing function signatures /and/ redefinining vm_fault_t?
> All in the same 90K patch?
> 
> I /was/ expecting a series of "convert XXXXX and all callers/users"
> patches followed by a trivial one to switch the definition, not a giant
> pile of change.  FWIW I don't mind so much if you make a patch
> containing a change for some super-common primitive and a hojillion
> little diff hunks tree-wide, but only one logical change at a time for a
> big patch, please...
> 
> I quite prefer seeing the whole series from start to finish all packaged
> up in one series, but wow this was overwhelming. :/

Another vote to split the change of the typedef, ok I get the message..
