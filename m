From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 05:58:32 +0000
Subject: [lustre-devel] [PATCH 17/21] lustre: obdclass: result of
 try_module_get() should not be ignored.
In-Reply-To: <154949781334.10620.18347323437724979128.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781334.10620.18347323437724979128.stgit@noble.brown>
Message-ID: <858E7527-2583-4332-B8E2-550342482D20@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> If try_module_get() fails, the open must fail.
> 
> In practice this should be impossible, but it is
> best to make the code look right.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
