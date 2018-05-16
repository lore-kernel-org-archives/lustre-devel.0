From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 16 May 2018 04:28:13 -0700
Subject: [lustre-devel] [PATCH 14/14] mm: turn on vm_fault_t type
 checking
In-Reply-To: <20180516054348.15950-15-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-15-hch@lst.de>
Message-ID: <20180516112813.GC20670@bombadil.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:48AM +0200, Christoph Hellwig wrote:
> Switch vm_fault_t to point to an unsigned int with __b?twise annotations.
> This both catches any old ->fault or ->page_mkwrite instance with plain
> compiler type checking, as well as finding more intricate problems with
> sparse.

Come on, Christoph; you know better than this.  This patch is completely
unreviewable.  Split it into one patch per maintainer tree, and in any
event, the patch to convert vm_fault_t to an unsigned int should be
separated from all the trivial conversions.
