From: Eric Barton <eeb@whamcloud.com>
Date: Tue, 11 Oct 2011 14:20:44 +0100
Subject: [Lustre-devel] IPv6 NIDs
Message-ID: <06e901cc8818$95acbc60$c1063520$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'd like to canvass thoughts on how big an IPv6 compatible NID
might be.  We'd like to start anticipating changing to these NIDs
so that current development at least doesn't dig us deeper into a
hole (e.g. on the nidtable entries sent over the wire in
imperative recovery).  So here are some suggestions....

Current NID: 32 bit address-within LNET + 32 bit LNET number
64 bits / 8 bytes total

IPv6 compatible NID:

1. Minimum: 128 bit address-within-LNET + 32 bit LNET number.
   160 bits / 20 bytes total.

2. Hedge a little by reserving an additional (say) 32 bits for
   something we've not thought of yet and keeping the total a
   multiple of 64 bits to simplify alignment.
   192 bits / 24 bytes total.

3. Hedge a lot with a nice round number.
   256 bits / 32 bytes total.

(2) gets my vote currently...

          Cheers,
                   Eric

Eric Barton
CTO Whamcloud, Inc.
Tel: +44 (117) 330 1575
Mob: +44 (7920) 797 273
