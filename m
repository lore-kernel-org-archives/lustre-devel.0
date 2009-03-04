From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 04 Mar 2009 12:19:53 -0500
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <20090302204501.GQ3199@webber.adilger.int>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
	<20090302204501.GQ3199@webber.adilger.int>
Message-ID: <5BC7F78A-7FD4-4F54-A1C9-F7A632EA7200@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 2, 2009, at 3:45 PM, Andreas Dilger wrote:

> On Mar 02, 2009  20:04 +0300, Vitaly Fertman wrote:
>>   RAM: enough to have a tmpfs for MDS;
> Note that strictly speaking we need to use ldiskfs on a ramdisk, not
> tmpfs, because we don't have an fsfilt_tmpfs.

The idea was loop device on tmpfs, I think.

Bye,
     Oleg
