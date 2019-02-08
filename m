From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 05:43:36 +0000
Subject: [lustre-devel] [PATCH 12/21] lustre: cl_page.c: remove PINVRNT()
In-Reply-To: <154949781317.10620.17224594880512218856.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781317.10620.17224594880512218856.stgit@noble.brown>
Message-ID: <95F5F7CE-B5F6-4D4C-9860-E075D321B154@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> This macro does nothing (it once was like 'assert'),
> so remove it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
