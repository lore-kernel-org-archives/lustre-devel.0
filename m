From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 06:02:30 +0000
Subject: [lustre-devel] [PATCH 18/21] lustre: move debug.c from obdclass
 to obdecho
In-Reply-To: <154949781337.10620.11481546344215316629.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781337.10620.11481546344215316629.stgit@noble.brown>
Message-ID: <9603E88A-ECFC-4D98-90D7-2E90E59DD93D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> The functions defined in debug.c are only used in
> obdecho, so move it there, and make the functions local
> to that unit.
> This allows lustre_debug.h to be removed.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
