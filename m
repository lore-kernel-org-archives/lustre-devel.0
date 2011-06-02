From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 2 Jun 2011 14:19:14 +0100
Subject: [Lustre-devel] discontiguous kiov pages
In-Reply-To: <4DE6F67B.6040207@cray.com>
References: <4DE6F67B.6040207@cray.com>
Message-ID: <002c01cc2127$ac5b7da0$051278e0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Wang,

Inline...

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf
> Of wang
> Sent: 02 June 2011 3:34 AM
> To: lustre-devel at lists.lustre.org
> Subject: [Lustre-devel] discontiguous kiov pages
> 
> Our gnilnd is running into a hole in kiov list in Lustre 2.1:
> 
> LustreError: 17837:0:(gnilnd_cb.c:594:kgnilnd_setup_phys_buffer()) Can't make payload
> contiguous in I/O VM:page 17, offset 0, nob 6350, kiov_offset 0 kiov_len 2254
> LustreError: 17837:0:(gnilnd_cb.c:1751:kgnilnd_send()) unable to setup buffer: -22
> 
> Is it now legal for an internal IOV (or KIOV) page to have less than a full page size ?
> 
> It used to be that only the first and last page in an IOV were allowed
> to be of a offset + length < PAGE_SIZE.

Quite correct.  LNDs have relied on this for years now.
A change like this should not have occurred without discussion
about the wider impact.

> It doesn't have this problem with 1.8 client and 2.1 server.
> 
> Wally
> 
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
