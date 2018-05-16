From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 16 May 2018 04:23:47 -0700
Subject: [lustre-devel] vm_fault_t conversion, for real
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516112347.GB20670@bombadil.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:34AM +0200, Christoph Hellwig wrote:
> this series tries to actually turn vm_fault_t into a type that can be
> typechecked and checks the fallout instead of sprinkling random
> annotations without context.

Yes, why should we have small tasks that newcomers can do when the mighty
Christoph Hellwig can swoop in and take over from them?  Seriously,
can't your talents find a better use than this?

> The first one fixes a real bug in orangefs, the second and third fix
> mismatched existing vm_fault_t annotations on the same function, the
> fourth removes an unused export that was in the chain.  The remainder
> until the last one do some not quite trivial conversions, and the last
> one does the trivial mass annotation and flips vm_fault_t to a __bitwise
> unsigned int - the unsigned means we also get plain compiler type
> checking for the new ->fault signature even without sparse.

Yes, that was (part of) the eventual goal.  Well done.  Would you like
a biscuit?
