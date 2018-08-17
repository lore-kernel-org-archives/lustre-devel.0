From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 15:56:08 +1000
Subject: [lustre-devel] [PATCH 06/38] lustre: llite: rename
 llite_sb_release
In-Reply-To: <1534475441-15543-7-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-7-git-send-email-jsimmons@infradead.org>
Message-ID: <874lftsfif.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> Since we are freeing a kobject rename llite_sb_release() to
> llite_kobj_release().

Thank you!  You told me *why*.  Easy to review!
:-)

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/4d812b77/attachment.sig>
