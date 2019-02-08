From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 05:57:24 +0000
Subject: [lustre-devel] [PATCH 16/21] lustre: obdclass: normalize a
 switch statement.
In-Reply-To: <154949781331.10620.12767117536447190491.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781331.10620.12767117536447190491.stgit@noble.brown>
Message-ID: <AF29B8B4-CDE2-470F-83F9-321A41EDF80B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> Remove the unnecessary {}, and use "break" rather than
> "goto out;" for normal exit from the cases.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
