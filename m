From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Thu, 1 Jul 2010 11:13:41 -0600
Subject: [Lustre-devel] [Lustre-discuss] configuration error while
	building lustre , please help !
In-Reply-To: <AANLkTilCTq2Q011hC9_esdkMgHarLzx7Hc3Ypyu9jvNz@mail.gmail.com>
References: <AANLkTilCTq2Q011hC9_esdkMgHarLzx7Hc3Ypyu9jvNz@mail.gmail.com>
Message-ID: <38816E5D-2B5D-4941-9CC4-09334998BB0F@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-07-01, at 05:58, Onkar Mahajan wrote:
> I am trying to compile lustre like this : 
> 
> [onkar at localhost build-lustre]$ ./configure --with-kernel-source-header=/home/onkar/LUSTRE/linux-2.6.33.3/include --with-linux=/home/onkar/LUSTRE/linux-2.6.33.3 --with-linux-obj=/home/onkar/LUSTRE/linux-2.6.33.3 --with-linux-config=/home/onkar/LUSTRE/linux-2.6.33.3

Lustre doesn't yet support 2.6.33.  Please use one of the supported vendor kernels (as listed at the top of lustre/ChangeLog).

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
