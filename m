From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 06:41:14 +0000
Subject: [lustre-devel] [PATCH 19/21] lustre: obdclass: avoid races in
 class_register_type()
In-Reply-To: <154949781342.10620.11880180011933935219.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781342.10620.11880180011933935219.stgit@noble.brown>
Message-ID: <36A43FA1-9CD0-4A9A-BDA4-A184F04B54BE@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> If there are two parallel attempts to register the
> same class name, it could get registered twice.
> So re-check after allocation to make sure the name is
> still unique.

The patch itself seems reasonable, but I don't see how this
scenario could ever happen?  class_register_type() is only
called once per device type from the module init code, and
I don't think it is possible to insert the same module twice?

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
