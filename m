From: David Howells <dhowells@redhat.com>
Date: Mon, 21 Sep 2015 14:42:25 +0100
Subject: [lustre-devel] [PATCH 00/38] Fixes related to incorrect usage
	of unsigned types
In-Reply-To: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Message-ID: <17571.1442842945@warthog.procyon.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andrzej Hajda <a.hajda@samsung.com> wrote:

> Semantic patch finds comparisons of types:
>     unsigned < 0
>     unsigned >= 0
> The former is always false, the latter is always true.
> Such comparisons are useless, so theoretically they could be
> safely removed, but their presence quite often indicates bugs.

Or someone has left them in because they don't matter and there's the
possibility that the type being tested might be or become signed under some
circumstances.  If the comparison is useless, I'd expect the compiler to just
discard it - for such cases your patch is pointless.

If I have, for example:

	unsigned x;

	if (x == 0 || x > 27)
		give_a_range_error();

I will write this as:

	unsigned x;

	if (x <= 0 || x > 27)
		give_a_range_error();

because it that gives a way to handle x being changed to signed at some point
in the future for no cost.  In which case, your changing the <= to an ==
"because the < part of the case is useless" is arguably wrong.

David
