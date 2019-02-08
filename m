From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 01:07:03 +0000
Subject: [lustre-devel] [PATCH 09/21] lustre: use list_last_entry()
 throughout
In-Reply-To: <154949781307.10620.3918792136275031845.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781307.10620.3918792136275031845.stgit@noble.brown>
Message-ID: <202E06D9-38C1-436A-A761-59B6301DD68E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> Convert
>  list_entry(foo->prev .....)
> to
>  list_last_entry(foo, ....)
> 
> throughout lustre.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
