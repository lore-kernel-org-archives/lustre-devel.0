From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 01:06:23 +0000
Subject: [lustre-devel] [PATCH 08/21] lustre: use list_first_entry()
 throughout
In-Reply-To: <154949781303.10620.10579175228046856433.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781303.10620.10579175228046856433.stgit@noble.brown>
Message-ID: <F406FC6F-D0E5-4EE4-BA59-B257E6C5CBC1@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> Convert
>  list_entry(foo->next .....)
> to
>  list_first_entry(foo, ....)
> 
> in remainder of lustre.
> 
> In several cases the call is combined with a list_empty() test and
> list_first_entry_or_null() is used
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
