From: NeilBrown <neilb@suse.com>
Date: Mon, 07 Jan 2019 16:17:33 +1100
Subject: [lustre-devel] [PATCH 00/14] lustre: fixes for many test
 failures
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87ftu5jbbm.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jan 06 2019, James Simmons wrote:

> This patch series contains mostly fixes to resolve the majority of
> the testing failures seen. Besides that are UAPI headers fixes to
> prepare for when lustre will leave the staging tree. Include Neil's
> dump_page_cache patch as well since it was landed in the OpenSFS
> branch and the migration of lu_objects to rhashtables depended on
> it.

Thanks - I've applied these.
I haven't received all of the PFL series yet ... 16,17,18 still in limbo
- so I haven't applied those yet.
When the stragglers here here, I suspect they'll all go in.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190107/694eb512/attachment.sig>
