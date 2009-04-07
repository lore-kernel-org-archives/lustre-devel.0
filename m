From: Andreas Dilger <adilger@sun.com>
Date: Tue, 07 Apr 2009 00:54:03 -0700
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike
	Booth	week ending 2009.03.15
In-Reply-To: <49DA7E4E.2080401@sun.com>
References: <52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
	<5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
	<20090331185111.GL3199@webber.adilger.int> <49D2E0FC.4040605@sun.com>
	<9BDC2632-E80E-4BA8-9ACF-8D7E70A9B236@Sun.COM>
	<20090402224310.GM3199@webber.adilger.int> <49DA7E4E.2080401@sun.com>
Message-ID: <20090407075403.GO3204@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 06, 2009  18:12 -0400, di wang wrote:
> I am not sure the current IO is "async" enough, since it still includes  
> some sync "process", for example, locks, read for partial page, some
> other stack overhead in commit_write, sometimes you can not ignore
> these overhead. For example, even without hit the dirty max limit, you  
> might get quite different write time for writing same data. I guess
> some of the reason might be the VM is just "out of control".
>
> With AIO,
>
> 1) The application  can  skip  these "sync" process?  For example by  
> creating an daemon to do the those routine  process.
> 2) We can control the write_page(sent to OST) ourselves, instead of rely  
> on VM.
> 3) These aio pages do not need comply the dirty max limit in the  
> submit_io(AIO) process, So user application do "real" memory for writing.
>
> Yes, AIO will be indeed complex for the application, but not that much,  

There was just a discussion about Linux AIO today (from former Linux AIO
maintainer, as it is currently unmaintained) and his statements were that
AIO is not really async at all, as it will block for local filesystems
on any file allocation, or any buffered IO.  Only preallocated files and
O_DIRECT even have a chance at AIO, and even that will not always work.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
