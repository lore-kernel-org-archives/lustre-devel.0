From: wang <wang@cray.com>
Date: Wed, 1 Jun 2011 19:33:31 -0700
Subject: [Lustre-devel] discontiguous kiov pages
Message-ID: <4DE6F67B.6040207@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Our gnilnd is running into a hole in kiov list in Lustre 2.1:

LustreError: 17837:0:(gnilnd_cb.c:594:kgnilnd_setup_phys_buffer()) Can't make payload
contiguous in I/O VM:page 17, offset 0, nob 6350, kiov_offset 0 kiov_len 2254
LustreError: 17837:0:(gnilnd_cb.c:1751:kgnilnd_send()) unable to setup buffer: -22

Is it now legal for an internal IOV (or KIOV) page to have less than a full page size ?

It used to be that only the first and last page in an IOV were allowed 
to be of a offset + length < PAGE_SIZE.

It doesn't have this problem with 1.8 client and 2.1 server.

Wally
