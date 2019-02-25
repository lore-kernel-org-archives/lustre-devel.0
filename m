From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:20 +0000
Subject: [lustre-devel] [PATCH 24/37] lustre: lu_object: remove extra
 newline from debug printing.
In-Reply-To: <155053494611.24125.2469014113532688461.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494611.24125.2469014113532688461.stgit@noble.brown>
Message-ID: <267E03EA-23B6-4555-B09E-8E71630FEF6C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> In lu_cdebug_printer(), is "complete" is true, then
> key->lck_area ends with a newline, so there is no need to
> include on in the format too.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
