From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 05:45:26 +0000
Subject: [lustre-devel] [PATCH 13/21] lustre: make cp_ref in cl_page a
 refcount_t
In-Reply-To: <154949781321.10620.15836497514344103445.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781321.10620.15836497514344103445.stgit@noble.brown>
Message-ID: <E8AA934C-CF76-4E6A-A780-9A245C7379B2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> As this is used as a refcount, it should be declared
> as one.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
