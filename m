From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Oct 2018 15:36:36 +1100
Subject: [lustre-devel] [PATCH 00/28] lustre: more assorted fixes for
 lustre 2.10
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <878t2q8unf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> Another bacth of assorted fixes missing in the linux client from
> lustre 2.10. All of these should be order independent and don't
> collide with the PFL work that will land at a later date.

Thanks, I've applied these and the other series.
And pushed it all out.
I ran a test and something went wrong - I haven't had a chance to look
properly yet....  I'm make sure tests mostly pass before moving it out
of lustre-testing.

Thanks a lot,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181022/41ed377f/attachment.sig>
