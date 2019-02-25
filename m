From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:17 +0000
Subject: [lustre-devel] [PATCH 14/37] lustre: llog: change lgh_refcount
 to struct kref.
In-Reply-To: <155053494558.24125.11270061933248014691.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494558.24125.11270061933248014691.stgit@noble.brown>
Message-ID: <8D48D671-98EF-4137-AB0B-1239A979D5DB@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> This is a refcount that perfectly fits the
> pattern for kref, so change it to a kref.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
