From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 07 Jan 2008 21:10:28 +0300
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <4782665E.1070406@sun.com>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com>
Message-ID: <47826B14.2050307@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan Rutman wrote:
> well, that's why I asked.  As I said, Andreas and I are in agreement, 
> and it certainly makes sense from a portability point of view, as well 
> as consistency with future features (snapshots, audit logs, etc.), and 
> the final elimination of our various /proc locking headaches.  But yes, 
> it would break user's scripts  - that's a 1-time thing, and I think not 
> too terrible.

it's not quite clear how do we do with userspace servers. there was an idea
to use named pipes, but I'm not sure it's very portable.

thanks, Alex
