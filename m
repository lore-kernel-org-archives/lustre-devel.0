From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 00:44:48 +0000
Subject: [lustre-devel] [PATCH 06/21] lustre: use list_first_entry() in
 lnet/lnet subdirectory.
In-Reply-To: <154949781293.10620.13774044385661376106.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781293.10620.13774044385661376106.stgit@noble.brown>
Message-ID: <4B487DA9-C27B-4A03-A21D-27F00C81858E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> Convert
>  list_entry(foo->next .....)
> to
>  list_first_entry(foo, ....)
> 
> in 'lnet/lnet'
> 
> In several cases the call is combined with
> a list_empty() test and list_first_entry_or_null() is used
> 
> In one case, list_splice_init() is used.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
