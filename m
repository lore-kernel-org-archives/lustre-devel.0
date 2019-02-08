From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 07:07:07 +0000
Subject: [lustre-devel] [PATCH 21/21] lustre: make exp_refcount in
 obd_export a refcount_t
In-Reply-To: <154949781349.10620.3269248433038576631.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781349.10620.3269248433038576631.stgit@noble.brown>
Message-ID: <4AB76021-DEB7-4081-ADF4-58E8F3101803@whamcloud.com>
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
