From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 20 Oct 2010 11:30:24 -0600
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <20101020171348.GU1635@oracle.com>
References: <D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<90E83093-2655-4C70-ACEA-E75D7E8C5511@oracle.com>
	<4CBF1D00.9080402@psc.edu>
	<269E1A0D-2117-4ADC-BCDE-67A60EA9B974@oracle.com>
	<20101020171348.GU1635@oracle.com>
Message-ID: <94C30482-7C88-4E67-89AE-CB9B43DF57FB@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-20, at 11:13, Nicolas Williams wrote:
> Well, if we're going to add openg() (or whatever its name), we might as
> well add variants of stat() that don't require getting the size when the
> app doesn't need it

That is "stat_lite" (or various different names), and was also under discussion for adding to the Linux kernel, until it turned from being a sensible API to a Linux-designed-by-committee API from hell (IMHO, of course) and has stopped dead in its tracks.

> Another possibility is to say that a handle is only good as long as the
> original file descriptor remains open (recovery issues here), and that
> client can tell the MDS that it will be sharing its handle with other
> clients.

That is partly what the MDS open lock does.  It was intended for NFS servers to allow them to open and close a file locally for its clients w/o MDS RPCs.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
