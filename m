From: Eric Barton <eeb@sun.com>
Date: Wed, 26 Nov 2008 15:59:24 +0000
Subject: [Lustre-devel] sparse files
Message-ID: <004701c94fdf$f4255b40$dc7011c0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Question for the HSM team.

Do we need to make the allocation map of a lustre file available
to the HSM agent so it can avoid copying all the holes in sparse
files?

    Cheers,
              Eric
