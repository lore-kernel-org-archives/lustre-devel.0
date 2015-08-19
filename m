From: Chris Horn <hornc@cray.com>
Date: Wed, 19 Aug 2015 16:31:04 +0000
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
Message-ID: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A thread on HPDD-discuss made me think about this question. AFAICT, the o2iblnd driver code will not let you have more that concurrent_sends messages in flight at the same time(in fact, we LASSERT on this fact in kiblnd_check_sends). Thus peer_credits is effectively limited by concurrent_sends anyways. What?s the reasoning behind allowing peer_credits to be larger than concurrent_sends?

Chris Horn
