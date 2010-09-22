From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Wed, 22 Sep 2010 18:20:01 +0200
Subject: [Lustre-devel] Meaning of LND/neterrors ?
Message-ID: <4C9A2CB1.9030701@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I've noticed that Lustre network error, especially LND errors, are considered as maskable errors.
That means that on a production node, where debug mask is 0, those specific errors won't be displayed if they happened.

Does that mean that they are harmless?
Do upper-layers resend their RPC/packet if LNDs report an error?

When, in my case, o2iblnd says something like "RDMA failed" (neterror). It is a big issue? Some RPC were lost or not?

Thanks in advance

-- 
Aurelien Degremont
