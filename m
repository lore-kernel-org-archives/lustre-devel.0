From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 05:46:16 +0000
Subject: [lustre-devel] [PATCH 14/21] lustre: make ccc_users in
 cl_client_cache a refcount_t
In-Reply-To: <154949781324.10620.6961645123977299300.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781324.10620.6961645123977299300.stgit@noble.brown>
Message-ID: <149B4014-1F4A-43A3-BA75-D6F363C0C15B@whamcloud.com>
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
