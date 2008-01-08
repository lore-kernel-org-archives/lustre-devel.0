From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 08 Jan 2008 09:53:39 +0300
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <20080108064815.GC3351@webber.adilger.int>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com> <1199729436.23325.65.camel@pc.ilinx>
	<20080107200718.GT3351@webber.adilger.int>
	<69573950-6797-4203-8516-CB7B0FC3271E@sun.com>
	<20080108064815.GC3351@webber.adilger.int>
Message-ID: <47831DF3.2070107@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
>> What's the plan to prevent various backups software (and also tar & 
>> friends)
>> from backing up and restoring (esp. restoring of course) values in these
>> files?
> 
> The typical way is that .lustre would not appear in readdir/getdirents
> but could be accessed if explicitly named.

wouldn't it make sense to get rid of .lustre and use lctl then?
I guess we'll have to do this anyway if we want to use all our
testing infrastructure with userspace servers.

thanks, Alex
